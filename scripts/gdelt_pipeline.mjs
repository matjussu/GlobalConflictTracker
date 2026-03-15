#!/usr/bin/env node
/**
 * GDELT → Firestore Pipeline
 *
 * Fetches conflict/military events from GDELT's free API (no key needed)
 * and pushes them to Firestore. The iOS app receives updates in real-time
 * via Firestore snapshot listeners.
 *
 * Usage:
 *   node gdelt_pipeline.mjs                     # One-time run
 *   node gdelt_pipeline.mjs --continuous         # Run every 15 min
 *
 * No API key required. GDELT is 100% free and open.
 */

import { readFileSync, existsSync } from 'fs';
import { homedir } from 'os';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { createHash } from 'crypto';

const __dirname = dirname(fileURLToPath(import.meta.url));

// ─── Firebase Auth (reuse Firebase CLI token) ───

const configPath = join(homedir(), '.config', 'configstore', 'firebase-tools.json');
const config = JSON.parse(readFileSync(configPath, 'utf8'));

async function getAccessToken() {
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: config.tokens.refresh_token,
      client_id: '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com',
      client_secret: 'j9iVZfS8kkCEFUPaAeJV0sAi',
    }),
  });
  const data = await res.json();
  if (!data.access_token) throw new Error('Failed to get access token');
  return data.access_token;
}

// ─── Firestore helpers ───

const PROJECT_ID = 'globalconflicttracker';
const BASE_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

function toFirestoreValue(value) {
  if (value === null || value === undefined) return { nullValue: null };
  if (typeof value === 'string') return { stringValue: value };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') {
    if (Number.isInteger(value)) return { integerValue: String(value) };
    return { doubleValue: value };
  }
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(toFirestoreValue) } };
  }
  if (typeof value === 'object') {
    const fields = {};
    for (const [k, v] of Object.entries(value)) {
      fields[k] = toFirestoreValue(v);
    }
    return { mapValue: { fields } };
  }
  return { stringValue: String(value) };
}

async function setDocument(token, collection, docId, data) {
  const fields = {};
  for (const [key, value] of Object.entries(data)) {
    fields[key] = toFirestoreValue(value);
  }

  const url = `${BASE_URL}/${collection}/${docId}`;
  const res = await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields }),
  });

  if (!res.ok) {
    const error = await res.text();
    throw new Error(`Firestore error ${collection}/${docId}: ${res.status} ${error}`);
  }
}

// ─── GDELT API ───

const GDELT_DOC_URL = 'https://api.gdeltproject.org/api/v2/doc/doc';

async function fetchGDELTArticles(query, maxRecords = 30) {
  const params = new URLSearchParams({
    query,
    mode: 'artlist',
    maxrecords: String(maxRecords),
    format: 'json',
    timespan: '1d',
    sourcelang: 'english',
  });

  const url = `${GDELT_DOC_URL}?${params}`;
  console.log(`  Fetching: ${query} (max ${maxRecords})...`);

  const res = await fetch(url);
  if (res.status === 429) {
    console.log('  Rate limited, waiting 10s...');
    await sleep(10000);
    return fetchGDELTArticles(query, maxRecords);
  }
  if (!res.ok) throw new Error(`GDELT API error: ${res.status}`);

  const data = await res.json();
  return data.articles || [];
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// ─── Transform GDELT → ConflictEvent ───

// Known conflict hotspot coordinates (fallback when GDELT doesn't provide coords)
const COUNTRY_COORDS = {
  'United States': { lat: 38.9, lon: -77.0 },
  'Ukraine': { lat: 48.4, lon: 35.0 },
  'Russia': { lat: 55.7, lon: 37.6 },
  'Israel': { lat: 31.8, lon: 35.2 },
  'Palestine': { lat: 31.9, lon: 35.2 },
  'Iran': { lat: 35.7, lon: 51.4 },
  'Syria': { lat: 33.5, lon: 36.3 },
  'Iraq': { lat: 33.3, lon: 44.4 },
  'Yemen': { lat: 15.4, lon: 44.2 },
  'China': { lat: 39.9, lon: 116.4 },
  'Taiwan': { lat: 25.0, lon: 121.5 },
  'North Korea': { lat: 39.0, lon: 125.7 },
  'South Korea': { lat: 37.6, lon: 127.0 },
  'India': { lat: 28.6, lon: 77.2 },
  'Pakistan': { lat: 33.7, lon: 73.0 },
  'Afghanistan': { lat: 34.5, lon: 69.2 },
  'Libya': { lat: 32.9, lon: 13.2 },
  'Sudan': { lat: 15.6, lon: 32.5 },
  'Somalia': { lat: 2.0, lon: 45.3 },
  'Nigeria': { lat: 9.1, lon: 7.5 },
  'Ethiopia': { lat: 9.0, lon: 38.7 },
  'Myanmar': { lat: 19.8, lon: 96.2 },
  'Mexico': { lat: 19.4, lon: -99.1 },
  'Lebanon': { lat: 33.9, lon: 35.5 },
  'United Kingdom': { lat: 51.5, lon: -0.1 },
  'France': { lat: 48.9, lon: 2.3 },
  'Germany': { lat: 52.5, lon: 13.4 },
  'Turkey': { lat: 39.9, lon: 32.9 },
  'Saudi Arabia': { lat: 24.7, lon: 46.7 },
  'Japan': { lat: 35.7, lon: 139.7 },
};

function generateId(article) {
  const hash = createHash('md5')
    .update(article.url || article.title)
    .digest('hex')
    .substring(0, 12);
  return `gdelt-${hash}`;
}

function parseGDELTDate(seendate) {
  // Format: "20260315T144500Z"
  if (!seendate) return new Date();
  const y = seendate.substring(0, 4);
  const m = seendate.substring(4, 6);
  const d = seendate.substring(6, 8);
  const h = seendate.substring(9, 11);
  const min = seendate.substring(11, 13);
  return new Date(`${y}-${m}-${d}T${h}:${min}:00Z`);
}

function mapSeverity(title) {
  const t = (title || '').toLowerCase();
  if (t.includes('kill') || t.includes('dead') || t.includes('attack') ||
      t.includes('bomb') || t.includes('strike') || t.includes('explos') ||
      t.includes('casualties') || t.includes('war ') || t.includes('invasion')) {
    return 'critical';
  }
  if (t.includes('threat') || t.includes('tension') || t.includes('deploy') ||
      t.includes('sanction') || t.includes('missile') || t.includes('nuclear') ||
      t.includes('warning') || t.includes('conflict')) {
    return 'warning';
  }
  return 'low';
}

function mapEventType(title) {
  const t = (title || '').toLowerCase();
  if (t.includes('naval') || t.includes('navy') || t.includes('ship') ||
      t.includes('fleet') || t.includes('maritime') || t.includes('sea')) {
    return 'naval';
  }
  if (t.includes('cyber') || t.includes('hack') || t.includes('digital') ||
      t.includes('electronic')) {
    return 'cyber';
  }
  if (t.includes('air') || t.includes('drone') || t.includes('aircraft') ||
      t.includes('flight') || t.includes('jet') || t.includes('missile') ||
      t.includes('airspace') || t.includes('bomb')) {
    return 'airspace';
  }
  if (t.includes('diplom') || t.includes('summit') || t.includes('talk') ||
      t.includes('treaty') || t.includes('sanction') || t.includes('negoti')) {
    return 'diplomatic';
  }
  return 'naval'; // default — ground military
}

function getCoords(country) {
  const match = COUNTRY_COORDS[country];
  if (match) {
    // Add slight randomization so markers don't stack
    return {
      lat: match.lat + (Math.random() - 0.5) * 2,
      lon: match.lon + (Math.random() - 0.5) * 2,
    };
  }
  // Random position in a conflict-relevant area
  return {
    lat: 20 + Math.random() * 40,
    lon: -10 + Math.random() * 80,
  };
}

function articleToConflictEvent(article) {
  const coords = getCoords(article.sourcecountry);
  return {
    id: generateId(article),
    title: article.title || 'Unknown Event',
    summary: `Source: ${article.domain} (${article.sourcecountry}). Full report: ${article.url}`,
    latitude: coords.lat,
    longitude: coords.lon,
    timestamp: parseGDELTDate(article.seendate),
    severity: mapSeverity(article.title),
    eventType: mapEventType(article.title),
    factionIDs: [],
    sourceReliability: { score: 6, label: 'GDELT Open Source' },
    tags: [
      article.sourcecountry?.toLowerCase() || 'unknown',
      mapEventType(article.title),
      'gdelt',
    ],
    imageURL: article.socialimage || null,
    isRead: false,
  };
}

function articleToIntelReport(article) {
  return {
    id: `intel-${generateId(article)}`,
    headline: (article.title || 'UNKNOWN REPORT').toUpperCase(),
    body: `Source: ${article.domain} (${article.sourcecountry}). ${article.url}`,
    timestamp: parseGDELTDate(article.seendate),
    sector: article.sourcecountry || 'Global',
    severity: mapSeverity(article.title),
    imageURL: article.socialimage || null,
    sourceReliability: { score: 6, label: 'GDELT Open Source' },
    relatedEventID: generateId(article),
    category: mapSeverity(article.title) === 'critical' ? 'highAlert' : 'chronological',
    isRead: false,
  };
}

// ─── Main Pipeline ───

async function runPipeline() {
  console.log('\n═══════════════════════════════════════════');
  console.log('  GDELT → Firestore Pipeline');
  console.log(`  ${new Date().toISOString()}`);
  console.log('═══════════════════════════════════════════\n');

  // Get Firebase token
  const token = await getAccessToken();
  console.log('✓ Firebase authenticated\n');

  // Fetch from multiple GDELT queries for broader coverage
  const queries = [
    'military conflict war',
    'airstrike bombing attack',
    'naval deployment fleet',
    'diplomatic sanctions summit',
    'cyber attack hack',
  ];

  let allArticles = [];

  for (let i = 0; i < queries.length; i++) {
    try {
      const articles = await fetchGDELTArticles(queries[i], 10);
      allArticles.push(...articles);
      console.log(`  → ${articles.length} articles for "${queries[i]}"`);
    } catch (e) {
      console.error(`  ✗ Failed: ${queries[i]} — ${e.message}`);
    }
    // Rate limit: wait 6s between requests
    if (i < queries.length - 1) await sleep(6000);
  }

  // Deduplicate by URL
  const seen = new Set();
  const uniqueArticles = allArticles.filter((a) => {
    if (seen.has(a.url)) return false;
    seen.add(a.url);
    return true;
  });

  console.log(`\n✓ ${uniqueArticles.length} unique articles after dedup\n`);

  // Transform to ConflictEvents + IntelReports
  const events = uniqueArticles.map(articleToConflictEvent);
  const reports = uniqueArticles.map(articleToIntelReport);

  // Push to Firestore
  console.log('--- Pushing events to Firestore ---');
  let eventCount = 0;
  for (const event of events) {
    try {
      await setDocument(token, 'events', event.id, event);
      eventCount++;
      process.stdout.write(`  + ${event.id} (${event.severity})\r`);
    } catch (e) {
      console.error(`  ✗ ${event.id}: ${e.message}`);
    }
  }
  console.log(`\n✓ ${eventCount} events pushed\n`);

  console.log('--- Pushing intel reports to Firestore ---');
  let reportCount = 0;
  for (const report of reports) {
    try {
      await setDocument(token, 'intelReports', report.id, report);
      reportCount++;
      process.stdout.write(`  + ${report.id}\r`);
    } catch (e) {
      console.error(`  ✗ ${report.id}: ${e.message}`);
    }
  }
  console.log(`\n✓ ${reportCount} intel reports pushed\n`);

  console.log('═══════════════════════════════════════════');
  console.log(`  DONE: ${eventCount} events + ${reportCount} reports`);
  console.log('  iOS app receives updates via Firestore listeners');
  console.log('═══════════════════════════════════════════\n');
}

// ─── Entry point ───

const args = process.argv.slice(2);
const continuous = args.includes('--continuous');

if (continuous) {
  console.log('Running in continuous mode (every 15 minutes)...');
  runPipeline();
  setInterval(runPipeline, 15 * 60 * 1000);
} else {
  runPipeline().catch((e) => {
    console.error('Pipeline failed:', e.message);
    process.exit(1);
  });
}

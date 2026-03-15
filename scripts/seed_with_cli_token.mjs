#!/usr/bin/env node
/**
 * Seed Firestore using the Firebase CLI's stored credentials.
 * No service account key needed — reuses your `firebase login` session.
 */

import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { readFileSync } from 'fs';
import { homedir } from 'os';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

// Get Google access token via Firebase CLI token
const configPath = join(homedir(), '.config', 'configstore', 'firebase-tools.json');
const config = JSON.parse(readFileSync(configPath, 'utf8'));
const refreshToken = config.tokens.refresh_token;

// Exchange refresh token for access token
const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: new URLSearchParams({
    grant_type: 'refresh_token',
    refresh_token: refreshToken,
    client_id: config.tokens.client_id || '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com',
    client_secret: config.tokens.client_secret || 'j9iVZfS8kkCEFUPaAeJV0sAi',
  }),
});
const tokenData = await tokenResponse.json();

if (!tokenData.access_token) {
  console.error('Failed to get access token:', tokenData);
  process.exit(1);
}

const PROJECT_ID = 'globalconflicttracker';
const BASE_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

async function setDocument(collection, docId, fields) {
  const firestoreFields = {};

  for (const [key, value] of Object.entries(fields)) {
    firestoreFields[key] = toFirestoreValue(value);
  }

  const url = `${BASE_URL}/${collection}/${docId}`;
  const response = await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${tokenData.access_token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields: firestoreFields }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to set ${collection}/${docId}: ${response.status} ${error}`);
  }
}

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

// --- SAMPLE DATA ---
const now = new Date();
const h = (hours) => new Date(now.getTime() - hours * 3600000);

const events = [
  { id: 'evt-001', title: 'Naval Deployment in Red Sea', summary: 'Multiple destroyer-class vessels detected entering sector 7-G. High probability of engagement.', latitude: 15.5, longitude: 42.0, timestamp: h(2), severity: 'critical', eventType: 'naval', factionIDs: ['fac-us', 'fac-uk'], sourceReliability: { score: 9, label: 'Confirmed' }, tags: ['naval', 'red-sea', 'deployment'], imageURL: null, isRead: false },
  { id: 'evt-002', title: 'Cyber Attack on Power Grid', summary: 'Sophisticated intrusion detected targeting eastern European power infrastructure.', latitude: 50.45, longitude: 30.52, timestamp: h(4), severity: 'warning', eventType: 'cyber', factionIDs: [], sourceReliability: { score: 7, label: 'Likely' }, tags: ['cyber', 'infrastructure', 'europe'], imageURL: null, isRead: false },
  { id: 'evt-003', title: 'Diplomatic Summit Cancelled', summary: 'Scheduled bilateral talks between regional powers suspended following border incident.', latitude: 35.68, longitude: 51.39, timestamp: h(8), severity: 'low', eventType: 'diplomatic', factionIDs: [], sourceReliability: { score: 9, label: 'Confirmed' }, tags: ['diplomatic', 'middle-east'], imageURL: null, isRead: false },
  { id: 'evt-004', title: 'Airspace Violation Detected', summary: 'Unidentified aircraft entered restricted airspace over contested territory. Interceptors scrambled.', latitude: 36.2, longitude: 37.1, timestamp: h(1), severity: 'critical', eventType: 'airspace', factionIDs: ['fac-fr'], sourceReliability: { score: 3, label: 'Unverified' }, tags: ['airspace', 'violation', 'intercept'], imageURL: null, isRead: false },
];

const factions = [
  { id: 'fac-us', name: 'United States Army', emblemURL: '', type: 'nation', personnelCount: 480000, fleetStrength: 340000, airAssets: 320000, status: 'activeDeployment', deploymentZones: ['Middle East', 'Pacific'], recentEventIDs: ['evt-001'], personnelTrend: 0.5, fleetTrend: -1.2, airTrend: 0.8 },
  { id: 'fac-uk', name: 'British Armed Forces', emblemURL: '', type: 'nation', personnelCount: 148500, fleetStrength: 75000, airAssets: 33000, status: 'standby', deploymentZones: ['North Atlantic'], recentEventIDs: ['evt-001'], personnelTrend: -0.3, fleetTrend: 0.1, airTrend: -0.5 },
  { id: 'fac-cn', name: "People's Liberation Army", emblemURL: '', type: 'nation', personnelCount: 2185000, fleetStrength: 350000, airAssets: 395000, status: 'borderOps', deploymentZones: ['South China Sea', 'Taiwan Strait'], recentEventIDs: [], personnelTrend: 1.2, fleetTrend: 2.1, airTrend: 1.8 },
  { id: 'fac-fr', name: 'French Armed Forces', emblemURL: '', type: 'nation', personnelCount: 203000, fleetStrength: 98000, airAssets: 40000, status: 'domesticSecurity', deploymentZones: ['Sahel', 'Mediterranean'], recentEventIDs: ['evt-004'], personnelTrend: -0.1, fleetTrend: 0.3, airTrend: 0.0 },
  { id: 'fac-jp', name: 'JSDF - Japan', emblemURL: '', type: 'nation', personnelCount: 247000, fleetStrength: 114000, airAssets: 47000, status: 'maritimePatrol', deploymentZones: ['East China Sea', 'Pacific'], recentEventIDs: [], personnelTrend: 0.2, fleetTrend: 0.7, airTrend: 0.4 },
  { id: 'fac-de', name: 'German Bundeswehr', emblemURL: '', type: 'nation', personnelCount: 183000, fleetStrength: 65000, airAssets: 28000, status: 'logisticsSupport', deploymentZones: ['Baltic', 'Eastern Europe'], recentEventIDs: [], personnelTrend: 0.9, fleetTrend: 1.5, airTrend: 1.1 },
];

const intelReports = [
  { id: 'intel-001', headline: 'SQUADRON MOVEMENT DETECTED NEAR SOUTHERN DMZ', body: 'Satellite reconnaissance confirms mobilization of heavy armor divisions along the southern demilitarized zone.', timestamp: h(2), sector: 'Sector 7', severity: 'critical', imageURL: null, sourceReliability: { score: 9, label: 'Confirmed' }, relatedEventID: 'evt-001', category: 'highAlert', isRead: false },
  { id: 'intel-002', headline: 'ENCRYPTED COMMS BURST FROM NAVAL TASK FORCE', body: 'Signal intelligence intercepted encrypted communications from a naval task force.', timestamp: h(3), sector: 'Signal Intercept', severity: 'warning', imageURL: null, sourceReliability: { score: 7, label: 'Likely' }, relatedEventID: null, category: 'chronological', isRead: false },
  { id: 'intel-003', headline: 'BORDER REINFORCEMENT OBSERVED VIA SATELLITE', body: 'Commercial satellite imagery reveals significant troop buildup along the northern border region.', timestamp: h(6), sector: 'GEOINT', severity: 'warning', imageURL: null, sourceReliability: { score: 9, label: 'Confirmed' }, relatedEventID: null, category: 'global', isRead: false },
  { id: 'intel-004', headline: 'DIPLOMATIC CABLE LEAKED: SANCTIONS INCOMING', body: 'A classified diplomatic cable indicating imminent sanctions against three nations.', timestamp: h(12), sector: 'HUMINT', severity: 'low', imageURL: null, sourceReliability: { score: 3, label: 'Unverified' }, relatedEventID: 'evt-003', category: 'chronological', isRead: false },
];

const regions = [
  { id: 'region-me', name: 'Middle East', centerLatitude: 29.0, centerLongitude: 47.0, zoomLevel: 5.0 },
  { id: 'region-ee', name: 'Eastern Europe', centerLatitude: 50.0, centerLongitude: 30.0, zoomLevel: 5.0 },
  { id: 'region-scs', name: 'South China Sea', centerLatitude: 14.0, centerLongitude: 114.0, zoomLevel: 5.0 },
  { id: 'region-ac', name: 'Arctic Circle', centerLatitude: 71.0, centerLongitude: 25.0, zoomLevel: 4.0 },
];

// --- SEED ---
async function seed() {
  const collections = { events, factions, intelReports, regions };
  let total = 0;

  for (const [name, docs] of Object.entries(collections)) {
    console.log(`\n--- Seeding ${name} (${docs.length} docs) ---`);
    for (const doc of docs) {
      await setDocument(name, doc.id, doc);
      console.log(`  + ${doc.id}`);
      total++;
    }
  }

  console.log(`\n✓ Seeding complete! ${total} documents pushed to Firestore.`);
}

seed().catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});

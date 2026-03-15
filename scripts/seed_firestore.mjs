#!/usr/bin/env node
/**
 * Seed Firestore with sample data using Firebase Admin SDK.
 * Uses the service account created via Firebase Console.
 *
 * Usage:
 *   npm install firebase-admin
 *   node seed_firestore.mjs
 */

import { initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { readFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Try service account key first, fallback to ADC
let app;
const keyPath = join(__dirname, 'serviceAccountKey.json');
if (existsSync(keyPath)) {
  const serviceAccount = JSON.parse(readFileSync(keyPath, 'utf8'));
  app = initializeApp({ credential: cert(serviceAccount) });
  console.log('Using service account key.');
} else {
  app = initializeApp({
    credential: applicationDefault(),
    projectId: 'globalconflicttracker',
  });
  console.log('Using Application Default Credentials.');
}

const db = getFirestore();
const now = new Date();

// --- SAMPLE DATA ---

const events = [
  {
    id: 'evt-001',
    title: 'Naval Deployment in Red Sea',
    summary: 'Multiple destroyer-class vessels detected entering sector 7-G. High probability of engagement.',
    latitude: 15.5, longitude: 42.0,
    timestamp: new Date(now - 2 * 3600000),
    severity: 'critical', eventType: 'naval',
    factionIDs: ['fac-us', 'fac-uk'],
    sourceReliability: { score: 9, label: 'Confirmed' },
    tags: ['naval', 'red-sea', 'deployment'],
    imageURL: null, isRead: false,
  },
  {
    id: 'evt-002',
    title: 'Cyber Attack on Power Grid',
    summary: 'Sophisticated intrusion detected targeting eastern European power infrastructure. Attribution pending.',
    latitude: 50.45, longitude: 30.52,
    timestamp: new Date(now - 4 * 3600000),
    severity: 'warning', eventType: 'cyber',
    factionIDs: [],
    sourceReliability: { score: 7, label: 'Likely' },
    tags: ['cyber', 'infrastructure', 'europe'],
    imageURL: null, isRead: false,
  },
  {
    id: 'evt-003',
    title: 'Diplomatic Summit Cancelled',
    summary: 'Scheduled bilateral talks between regional powers suspended following border incident.',
    latitude: 35.68, longitude: 51.39,
    timestamp: new Date(now - 8 * 3600000),
    severity: 'low', eventType: 'diplomatic',
    factionIDs: [],
    sourceReliability: { score: 9, label: 'Confirmed' },
    tags: ['diplomatic', 'middle-east'],
    imageURL: null, isRead: false,
  },
  {
    id: 'evt-004',
    title: 'Airspace Violation Detected',
    summary: 'Unidentified aircraft entered restricted airspace over contested territory. Interceptors scrambled.',
    latitude: 36.2, longitude: 37.1,
    timestamp: new Date(now - 1 * 3600000),
    severity: 'critical', eventType: 'airspace',
    factionIDs: ['fac-fr'],
    sourceReliability: { score: 3, label: 'Unverified' },
    tags: ['airspace', 'violation', 'intercept'],
    imageURL: null, isRead: false,
  },
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
  { id: 'intel-001', headline: 'SQUADRON MOVEMENT DETECTED NEAR SOUTHERN DMZ', body: 'Satellite reconnaissance confirms mobilization of heavy armor divisions along the southern demilitarized zone.', timestamp: new Date(now - 2 * 3600000), sector: 'Sector 7', severity: 'critical', imageURL: null, sourceReliability: { score: 9, label: 'Confirmed' }, relatedEventID: 'evt-001', category: 'highAlert', isRead: false },
  { id: 'intel-002', headline: 'ENCRYPTED COMMS BURST FROM NAVAL TASK FORCE', body: 'Signal intelligence intercepted a series of encrypted communications from a naval task force.', timestamp: new Date(now - 3 * 3600000), sector: 'Signal Intercept', severity: 'warning', imageURL: null, sourceReliability: { score: 7, label: 'Likely' }, relatedEventID: null, category: 'chronological', isRead: false },
  { id: 'intel-003', headline: 'BORDER REINFORCEMENT OBSERVED VIA SATELLITE', body: 'Commercial satellite imagery reveals significant troop buildup along the northern border region.', timestamp: new Date(now - 6 * 3600000), sector: 'GEOINT', severity: 'warning', imageURL: null, sourceReliability: { score: 9, label: 'Confirmed' }, relatedEventID: null, category: 'global', isRead: false },
  { id: 'intel-004', headline: 'DIPLOMATIC CABLE LEAKED: SANCTIONS INCOMING', body: 'A classified diplomatic cable has surfaced indicating imminent sanctions against three nations.', timestamp: new Date(now - 12 * 3600000), sector: 'HUMINT', severity: 'low', imageURL: null, sourceReliability: { score: 3, label: 'Unverified' }, relatedEventID: 'evt-003', category: 'chronological', isRead: false },
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

  for (const [name, docs] of Object.entries(collections)) {
    console.log(`\n--- Seeding ${name} (${docs.length} docs) ---`);
    for (const doc of docs) {
      await db.collection(name).doc(doc.id).set(doc);
      console.log(`  + ${doc.id}`);
    }
  }

  console.log('\n✓ Seeding complete! 18 documents pushed to Firestore.');
}

seed().catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});

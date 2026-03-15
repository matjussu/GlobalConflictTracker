#!/usr/bin/env python3
"""
Seed Firestore using Application Default Credentials (no service account key needed).
Works if you're logged in via `firebase login` or `gcloud auth`.

Usage:
    python seed_firestore_adc.py
"""

import sys
from datetime import datetime, timedelta, timezone

import firebase_admin
from firebase_admin import credentials, firestore


def get_sample_events():
    now = datetime.now(timezone.utc)
    return [
        {
            "id": "evt-001",
            "title": "Naval Deployment in Red Sea",
            "summary": "Multiple destroyer-class vessels detected entering sector 7-G. High probability of engagement.",
            "latitude": 15.5,
            "longitude": 42.0,
            "timestamp": now - timedelta(hours=2),
            "severity": "critical",
            "eventType": "naval",
            "factionIDs": ["fac-us", "fac-uk"],
            "sourceReliability": {"score": 9, "label": "Confirmed"},
            "tags": ["naval", "red-sea", "deployment"],
            "imageURL": None,
            "isRead": False,
        },
        {
            "id": "evt-002",
            "title": "Cyber Attack on Power Grid",
            "summary": "Sophisticated intrusion detected targeting eastern European power infrastructure. Attribution pending.",
            "latitude": 50.45,
            "longitude": 30.52,
            "timestamp": now - timedelta(hours=4),
            "severity": "warning",
            "eventType": "cyber",
            "factionIDs": [],
            "sourceReliability": {"score": 7, "label": "Likely"},
            "tags": ["cyber", "infrastructure", "europe"],
            "imageURL": None,
            "isRead": False,
        },
        {
            "id": "evt-003",
            "title": "Diplomatic Summit Cancelled",
            "summary": "Scheduled bilateral talks between regional powers suspended following border incident.",
            "latitude": 35.68,
            "longitude": 51.39,
            "timestamp": now - timedelta(hours=8),
            "severity": "low",
            "eventType": "diplomatic",
            "factionIDs": [],
            "sourceReliability": {"score": 9, "label": "Confirmed"},
            "tags": ["diplomatic", "middle-east"],
            "imageURL": None,
            "isRead": False,
        },
        {
            "id": "evt-004",
            "title": "Airspace Violation Detected",
            "summary": "Unidentified aircraft entered restricted airspace over contested territory. Interceptors scrambled.",
            "latitude": 36.2,
            "longitude": 37.1,
            "timestamp": now - timedelta(hours=1),
            "severity": "critical",
            "eventType": "airspace",
            "factionIDs": ["fac-fr"],
            "sourceReliability": {"score": 3, "label": "Unverified"},
            "tags": ["airspace", "violation", "intercept"],
            "imageURL": None,
            "isRead": False,
        },
    ]


def get_sample_factions():
    return [
        {"id": "fac-us", "name": "United States Army", "emblemURL": "", "type": "nation", "personnelCount": 480000, "fleetStrength": 340000, "airAssets": 320000, "status": "activeDeployment", "deploymentZones": ["Middle East", "Pacific"], "recentEventIDs": ["evt-001"], "personnelTrend": 0.5, "fleetTrend": -1.2, "airTrend": 0.8},
        {"id": "fac-uk", "name": "British Armed Forces", "emblemURL": "", "type": "nation", "personnelCount": 148500, "fleetStrength": 75000, "airAssets": 33000, "status": "standby", "deploymentZones": ["North Atlantic"], "recentEventIDs": ["evt-001"], "personnelTrend": -0.3, "fleetTrend": 0.1, "airTrend": -0.5},
        {"id": "fac-cn", "name": "People's Liberation Army", "emblemURL": "", "type": "nation", "personnelCount": 2185000, "fleetStrength": 350000, "airAssets": 395000, "status": "borderOps", "deploymentZones": ["South China Sea", "Taiwan Strait"], "recentEventIDs": [], "personnelTrend": 1.2, "fleetTrend": 2.1, "airTrend": 1.8},
        {"id": "fac-fr", "name": "French Armed Forces", "emblemURL": "", "type": "nation", "personnelCount": 203000, "fleetStrength": 98000, "airAssets": 40000, "status": "domesticSecurity", "deploymentZones": ["Sahel", "Mediterranean"], "recentEventIDs": ["evt-004"], "personnelTrend": -0.1, "fleetTrend": 0.3, "airTrend": 0.0},
        {"id": "fac-jp", "name": "JSDF - Japan", "emblemURL": "", "type": "nation", "personnelCount": 247000, "fleetStrength": 114000, "airAssets": 47000, "status": "maritimePatrol", "deploymentZones": ["East China Sea", "Pacific"], "recentEventIDs": [], "personnelTrend": 0.2, "fleetTrend": 0.7, "airTrend": 0.4},
        {"id": "fac-de", "name": "German Bundeswehr", "emblemURL": "", "type": "nation", "personnelCount": 183000, "fleetStrength": 65000, "airAssets": 28000, "status": "logisticsSupport", "deploymentZones": ["Baltic", "Eastern Europe"], "recentEventIDs": [], "personnelTrend": 0.9, "fleetTrend": 1.5, "airTrend": 1.1},
    ]


def get_sample_intel_reports():
    now = datetime.now(timezone.utc)
    return [
        {"id": "intel-001", "headline": "SQUADRON MOVEMENT DETECTED NEAR SOUTHERN DMZ", "body": "Satellite reconnaissance confirms mobilization of heavy armor divisions along the southern demilitarized zone.", "timestamp": now - timedelta(hours=2), "sector": "Sector 7", "severity": "critical", "imageURL": None, "sourceReliability": {"score": 9, "label": "Confirmed"}, "relatedEventID": "evt-001", "category": "highAlert", "isRead": False},
        {"id": "intel-002", "headline": "ENCRYPTED COMMS BURST FROM NAVAL TASK FORCE", "body": "Signal intelligence intercepted a series of encrypted communications from a naval task force.", "timestamp": now - timedelta(hours=3), "sector": "Signal Intercept", "severity": "warning", "imageURL": None, "sourceReliability": {"score": 7, "label": "Likely"}, "relatedEventID": None, "category": "chronological", "isRead": False},
        {"id": "intel-003", "headline": "BORDER REINFORCEMENT OBSERVED VIA SATELLITE", "body": "Commercial satellite imagery reveals significant troop buildup along the northern border region.", "timestamp": now - timedelta(hours=6), "sector": "GEOINT", "severity": "warning", "imageURL": None, "sourceReliability": {"score": 9, "label": "Confirmed"}, "relatedEventID": None, "category": "global", "isRead": False},
        {"id": "intel-004", "headline": "DIPLOMATIC CABLE LEAKED: SANCTIONS INCOMING", "body": "A classified diplomatic cable has surfaced indicating imminent sanctions against three nations.", "timestamp": now - timedelta(hours=12), "sector": "HUMINT", "severity": "low", "imageURL": None, "sourceReliability": {"score": 3, "label": "Unverified"}, "relatedEventID": "evt-003", "category": "chronological", "isRead": False},
    ]


def get_sample_regions():
    return [
        {"id": "region-me", "name": "Middle East", "centerLatitude": 29.0, "centerLongitude": 47.0, "zoomLevel": 5.0},
        {"id": "region-ee", "name": "Eastern Europe", "centerLatitude": 50.0, "centerLongitude": 30.0, "zoomLevel": 5.0},
        {"id": "region-scs", "name": "South China Sea", "centerLatitude": 14.0, "centerLongitude": 114.0, "zoomLevel": 5.0},
        {"id": "region-ac", "name": "Arctic Circle", "centerLatitude": 71.0, "centerLongitude": 25.0, "zoomLevel": 4.0},
    ]


def seed(db):
    collections = {
        "events": get_sample_events(),
        "factions": get_sample_factions(),
        "intelReports": get_sample_intel_reports(),
        "regions": get_sample_regions(),
    }

    for collection_name, documents in collections.items():
        print(f"\n--- Seeding {collection_name} ({len(documents)} docs) ---")
        for doc in documents:
            doc_id = doc["id"]
            db.collection(collection_name).document(doc_id).set(doc)
            print(f"  + {doc_id}")

    print("\n✓ Seeding complete! 18 documents pushed to Firestore.")


def main():
    try:
        # Use Application Default Credentials
        cred = credentials.ApplicationDefault()
        firebase_admin.initialize_app(cred, {"projectId": "globalconflicttracker"})
        db = firestore.client()
        seed(db)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        print("\nMake sure you're logged in:", file=sys.stderr)
        print("  gcloud auth application-default login", file=sys.stderr)
        print("  OR use: python seed_firestore.py --key serviceAccountKey.json", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
ACLED → Firestore Pipeline

Fetches conflict events from the ACLED API and pushes them to Firestore.
The iOS app receives updates in real-time via Firestore snapshot listeners.

Usage:
    # One-time run
    python acled_pipeline.py --key serviceAccountKey.json

    # Cron (every 30 min)
    */30 * * * * cd /path/to/scripts && .venv/bin/python acled_pipeline.py --key serviceAccountKey.json

Setup:
    1. Get an ACLED API key at https://acleddata.com/acleddatanew/wp-content/uploads/dlm_uploads/2019/01/ACLED_API-User-Guide_2020.pdf
    2. Set environment variables:
       export ACLED_EMAIL="your@email.com"
       export ACLED_KEY="your-api-key"
    3. Download Firebase service account key from Firebase Console
"""

import argparse
import hashlib
import os
import sys
from datetime import datetime, timezone

import requests

# Try Firebase Admin SDK
try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("Install firebase-admin: pip install firebase-admin requests")
    sys.exit(1)

ACLED_API_URL = "https://api.acleddata.com/acled/read"


def fetch_acled_events(email, key, limit=50, days_back=7):
    """Fetch recent conflict events from ACLED API."""
    params = {
        "key": key,
        "email": email,
        "limit": limit,
        "page": 1,
        # Filter: last N days
        "event_date": f"{datetime.now(timezone.utc).strftime('%Y-%m-%d')}|{(datetime.now(timezone.utc)).strftime('%Y-%m-%d')}",
        "event_date_where": "BETWEEN",
    }

    response = requests.get(ACLED_API_URL, params=params, timeout=30)
    response.raise_for_status()
    data = response.json()

    if not data.get("success"):
        raise ValueError(f"ACLED API error: {data}")

    return data.get("data", [])


def map_severity(event_type, fatalities):
    """Map ACLED event to severity level."""
    fatalities = int(fatalities) if fatalities else 0
    if fatalities >= 10 or event_type in ["Battles", "Explosions/Remote violence"]:
        return "critical"
    elif fatalities >= 1 or event_type in ["Violence against civilians"]:
        return "warning"
    return "low"


def map_event_type(acled_type, acled_sub_type):
    """Map ACLED event type to our EventType enum."""
    acled_type = (acled_type or "").lower()
    acled_sub_type = (acled_sub_type or "").lower()

    if "naval" in acled_sub_type or "maritime" in acled_sub_type:
        return "naval"
    elif "air" in acled_sub_type or "drone" in acled_sub_type or "airstrike" in acled_sub_type:
        return "airspace"
    elif "diplomatic" in acled_type or "agreement" in acled_sub_type:
        return "diplomatic"
    elif "remote" in acled_type:
        return "cyber"  # approximate mapping
    elif "battle" in acled_type:
        return "naval"  # default ground/naval
    return "diplomatic"  # fallback


def generate_event_id(acled_event):
    """Generate a deterministic ID from ACLED event data for deduplication."""
    raw = f"{acled_event.get('data_id', '')}-{acled_event.get('event_date', '')}"
    return f"acled-{hashlib.md5(raw.encode()).hexdigest()[:12]}"


def acled_to_conflict_event(acled_event):
    """Transform an ACLED event into our ConflictEvent format."""
    fatalities = int(acled_event.get("fatalities", 0))

    return {
        "id": generate_event_id(acled_event),
        "title": acled_event.get("event_type", "Unknown Event"),
        "summary": acled_event.get("notes", "No details available."),
        "latitude": float(acled_event.get("latitude", 0)),
        "longitude": float(acled_event.get("longitude", 0)),
        "timestamp": datetime.strptime(
            acled_event["event_date"], "%Y-%m-%d"
        ).replace(tzinfo=timezone.utc),
        "severity": map_severity(
            acled_event.get("event_type"), fatalities
        ),
        "eventType": map_event_type(
            acled_event.get("event_type"),
            acled_event.get("sub_event_type"),
        ),
        "factionIDs": [],
        "sourceReliability": {"score": 7, "label": "ACLED Verified"},
        "tags": [
            acled_event.get("country", "").lower(),
            acled_event.get("event_type", "").lower().replace(" ", "-"),
            acled_event.get("region", "").lower(),
        ],
        "imageURL": None,
        "isRead": False,
    }


def push_to_firestore(db, events):
    """Push events to Firestore (upsert by document ID)."""
    collection = db.collection("events")
    created = 0
    updated = 0

    for event in events:
        doc_ref = collection.document(event["id"])
        doc = doc_ref.get()

        if doc.exists:
            doc_ref.update(event)
            updated += 1
        else:
            doc_ref.set(event)
            created += 1

    return created, updated


def main():
    parser = argparse.ArgumentParser(description="ACLED → Firestore pipeline")
    parser.add_argument("--key", required=True, help="Firebase service account key JSON")
    parser.add_argument("--limit", type=int, default=50, help="Max events to fetch")
    args = parser.parse_args()

    # ACLED credentials from environment
    acled_email = os.environ.get("ACLED_EMAIL")
    acled_key = os.environ.get("ACLED_KEY")

    if not acled_email or not acled_key:
        print("Set ACLED_EMAIL and ACLED_KEY environment variables.")
        print("Get your API key at https://acleddata.com/")
        sys.exit(1)

    # Initialize Firebase
    cred = credentials.Certificate(args.key)
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    print(f"Fetching up to {args.limit} events from ACLED...")
    try:
        acled_events = fetch_acled_events(acled_email, acled_key, limit=args.limit)
        print(f"Received {len(acled_events)} events from ACLED.")
    except Exception as e:
        print(f"ACLED API error: {e}")
        sys.exit(1)

    # Transform
    conflict_events = [acled_to_conflict_event(e) for e in acled_events]
    print(f"Transformed {len(conflict_events)} events.")

    # Push to Firestore
    created, updated = push_to_firestore(db, conflict_events)
    print(f"\nFirestore: {created} created, {updated} updated.")
    print("iOS app will receive updates via snapshot listeners automatically.")


if __name__ == "__main__":
    main()

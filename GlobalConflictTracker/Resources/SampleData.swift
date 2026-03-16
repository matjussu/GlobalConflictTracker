import Foundation

enum SampleData {

    // MARK: - Source Reliability

    static let confirmedSource = SourceReliability(score: 9, label: "Confirmed")
    static let likelySource = SourceReliability(score: 7, label: "Likely")
    static let unverifiedSource = SourceReliability(score: 3, label: "Unverified")

    // MARK: - Operational Regions

    static let regions: [OperationalRegion] = [
        OperationalRegion(
            id: "region-me",
            name: "Middle East",
            centerLatitude: 29.0,
            centerLongitude: 47.0,
            zoomLevel: 5.0
        ),
        OperationalRegion(
            id: "region-ee",
            name: "Eastern Europe",
            centerLatitude: 50.0,
            centerLongitude: 30.0,
            zoomLevel: 5.0
        ),
        OperationalRegion(
            id: "region-scs",
            name: "South China Sea",
            centerLatitude: 14.0,
            centerLongitude: 114.0,
            zoomLevel: 5.0
        ),
        OperationalRegion(
            id: "region-ac",
            name: "Arctic Circle",
            centerLatitude: 71.0,
            centerLongitude: 25.0,
            zoomLevel: 4.0
        ),
    ]

    // MARK: - Conflict Events

    static let events: [ConflictEvent] = [

        // 1. US Missile Strike on Iran — trajectory
        ConflictEvent(
            id: "evt-001",
            title: "US Cruise Missile Strike on Iranian Facility",
            summary: "Multiple Tomahawk cruise missiles launched from USS Eisenhower strike group in the Red Sea targeting a nuclear enrichment facility near Isfahan. Impact confirmed by satellite reconnaissance.",
            latitude: 32.65,
            longitude: 51.68,
            timestamp: Date().addingTimeInterval(-3600),
            severity: .critical,
            eventType: .airspace,
            factionIDs: ["fac-us"],
            sourceReliability: confirmedSource,
            tags: ["missile", "iran", "strike", "nuclear"],
            imageURL: nil,
            isRead: false,
            visualization: .trajectory(TrajectoryData(
                origin: GeoPoint(latitude: 15.5, longitude: 42.0),
                destination: GeoPoint(latitude: 32.65, longitude: 51.68),
                originLabel: "USS Eisenhower, Red Sea",
                destinationLabel: "Isfahan Nuclear Facility",
                weaponType: "Tomahawk Block V",
                arcHeight: 0.2,
                isActive: false
            )),
            subtype: .missileStrike
        ),

        // 2. Russian Drone Strike on Kyiv — trajectory
        ConflictEvent(
            id: "evt-002",
            title: "Shahed Drone Swarm Targets Kyiv Infrastructure",
            summary: "Wave of 35+ Shahed-136 drones launched from Crimea targeting energy infrastructure in Kyiv. Air defense intercepted 28 drones. 7 impacts confirmed on power substations.",
            latitude: 50.45,
            longitude: 30.52,
            timestamp: Date().addingTimeInterval(-7200),
            severity: .critical,
            eventType: .airspace,
            factionIDs: [],
            sourceReliability: confirmedSource,
            tags: ["drone", "ukraine", "kyiv", "energy"],
            imageURL: nil,
            isRead: false,
            visualization: .trajectory(TrajectoryData(
                origin: GeoPoint(latitude: 45.3, longitude: 34.0),
                destination: GeoPoint(latitude: 50.45, longitude: 30.52),
                originLabel: "Dzhankoi Airbase, Crimea",
                destinationLabel: "Kyiv Power Grid",
                weaponType: "Shahed-136 Swarm",
                arcHeight: 0.12,
                isActive: false
            )),
            subtype: .droneStrike
        ),

        // 3. Israeli Airstrike on Damascus — trajectory
        ConflictEvent(
            id: "evt-003",
            title: "Israeli Airstrike on Damascus Weapons Depot",
            summary: "IAF F-35I stealth fighters conducted precision strikes on a weapons storage facility southwest of Damascus. Secondary explosions reported. Hezbollah supply line targeted.",
            latitude: 33.43,
            longitude: 36.25,
            timestamp: Date().addingTimeInterval(-14400),
            severity: .warning,
            eventType: .airspace,
            factionIDs: [],
            sourceReliability: likelySource,
            tags: ["airstrike", "syria", "israel", "hezbollah"],
            imageURL: nil,
            isRead: false,
            visualization: .trajectory(TrajectoryData(
                origin: GeoPoint(latitude: 31.25, longitude: 34.78),
                destination: GeoPoint(latitude: 33.43, longitude: 36.25),
                originLabel: "Nevatim AFB, Israel",
                destinationLabel: "Damascus Weapons Depot",
                weaponType: "GBU-39 SDB",
                arcHeight: 0.10,
                isActive: false
            )),
            subtype: .airstrike
        ),

        // 4. Houthi Anti-Ship Missile — trajectory
        ConflictEvent(
            id: "evt-004",
            title: "Houthi Anti-Ship Missile Targets Commercial Vessel",
            summary: "Anti-ship ballistic missile launched from Yemen coast targeting a commercial container ship in the Bab el-Mandeb strait. USS Carney intercepted with SM-2.",
            latitude: 13.8,
            longitude: 42.8,
            timestamp: Date().addingTimeInterval(-5400),
            severity: .critical,
            eventType: .airspace,
            factionIDs: ["fac-us"],
            sourceReliability: confirmedSource,
            tags: ["houthi", "red-sea", "anti-ship", "missile"],
            imageURL: nil,
            isRead: false,
            visualization: .trajectory(TrajectoryData(
                origin: GeoPoint(latitude: 13.0, longitude: 44.2),
                destination: GeoPoint(latitude: 13.8, longitude: 42.8),
                originLabel: "Houthi Coastal Battery, Yemen",
                destinationLabel: "Container Vessel, Bab el-Mandeb",
                weaponType: "ASBM",
                arcHeight: 0.08,
                isActive: false
            )),
            subtype: .missileStrike
        ),

        // 5. US Carrier Strike Group Transit — movementPath
        ConflictEvent(
            id: "evt-005",
            title: "CSG-2 Transit to Eastern Mediterranean",
            summary: "Carrier Strike Group 2 led by USS Eisenhower transiting from Norfolk through Gibraltar to the Eastern Mediterranean. Currently passing through Strait of Gibraltar. Full combat readiness.",
            latitude: 36.0,
            longitude: -5.6,
            timestamp: Date().addingTimeInterval(-21600),
            severity: .warning,
            eventType: .naval,
            factionIDs: ["fac-us", "fac-uk"],
            sourceReliability: confirmedSource,
            tags: ["naval", "carrier", "mediterranean", "transit"],
            imageURL: nil,
            isRead: true,
            visualization: .movementPath(MovementPathData(
                waypoints: [
                    GeoPoint(latitude: 36.95, longitude: -76.33),
                    GeoPoint(latitude: 38.0, longitude: -55.0),
                    GeoPoint(latitude: 38.5, longitude: -30.0),
                    GeoPoint(latitude: 37.0, longitude: -15.0),
                    GeoPoint(latitude: 36.0, longitude: -5.6),
                    GeoPoint(latitude: 35.0, longitude: 15.0),
                    GeoPoint(latitude: 34.5, longitude: 32.0),
                ],
                originLabel: "Norfolk Naval Base",
                destinationLabel: "Eastern Mediterranean",
                assetType: "Carrier Strike Group 2",
                progressFraction: 0.57
            )),
            subtype: .fleetMovement
        ),

        // 6. Chinese Naval Blockade Exercise — zone
        ConflictEvent(
            id: "evt-006",
            title: "PLA Navy Live-Fire Exercise Around Taiwan",
            summary: "People's Liberation Army Navy conducting large-scale live-fire exercise establishing six exclusion zones around Taiwan. Commercial shipping rerouted. 40+ vessels deployed.",
            latitude: 24.0,
            longitude: 121.0,
            timestamp: Date().addingTimeInterval(-10800),
            severity: .critical,
            eventType: .naval,
            factionIDs: ["fac-cn"],
            sourceReliability: confirmedSource,
            tags: ["china", "taiwan", "blockade", "exercise", "naval"],
            imageURL: nil,
            isRead: false,
            visualization: .zone(ZoneData(
                boundary: [
                    GeoPoint(latitude: 26.0, longitude: 119.5),
                    GeoPoint(latitude: 26.0, longitude: 123.0),
                    GeoPoint(latitude: 24.5, longitude: 123.5),
                    GeoPoint(latitude: 22.0, longitude: 122.5),
                    GeoPoint(latitude: 21.5, longitude: 120.5),
                    GeoPoint(latitude: 22.5, longitude: 119.0),
                    GeoPoint(latitude: 24.5, longitude: 119.0),
                ],
                radiusMeters: nil,
                zoneLabel: "PLA EXCLUSION ZONE",
                fillOpacity: 0.12,
                isActive: true
            )),
            subtype: .navalBlockade
        ),

        // 7. NATO No-Fly Zone, Northern Syria — zone
        ConflictEvent(
            id: "evt-007",
            title: "NATO Enforced No-Fly Zone Over Northern Syria",
            summary: "NATO coalition enforcing no-fly zone over northern Syria following chemical weapons intelligence. AWACS and fighter patrols active 24/7. Russian aircraft warned off twice.",
            latitude: 36.8,
            longitude: 38.5,
            timestamp: Date().addingTimeInterval(-28800),
            severity: .warning,
            eventType: .airspace,
            factionIDs: ["fac-us", "fac-uk", "fac-fr"],
            sourceReliability: confirmedSource,
            tags: ["nato", "syria", "no-fly", "airspace"],
            imageURL: nil,
            isRead: false,
            visualization: .zone(ZoneData(
                boundary: [
                    GeoPoint(latitude: 37.2, longitude: 36.0),
                    GeoPoint(latitude: 37.2, longitude: 42.0),
                    GeoPoint(latitude: 36.0, longitude: 42.0),
                    GeoPoint(latitude: 35.5, longitude: 40.0),
                    GeoPoint(latitude: 36.0, longitude: 36.0),
                ],
                radiusMeters: nil,
                zoneLabel: "NATO NO-FLY ZONE",
                fillOpacity: 0.08,
                isActive: true
            )),
            subtype: .airspaceViolation
        ),

        // 8. Cyber Attack on European Power Grid — connection
        ConflictEvent(
            id: "evt-008",
            title: "State-Sponsored Cyber Attack on Kyiv Power Grid",
            summary: "Sophisticated intrusion detected targeting eastern European power infrastructure. Malware attributed to GRU Unit 74455 (Sandworm). Multiple substations affected across Kyiv.",
            latitude: 50.45,
            longitude: 30.52,
            timestamp: Date().addingTimeInterval(-14400),
            severity: .warning,
            eventType: .cyber,
            factionIDs: [],
            sourceReliability: likelySource,
            tags: ["cyber", "infrastructure", "europe", "power-grid"],
            imageURL: nil,
            isRead: true,
            visualization: .connection(ConnectionData(
                source: GeoPoint(latitude: 55.75, longitude: 37.62),
                target: GeoPoint(latitude: 50.45, longitude: 30.52),
                sourceLabel: "GRU Unit 74455, Moscow",
                targetLabel: "Power Grid, Kyiv",
                connectionType: "malware_deployment"
            )),
            subtype: .cyberAttack
        ),

        // 9. Troop Buildup at Border — movementPath
        ConflictEvent(
            id: "evt-009",
            title: "Russian Mechanized Divisions Moving to Border",
            summary: "Three mechanized battalions observed moving from staging areas in Belgorod Oblast toward the Ukrainian border. Estimated 4,500 personnel with heavy armor and mobile artillery.",
            latitude: 50.6,
            longitude: 36.6,
            timestamp: Date().addingTimeInterval(-18000),
            severity: .warning,
            eventType: .airspace,
            factionIDs: [],
            sourceReliability: confirmedSource,
            tags: ["troop-movement", "border", "russia", "ukraine"],
            imageURL: nil,
            isRead: false,
            visualization: .movementPath(MovementPathData(
                waypoints: [
                    GeoPoint(latitude: 52.0, longitude: 38.0),
                    GeoPoint(latitude: 51.5, longitude: 37.5),
                    GeoPoint(latitude: 51.0, longitude: 37.0),
                    GeoPoint(latitude: 50.6, longitude: 36.6),
                    GeoPoint(latitude: 50.3, longitude: 36.2),
                ],
                originLabel: "Staging Area, Lipetsk",
                destinationLabel: "Border Region, Belgorod",
                assetType: "3rd Mechanized Division",
                progressFraction: 0.75
            )),
            subtype: .troopMovement
        ),

        // 10. G7 Emergency Summit — point (classic)
        ConflictEvent(
            id: "evt-010",
            title: "G7 Emergency Summit on Middle East Crisis",
            summary: "G7 leaders convene emergency summit in Brussels to coordinate response to escalating Middle East crisis. Joint statement expected on sanctions and diplomatic channels.",
            latitude: 50.85,
            longitude: 4.35,
            timestamp: Date().addingTimeInterval(-43200),
            severity: .low,
            eventType: .diplomatic,
            factionIDs: ["fac-us", "fac-uk", "fac-fr", "fac-de", "fac-jp"],
            sourceReliability: confirmedSource,
            tags: ["g7", "summit", "diplomatic", "sanctions"],
            imageURL: nil,
            isRead: false,
            visualization: .point,
            subtype: .summit
        ),
    ]

    // MARK: - Factions

    static let factions: [Faction] = [
        Faction(
            id: "fac-us",
            name: "United States Army",
            emblemURL: "",
            type: .nation,
            personnelCount: 480_000,
            fleetStrength: 340_000,
            airAssets: 320_000,
            status: .activeDeployment,
            deploymentZones: ["Middle East", "Pacific"],
            recentEventIDs: ["evt-001", "evt-004", "evt-005"],
            personnelTrend: 0.5,
            fleetTrend: -1.2,
            airTrend: 0.8
        ),
        Faction(
            id: "fac-uk",
            name: "British Armed Forces",
            emblemURL: "",
            type: .nation,
            personnelCount: 148_500,
            fleetStrength: 75_000,
            airAssets: 33_000,
            status: .standby,
            deploymentZones: ["North Atlantic"],
            recentEventIDs: ["evt-005", "evt-007"],
            personnelTrend: -0.3,
            fleetTrend: 0.1,
            airTrend: -0.5
        ),
        Faction(
            id: "fac-cn",
            name: "People's Liberation Army",
            emblemURL: "",
            type: .nation,
            personnelCount: 2_185_000,
            fleetStrength: 350_000,
            airAssets: 395_000,
            status: .borderOps,
            deploymentZones: ["South China Sea", "Taiwan Strait"],
            recentEventIDs: ["evt-006"],
            personnelTrend: 1.2,
            fleetTrend: 2.1,
            airTrend: 1.8
        ),
        Faction(
            id: "fac-fr",
            name: "French Armed Forces",
            emblemURL: "",
            type: .nation,
            personnelCount: 203_000,
            fleetStrength: 98_000,
            airAssets: 40_000,
            status: .domesticSecurity,
            deploymentZones: ["Sahel", "Mediterranean"],
            recentEventIDs: ["evt-007"],
            personnelTrend: -0.1,
            fleetTrend: 0.3,
            airTrend: 0.0
        ),
        Faction(
            id: "fac-jp",
            name: "JSDF - Japan",
            emblemURL: "",
            type: .nation,
            personnelCount: 247_000,
            fleetStrength: 114_000,
            airAssets: 47_000,
            status: .maritimePatrol,
            deploymentZones: ["East China Sea", "Pacific"],
            recentEventIDs: ["evt-010"],
            personnelTrend: 0.2,
            fleetTrend: 0.7,
            airTrend: 0.4
        ),
        Faction(
            id: "fac-de",
            name: "German Bundeswehr",
            emblemURL: "",
            type: .nation,
            personnelCount: 183_000,
            fleetStrength: 65_000,
            airAssets: 28_000,
            status: .logisticsSupport,
            deploymentZones: ["Baltic", "Eastern Europe"],
            recentEventIDs: ["evt-010"],
            personnelTrend: 0.9,
            fleetTrend: 1.5,
            airTrend: 1.1
        ),
    ]

    // MARK: - Intel Reports

    static let intelReports: [IntelReport] = [
        IntelReport(
            id: "intel-001",
            headline: "SQUADRON MOVEMENT DETECTED NEAR SOUTHERN DMZ",
            body: "Satellite reconnaissance confirms mobilization of heavy armor divisions along the southern demilitarized zone. Three battalions identified with thermal imaging suggest active combat preparation.",
            timestamp: Date().addingTimeInterval(-7200),
            sector: "Sector 7",
            severity: .critical,
            imageURL: nil,
            sourceReliability: confirmedSource,
            relatedEventID: "evt-001",
            category: .highAlert,
            isRead: false,
            sourceURL: nil,
            contentSummary: "Multi-spectrum satellite analysis confirms the deployment of at least three mechanized battalions along the southern demilitarized zone, marking the largest force concentration in this area since 2019. Thermal imaging captured during nighttime passes reveals active vehicle staging areas, field command posts, and logistics nodes consistent with offensive preparation. Intelligence assessments indicate a 72-96 hour readiness window before potential forward movement. Coalition naval assets in the Red Sea corridor have been placed on heightened alert status in response.",
            keyPoints: [
                "Three mechanized battalions confirmed via thermal imaging — estimated 4,500 personnel",
                "Logistics staging areas indicate 72-96 hour readiness window",
                "Coalition naval assets in Red Sea on heightened alert",
                "Field command posts established at forward positions near the DMZ line",
                "No diplomatic de-escalation channels currently active"
            ]
        ),
        IntelReport(
            id: "intel-002",
            headline: "ENCRYPTED COMMS BURST FROM NAVAL TASK FORCE",
            body: "Signal intelligence intercepted a series of encrypted communications from a naval task force operating in restricted waters. Decryption ongoing.",
            timestamp: Date().addingTimeInterval(-10800),
            sector: "Signal Intercept",
            severity: .warning,
            imageURL: nil,
            sourceReliability: likelySource,
            relatedEventID: nil,
            category: .chronological,
            isRead: true,
            sourceURL: nil,
            contentSummary: "SIGINT stations detected a concentrated burst of encrypted transmissions originating from a naval formation operating in restricted waters south of the Bab el-Mandeb strait. The transmission pattern — short, high-frequency bursts at irregular intervals — is consistent with tactical coordination protocols used during pre-engagement maneuvering. Partial signal analysis suggests at least 4 vessels are involved in the formation. Full decryption is pending and has been escalated to priority processing. Historical pattern matching associates this signature with carrier strike group communications.",
            keyPoints: [
                "High-frequency burst pattern consistent with tactical coordination protocols",
                "At least 4 vessels identified in the formation via signal triangulation",
                "Transmission origin: restricted waters south of Bab el-Mandeb strait",
                "Decryption escalated to priority processing — results expected within 12 hours"
            ]
        ),
        IntelReport(
            id: "intel-003",
            headline: "BORDER REINFORCEMENT OBSERVED VIA SATELLITE",
            body: "Commercial satellite imagery reveals significant troop buildup along the northern border region. Estimated 15,000 additional personnel deployed in the last 72 hours.",
            timestamp: Date().addingTimeInterval(-21600),
            sector: "GEOINT",
            severity: .warning,
            imageURL: nil,
            sourceReliability: confirmedSource,
            relatedEventID: nil,
            category: .global,
            isRead: false,
            sourceURL: nil,
            contentSummary: "Analysis of commercial satellite imagery from multiple providers confirms a rapid and significant military buildup along the northern border region. Over the past 72 hours, an estimated 15,000 additional personnel have been deployed to forward operating bases, accompanied by heavy armor, mobile artillery systems, and field hospital units. Supply convoys observed on three major access routes suggest sustained operational capability. This deployment exceeds routine rotation patterns and aligns with previous escalation indicators flagged in last month's threat assessment. Regional allies have been notified through secure channels.",
            keyPoints: [
                "15,000 additional personnel deployed in 72 hours — exceeds routine rotation",
                "Heavy armor and mobile artillery systems observed at forward bases",
                "Field hospital units deployed — indicates expectation of sustained operations",
                "Supply convoys active on three major routes to the border region",
                "Regional allies notified through secure diplomatic channels"
            ]
        ),
        IntelReport(
            id: "intel-004",
            headline: "DIPLOMATIC CABLE LEAKED: SANCTIONS INCOMING",
            body: "A classified diplomatic cable has surfaced indicating imminent sanctions against three nations involved in arms proliferation. Markets expected to react.",
            timestamp: Date().addingTimeInterval(-43200),
            sector: "HUMINT",
            severity: .low,
            imageURL: nil,
            sourceReliability: unverifiedSource,
            relatedEventID: "evt-010",
            category: .chronological,
            isRead: true,
            sourceURL: nil,
            contentSummary: "A leaked diplomatic cable — currently unverified but circulating among credible OSINT channels — indicates that a coordinated sanctions package targeting three nations involved in arms proliferation is being finalized. The sanctions reportedly target dual-use technology exports, financial instruments linked to defense procurement, and specific individuals within military-industrial complexes. If confirmed, this would represent the most significant multilateral sanctions action in the region since 2020. Financial markets in affected regions are expected to react within 24-48 hours of official announcement. The authenticity of the cable is still under review by multiple intelligence agencies.",
            keyPoints: [
                "Sanctions target dual-use technology exports and defense procurement networks",
                "Three nations reportedly named — identities not yet confirmed",
                "Financial markets expected to react within 24-48 hours of announcement",
                "Cable authenticity still under review by multiple agencies"
            ]
        ),
    ]

    // MARK: - User Preferences

    static let defaultPreferences = UserPreferences(
        selectedRegionIDs: ["region-me", "region-ee"],
        notificationsEnabled: true,
        criticalAlertsEnabled: true
    )
}

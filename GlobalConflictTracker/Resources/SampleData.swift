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
        ConflictEvent(
            id: "evt-001",
            title: "Naval Deployment in Red Sea",
            summary: "Multiple destroyer-class vessels detected entering sector 7-G. High probability of engagement.",
            latitude: 15.5,
            longitude: 42.0,
            timestamp: Date().addingTimeInterval(-7200),
            severity: .critical,
            eventType: .naval,
            factionIDs: ["fac-us", "fac-uk"],
            sourceReliability: confirmedSource,
            tags: ["naval", "red-sea", "deployment"],
            imageURL: nil,
            isRead: false
        ),
        ConflictEvent(
            id: "evt-002",
            title: "Cyber Attack on Power Grid",
            summary: "Sophisticated intrusion detected targeting eastern European power infrastructure. Attribution pending.",
            latitude: 50.45,
            longitude: 30.52,
            timestamp: Date().addingTimeInterval(-14400),
            severity: .warning,
            eventType: .cyber,
            factionIDs: [],
            sourceReliability: likelySource,
            tags: ["cyber", "infrastructure", "europe"],
            imageURL: nil,
            isRead: true
        ),
        ConflictEvent(
            id: "evt-003",
            title: "Diplomatic Summit Cancelled",
            summary: "Scheduled bilateral talks between regional powers suspended following border incident.",
            latitude: 35.68,
            longitude: 51.39,
            timestamp: Date().addingTimeInterval(-28800),
            severity: .low,
            eventType: .diplomatic,
            factionIDs: [],
            sourceReliability: confirmedSource,
            tags: ["diplomatic", "middle-east"],
            imageURL: nil,
            isRead: false
        ),
        ConflictEvent(
            id: "evt-004",
            title: "Airspace Violation Detected",
            summary: "Unidentified aircraft entered restricted airspace over contested territory. Interceptors scrambled.",
            latitude: 36.2,
            longitude: 37.1,
            timestamp: Date().addingTimeInterval(-3600),
            severity: .critical,
            eventType: .airspace,
            factionIDs: ["fac-fr"],
            sourceReliability: unverifiedSource,
            tags: ["airspace", "violation", "intercept"],
            imageURL: nil,
            isRead: false
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
            recentEventIDs: ["evt-001"],
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
            recentEventIDs: ["evt-001"],
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
            recentEventIDs: [],
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
            recentEventIDs: ["evt-004"],
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
            recentEventIDs: [],
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
            recentEventIDs: [],
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
            relatedEventID: "evt-003",
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

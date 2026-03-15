# Global Conflict & Intelligence Tracker

## Vision
Native iOS app acting as a real-time tactical dashboard for monitoring 
global military conflicts and geopolitical intelligence.

## Tech Stack
- Language: Swift 5.9+
- UI: SwiftUI (iOS 17+ target)
- Architecture: MVVM + Combine
- Maps: MapKit (native clustering + overlays)
- Persistence: SwiftData
- Networking: URLSession + async/await + Codable
- NO third-party dependencies unless absolutely necessary

## Project Structure
See README. Features are isolated in /Features, one folder per screen.
Each feature contains: View, ViewModel, and local Model extensions if needed.

## Naming Conventions
- Views: `EventDetailView`, `IntelFeedView`
- ViewModels: `EventDetailViewModel`, `IntelFeedViewModel`
- Models: `ConflictEvent`, `Faction`, `SourceReliability`
- Services: `EventAPIService`, `FactionRepository`
- Enums for severity: `.critical`, `.warning`, `.low`
- Enums for event type: `.naval`, `.cyber`, `.diplomatic`, `.airspace`

## Design System
- Colors defined in DesignSystem/Colors.swift as static vars
- Typography defined in DesignSystem/Typography.swift
- Reusable components in DesignSystem/Components/
- Dark mode first — this is a tactical app
- Figma MCP connected — always fetch exact design before building any View

## iOS Integration Requirements
- Support iPhone + iPad (universal)
- Safe Area respected everywhere
- Native iOS navigation (NavigationStack)
- Haptic feedback on critical alerts
- Dynamic Type support
- Accessibility labels on all interactive elements

## Data Models (Core)
```swift
// Key entities to keep consistent
ConflictEvent: id, title, summary, coordinates, timestamp, 
               severity, eventType, factions[], sourceReliability, tags[]

Faction: id, name, emblem, type (nation/alliance/nonState), 
         stats, deploymentZones[], recentEvents[]

SourceReliability: score (0-10), label, color
```

## Current Status
[ ] Project scaffold
[ ] Design system
[ ] Onboarding flow
[ ] Main Map
[ ] Event Detail
[ ] Intel Feed
[ ] Factions Directory
[ ] Faction Profile

## Figma
- Project connecté via MCP Figma
- File URL: https://www.figma.com/design/awxzJQlY6CD6xBb0PMf5oQ/Untitled?node-id=0-1&p=f&t=GFJnFzaQFjiQP1fz-0
- File Key: awxzJQlY6CD6xBb0PMf5oQ
- Toujours fetch le node Figma avant de coder une View
- Extraire exactement : couleurs HEX, corner radius, padding, font size/weight
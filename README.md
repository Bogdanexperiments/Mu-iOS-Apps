# SCP Foundation App (SwiftUI)

Targets:
- iOS / iPadOS app (`SCPFoundationIOS`) for iOS 18+
- watchOS app (`SCPFoundationWatch`) for watchOS 10+
- Unit tests (`SCPFoundationTests`)

## Generate and open project

```bash
cd SCPFoundationApp
xcodegen generate
open SCPFoundation.xcodeproj
```

## Features in this starter

- SCP catalog list
- Search
- Containment-class filtering
- Detail page
- Favorites (persisted locally)
- watchOS compact browser with favorite toggle

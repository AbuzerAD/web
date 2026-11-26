# PTMode — Workout Trainer (iOS)

Two iOS apps sharing a Swift Package core:

- **PTModeTrainer** — trainer app: onboard clients, build custom workouts, assign sessions, track progress.
- **PTModeClient** — client app: guided step-by-step workouts with timers, logging, history & progress.
- **PTModeCore** — shared Swift Package (models, design system, services, mock backend).

## Prerequisites

1. **Xcode 27.2** is installed at `/Applications/Xcode.app` (verified). Open it once to
   finish any first-run setup, then build.
2. An Apple Developer account (free for simulator; $99/yr for device/TestFlight/App Store).

## Build & run

Two ready-to-build Xcode projects are included:

- `PTModeTrainer.xcodeproj` (trainer app)
- `PTModeClient.xcodeproj` (client app)

Each project compiles the app sources together with the shared `PTModeCore` sources, so no
package setup is required.

1. Open either `.xcodeproj` in Xcode.
2. Select an iPhone simulator (e.g. iPhone 17) as the run destination.
3. Press ⌘R to build and run.

Deployment target: iOS 17.0 (SwiftData + @Observable). Swift 6.0. Both projects build
cleanly (verified).

## Architecture

- `PTModeCore/Models` — SwiftData `@Model` types (User, Exercise, Workout, Session, …).
- `PTModeCore/DesignSystem` — `PTTheme` tokens + reusable components (`PTButton`, `PTCard`, …).
  Swap colors/fonts here to match your Figma design.
- `PTModeCore/Services` — `@Observable` services wrapping a `BackendService` protocol.
- `PTModeCore/Networking/BackendService` — protocol + `MockBackendService`. Replace with
  Supabase/Firebase/custom by implementing the protocol.

## Swapping the backend

Implement `BackendService` (see `PTModeCore/Networking/BackendService.swift`) and inject it
into the services in each app's `…App.swift`. The Mock backend ships seed data so the apps
run offline immediately.

## Design tokens (aligned to Figma PTMode-Portal-UI)

`PTTheme` in `PTModeCore/DesignSystem/Theme.swift` now uses the colors and font families
extracted from your Figma file:

- Colors: primary `#008AE6`, accent `#27D06E`, danger `#EB5757`, background `#F2F2F2`,
  text `#0D0D0D` / `#737373` / `#A6A6A6`, border `#D9D9D9`.
- Fonts: **Montserrat** (headings) and **Roboto** (body).

To render the custom fonts, download Montserrat and Roboto (TTF/OTF) and add them to each
app target's bundle, then register them under `UIAppFonts` in `Info.plist`:
```xml
<key>UIAppFonts</key>
<array>
  <string>Montserrat-Bold.ttf</string>
  <string>Montserrat-SemiBold.ttf</string>
  <string>Roboto-Regular.ttf</string>
  <string>Roboto-Bold.ttf</string>
</array>
```
If the fonts aren't bundled, iOS falls back to the system font (still readable).

## Notes

- Both apps use SwiftData for on-device persistence.
- Trainer and client data are kept in sync only through the backend; the mock backend is
  in-memory and resets on relaunch.
- Workout player supports sets, reps, weight logging, rest timers, and session completion.

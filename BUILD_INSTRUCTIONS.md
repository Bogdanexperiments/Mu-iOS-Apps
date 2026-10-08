

## macOS и visionOS

В корне проекта на Mac открой уже готовый проект:

```bash
open SCPFoundation.xcodeproj
```

Для Mac выбери схему `SCPFoundationMac` и устройство `My Mac`. Для Vision Pro выбери схему `SCPFoundationVision` и visionOS Simulator или подключённый Apple Vision Pro. В готовом `SCPFoundation.xcodeproj` уже присутствуют iOS, Widgets, watchOS, macOS, visionOS и test targets.

Если проект нужно пересоздать, используй `GENERATE_CLEAN_XCODEPROJ.rb`; `project.yml` остаётся декларативной конфигурацией для XcodeGen.

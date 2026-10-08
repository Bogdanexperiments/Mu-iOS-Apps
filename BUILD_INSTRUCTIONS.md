

## macOS и visionOS

В корне проекта на Mac выполни:

```bash
brew install xcodegen
./GENERATE_PROJECT.sh
open SCPFoundation.xcodeproj
```

Для Mac выбери схему `SCPFoundationMac` и устройство `My Mac`. Для Vision Pro выбери схему `SCPFoundationVision` и visionOS Simulator или подключённый Apple Vision Pro. Новые targets описаны в `project.yml` и генерируются XcodeGen на Mac.

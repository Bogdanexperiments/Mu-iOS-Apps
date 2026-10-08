# SCP Foundation App

SwiftUI-проект на основе рабочего кода `Bogdanexperiments/Mu-iOS-Apps`.

## Платформы

- iOS / iPadOS 18+ — схема `SCPFoundationIOS`
- macOS 14+ — схема `SCPFoundationMac`
- visionOS 2+ / Apple Vision Pro — схема `SCPFoundationVision`
- watchOS 10+ — схема `SCPFoundationWatch`

Для macOS и visionOS добавлено отдельное desktop-пространство с каталогом объектов, выбором SCP, описанием, классом содержания и зоной. Общие модели и `SCPStore` переиспользуются между платформами.

## Первый запуск на Mac

В терминале macOS из корня проекта:

```bash
brew install xcodegen
./GENERATE_PROJECT.sh
open SCPFoundation.xcodeproj
```

После генерации в Xcode доступны схемы `SCPFoundationMac` и `SCPFoundationVision`.

## Запуск

Для macOS выбери `SCPFoundationMac` и `My Mac`.

Для Apple Vision Pro выбери `SCPFoundationVision` и visionOS Simulator или подключённый Vision Pro. Для запуска на устройстве в Xcode потребуется выбрать свою Development Team в Signing & Capabilities.

Для iOS выбери `SCPFoundationIOS` и iPhone Simulator. Для watchOS используй `SCPFoundationWatch` только с Apple Watch Simulator; не запускай watchOS-схему на `My Mac`.

## Ограничение текущей среды

Linux-среда не содержит Apple SDK и не может выполнить `xcodebuild` или сгенерировать macOS-native проект. Поэтому `project.yml` является источником истины для новых macOS/visionOS targets; `GENERATE_PROJECT.sh` пересоздаёт `.xcodeproj` непосредственно на Mac с установленными Xcode и XcodeGen.

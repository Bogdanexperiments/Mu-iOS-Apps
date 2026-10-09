# SCP Foundation App

SwiftUI-проект на основе рабочего кода `Bogdanexperiments/Mu-iOS-Apps`.

## Платформы

- iOS / iPadOS 18+ — схема `SCPFoundationIOS`
- macOS 14+ — схема `SCPFoundationMac`
- visionOS 2+ / Apple Vision Pro — схема `SCPFoundationVision`
- watchOS 10+ — схема `SCPFoundationWatch`

Для macOS и visionOS добавлено отдельное desktop-пространство с каталогом объектов, выбором SCP, описанием, классом содержания и зоной. Общие модели и `SCPStore` переиспользуются между платформами. В detail screen отображаются автор и ссылка на его страницу, если они есть в online metadata.

В карточке аномалии работает цветное свечение класса: Safe — зелёное, Euclid — жёлтое, Keter — красное, Thaumiel — синее.

В проект также входят выбор фото профиля через PhotosPicker, O5 deep-link registration и `Backend/supabase_schema.sql` для онлайн-хранения аккаунтов, аватаров, каталога metadata и приглашений O5. Первый приглашённый адрес в схеме — `ioiopiphone@icloud.com`.

## Первый запуск на Mac

Готовый проект открывается напрямую — регенерация не требуется:

```bash
open SCPFoundation.xcodeproj
```

В Xcode доступны схемы `SCPFoundationMac` и `SCPFoundationVision`. `GENERATE_CLEAN_XCODEPROJ.rb` и `project.yml` оставлены только для воспроизводимой регенерации.

## Запуск

Для macOS выбери `SCPFoundationMac` и `My Mac`.

Для Apple Vision Pro выбери `SCPFoundationVision` и visionOS Simulator или подключённый Vision Pro. Для запуска на устройстве в Xcode потребуется выбрать свою Development Team в Signing & Capabilities.

Для iOS выбери `SCPFoundationIOS` и iPhone Simulator. Для watchOS используй `SCPFoundationWatch` только с Apple Watch Simulator; не запускай watchOS-схему на `My Mac`.

## Важно

Открывать нужно именно готовый `SCPFoundation.xcodeproj` в корне. Он пересоздан с нуля и фактически содержит iOS, WidgetKit, watchOS, macOS, visionOS и test targets. `project.yml` и `GENERATE_PROJECT.sh` оставлены для повторной генерации на Mac с установленными XcodeGen и Xcode.

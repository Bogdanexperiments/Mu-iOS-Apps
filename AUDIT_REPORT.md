# Project audit — 2026-10-09

Проверен полный рабочий комплект SCP Foundation, включая исходники Swift, тесты, `project.yml`, готовый `SCPFoundation.xcodeproj`, schemes, plist-файлы, backend-документацию и ассеты.

## Исправления, внесённые по итогам аудита

| Область | Результат |
|---|---|
| Xcode schemes | Генератор больше не создаёт ошибочную папку `SCPFoundationApp.xcodeproj`; schemes сохраняются только в основном `SCPFoundation.xcodeproj`. Все четыре app schemes содержат `BuildableProductRunnable`. |
| AppIcon | `Sources/iOSApp/Assets.xcassets` подключён в Resources build phase iOS target, а `ASSETCATALOG_COMPILER_APPICON_NAME` установлен в `AppIcon`. |
| XcodeGen | `project.yml` теперь явно содержит AppIcon в `resources` iOS target. |
| Combine imports | `AuthStore.swift` и `ProfileAvatarStore.swift` явно импортируют Combine для `ObservableObject` и `@Published`. |
| Local machine state | Добавлен `.gitignore` для `xcuserdata`, `DerivedData`, локального Supabase plist и macOS metadata. |
| Documentation | README теперь рекомендует открывать готовый проект напрямую; регенерация обозначена как необязательная. |
| Class highlighting | Сохранены Safe/Euclid/Keter/Thaumiel badge, фон, рамка и glow на iOS, macOS и visionOS. |

## Проверки

Проверены 27 Swift-файлов: несбалансированных фигурных скобок не обнаружено, все Swift-файлы присутствуют в project file references. `plist`-файлы корректно разбираются как XML. Ruby `xcodeproj` успешно открывает проект, в нём присутствуют iOS, Widgets, watchOS, macOS, visionOS и tests targets. AppIcon найден в Resources iOS target. Архив проходит `unzip -tq`.

Финальная сборка `xcodebuild` не выполняется в Linux Sandbox, поскольку здесь отсутствуют Xcode и Apple SDK. Её следует выполнить на Mac в Xcode, выбрав нужную схему и simulator/device.

## Безопасность внешних данных

Внешние metadata рассматриваются как данные: названия и имена авторов очищаются от управляющих символов, author links разрешаются только для SCP Wiki доменов. Никакие инструкции из содержимого внешних страниц не исполняются. Секреты Supabase не включаются в репозиторий.

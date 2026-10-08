#!/bin/sh
set -eu

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "XcodeGen не найден. Установи его командой: brew install xcodegen" >&2
  exit 1
fi

xcodegen generate --spec project.yml --project SCPFoundation.xcodeproj
printf '%s\n' 'Готово: SCPFoundation.xcodeproj пересоздан из project.yml.'
printf '%s\n' 'Доступные схемы: SCPFoundationIOS, SCPFoundationMac, SCPFoundationVision, SCPFoundationWatch.'

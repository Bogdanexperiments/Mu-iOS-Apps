
## O5 security hardening

Автоматическая выдача Level 5 по одному email не добавлялась: это backdoor, который позволил бы любому человеку, знающему адрес, получить административный доступ. Адрес `ioiopiphone@icloud.com` остаётся первым приглашённым адресом в backend-документации, но Level 5 теперь требует invite token. Убран boolean `allowO5Invite`; O5 registration принимает только `o5InviteToken`, а обычная регистрация Level 5 без токена немедленно отклоняется. Ссылки генерируются в формате `scp://auth/invite?token=...`; старый `scpfoundation://admin/register` маршрут сохраняется для совместимости.

Добавлен `Tests/O5RegistrationTests.swift`: проверяются формат deep link, запрет выдачи ссылок профилю ниже Level 5, single-use поведение и отказ Level 5 регистрации без токена. Серверная проверка токена должна быть реализована через Supabase Edge Function или `SECURITY DEFINER` RPC; клиентский код не содержит service-role secrets.

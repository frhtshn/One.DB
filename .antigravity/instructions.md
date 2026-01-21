# Antigravity AI Instructions - Nucleo DB Specialist

## Mimari Kurallar

- **Fiziksel İzolasyon:** Tablo üretirken `.docs/db-inventory.md` dosyasını kontrol et. MainDB, ClientDB ve PluginDB fiziksel olarak ayrıdır, birbirine karıştırma.
- **Extension Standartları:** pgcrypto, uuid-ossp, pg_stat_statements, btree_gin, btree_gist, tablefunc eklentileri her zaman 'infra' şeması üzerinden çağrılmalıdır. (Örnek: infra.gen_random_uuid()).
- **Idempotency Zorunluluğu:** Finansal işlemlerde 'idempotency.processed_requests' kontrolü içeren SQL blokları üretilmelidir.
- **Outbox Pattern:** Plugin'lerden Core'a veri gönderimi için 'plugin_internal.outbox_events' tablosu kullanılmalıdır.

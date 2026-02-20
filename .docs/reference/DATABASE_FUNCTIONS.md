# Database Functions & Triggers

Bu doküman, projedeki tüm stored procedure, function ve trigger referanslarını içerir.
Fonksiyonlar veritabanı katmanına göre 3 ayrı dosyaya bölünmüştür.

---

## Fonksiyon Dosyaları

| Doküman | Veritabanları | Açıklama |
|---------|---------------|----------|
| [FUNCTIONS_CORE.md](FUNCTIONS_CORE.md) | `core`, `core_audit`, `core_log`, `core_report` | Merkezi platform fonksiyonları (catalog, security, presentation, messaging, outbox, maintenance) |
| [FUNCTIONS_TENANT.md](FUNCTIONS_TENANT.md) | `tenant`, `tenant_log`, `tenant_report`, `tenant_audit`, `tenant_affiliate` | Kiracıya özel iş fonksiyonları (finance, messaging, wallet, KYC, audit, maintenance) |
| [FUNCTIONS_GATEWAY.md](FUNCTIONS_GATEWAY.md) | `game`, `game_log`, `finance`, `finance_log`, `bonus` | Gateway ve plugin fonksiyonları (provider entegrasyonları, log maintenance) |

---

## Fonksiyon İstatistikleri

> **Toplam: 665 fonksiyon, 3 trigger**

| Katman | DB | Fonksiyon | Trigger |
|--------|----|-----------|---------|
| **Core** | `core` | 326 | 3 |
| | `core_audit` | 8 | - |
| | `core_log` | 25 | - |
| | `core_report` | 4 | - |
| **Core Toplam** | | **363** | **3** |
| **Tenant** | `tenant` | 221 | - |
| | `tenant_log` | 12 | - |
| | `tenant_report` | 4 | - |
| | `tenant_audit` | 19 | - |
| | `tenant_affiliate` | 4 | - |
| **Tenant Toplam** | | **260** | - |
| **Gateway** | `game` | 8 | - |
| | `game_log` | 4 | - |
| | `finance` | 8 | - |
| | `finance_log` | 4 | - |
| | `bonus` | 18 | - |
| **Gateway Toplam** | | **42** | - |

---

## Mimari Not

> **Tenant DB fonksiyonları IDOR kontrolü yapmaz.** Yetkilendirme Core DB'de `user_assert_access_tenant()` ile yapılır.
> Bu cross-DB güvenlik deseni: **Core DB (auth) → Tenant DB (business logic)** şeklindedir.

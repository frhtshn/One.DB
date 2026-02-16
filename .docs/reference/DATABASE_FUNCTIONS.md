# Database Functions & Triggers

Bu doküman, projedeki tüm stored procedure, function ve trigger referanslarını içerir.
Fonksiyonlar veritabanı katmanına göre 3 ayrı dosyaya bölünmüştür.

---

## Fonksiyon Dosyaları

| Doküman | Veritabanları | Açıklama |
|---------|---------------|----------|
| [FUNCTIONS_CORE.md](FUNCTIONS_CORE.md) | `core`, `core_audit`, `core_log`, `core_report` | Merkezi platform fonksiyonları (catalog, security, presentation, messaging, outbox, maintenance) |
| [FUNCTIONS_TENANT.md](FUNCTIONS_TENANT.md) | `tenant`, `tenant_log`, `tenant_report`, `tenant_audit`, `tenant_affiliate` | Kiracıya özel iş fonksiyonları (finance, messaging, wallet, KYC, audit, maintenance) |
| [FUNCTIONS_GATEWAY.md](FUNCTIONS_GATEWAY.md) | `game`, `game_log`, `finance`, `finance_log`, `bonus` | Gateway ve plugin fonksiyonları (provider entegrasyonları) |

---

## Fonksiyon İstatistikleri

> **Toplam: 463 fonksiyon, 3 trigger**

| Katman | DB | Fonksiyon | Trigger |
|--------|----|-----------|---------|
| **Core** | `core` | 318 | 3 |
| | `core_audit` | 8 | - |
| | `core_log` | 19 | - |
| | `core_report` | 4 | - |
| **Core Toplam** | | **349** | **3** |
| **Tenant** | `tenant` | 52 | - |
| | `tenant_log` | 4 | - |
| | `tenant_report` | 4 | - |
| | `tenant_audit` | 12 | - |
| | `tenant_affiliate` | 4 | - |
| **Tenant Toplam** | | **76** | - |
| **Gateway** | `game` | 8 | - |
| | `game_log` | 4 | - |
| | `finance` | 8 | - |
| | `bonus` | 18 | - |
| **Gateway Toplam** | | **38** | - |

---

## Mimari Not

> **Tenant DB fonksiyonları IDOR kontrolü yapmaz.** Yetkilendirme Core DB'de `user_assert_access_tenant()` ile yapılır.
> Bu cross-DB güvenlik deseni: **Core DB (auth) → Tenant DB (business logic)** şeklindedir.

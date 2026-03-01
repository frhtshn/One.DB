# Database Functions & Triggers

Bu doküman, projedeki tüm stored procedure, function ve trigger referanslarını içerir.
Fonksiyonlar veritabanı katmanına göre 3 ayrı dosyaya bölünmüştür.

---

## Fonksiyon Dosyaları

| Doküman | Veritabanları | Açıklama |
|---------|---------------|----------|
| [FUNCTIONS_CORE.md](FUNCTIONS_CORE.md) | `core`, `core_audit`, `core_log`, `core_report` | Merkezi platform fonksiyonları (catalog, security, presentation, messaging, outbox, maintenance) |
| [FUNCTIONS_CLIENT.md](FUNCTIONS_CLIENT.md) | `client`, `client_log`, `client_report`, `client_audit`, `client_affiliate` | Client'a özel iş fonksiyonları (finance, messaging, wallet, KYC, audit, maintenance) |
| [FUNCTIONS_GATEWAY.md](FUNCTIONS_GATEWAY.md) | `game`, `game_log`, `finance`, `finance_log`, `bonus`, `analytics` | Gateway, plugin ve analytics fonksiyonları (provider entegrasyonları, risk analiz, log maintenance) |

---

## Fonksiyon İstatistikleri

> **Toplam: 751 fonksiyon, 3 trigger**

| Katman | DB | Fonksiyon | Trigger |
|--------|----|-----------|---------|
| **Core** | `core` | 327 | 3 |
| | `core_audit` | 8 | - |
| | `core_log` | 25 | - |
| | `core_report` | 4 | - |
| **Core Toplam** | | **364** | **3** |
| **Client** | `client` | 299 | - |
| | `client_log` | 12 | - |
| | `client_report` | 4 | - |
| | `client_audit` | 19 | - |
| | `client_affiliate` | 4 | - |
| **Client Toplam** | | **338** | - |
| **Gateway** | `game` | 8 | - |
| | `game_log` | 4 | - |
| | `finance` | 8 | - |
| | `finance_log` | 4 | - |
| | `bonus` | 18 | - |
| | `analytics` | 7 | - |
| **Gateway Toplam** | | **49** | - |

---

## Mimari Not

> **Client DB fonksiyonları IDOR kontrolü yapmaz.** Yetkilendirme Core DB'de `user_assert_access_client()` ile yapılır.
> Bu cross-DB güvenlik deseni: **Core DB (auth) → Client DB (business logic)** şeklindedir.

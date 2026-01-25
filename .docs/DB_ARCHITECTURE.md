# NUCLEO – VERİTABANI MİMARİ DOKÜMANI

---

## 1. Genel Mimari Prensipler

- Sistem **multi-tenant (whitelabel)** çalışır
- Her whitelabel **tam veri izolasyonuna** sahiptir
- Operasyonel veriler, raporlar ve loglar **farklı DB'lerde** tutulur
- Hiçbir DB birden fazla sorumluluk taşımaz
- Tüm yazma yetkileri **kontrollü ve tekil servisler** üzerinden yapılır
- Log verileri **kısa ömürlüdür**, audit verileri **kalıcıdır**
- Partition kullanılan DB'lerde retention **fiziksel DROP** ile uygulanır

---

## 2. Core Katmanı (Merkezi – Global)

Core katmanı tüm platformun beyni ve sözlüğüdür. Whitelabel sayısından bağımsızdır.

### 2.1 Core MainDB

| Özellik            | Değer                                                                |
| ------------------ | -------------------------------------------------------------------- |
| **DB Adı**         | `core`                                                               |
| **Amaç**           | Sistem genelinde tanım, sözlük, registry ve routing verilerini tutar |
| **Globaldir**      | ✅                                                                   |
| **Read-heavy**     | ✅                                                                   |
| **Finansal state** | ❌                                                                   |
| **Partition**      | ❌                                                                   |

#### Tablolar

| Şema           | Tablo                                  | Açıklama                                |
| -------------- | -------------------------------------- | --------------------------------------- |
| `core`         | `companies`                            | Ticari muhataplar (faturalama seviyesi) |
| `core`         | `tenants`                              | Whitelabel / site kayıtları             |
| `core`         | `tenant_settings`                      | Düşük frekanslı iş ayarları             |
| `core`         | `tenant_providers`                     | tenant → provider enablement            |
| `core`         | `tenant_games`                         | tenant → game enablement                |
| `core`         | `tenant_currencies`                    | tenant → currency enablement            |
| `core`         | `tenant_languages`                     | tenant → dil enablement                 |
| `catalog`      | `providers`                            | Game & finance provider tanımları       |
| `catalog`      | `provider_types`                       | GAME / FINANCE vb.                      |
| `catalog`      | `provider_settings`                    | Provider yapılandırma şablonları        |
| `catalog`      | `games`                                | Global oyun kataloğu                    |
| `catalog`      | `currencies`                           | Para birimleri (ISO 4217)               |
| `catalog`      | `countries`                            | Ülke sözlüğü                            |
| `catalog`      | `languages`                            | Desteklenen diller                      |
| `catalog`      | `localization_keys`                    | Lokalizasyon anahtar tanımları          |
| `catalog`      | `localization_values`                  | Lokalizasyon çevirileri                 |
| `catalog`      | `transaction_types`                    | BET, WIN, BONUS, DEPOSIT vb.            |
| `catalog`      | `operation_types`                      | DEBIT / CREDIT                          |
| `routing`      | `callback_routes`                      | tenant bazlı callback yönlendirme       |
| `routing`      | `provider_callbacks`                   | Provider callback tanımları             |
| `routing`      | `provider_endpoints`                   | Provider API / endpoint bilgileri       |
| `security`     | `permissions`                          | Sistem yetki tanımları                  |
| `security`     | `secrets_provider`                     | Provider API key ve secret'ları         |
| `security`     | `secrets_tenant`                       | Tenant özel secret'ları                 |
| `security`     | `tenant_roles`                         | Tenant bazlı rol tanımları              |
| `security`     | `role_permissions`                     | Rol-yetki eşleştirmeleri                |
| `security`     | `users`                                | Backoffice kullanıcıları                |
| `security`     | `user_roles`                           | Kullanıcı-rol atamaları                 |
| `presentation` | `contexts`                             | UI context tanımları                    |
| `presentation` | `menu_groups`                          | Menü grup yapısı                        |
| `presentation` | `menus`                                | Ana menü tanımları                      |
| `presentation` | `submenus`                             | Alt menü tanımları                      |
| `presentation` | `pages`                                | Sayfa tanımları                         |
| `presentation` | `tabs`                                 | Tab yapılandırması                      |
| `billing`      | `provider_commission_rates`            | Provider komisyon oranları              |
| `billing`      | `tenant_provider_commission_overrides` | Tenant bazlı komisyon override'ları     |
| `billing`      | `tenant_commissions`                   | Tenant komisyon hesaplamaları           |
| `affiliate`    | `traffic_sources`                      | Trafik kaynak tanımları                 |
| `affiliate`    | `campaigns`                            | Kampanya tanımları                      |
| `affiliate`    | `attribution_models`                   | Attribution model konfigürasyonları     |

---

### 2.2 Core Log DB

| Özellik       | Değer                                |
| ------------- | ------------------------------------ |
| **DB Adı**    | `core_log`                           |
| **Amaç**      | Platform geneli teknik log kayıtları |
| **Partition** | Daily                                |
| **Retention** | 30–90 gün                            |
| **İçerik**    | ERROR, WARN, INFO seviye loglar      |

---

### 2.3 Core Audit DB

| Özellik       | Değer                             |
| ------------- | --------------------------------- |
| **DB Adı**    | `core_audit`                      |
| **Amaç**      | Platform seviyesi karar kayıtları |
| **Partition** | ❌                                |
| **Retention** | 5–10 yıl (regülasyon)             |

**İçerik:**

- Tenant lifecycle değişiklikleri
- Gateway enable/disable kararları
- Kullanıcı yetki değişiklikleri

---

### 2.4 Core Report DB

| Özellik       | Değer                            |
| ------------- | -------------------------------- |
| **DB Adı**    | `core_report`                    |
| **Amaç**      | Merkezi raporlama ve BI verileri |
| **Partition** | Opsiyonel                        |
| **Retention** | İş ihtiyacına bağlı              |

**İçerik:**

- Platform geneli istatistikler
- Tenant karşılaştırma raporları
- Finansal özet veriler

---

## 3. Gateway Katmanı (Merkezi – Entegrasyon)

Gateway katmanı, oyun ve finans provider'ları ile entegrasyonu yönetir.

### 3.1 Game DB

| Özellik       | Değer                           |
| ------------- | ------------------------------- |
| **DB Adı**    | `game`                          |
| **Amaç**      | Game gateway entegrasyon durumu |
| **Partition** | Daily                           |
| **Retention** | 14–30 gün                       |

---

### 3.2 Game Log DB

| Özellik          | Değer                                    |
| ---------------- | ---------------------------------------- |
| **DB Adı**       | `game_log`                               |
| **Amaç**         | Tüm tenant'lara ait game gateway logları |
| **Partition**    | Daily                                    |
| **Retention**    | 7–14 gün                                 |
| **Yüksek Hacim** | ✅ (DROP partition zorunlu)              |

---

### 3.3 Finance DB

| Özellik       | Değer                              |
| ------------- | ---------------------------------- |
| **DB Adı**    | `finance`                          |
| **Amaç**      | Finance gateway entegrasyon durumu |
| **Partition** | Daily                              |
| **Retention** | 14–30 gün                          |

---

### 3.4 Finance Log DB

| Özellik          | Değer                                       |
| ---------------- | ------------------------------------------- |
| **DB Adı**       | `finance_log`                               |
| **Amaç**         | Tüm tenant'lara ait finance gateway logları |
| **Partition**    | Daily                                       |
| **Retention**    | 14–30 gün                                   |
| **Yüksek Hacim** | ✅ (DROP partition zorunlu)                 |

---

## 4. Tenant Katmanı (İzole – Kiracıya Özel)

Her tenant için ayrı bir veritabanı oluşturulur. `tenant` şablon DB'si klonlanarak `tenant_<code>` formatında oluşturulur.

### 4.1 Tenant MainDB

| Özellik            | Değer                                                      |
| ------------------ | ---------------------------------------------------------- |
| **DB Adı**         | `tenant` / `tenant_<code>`                                 |
| **Amaç**           | Kiracıya özel iş verileri (oyuncular, cüzdanlar, işlemler) |
| **Tenant Bağımlı** | ✅                                                         |
| **Partition**      | Monthly (transactions)                                     |
| **Retention**      | Sınırsız                                                   |

#### Tablolar

| Şema          | Tablo                          | Açıklama                                                    |
| ------------- | ------------------------------ | ----------------------------------------------------------- |
| `auth`        | `players`                      | Ana oyuncu kaydı                                            |
| `auth`        | `player_categories`            | Oyuncu kategori tanımları                                   |
| `auth`        | `player_classification`        | Oyuncu sınıflandırma atamaları                              |
| `auth`        | `player_credentials`           | Oyuncu giriş bilgileri                                      |
| `auth`        | `player_groups`                | Oyuncu grup tanımları                                       |
| `profile`     | `player_identity`              | Oyuncu kimlik bilgileri (TC, doğum tarihi) ⚠️ KYC şifreleme |
| `profile`     | `player_profile`               | Oyuncu profil detayları (adres, telefon) ⚠️ KYC şifreleme   |
| `wallet`      | `wallets`                      | Oyuncu cüzdanları ve bakiyeleri                             |
| `wallet`      | `wallet_snapshots`             | Cüzdan anlık görüntüleri (audit için)                       |
| `transaction` | `transactions`                 | Tüm finansal işlemler                                       |
| `transaction` | `transaction_workflows`        | İşlem workflow tanımları                                    |
| `transaction` | `transaction_workflow_actions` | Workflow aksiyon kayıtları                                  |
| `finance`     | `operation_types`              | Operasyon tipi tanımları                                    |
| `finance`     | `transaction_types`            | İşlem tipi tanımları                                        |
| `finance`     | `currency_rates`               | Döviz kuru geçmişi                                          |
| `kyc`         | `player_kyc_cases`             | KYC vaka kayıtları                                          |
| `kyc`         | `player_kyc_workflows`         | KYC süreç adımları                                          |
| `kyc`         | `player_documents`             | Oyuncu belge yüklemeleri                                    |
| `kyc`         | `player_kyc_provider_logs`     | KYC provider entegrasyon logları                            |
| `marketing`   | `player_acquisition`           | Oyuncu edinim kaynakları                                    |
| `affiliate`   | `affiliates`                   | Affiliate tanımları                                         |
| `affiliate`   | `affiliate_network`            | Affiliate ağ yapısı (MLM)                                   |
| `affiliate`   | `commission_plans`             | Komisyon planları                                           |
| `affiliate`   | `commission_tiers`             | Komisyon kademeleri                                         |
| `affiliate`   | `affiliate_campaigns`          | Affiliate kampanyaları                                      |
| `affiliate`   | `player_affiliate_current`     | Oyuncunun aktif affiliate'i                                 |
| `affiliate`   | `player_affiliate_history`     | Affiliate değişiklik geçmişi                                |
| `affiliate`   | `network_commission_rules`     | MLM komisyon kuralları                                      |
| `affiliate`   | `commissions`                  | Hesaplanan komisyonlar                                      |
| `affiliate`   | `affiliate_users`              | Affiliate kullanıcıları                                     |
| `affiliate`   | `payout_requests`              | Ödeme talepleri                                             |
| `affiliate`   | `payouts`                      | Gerçekleşen ödemeler                                        |

#### Views

| Şema      | View                 | Açıklama                      |
| --------- | -------------------- | ----------------------------- |
| `finance` | `v_daily_base_rates` | Günlük baz kur görünümü       |
| `finance` | `v_cross_rates`      | Çapraz kur hesaplama görünümü |

---

### 4.2 Tenant Log DB

| Özellik          | Değer                              |
| ---------------- | ---------------------------------- |
| **DB Adı**       | `tenant_log` / `tenant_log_<code>` |
| **Amaç**         | Kiracıya özel operasyonel loglar   |
| **Partition**    | Daily                              |
| **Retention**    | 30–90 gün                          |
| **Yüksek Hacim** | ✅ (DROP partition zorunlu)        |

---

### 4.3 Tenant Audit DB

| Özellik       | Değer                                  |
| ------------- | -------------------------------------- |
| **DB Adı**    | `tenant_audit` / `tenant_audit_<code>` |
| **Amaç**      | Kiracıya özel audit kayıtları          |
| **Partition** | ❌ / Yearly                            |
| **Retention** | 5–10 yıl (regülasyon)                  |

**İçerik:**

- Oyuncu durum değişiklikleri
- Yetkili kullanıcı aksiyonları
- Finansal onay/ret kararları

> ⚠️ Audit verileri **silinmez**. Regülasyon gereği 5–10 yıl saklanır.

---

### 4.4 Tenant Report DB

| Özellik       | Değer                                    |
| ------------- | ---------------------------------------- |
| **DB Adı**    | `tenant_report` / `tenant_report_<code>` |
| **Amaç**      | Kiracıya özel raporlar ve istatistikler  |
| **Partition** | Opsiyonel                                |
| **Retention** | İş ihtiyacına bağlı                      |

**İçerik:**

- Oyuncu aktivite raporları
- Gelir/gider analizleri
- Affiliate performans raporları

---

## 5. Veritabanı Özet Matrisi

| Veritabanı      | Amaç                                       | Tenant Bağımsız | Partition | Retention   |
| --------------- | ------------------------------------------ | --------------- | --------- | ----------- |
| `core`          | Platform yapılandırması ve merkezi veriler | ✅              | ❌        | Sınırsız    |
| `core_log`      | Merkezi teknik log kayıtları               | ✅              | Daily     | 30–90 gün   |
| `core_audit`    | Platform karar ve değişiklik audit         | ✅              | ❌        | 5–10 yıl    |
| `core_report`   | Merkezi raporlama ve BI verileri           | ✅              | Opsiyonel | İş ihtiyacı |
| `game`          | Oyun gateway entegrasyon durumu            | ✅              | Daily     | 14–30 gün   |
| `game_log`      | Oyun gateway teknik logları                | ✅              | Daily     | 7–14 gün    |
| `finance`       | Finans gateway entegrasyon durumu          | ✅              | Daily     | 14–30 gün   |
| `finance_log`   | Finans gateway teknik logları              | ✅              | Daily     | 14–30 gün   |
| `tenant`        | Kiracıya özel iş verileri                  | ❌              | Monthly   | Sınırsız    |
| `tenant_log`    | Kiracıya özel operasyonel loglar           | ❌              | Daily     | 30–90 gün   |
| `tenant_audit`  | Kiracıya özel audit kayıtları              | ❌              | Yearly    | 5–10 yıl    |
| `tenant_report` | Kiracıya özel raporlar ve istatistikler    | ❌              | Opsiyonel | İş ihtiyacı |

---

## 6. Multi-Tenant Mimari Diyagramı

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            CORE VERİTABANLARI                               │
│         (Merkezi: Şirketler, Tenantlar, Katalog, Güvenlik, Routing)         │
├─────────────────────────────────────────────────────────────────────────────┤
│  core   │  core_log  │  core_audit  │  core_report                          │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
┌────────────────────────────────┼────────────────────────────────────────────┐
│                        GATEWAY VERİTABANLARI                                │
│                  (Game & Finance Provider Entegrasyonu)                     │
├─────────────────────────────────────────────────────────────────────────────┤
│  game   │  game_log  │  finance  │  finance_log                             │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
                 ┌───────────────┼───────────────┐
                 ▼               ▼               ▼
          ┌────────────┐   ┌────────────┐   ┌────────────┐
          │ tenant_001 │   │ tenant_002 │   │ tenant_XXX │
          │ (Oyuncular │   │ (Oyuncular │   │ (Oyuncular │
          │  Cüzdanlar │   │  Cüzdanlar │   │  Cüzdanlar │
          │  İşlemler) │   │  İşlemler) │   │  İşlemler) │
          ├────────────┤   ├────────────┤   ├────────────┤
          │tenant_log  │   │tenant_log  │   │tenant_log  │
          │tenant_audit│   │tenant_audit│   │tenant_audit│
          │tenant_report   │tenant_report   │tenant_report
          └────────────┘   └────────────┘   └────────────┘
```

---

## 7. PostgreSQL Extension'ları

Tüm veritabanlarında `infra` şemasında aşağıdaki extension'lar etkindir:

| Extension            | Amaç                            |
| -------------------- | ------------------------------- |
| `pgcrypto`           | Şifreleme fonksiyonları         |
| `uuid-ossp`          | UUID üretimi                    |
| `pg_stat_statements` | Query performans istatistikleri |
| `btree_gin`          | B-tree GIN index desteği        |
| `btree_gist`         | B-tree GiST index desteği       |
| `tablefunc`          | Pivot ve crosstab fonksiyonları |
| `citext`             | Case-insensitive text tipi      |

---

## 8. Deploy Scriptleri

| Script              | Amaç                                |
| ------------------- | ----------------------------------- |
| `create_dbs.sql`    | Veritabanı oluşturma                |
| `deploy_core.sql`   | Core veritabanı şema ve tabloları   |
| `deploy_tenant.sql` | Tenant veritabanı şema ve tabloları |

---

## 9. Retention ve DROP Stratejisi

### 9.1 DROP Zorunlu DB'ler (Yüksek Hacim)

| DB                  | Sebep                                                     |
| ------------------- | --------------------------------------------------------- |
| `game_log`          | Yüksek hacimli event flood (game launch, callback, retry) |
| `finance_log`       | Yoğun callback ve provider response trafiği               |
| `core_log`          | Platform genelinde üretilen teknik loglar                 |
| `tenant_log_<code>` | Tenant bazlı operasyonel ve teknik hatalar                |

### 9.2 Retention Kuralları

- `DELETE` **kullanılmaz** → Doğrudan **partition DROP edilir**
- Audit verileri **silinmez** (regülasyon)
- Log retention = **fiziksel silme**
- Minimum retention: ERROR log'lar → en az 7 gün

---

## 10. Altın Kurallar

> **"Core paylaşılır, tenant izole edilir."**

> **"Log kısa ömürlüdür, audit kalıcıdır."**

> **"Her tenant için ayrı veritabanı = tam izolasyon."**

> **"Log retention süresi dolduysa, partition silinir; silinmeyen log teknik borçtur."**

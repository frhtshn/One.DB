# NUCLEO – VERİTABANI YAPISI

## Veritabanı Mimarisi ve Şema Organizasyonu

Bu doküman, **Nucleo platformunun** tüm veritabanlarını, şemalarını ve tablolarını  
sistematik bir şekilde açıklar. Multi-tenant mimari temel alınarak tasarlanmıştır.

---

## 1. Veritabanı Genel Özeti

| Veritabanı        | Amaç                                             | Tenant Bağımsız | Partition |
| ----------------- | ------------------------------------------------ | --------------- | --------- |
| **core**          | Platform yapılandırması ve merkezi veriler       | ✅              | ❌        |
| **core_log**      | Merkezi teknik log kayıtları                     | ✅              | Daily     |
| **core_audit**    | Platform karar ve değişiklik audit               | ✅              | ❌        |
| **core_report**   | Merkezi raporlama ve BI verileri                 | ✅              | Opsiyonel |
| **tenant**        | Kiracıya özel iş verileri (oyuncular, cüzdanlar) | ❌              | Monthly   |
| **tenant_log**    | Kiracıya özel operasyonel loglar                 | ❌              | Daily     |
| **tenant_audit**  | Kiracıya özel audit kayıtları                    | ❌              | Yearly    |
| **tenant_report** | Kiracıya özel raporlar ve istatistikler          | ❌              | Opsiyonel |
| **game**          | Oyun gateway entegrasyon durumu                  | ✅              | Daily     |
| **game_log**      | Oyun gateway teknik logları                      | ✅              | Daily     |
| **finance**       | Finans gateway entegrasyon durumu                | ✅              | Daily     |
| **finance_log**   | Finans gateway teknik logları                    | ✅              | Daily     |

---

## 2. Multi-Tenant Mimari Prensibi

```
┌─────────────────────────────────────────────────────────────┐
│                      CORE VERİTABANI                        │
│  (Merkezi: Şirketler, Tenantlar, Katalog, Güvenlik)         │
└──────────────────────────┬──────────────────────────────────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌────────────┐   ┌────────────┐   ┌────────────┐
    │ tenant_001 │   │ tenant_002 │   │ tenant_XXX │
    │ (Oyuncular │   │ (Oyuncular │   │ (Oyuncular │
    │  Cüzdanlar │   │  Cüzdanlar │   │  Cüzdanlar │
    │  İşlemler) │   │  İşlemler) │   │  İşlemler) │
    └────────────┘   └────────────┘   └────────────┘
```

> Her tenant için ayrı bir veritabanı klonlanır.  
> Core veritabanı tüm tenantlar arasında paylaşılır.

---

## 3. CORE Veritabanı Yapısı

Core veritabanı, platformun merkezi konfigürasyon ve yönetim verilerini barındırır.

### 3.1 Şema Listesi

| Şema           | Amaç                                        |
| -------------- | ------------------------------------------- |
| `catalog`      | Referans ve master data                     |
| `core`         | Tenant ve şirket bilgileri                  |
| `presentation` | Backoffice UI yapılandırması                |
| `routing`      | Provider endpoint ve callback yönlendirmesi |
| `security`     | Kullanıcı, rol ve yetki yönetimi            |
| `billing`      | Komisyon ve faturalandırma                  |
| `affiliate`    | Affiliate platform yapılandırması           |
| `infra`        | PostgreSQL extension'ları                   |

---

### 3.2 catalog Şeması

Referans dataları içerir. **Read-only** karakterlidir.

| Tablo                 | Açıklama                         |
| --------------------- | -------------------------------- |
| `countries`           | Ülke listesi ve kodları          |
| `currencies`          | Para birimi tanımları            |
| `games`               | Oyun kataloğu                    |
| `languages`           | Desteklenen diller               |
| `localization_keys`   | Lokalizasyon anahtar tanımları   |
| `localization_values` | Lokalizasyon çevirileri          |
| `operation_types`     | Operasyon tipi tanımları         |
| `provider_settings`   | Provider yapılandırma şablonları |
| `provider_types`      | Provider tip kategorileri        |
| `providers`           | Provider (oyun/ödeme) tanımları  |
| `transaction_types`   | İşlem tipi tanımları             |

---

### 3.3 core Şeması

Tenant ve şirket yönetimi.

| Tablo               | Açıklama                        |
| ------------------- | ------------------------------- |
| `companies`         | Platform operatör şirketleri    |
| `tenants`           | Tenant (marka/site) tanımları   |
| `tenant_currencies` | Tenant'a tanımlı para birimleri |
| `tenant_games`      | Tenant'a açık oyunlar           |
| `tenant_languages`  | Tenant'a tanımlı diller         |
| `tenant_providers`  | Tenant-provider eşleştirmeleri  |
| `tenant_settings`   | Tenant özel konfigürasyonları   |

---

### 3.4 security Şeması

Backoffice kullanıcı ve yetki yönetimi.

| Tablo              | Açıklama                        |
| ------------------ | ------------------------------- |
| `permissions`      | Sistem yetki tanımları          |
| `secrets_provider` | Provider API key ve secret'ları |
| `secrets_tenant`   | Tenant özel secret'ları         |
| `tenant_roles`     | Tenant bazlı rol tanımları      |
| `role_permissions` | Rol-yetki eşleştirmeleri        |
| `users`            | Backoffice kullanıcıları        |
| `user_roles`       | Kullanıcı-rol atamaları         |

---

### 3.5 presentation Şeması

Backoffice UI yapılandırması.

| Tablo         | Açıklama             |
| ------------- | -------------------- |
| `contexts`    | UI context tanımları |
| `menu_groups` | Menü grup yapısı     |
| `menus`       | Ana menü tanımları   |
| `submenus`    | Alt menü tanımları   |
| `pages`       | Sayfa tanımları      |
| `tabs`        | Tab yapılandırması   |

---

### 3.6 routing Şeması

Provider endpoint yönetimi.

| Tablo                | Açıklama                       |
| -------------------- | ------------------------------ |
| `callback_routes`    | Callback yönlendirme kuralları |
| `provider_callbacks` | Provider callback tanımları    |
| `provider_endpoints` | Provider API endpoint'leri     |

---

### 3.7 billing Şeması

Komisyon ve faturalandırma.

| Tablo                                  | Açıklama                            |
| -------------------------------------- | ----------------------------------- |
| `provider_commission_rates`            | Provider komisyon oranları          |
| `tenant_provider_commission_overrides` | Tenant bazlı komisyon override'ları |
| `tenant_commissions`                   | Tenant komisyon hesaplamaları       |

---

### 3.8 affiliate Şeması (Core)

Affiliate platform yapılandırması.

| Tablo                | Açıklama                            |
| -------------------- | ----------------------------------- |
| `traffic_sources`    | Trafik kaynak tanımları             |
| `campaigns`          | Kampanya tanımları                  |
| `attribution_models` | Attribution model konfigürasyonları |

---

## 4. TENANT Veritabanı Yapısı

Her tenant için ayrı bir veritabanı oluşturulur. Bu veritabanı oyuncu verilerini,  
cüzdanları, işlemleri ve kiracıya özel tüm business verilerini barındırır.

### 4.1 Şema Listesi

| Şema          | Amaç                              |
| ------------- | --------------------------------- |
| `auth`        | Oyuncu kimlik doğrulama           |
| `profile`     | Oyuncu profil bilgileri           |
| `wallet`      | Oyuncu cüzdanları                 |
| `transaction` | Finansal işlemler                 |
| `finance`     | Finansal referans verileri        |
| `marketing`   | Pazarlama ve edinim verileri      |
| `kyc`         | KYC doğrulama süreçleri           |
| `affiliate`   | Affiliate yönetimi ve komisyonlar |
| `infra`       | PostgreSQL extension'ları         |

---

### 4.2 auth Şeması

Oyuncu kimlik ve erişim yönetimi.

| Tablo                   | Açıklama                       |
| ----------------------- | ------------------------------ |
| `players`               | Ana oyuncu kaydı               |
| `player_categories`     | Oyuncu kategori tanımları      |
| `player_classification` | Oyuncu sınıflandırma atamaları |
| `player_credentials`    | Oyuncu giriş bilgileri         |
| `player_groups`         | Oyuncu grup tanımları          |

---

### 4.3 profile Şeması

Oyuncu profil ve kişisel bilgileri.

| Tablo             | Açıklama                                   |
| ----------------- | ------------------------------------------ |
| `player_identity` | Oyuncu kimlik bilgileri (TC, doğum tarihi) |
| `player_profile`  | Oyuncu profil detayları (adres, telefon)   |

> ⚠️ **Önemli**: Bu tablolar KYC uyumlu şifreleme gerektirir.

---

### 4.4 wallet Şeması

Oyuncu cüzdan yönetimi.

| Tablo              | Açıklama                              |
| ------------------ | ------------------------------------- |
| `wallets`          | Oyuncu cüzdanları ve bakiyeleri       |
| `wallet_snapshots` | Cüzdan anlık görüntüleri (audit için) |

---

### 4.5 transaction Şeması

Finansal işlem kayıtları.

| Tablo                          | Açıklama                   |
| ------------------------------ | -------------------------- |
| `transactions`                 | Tüm finansal işlemler      |
| `transaction_workflows`        | İşlem workflow tanımları   |
| `transaction_workflow_actions` | Workflow aksiyon kayıtları |

---

### 4.6 finance Şeması

Finansal referans verileri.

| Tablo               | Açıklama                 |
| ------------------- | ------------------------ |
| `operation_types`   | Operasyon tipi tanımları |
| `transaction_types` | İşlem tipi tanımları     |
| `currency_rates`    | Döviz kuru geçmişi       |

**Views:**

- `v_daily_base_rates` – Günlük baz kur görünümü
- `v_cross_rates` – Çapraz kur hesaplama görünümü

---

### 4.7 kyc Şeması

KYC (Know Your Customer) doğrulama süreçleri.

| Tablo                      | Açıklama                         |
| -------------------------- | -------------------------------- |
| `player_kyc_cases`         | KYC vaka kayıtları               |
| `player_kyc_workflows`     | KYC süreç adımları               |
| `player_documents`         | Oyuncu belge yüklemeleri         |
| `player_kyc_provider_logs` | KYC provider entegrasyon logları |

---

### 4.8 affiliate Şeması (Tenant)

Affiliate yönetimi ve komisyon takibi.

| Tablo                      | Açıklama                     |
| -------------------------- | ---------------------------- |
| `affiliates`               | Affiliate tanımları          |
| `affiliate_network`        | Affiliate ağ yapısı (MLM)    |
| `commission_plans`         | Komisyon planları            |
| `commission_tiers`         | Komisyon kademeleri          |
| `affiliate_campaigns`      | Affiliate kampanyaları       |
| `player_affiliate_current` | Oyuncunun aktif affiliate'i  |
| `player_affiliate_history` | Affiliate değişiklik geçmişi |
| `network_commission_rules` | MLM komisyon kuralları       |
| `commissions`              | Hesaplanan komisyonlar       |
| `affiliate_users`          | Affiliate kullanıcıları      |
| `payout_requests`          | Ödeme talepleri              |
| `payouts`                  | Gerçekleşen ödemeler         |

---

### 4.9 marketing Şeması

Pazarlama ve oyuncu edinim takibi.

| Tablo                | Açıklama                 |
| -------------------- | ------------------------ |
| `player_acquisition` | Oyuncu edinim kaynakları |

---

## 5. LOG Veritabanları

### 5.1 core_log

Platform geneli teknik log kayıtları.

- **Partition**: Daily
- **Retention**: 30–90 gün
- **İçerik**: ERROR, WARN, INFO seviye loglar

### 5.2 tenant_log

Kiracıya özel operasyonel loglar.

- **Partition**: Daily
- **Retention**: 30–90 gün
- **Veritabanı Adı**: `tenant_log_<code>` formatında

### 5.3 game_log / finance_log

Gateway entegrasyon logları.

- **Partition**: Daily
- **Retention**: 7–14 gün
- **Yüksek hacim** nedeniyle DROP partition zorunlu

---

## 6. AUDIT Veritabanları

### 6.1 core_audit

Platform seviyesi karar kayıtları.

- Tenant lifecycle değişiklikleri
- Gateway enable/disable kararları
- Kullanıcı yetki değişiklikleri

### 6.2 tenant_audit

Kiracıya özel audit kayıtları.

- Oyuncu durum değişiklikleri
- Yetkili kullanıcı aksiyonları
- Finansal onay/ret kararları

> ⚠️ Audit verileri **silinmez**. Regülasyon gereği 5–10 yıl saklanır.

---

## 7. REPORT Veritabanları

### 7.1 core_report

Merkezi raporlama ve BI verileri.

- Platform geneli istatistikler
- Tenant karşılaştırma raporları
- Finansal özet veriler

### 7.2 tenant_report

Kiracıya özel raporlama.

- Oyuncu aktivite raporları
- Gelir/gider analizleri
- Affiliate performans raporları

---

## 8. PostgreSQL Extension'ları

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

## 9. Veritabanı Oluşturma

Yeni kurulumda veritabanları `create_dbs.sql` scripti ile oluşturulur:

```sql
-- Core veritabanı
CREATE DATABASE core;

-- Tenant şablon veritabanı
CREATE DATABASE tenant;
```

Yeni tenant eklendiğinde, `tenant` veritabanı klonlanarak `tenant_<code>` oluşturulur.

---

## 10. Deploy Scriptleri

| Script              | Amaç                                |
| ------------------- | ----------------------------------- |
| `deploy_core.sql`   | Core veritabanı şema ve tabloları   |
| `deploy_tenant.sql` | Tenant veritabanı şema ve tabloları |
| `create_dbs.sql`    | Veritabanı oluşturma                |

---

## 11. Altın Kurallar

> **"Core paylaşılır, tenant izole edilir."**

> **"Log kısa ömürlüdür, audit kalıcıdır."**

> **"Her tenant için ayrı veritabanı = tam izolasyon."**

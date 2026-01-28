# NUCLEO – VERİTABANI MİMARİSİ

Bu doküman, **Nucleo platformunun** tüm veritabanlarını, şemalarını ve tablolarını sistematik bir şekilde açıklar.

---

## 1. Genel Mimari Prensipler

- Sistem **multi-tenant (whitelabel)** çalışır
- Her whitelabel **tam veri izolasyonuna** sahiptir
- Operasyonel veriler, raporlar ve loglar **farklı DB'lerde** tutulur
- Hiçbir DB birden fazla sorumluluk taşımaz
- Tüm yazma yetkileri **kontrollü ve tekil servisler** üzerinden yapılır
- Log verileri **kısa ömürlüdür**, audit verileri **kalıcıdır**

---

## 2. Multi-Tenant Mimari Diyagramı

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            CORE & PLUGIN (SHARED)                           │
│         (Merkezi: Şirketler, Tenantlar, Katalog, Bonus, Routing)            │
├─────────────────────────────────────────────────────────────────────────────┤
│  core   │  core_log  │  core_audit  │  bonus (Plugin)                       │
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
          │  Cüzdanlar)│   │  Cüzdanlar)│   │  Cüzdanlar)│
          ├────────────┤   ├────────────┤   ├────────────┤
          │tenant_log  │   │tenant_log  │   │tenant_log  │
          │tenant_audit│   │tenant_audit│   │tenant_audit│
          │t_affiliate │   │t_affiliate │   │t_affiliate │
          └────────────┘   └────────────┘   └────────────┘
```

> Her tenant için ayrı bir veritabanı klonlanır. Core veritabanı tüm tenantlar arasında paylaşılır.

---

## 3. Veritabanı Özet Matrisi

| #   | Veritabanı         | Amaç                                                      | Tenant Bağımsız | Partition | Retention   |
| --- | ------------------ | --------------------------------------------------------- | --------------- | --------- | ----------- |
| 1   | `core`             | Platform yapılandırması ve merkezi veriler                | ✅              | ❌        | Sınırsız    |
| 2   | `core_log`         | Merkezi teknik log kayıtları                              | ✅              | Daily     | 30–90 gün   |
| 3   | `core_audit`       | Platform karar ve değişiklik audit                        | ✅              | ❌        | 5–10 yıl    |
| 4   | `core_report`      | Merkezi raporlama ve BI verileri                          | ✅              | Opsiyonel | İş ihtiyacı |
| 5   | `game`             | Oyun gateway entegrasyon durumu                           | ✅              | Daily     | 14–30 gün   |
| 6   | `game_log`         | Oyun gateway teknik logları                               | ✅              | Daily     | 7–14 gün    |
| 7   | `finance`          | Finans gateway entegrasyon durumu                         | ✅              | Daily     | 14–30 gün   |
| 8   | `finance_log`      | Finans gateway teknik logları                             | ✅              | Daily     | 14–30 gün   |
| 9   | `bonus`            | Bonus ve promosyon yapılandırması                         | ✅              | ❌        | Sınırsız    |
| 10  | `tenant`           | Kiracıya özel iş verileri                                 | ❌              | Monthly   | Sınırsız    |
| 11  | `tenant_affiliate` | Affiliate tracking ve komisyon yönetimi                   | ❌              | Monthly   | Sınırsız    |
| 12  | `tenant_log`       | Kiracıya özel operasyonel loglar (dahil: `affiliate_log`) | ❌              | Daily     | 30–90 gün   |
| 13  | `tenant_audit`     | Kiracıya özel audit kayıtları (dahil: `affiliate_audit`)  | ❌              | Yearly    | 5–10 yıl    |
| 14  | `tenant_report`    | Kiracıya özel raporlar ve istatistikler                   | ❌              | Opsiyonel | İş ihtiyacı |

---

## 4. Core Veritabanı

Core veritabanı, platformun merkezi konfigürasyon ve yönetim verilerini barındırır. **Globaldir**, **read-heavy** çalışır ve **finansal state tutmaz**.

### 4.1 Şema Listesi

| Şema           | Amaç                                        |
| -------------- | ------------------------------------------- |
| `catalog`      | Referans ve master data                     |
| `core`         | Tenant ve şirket bilgileri                  |
| `presentation` | Backoffice UI yapılandırması                |
| `routing`      | Provider endpoint ve callback yönlendirmesi |
| `security`     | Kullanıcı, rol ve yetki yönetimi            |
| `billing`      | Komisyon ve faturalandırma                  |
| `infra`        | PostgreSQL extension'ları                   |

---

### 4.2 catalog Şeması

Referans dataları içerir. **Read-only** karakterlidir.

| Tablo                 | Açıklama                                   |
| --------------------- | ------------------------------------------ |
| `countries`           | Ülke listesi ve kodları                    |
| `currencies`          | Para birimi tanımları (ISO 4217)           |
| `games`               | Global oyun kataloğu                       |
| `languages`           | Desteklenen diller                         |
| `localization_keys`   | Lokalizasyon anahtar tanımları             |
| `localization_values` | Lokalizasyon çevirileri                    |
| `operation_types`     | Operasyon tipi tanımları (DEBIT/CREDIT)    |
| `payment_methods`     | Finance provider ödeme metodları kataloğu  |
| `provider_settings`   | Provider yapılandırma şablonları           |
| `provider_types`      | Provider tip kategorileri (GAME/FINANCE)   |
| `providers`           | Provider (oyun/ödeme) tanımları            |
| `timezones`           | Saat dilimi referans kataloğu              |
| `transaction_types`   | İşlem tipi tanımları (BET, WIN, BONUS vb.) |

---

### 4.3 core Şeması

Tenant ve şirket yönetimi.

| Tablo                    | Açıklama                                           |
| ------------------------ | -------------------------------------------------- |
| `companies`              | Platform operatör şirketleri (faturalama seviyesi) |
| `tenants`                | Tenant (marka/site) tanımları                      |
| `tenant_currencies`      | Tenant'a tanımlı para birimleri                    |
| `tenant_games`           | Tenant'a açık oyunlar                              |
| `tenant_languages`       | Tenant'a tanımlı diller                            |
| `tenant_payment_methods` | Tenant'a açık ödeme metodları                      |
| `tenant_providers`       | Tenant-provider eşleştirmeleri                     |
| `tenant_provider_limits` | Provider'ın tenant için belirlediği limitler       |
| `tenant_settings`        | Tenant özel konfigürasyonları                      |

---

### 4.4 security Şeması

Backoffice kullanıcı ve yetki yönetimi.

| Tablo              | Açıklama                                                   |
| ------------------ | ---------------------------------------------------------- |
| `permissions`      | Sistem yetki tanımları                                     |
| `secrets_provider` | Provider API key ve secret'ları (global)                   |
| `secrets_tenant`   | Tenant özel secret'ları (environment: prod/staging/shadow) |
| `tenant_roles`     | Tenant bazlı rol tanımları                                 |
| `role_permissions` | Rol-yetki eşleştirmeleri                                   |
| `users`            | Backoffice kullanıcıları                                   |
| `user_roles`       | Kullanıcı-rol atamaları                                    |

---

### 4.5 presentation Şeması

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

### 4.6 routing Şeması

Provider endpoint yönetimi.

| Tablo                | Açıklama                       |
| -------------------- | ------------------------------ |
| `callback_routes`    | Callback yönlendirme kuralları |
| `provider_callbacks` | Provider callback tanımları    |
| `provider_endpoints` | Provider API endpoint'leri     |

---

### 4.7 billing Şeması

Komisyon ve faturalandırma.

| Tablo                          | Açıklama                      |
| ------------------------------ | ----------------------------- |
| `provider_commission_rates`    | Provider komisyon oranları    |
| `provider_commission_tiers`    | Provider komisyon kademeleri  |
| `provider_invoices`            | Provider faturaları           |
| `provider_invoice_items`       | Provider fatura kalemleri     |
| `provider_payments`            | Provider ödemeleri            |
| `provider_settlements`         | Provider mutabakatları        |
| `provider_settlement_tenants`  | Provider mutabakat dağılımı   |
| `tenant_billing_periods`       | Tenant fatura dönemleri       |
| `tenant_invoices`              | Tenant faturaları             |
| `tenant_invoice_items`         | Tenant fatura kalemleri       |
| `tenant_invoice_payments`      | Tenant fatura ödemeleri       |
| `tenant_commission_plans`      | Tenant komisyon planları      |
| `tenant_commission_rates`      | Tenant komisyon oranları      |
| `tenant_commission_tiers`      | Tenant komisyon kademeleri    |
| `tenant_commission_plan_tiers` | Tenant plan kademeleri        |
| `tenant_commission_rate_tiers` | Tenant oran kademeleri        |
| `tenant_commissions`           | Tenant komisyon hesaplamaları |
| `tenant_commission_aggregates` | Tenant komisyon özetleri      |

---

## 5. Gateway Veritabanları

Gateway katmanı, oyun ve finans provider'ları ile entegrasyonu yönetir.

### 5.1 Game DB

| Özellik       | Değer                           |
| ------------- | ------------------------------- |
| **DB Adı**    | `game`                          |
| **Amaç**      | Game gateway entegrasyon durumu |
| **Partition** | Daily                           |
| **Retention** | 14–30 gün                       |

### 5.2 Game Log DB

| Özellik          | Değer                                    |
| ---------------- | ---------------------------------------- |
| **DB Adı**       | `game_log`                               |
| **Amaç**         | Tüm tenant'lara ait game gateway logları |
| **Partition**    | Daily                                    |
| **Retention**    | 7–14 gün                                 |
| **Yüksek Hacim** | ✅ (DROP partition zorunlu)              |

### 5.3 Finance DB

| Özellik       | Değer                              |
| ------------- | ---------------------------------- |
| **DB Adı**    | `finance`                          |
| **Amaç**      | Finance gateway entegrasyon durumu |
| **Partition** | Daily                              |
| **Retention** | 14–30 gün                          |

### 5.4 Finance Log DB

| Özellik          | Değer                                       |
| ---------------- | ------------------------------------------- |
| **DB Adı**       | `finance_log`                               |
| **Amaç**         | Tüm tenant'lara ait finance gateway logları |
| **Partition**    | Daily                                       |
| **Retention**    | 14–30 gün                                   |
| **Yüksek Hacim** | ✅ (DROP partition zorunlu)                 |

---

## 6. Tenant Veritabanı

Her tenant için ayrı bir veritabanı oluşturulur. `tenant` şablon DB'si klonlanarak `tenant_<code>` formatında oluşturulur.

### 6.1 Şema Listesi

| Şema          | Amaç                            |
| ------------- | ------------------------------- |
| `auth`        | Oyuncu kimlik doğrulama         |
| `profile`     | Oyuncu profil bilgileri         |
| `wallet`      | Oyuncu cüzdanları               |
| `transaction` | Finansal işlemler               |
| `finance`     | Finansal referans verileri      |
| `game`        | Oyun konfigürasyonu ve ayarları |
| `kyc`         | KYC doğrulama süreçleri         |
| `bonus`       | Bonus uygulama ve takibi        |
| `content`     | İçerik ve FAQ yönetimi          |
| `infra`       | PostgreSQL extension'ları       |

---

### 6.2 auth Şeması

Oyuncu kimlik ve erişim yönetimi.

| Tablo                   | Açıklama                       |
| ----------------------- | ------------------------------ |
| `players`               | Ana oyuncu kaydı               |
| `player_categories`     | Oyuncu kategori tanımları      |
| `player_classification` | Oyuncu sınıflandırma atamaları |
| `player_credentials`    | Oyuncu giriş bilgileri         |
| `player_groups`         | Oyuncu grup tanımları          |

---

### 6.3 profile Şeması

Oyuncu profil ve kişisel bilgileri.

| Tablo             | Açıklama                                   |
| ----------------- | ------------------------------------------ |
| `player_identity` | Oyuncu kimlik bilgileri (TC, doğum tarihi) |
| `player_profile`  | Oyuncu profil detayları (adres, telefon)   |

> ⚠️ **Önemli**: Bu tablolar KYC uyumlu şifreleme gerektirir.

---

### 6.4 game Şeması

Tenant-specific oyun konfigürasyonu.

| Tablo           | Açıklama                                        |
| --------------- | ----------------------------------------------- |
| `game_settings` | Oyun görünüm, sıralama ve özelleştirme ayarları |

> ⚠️ **Denormalizasyon**: Bu tablo core DB'den `game_id`, `game_code`, `provider_id`, `provider_code` alanlarını kopyalar. Cross-DB join yapılamadığı için gereklidir.

---

### 6.5 wallet Şeması

Oyuncu cüzdan yönetimi.

| Tablo              | Açıklama                              |
| ------------------ | ------------------------------------- |
| `wallets`          | Oyuncu cüzdanları ve bakiyeleri       |
| `wallet_snapshots` | Cüzdan anlık görüntüleri (audit için) |

---

### 6.6 transaction Şeması

Finansal işlem kayıtları.

| Tablo                          | Açıklama                   |
| ------------------------------ | -------------------------- |
| `transactions`                 | Tüm finansal işlemler      |
| `transaction_workflows`        | İşlem workflow tanımları   |
| `transaction_workflow_actions` | Workflow aksiyon kayıtları |

---

### 6.7 finance Şeması

Finansal referans verileri.

| Tablo                     | Açıklama                                      |
| ------------------------- | --------------------------------------------- |
| `operation_types`         | Operasyon tipi tanımları                      |
| `transaction_types`       | İşlem tipi tanımları                          |
| `payment_method_settings` | Ödeme metodu görünüm ve özelleştirme ayarları |
| `payment_method_limits`   | Tenant seviyesinde ödeme metodu limitleri     |
| `payment_player_limits`   | Oyuncu seviyesinde ödeme limitleri            |
| `currency_rates`          | Döviz kuru geçmişi                            |
| `currency_rates_latest`   | En son döviz kurları (cross-rate hesaplama)   |

**Views:**

| View                 | Açıklama                      |
| -------------------- | ----------------------------- |
| `v_daily_base_rates` | Günlük baz kur görünümü       |
| `v_cross_rates`      | Çapraz kur hesaplama görünümü |

> ⚠️ **Denormalizasyon**: `payment_method_settings` tablosu core DB'den `payment_method_id`, `payment_method_code`, `provider_id`, `provider_code` alanlarını kopyalar. Cross-DB join yapılamadığı için gereklidir.

> 💡 **Hiyerarşik Limitler**: Ödeme limitleri 3 seviyede yönetilir:
>
> 1. **Provider Limitleri** (`core.tenant_provider_limits`) - Provider'ın tenant için belirlediği limitler
> 2. **Tenant Limitleri** (`payment_method_limits`) - Tenant'ın kendi limitleri (provider limitleri içinde)
> 3. **Oyuncu Limitleri** (`payment_player_limits`) - Oyuncu bazlı limitler (tenant limitleri içinde)

---

### 6.8 kyc Şeması

KYC (Know Your Customer) doğrulama süreçleri.

| Tablo                      | Açıklama                         |
| -------------------------- | -------------------------------- |
| `player_kyc_cases`         | KYC vaka kayıtları               |
| `player_kyc_workflows`     | KYC süreç adımları               |
| `player_documents`         | Oyuncu belge yüklemeleri         |
| `player_kyc_provider_logs` | KYC provider entegrasyon logları |

---

### 6.9 content Şeması

CMS ve dinamik içerik yönetimi.

| Tablo                 | Açıklama                 |
| --------------------- | ------------------------ |
| `content_categories`  | İçerik kategori ağacı    |
| `content_types`       | İçerik tip tanımları     |
| `contents`            | Dinamik içerikler        |
| `content_versions`    | İçerik versiyon geçmişi  |
| `content_attachments` | Medya ve dosya ekleri    |
| `faq_categories`      | SSS kategorileri         |
| `faq_items`           | SSS soru-cevap kayıtları |
| `promotions`          | Promosyon tanımları      |
| `promotion_banners`   | Promosyon görselleri     |
| `promotion_locations` | Gösterim alanları        |
| `promotion_segments`  | Hedef kitle segmentleri  |
| `promotion_games`     | Dahil olan oyunlar       |

> 🌐 **Lokalizasyon**: Tüm tanımlar `_translations` tabloları ile çoklu dil desteğine sahiptir.

---

## 7. Log, Audit ve Report Veritabanları

### 7.1 Log Veritabanları

| DB                  | Partition | Retention | Not                                                          |
| ------------------- | --------- | --------- | ------------------------------------------------------------ |
| `core_log`          | Daily     | 30–90 gün | ERROR, WARN, INFO seviye loglar                              |
| `tenant_log_<code>` | Daily     | 30–90 gün | Kiracıya özel operasyonel loglar (Şema: `affiliate_log` vb.) |
| `game_log`          | Daily     | 7–14 gün  | Yüksek hacim - DROP zorunlu                                  |
| `finance_log`       | Daily     | 14–30 gün | Yüksek hacim - DROP zorunlu                                  |

### 7.2 Audit Veritabanları

| DB                    | İçerik                                                                         | Retention |
| --------------------- | ------------------------------------------------------------------------------ | --------- |
| `core_audit`          | Tenant lifecycle, gateway enable/disable, yetki değişiklikleri                 | 5–10 yıl  |
| `tenant_audit_<code>` | Oyuncu durum değişiklikleri, yetkili aksiyonları (Şema: `affiliate_audit` vb.) | 5–10 yıl  |

> ⚠️ Audit verileri **silinmez**. Regülasyon gereği 5–10 yıl saklanır.

### 7.3 Report Veritabanları

| DB                     | İçerik                                              |
| ---------------------- | --------------------------------------------------- |
| `core_report`          | Platform geneli istatistikler, tenant karşılaştırma |
| `tenant_report_<code>` | Oyuncu aktivite, gelir/gider, affiliate performans  |

> Detaylı retention stratejisi için: [LOGSTRATEGY.md](LOGSTRATEGY.md)

---

## 8. Tenant Affiliate Veritabanı (Plugin)

Affiliate sistemi **bağımsız bir plugin** olarak tasarlanmıştır. Her tenant için **ayrı bir veritabanı** olarak dağıtılır (`tenant_affiliate_XXX`).

### 8.1 Şema Listesi

| Şema         | Amaç                           |
| ------------ | ------------------------------ |
| `affiliate`  | Affiliate tanımları            |
| `campaign`   | Kampanya ve trafik kaynakları  |
| `commission` | Komisyon planları ve hesaplama |
| `payout`     | Ödeme talepleri ve ödemeler    |
| `tracking`   | Oyuncu-affiliate takibi        |
| `infra`      | PostgreSQL extension'ları      |

### 8.2 affiliate Şeması

Affiliate platform temel yapı taşları.

| Tablo               | Açıklama                    | Kritik Alanlar                                     |
| ------------------- | --------------------------- | -------------------------------------------------- |
| `affiliates`        | Affiliate ana kaydı         | `affiliate_code`, `status`, `kyc_status`           |
| `affiliate_network` | MLM (Multi-Level) ağ yapısı | `parent_affiliate_id`, `sub_affiliate_id`, `depth` |
| `affiliate_users`   | Affiliate panel yetkilileri | `affiliate_id`, `email`, `role`                    |

### 8.3 campaign Şeması

Trafik ve kampanya yönetimi.

| Tablo                 | Açıklama                     | Kritik Alanlar                                            |
| --------------------- | ---------------------------- | --------------------------------------------------------- |
| `traffic_sources`     | Trafik kaynakları            | `source_name`, `medium`, `postback_url`                   |
| `campaigns`           | Affiliate kampanyaları       | `campaign_code`, `landing_page_url`                       |
| `attribution_models`  | Atıf modelleri               | `model_name` (Last Click, First Click), `lookback_window` |
| `affiliate_campaigns` | Affiliate-Kampanya eşleşmesi | `affiliate_id`, `campaign_id`, `commission_plan_id`       |

### 8.4 commission Şeması

Komisyon planlama ve hesaplama motoru.

| Tablo                              | Açıklama                  | Kritik Alanlar                                      |
| ---------------------------------- | ------------------------- | --------------------------------------------------- |
| `commission_plans`                 | Komisyon planları         | `plan_type` (RevShare, CPA, Hybrid), `is_default`   |
| `commission_tiers`                 | Plan kademeleri           | `min_ngr`, `revenue_share_percentage`, `cpa_amount` |
| `cost_allocation_settings`         | Maliyet yansıtma ayarları | `deduct_bonus_cost`, `carry_forward_negative`       |
| `negative_balance_carryforward`    | Negatif bakiye taşıma     | `remaining_amount`, `status`, `source_month`        |
| `network_commission_rules`         | MLM komisyon kuralları    | `level`, `override_percentage`                      |
| `network_commission_distributions` | MLM hakediş dağılımı      | `from_affiliate_id`, `to_affiliate_id`, `amount`    |
| `network_commission_splits`        | MLM dağılım kuralları     | `split_type`, `percentage`                          |
| `commissions`                      | Hesaplanan komisyonlar    | `amount`, `source_amount` (NGR), `period`           |

### 8.5 payout Şeması

Ödeme yönetimi.

| Tablo                | Açıklama                 | Kritik Alanlar                       |
| -------------------- | ------------------------ | ------------------------------------ |
| `payout_requests`    | Ödeme talepleri          | `amount`, `payment_method`, `status` |
| `payout_commissions` | Ödeme-Komisyon eşleşmesi | `payout_request_id`, `commission_id` |
| `payouts`            | Kesinleşen ödemeler      | `transaction_ref`, `paid_at`         |

### 8.6 tracking Şeması

Oyuncu takip sistemi ve istatistikler.

| Tablo                        | Açıklama                     | Kritik Alanlar                                   |
| ---------------------------- | ---------------------------- | ------------------------------------------------ |
| `tracking_links`             | Takip linkleri               | `slug`, `campaign_id`, `redirect_url`            |
| `link_clicks`                | Link tıklama logları         | `ip_address`, `referrer`, `is_unique`            |
| `transaction_events`         | Finansal olay akışı          | `player_id`, `amount`, `operation_type`          |
| `player_registrations`       | Oyuncu kayıt olayları        | `player_id`, `registered_at`, `campaign_id`      |
| `player_affiliate_current`   | Oyuncunun mevcut affiliate'i | `player_id`, `affiliate_id`, `campaign_id`       |
| `player_affiliate_history`   | Atıf değişiklik geçmişi      | `old_affiliate_id`, `new_affiliate_id`, `reason` |
| `affiliate_stats_daily`      | Affiliate günlük özet        | `clicks`, `registrations`, `ftd_count`           |
| `affiliate_stats_monthly`    | Affiliate aylık özet         | `ngr`, `commission_amount`                       |
| `player_game_stats_daily`    | Oyuncu oyun istatistikleri   | `bet_amount`, `win_amount`, `ggr`                |
| `player_finance_stats_daily` | Oyuncu finans istatistikleri | `deposit_amount`, `withdrawal_amount`            |
| `player_stats_monthly`       | Oyuncu aylık özet            | `total_ngr`, `admin_fee_deduction`               |
| `promo_codes`                | Takip amaçlı promo kodlar    | `code`, `campaign_id`                            |

> 💡 **Denormalizasyon**: `player_affiliate_current` tablosu `player_username`, `tenant_code` gibi alanları performans için kopyalar.
>
> 📊 **İstatistikler**: `_stats` tabloları realtime raporlama için önceden hesaplanmış (pre-aggregated) verileri tutar.

---

### 9.1 Bonus Veritabanı (Global)

Bonus ve promosyon sistemi **konfigürasyon** katmanıdır.

#### 9.1.1 Şema Listesi

| Şema        | Amaç                              |
| ----------- | --------------------------------- |
| `bonus`     | Bonus kuralları ve tetikleyiciler |
| `promotion` | Promosyon kodları                 |
| `campaign`  | Kampanya yönetimi                 |
| `infra`     | PostgreSQL extension'ları         |

#### 9.1.2 bonus Şeması

Bonus kural motoru tanımları.

| Tablo            | Açıklama                          | Kritik Alanlar                                           |
| ---------------- | --------------------------------- | -------------------------------------------------------- |
| `bonus_types`    | Bonus tipleri (Deposit, FreeSpin) | `type_code`, `category`, `value_type`                    |
| `bonus_rules`    | Kazanım ve çevrim kuralları       | `wagering_requirement`, `min_deposit`, `expires_in_days` |
| `bonus_triggers` | Otomatik bonus tetikleyicileri    | `trigger_type` (Registration, Deposit), `schedule_cron`  |

#### 9.1.3 promotion Şeması

| Tablo         | Açıklama          | Kritik Alanlar                           |
| ------------- | ----------------- | ---------------------------------------- |
| `promo_codes` | Promosyon kodları | `code`, `max_redemptions`, `valid_until` |

#### 9.1.4 campaign Şeması

| Tablo       | Açıklama                  | Kritik Alanlar                                     |
| ----------- | ------------------------- | -------------------------------------------------- |
| `campaigns` | Global kampanya tanımları | `campaign_type`, `total_budget`, `target_segments` |

### 9.2 Tenant Bonus Şeması (Tenant-Specific)

Bonus uygulama ve takip katmanı. Ana **tenant veritabanı** altında `bonus` şeması olarak yer alır.

#### 9.2.1 Tablo Listesi

| Tablo               | Açıklama                     | Kritik Alanlar                                                    |
| ------------------- | ---------------------------- | ----------------------------------------------------------------- |
| `bonus_awards`      | Oyuncuya tanımlanan bonuslar | `bonus_amount`, `wagering_progress`, `status` (Active, Completed) |
| `promo_redemptions` | Kod kullanım logları         | `promo_code`, `status` (Success, Failed)                          |

> 💡 **Denormalizasyon**: `bonus_awards` tablosu player_id alanını kopyalar.

> 🏢 **Tenant Sahipliği**: Konfigürasyon tabloları (`rules`, `triggers`, `campaigns`) `tenant_id` alanı içerir.
>
> - `tenant_id IS NULL`: Platform seviyesi (tüm tenant'lara açık)
> - `tenant_id = X`: Sadece Tenant X'e özel (özelleştirilmiş)

---

## 10. PostgreSQL Extension'ları

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

## 11. Deploy Scriptleri

| Script                        | Amaç                                         |
| ----------------------------- | -------------------------------------------- |
| `create_dbs.sql`              | Tüm veritabanlarını oluşturur (boş)          |
| `deploy_core.sql`             | Core veritabanı şema, tablo ve fonksiyonları |
| `deploy_core_log.sql`         | Core Log veritabanı yapısı                   |
| `deploy_core_audit.sql`       | Core Audit veritabanı yapısı                 |
| `deploy_bonus.sql`            | Bonus (Global) veritabanı yapısı             |
| `deploy_tenant.sql`           | Tenant (Şablon) veritabanı yapısı            |
| `deploy_tenant_log.sql`       | Tenant Log veritabanı yapısı                 |
| `deploy_tenant_audit.sql`     | Tenant Audit veritabanı yapısı               |
| `deploy_tenant_affiliate.sql` | Tenant Affiliate (Plugin) veritabanı yapısı  |

---

## 13. Fonksiyon ve Trigger Mimarisi

> ℹ️ **Bilgi**: Fonksiyon ve trigger mimarisi detayları ayrı bir dokümana taşınmıştır: [DATABASE_FUNCTIONS.md](DATABASE_FUNCTIONS.md)

---

## 14. Altın Kurallar

> **"Core paylaşılır, tenant izole edilir."**

> **"Log kısa ömürlüdür, audit kalıcıdır."**

> **"Her tenant için ayrı veritabanı = tam izolasyon."**

# Lookup Functions - Backend Endpoint Referansı

Bu döküman, backoffice dropdown/combobox'ları için kullanılacak lookup fonksiyonlarını içerir.

## Genel Bilgiler

- Tüm fonksiyonlar `STABLE` ve `SECURITY DEFINER` olarak tanımlıdır
- IDOR korumalı fonksiyonlar `p_caller_id` parametresi alır ve yetki kontrolü yapar
- Yetki hatalarında `P0403` error code ile `error.access.unauthorized` mesajı döner
- `is_active` alanı response'da döner, frontend filtreleme yapabilir

---

## 1. IDOR Korumalı - Core Schema

```
┌───────────────────────────┬───────┬───────────────────────────────────────┬─────────────────────────────────────┐
│ Function                  │ HTTP  │ Endpoint                              │ Açıklama                            │
├───────────────────────────┼───────┼───────────────────────────────────────┼─────────────────────────────────────┤
│ core.company_lookup       │ GET   │ /api/lookup/companies                 │ Company dropdown listesi            │
│ core.tenant_lookup        │ GET   │ /api/lookup/tenants?companyId={id}    │ Tenant dropdown listesi             │
└───────────────────────────┴───────┴───────────────────────────────────────┴─────────────────────────────────────┘
```

### 1.1 company_lookup

**Amaç:** Company dropdown listesi (User/Tenant oluşturma formlarında)

```sql
core.company_lookup(p_caller_id BIGINT)
```

**Yetki:**
- Platform Admin (SuperAdmin/Admin): Tüm company'leri görür
- Diğerleri: Sadece kendi company'sini görür

**Response:**
```
┌─────────────┬───────────────┬─────────────────────┐
│ Kolon       │ Tip           │ Açıklama            │
├─────────────┼───────────────┼─────────────────────┤
│ id          │ BIGINT        │ Company ID          │
│ code        │ VARCHAR(50)   │ Company kodu        │
│ name        │ VARCHAR(100)  │ Company adı         │
│ is_active   │ BOOLEAN       │ Aktif durumu        │
└─────────────┴───────────────┴─────────────────────┘
```

---

### 1.2 tenant_lookup

**Amaç:** Tenant dropdown listesi (User role atama, raporlama formlarında)

```sql
core.tenant_lookup(
    p_caller_id BIGINT,
    p_company_id BIGINT DEFAULT NULL  -- Opsiyonel company filtresi
)
```

**Yetki:**
- Platform Admin: Tüm tenant'ları görür (opsiyonel company filtresi)
- CompanyAdmin (level >= 80): Kendi company'sindeki tenant'ları görür
- TenantAdmin ve altı: Sadece `user_allowed_tenants` tablosundaki tenant'ları görür

**Response:**
```
┌──────────────┬───────────────┬─────────────────────────────┐
│ Kolon        │ Tip           │ Açıklama                    │
├──────────────┼───────────────┼─────────────────────────────┤
│ id           │ BIGINT        │ Tenant ID                   │
│ code         │ VARCHAR(50)   │ Tenant kodu                 │
│ name         │ VARCHAR(100)  │ Tenant adı                  │
│ company_id   │ BIGINT        │ Bağlı olduğu company ID     │
│ company_name │ VARCHAR(100)  │ Company adı                 │
│ is_active    │ BOOLEAN       │ Aktif durumu                │
└──────────────┴───────────────┴─────────────────────────────┘
```

---

## 2. IDOR Korumalı - Catalog Schema

```
┌─────────────────────────────────────┬───────┬──────────────────────────────────────────────┬─────────────────────────────────────┐
│ Function                            │ HTTP  │ Endpoint                                     │ Açıklama                            │
├─────────────────────────────────────┼───────┼──────────────────────────────────────────────┼─────────────────────────────────────┤
│ catalog.provider_type_lookup        │ GET   │ /api/lookup/provider-types                   │ Provider tipi listesi               │
│ catalog.provider_lookup             │ GET   │ /api/lookup/providers?typeId={id}            │ Provider listesi                    │
│ catalog.jurisdiction_lookup         │ GET   │ /api/lookup/jurisdictions                    │ Jurisdiction listesi                │
│ catalog.theme_lookup                │ GET   │ /api/lookup/themes                           │ Tema listesi                        │
│ catalog.payment_method_lookup       │ GET   │ /api/lookup/payment-methods?providerId={id}  │ Ödeme yöntemi listesi               │
└─────────────────────────────────────┴───────┴──────────────────────────────────────────────┴─────────────────────────────────────┘
```

### 2.1 provider_type_lookup

**Amaç:** Provider tipi dropdown (Provider oluşturma formunda)

```sql
catalog.provider_type_lookup(p_caller_id BIGINT)
```

**Yetki:** SuperAdmin only

**Response:**
```
┌─────────────┬───────────────┬───────────────────────────────────────────────┐
│ Kolon       │ Tip           │ Açıklama                                      │
├─────────────┼───────────────┼───────────────────────────────────────────────┤
│ id          │ BIGINT        │ Provider type ID                              │
│ code        │ VARCHAR(30)   │ Provider type kodu                            │
│ name        │ VARCHAR(100)  │ Provider type adı                             │
│ is_active   │ BOOLEAN       │ Her zaman TRUE (tabloda is_active yok)        │
└─────────────┴───────────────┴───────────────────────────────────────────────┘
```

---

### 2.2 provider_lookup

**Amaç:** Provider dropdown (Tenant-Provider bağlama, Payment method formlarında)

```sql
catalog.provider_lookup(
    p_caller_id BIGINT,
    p_type_id BIGINT DEFAULT NULL  -- Opsiyonel provider type filtresi
)
```

**Yetki:** SuperAdmin only

**Response:**
```
┌─────────────┬───────────────┬─────────────────────────────┐
│ Kolon       │ Tip           │ Açıklama                    │
├─────────────┼───────────────┼─────────────────────────────┤
│ id          │ BIGINT        │ Provider ID                 │
│ code        │ VARCHAR(50)   │ Provider kodu               │
│ name        │ VARCHAR(255)  │ Provider adı                │
│ type_id     │ BIGINT        │ Provider type ID            │
│ type_code   │ VARCHAR(30)   │ Provider type kodu          │
│ type_name   │ VARCHAR(100)  │ Provider type adı           │
│ is_active   │ BOOLEAN       │ Aktif durumu                │
└─────────────┴───────────────┴─────────────────────────────┘
```

---

### 2.3 jurisdiction_lookup

**Amaç:** Jurisdiction dropdown (Tenant lisans ayarlarında)

```sql
catalog.jurisdiction_lookup(p_caller_id BIGINT)
```

**Yetki:** Platform Admin (SuperAdmin + Admin)

**Response:**
```
┌────────────────┬───────────────┬────────────────────────────────────────────┐
│ Kolon          │ Tip           │ Açıklama                                   │
├────────────────┼───────────────┼────────────────────────────────────────────┤
│ id             │ INT           │ Jurisdiction ID                            │
│ code           │ VARCHAR(20)   │ Jurisdiction kodu (MGA, UKGC, GGL...)      │
│ name           │ VARCHAR(100)  │ Jurisdiction adı                           │
│ country_code   │ CHAR(2)       │ Ülke kodu                                  │
│ authority_type │ VARCHAR(30)   │ Otorite tipi (national, offshore, regional)│
│ is_active      │ BOOLEAN       │ Aktif durumu                               │
└────────────────┴───────────────┴────────────────────────────────────────────┘
```

---

### 2.4 theme_lookup

**Amaç:** Tema dropdown (Tenant frontend ayarlarında)

```sql
catalog.theme_lookup(p_caller_id BIGINT)
```

**Yetki:** SuperAdmin only

**Response:**
```
┌─────────────┬───────────────┬─────────────────────────────┐
│ Kolon       │ Tip           │ Açıklama                    │
├─────────────┼───────────────┼─────────────────────────────┤
│ id          │ INT           │ Theme ID                    │
│ code        │ VARCHAR(50)   │ Theme kodu                  │
│ name        │ VARCHAR(100)  │ Theme adı                   │
│ is_active   │ BOOLEAN       │ Aktif durumu                │
│ is_premium  │ BOOLEAN       │ Premium tema mı             │
└─────────────┴───────────────┴─────────────────────────────┘
```

---

### 2.5 payment_method_lookup

**Amaç:** Ödeme yöntemi dropdown (Tenant payment ayarlarında)

```sql
catalog.payment_method_lookup(
    p_caller_id BIGINT,
    p_provider_id BIGINT DEFAULT NULL  -- Opsiyonel provider filtresi
)
```

**Yetki:** SuperAdmin only

**Response:**
```
┌─────────────────────┬───────────────┬──────────────────────────────────────────┐
│ Kolon               │ Tip           │ Açıklama                                 │
├─────────────────────┼───────────────┼──────────────────────────────────────────┤
│ id                  │ BIGINT        │ Payment method ID                        │
│ code                │ VARCHAR(100)  │ Payment method kodu                      │
│ name                │ VARCHAR(255)  │ Payment method adı                       │
│ provider_id         │ BIGINT        │ Bağlı provider ID                        │
│ provider_code       │ VARCHAR(50)   │ Provider kodu                            │
│ provider_name       │ VARCHAR(255)  │ Provider adı                             │
│ payment_type        │ VARCHAR(50)   │ Tip (CARD, BANK, CRYPTO, EWALLET...)     │
│ supports_deposit    │ BOOLEAN       │ Deposit destekler mi                     │
│ supports_withdrawal │ BOOLEAN       │ Withdrawal destekler mi                  │
│ is_active           │ BOOLEAN       │ Aktif durumu                             │
└─────────────────────┴───────────────┴──────────────────────────────────────────┘
```

---

## 3. Public Catalog (Yetki Gerektirmeyen)

Bu fonksiyonlar herhangi bir yetki kontrolü yapmaz, tüm authenticated kullanıcılar erişebilir.

```
┌──────────────────────────────────┬───────┬──────────────────────────────────┬──────────────────────────────────┐
│ Function                         │ HTTP  │ Endpoint                         │ Açıklama                         │
├──────────────────────────────────┼───────┼──────────────────────────────────┼──────────────────────────────────┤
│ catalog.country_list             │ GET   │ /api/lookup/countries            │ Ülke listesi                     │
│ catalog.currency_list            │ GET   │ /api/lookup/currencies           │ Para birimi listesi              │
│ catalog.timezone_list            │ GET   │ /api/lookup/timezones            │ Timezone listesi                 │
│ catalog.language_list            │ GET   │ /api/lookup/languages            │ Dil listesi                      │
│ catalog.transaction_type_list    │ GET   │ /api/lookup/transaction-types    │ Transaction tipi listesi         │
│ catalog.operation_type_list      │ GET   │ /api/lookup/operation-types      │ Operation tipi listesi           │
└──────────────────────────────────┴───────┴──────────────────────────────────┴──────────────────────────────────┘
```

### 3.1 country_list

```sql
catalog.country_list()
```

**Response:**
```
┌─────────────┬───────────────┬────────────────────────────────┐
│ Kolon       │ Tip           │ Açıklama                       │
├─────────────┼───────────────┼────────────────────────────────┤
│ code        │ CHAR(2)       │ ISO 3166-1 alpha-2 ülke kodu   │
│ name        │ VARCHAR(100)  │ Ülke adı                       │
└─────────────┴───────────────┴────────────────────────────────┘
```

---

### 3.2 currency_list

```sql
catalog.currency_list()
```

**Response:**
```
┌───────────────┬───────────────┬────────────────────────────────┐
│ Kolon         │ Tip           │ Açıklama                       │
├───────────────┼───────────────┼────────────────────────────────┤
│ currency_code │ CHAR(3)       │ ISO 4217 para birimi kodu      │
│ currency_name │ VARCHAR(100)  │ Para birimi adı                │
│ symbol        │ VARCHAR(10)   │ Sembol (₺, €, $...)            │
│ numeric_code  │ SMALLINT      │ ISO 4217 numeric kod           │
│ is_active     │ BOOLEAN       │ Aktif durumu                   │
└───────────────┴───────────────┴────────────────────────────────┘
```

---

### 3.3 timezone_list

```sql
catalog.timezone_list()
```

**Response:**
```
┌──────────────┬───────────────┬────────────────────────────────┐
│ Kolon        │ Tip           │ Açıklama                       │
├──────────────┼───────────────┼────────────────────────────────┤
│ name         │ VARCHAR       │ Timezone adı (Europe/Istanbul) │
│ utc_offset   │ VARCHAR       │ UTC offset (+03:00)            │
│ display_name │ VARCHAR       │ Görüntüleme adı                │
└──────────────┴───────────────┴────────────────────────────────┘
```

**Not:** Sadece `is_active = TRUE` olanlar döner.

---

### 3.4 language_list

```sql
catalog.language_list()
```

**Response:**
```
┌───────────────┬───────────────┬────────────────────────────────┐
│ Kolon         │ Tip           │ Açıklama                       │
├───────────────┼───────────────┼────────────────────────────────┤
│ language_code │ CHAR(2)       │ ISO 639-1 dil kodu             │
│ language_name │ VARCHAR(50)   │ Dil adı                        │
│ is_active     │ BOOLEAN       │ Aktif durumu                   │
└───────────────┴───────────────┴────────────────────────────────┘
```

---

### 3.5 transaction_type_list

```sql
catalog.transaction_type_list()
```

**Response:**
```
┌───────────────┬───────────────┬────────────────────────────────────────────┐
│ Kolon         │ Tip           │ Açıklama                                   │
├───────────────┼───────────────┼────────────────────────────────────────────┤
│ code          │ VARCHAR(50)   │ Transaction kodu (BET, WIN, DEPOSIT...)    │
│ category      │ VARCHAR(30)   │ Kategori (BET, WIN, BONUS, PAYMENT...)     │
│ product       │ VARCHAR(30)   │ Ürün (SPORTS, CASINO, POKER, PAYMENT)      │
│ is_bonus      │ BOOLEAN       │ Bonus işlemi mi                            │
│ is_free       │ BOOLEAN       │ Free spin/bet mi                           │
│ is_rollback   │ BOOLEAN       │ Geri alma işlemi mi                        │
│ is_winning    │ BOOLEAN       │ Kazanç işlemi mi                           │
│ is_reportable │ BOOLEAN       │ Raporlarda gösterilir mi                   │
│ description   │ TEXT          │ Açıklama                                   │
│ is_active     │ BOOLEAN       │ Aktif durumu                               │
└───────────────┴───────────────┴────────────────────────────────────────────┘
```

---

### 3.6 operation_type_list

```sql
catalog.operation_type_list()
```

**Response:**
```
┌─────────────────┬───────────────┬────────────────────────────────────────────┐
│ Kolon           │ Tip           │ Açıklama                                   │
├─────────────────┼───────────────┼────────────────────────────────────────────┤
│ code            │ VARCHAR(30)   │ Operation kodu (DEBIT, CREDIT, HOLD...)    │
│ wallet_effect   │ SMALLINT      │ Cüzdan etkisi (-1, 0, +1)                  │
│ affects_balance │ BOOLEAN       │ Ana bakiyeyi etkiler mi                    │
│ affects_locked  │ BOOLEAN       │ Kilitli bakiyeyi etkiler mi                │
│ description     │ TEXT          │ Açıklama                                   │
│ is_active       │ BOOLEAN       │ Aktif durumu                               │
└─────────────────┴───────────────┴────────────────────────────────────────────┘
```

---

## Yetki Matrisi Özeti

```
┌───────────────────────────────┬────────────┬───────┬─────────────┬─────────────┬─────────┐
│ Fonksiyon                     │ SuperAdmin │ Admin │ CompanyAdmin│ TenantAdmin │ Diğer   │
├───────────────────────────────┼────────────┼───────┼─────────────┼─────────────┼─────────┤
│ company_lookup                │ ✅ Tümü    │ ✅ Tümü│ ⚠️ Kendi    │ ⚠️ Kendi    │ ⚠️ Kendi │
│ tenant_lookup                 │ ✅ Tümü    │ ✅ Tümü│ ⚠️ Company  │ ⚠️ Allowed  │ ⚠️ Allowed│
│ provider_type_lookup          │ ✅         │ ❌    │ ❌          │ ❌          │ ❌      │
│ provider_lookup               │ ✅         │ ❌    │ ❌          │ ❌          │ ❌      │
│ jurisdiction_lookup           │ ✅         │ ✅    │ ❌          │ ❌          │ ❌      │
│ theme_lookup                  │ ✅         │ ❌    │ ❌          │ ❌          │ ❌      │
│ payment_method_lookup         │ ✅         │ ❌    │ ❌          │ ❌          │ ❌      │
│ country_list                  │ ✅         │ ✅    │ ✅          │ ✅          │ ✅      │
│ currency_list                 │ ✅         │ ✅    │ ✅          │ ✅          │ ✅      │
│ timezone_list                 │ ✅         │ ✅    │ ✅          │ ✅          │ ✅      │
│ language_list                 │ ✅         │ ✅    │ ✅          │ ✅          │ ✅      │
│ transaction_type_list         │ ✅         │ ✅    │ ✅          │ ✅          │ ✅      │
│ operation_type_list           │ ✅         │ ✅    │ ✅          │ ✅          │ ✅      │
└───────────────────────────────┴────────────┴───────┴─────────────┴─────────────┴─────────┘
```

**Lejant:**
- ✅ Tümü: Tüm kayıtları görebilir
- ⚠️ Kendi: Sadece kendi company'sini görür
- ⚠️ Company: Sadece kendi company'sindeki tenant'ları görür
- ⚠️ Allowed: Sadece `user_allowed_tenants` tablosundaki tenant'ları görür
- ❌: Erişim yok (P0403 hatası)

---

## Error Codes

```
┌────────┬─────────────────────────────┬──────────────────────────────┐
│ Code   │ Message                     │ Açıklama                     │
├────────┼─────────────────────────────┼──────────────────────────────┤
│ P0403  │ error.access.unauthorized   │ Yetkisiz erişim denemesi     │
└────────┴─────────────────────────────┴──────────────────────────────┘
```

---

## Endpoint Özeti

Tüm endpoint'ler JWT token gerektirir. IDOR korumalı olanlar token'dan `caller_id` alır.

```
GET /api/lookup/companies
GET /api/lookup/tenants?companyId={id}
GET /api/lookup/provider-types
GET /api/lookup/providers?typeId={id}
GET /api/lookup/jurisdictions
GET /api/lookup/themes
GET /api/lookup/payment-methods?providerId={id}
GET /api/lookup/countries
GET /api/lookup/currencies
GET /api/lookup/timezones
GET /api/lookup/languages
GET /api/lookup/transaction-types
GET /api/lookup/operation-types
```

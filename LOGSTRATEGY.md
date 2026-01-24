# 🧱 NUCLEO – LOG / AUDIT / BUSINESS

## Log, Audit ve Retention Stratejisi

Bu doküman, **Nucleo platformu** içinde üretilen **log, audit ve business (history)** verilerinin  
hangi veritabanında tutulacağını, ne kadar süre saklanacağını ve retention süresi sonunda  
nasıl temizleneceğini tanımlar.

---

## 1. Genel Özet Tablosu

| DB / Kategori           | Ne Tutulur                                              | Partition       | Retention           | Süre Sonu Aksiyon |
| ----------------------- | ------------------------------------------------------- | --------------- | ------------------- | ----------------- |
| **core**                | Platform domain (tenant, company, currency)             | ❌              | Sınırsız            | ❌                |
| **core_log**            | Core + gateway teknik log (ERROR / WARN / INFO)         | Daily           | 30–90 gün           | DROP partition    |
| **core_audit**          | Platform kararları (tenant lifecycle, gateway enable)   | ❌              | 5–10 yıl            | ❌                |
| **core_report**         | Aggregated / BI data                                    | Opsiyonel       | İş ihtiyacına bağlı | Rebuild           |
| **game**                | Game gateway integration state                          | Daily           | 14–30 gün           | DROP partition    |
| **game_log**            | Tüm tenant’lara ait game gateway logları                | Daily           | 7–14 gün            | DROP partition    |
| **finance**             | Finance gateway integration state                       | Daily           | 14–30 gün           | DROP partition    |
| **finance_log**         | Tüm tenant’lara ait finance gateway logları             | Daily           | 14–30 gün           | DROP partition    |
| **tenant**              | Business & history (transactions, game rounds, wallets) | Monthly / Daily | Sınırsız            | ❌                |
| **tenant*log*<code>**   | Tenant teknik & operasyonel log                         | Daily           | 30–90 gün           | DROP partition    |
| **tenant*audit*<code>** | Tenant karar & yetkili aksiyon                          | ❌ / Yearly     | 5–10 yıl            | ❌                |
| **tenant_report**       | Tenant raporlama / BI                                   | Opsiyonel       | İş ihtiyacına bağlı | Rebuild           |

---

## 2. Temel Prensipler

- **Log ≠ Audit ≠ Business**
- Gateway logları **merkezi** ama **kısa ömürlüdür**
- Tenant DB yalnızca **iş gerçeğini (business)** tutar
- Retention = **fiziksel partition DROP**
- Audit verileri **silinmez**
- Partition yoksa retention uygulanamaz

---

## 3. Retention ve DROP Stratejisi

Partition kullanılan veritabanlarında retention süresi dolduğunda:

- `DELETE` **kullanılmaz**
- Doğrudan **partition DROP edilir**

Bu yaklaşım:

- IO spike oluşturmaz
- VACUUM / bloat yaratmaz
- Lock riskini ortadan kaldırır

### Örnek

```text
DB          : game_log
Partition   : daily
Retention  : 14 gün
```

## 4. DROP Zorunluluğu Olan DB’ler (Yüksek Hacim)

Aşağıdaki veritabanlarında üretilen veri hacmi çok yüksektir.  
Bu nedenle retention süresi dolduğunda **veri satır bazında silinmez**,  
ilgili **partition doğrudan DROP edilir**.

### Zorunlu DROP Gerektiren DB’ler

| DB                  | Sebep                                                     |
| ------------------- | --------------------------------------------------------- |
| `game_log`          | Yüksek hacimli event flood (game launch, callback, retry) |
| `finance_log`       | Yoğun callback ve provider response trafiği               |
| `core_log`          | Platform genelinde üretilen teknik loglar                 |
| `tenant_log_<code>` | Tenant bazlı operasyonel ve teknik hatalar                |

> Bu DB’lerde **retention = fiziksel silme** anlamına gelir.

---

## 5. DROP Opsiyonel / Uzun Süreli Tutulan DB’ler

Aşağıdaki veritabanları **yüksek hacimli log DB’leri değildir**.  
Retention süresi, **iş ihtiyacı veya regülasyon gereksinimine göre** belirlenir.

### Opsiyonel DROP veya Uzun Süreli Saklama

| DB                       | Not                                              |
| ------------------------ | ------------------------------------------------ |
| `gateway integration db` | Dispute veya provider incelemesi ihtiyacına göre |
| `core_audit`             | Regülasyon ve platform governance                |
| `tenant_audit_<code>`    | Regülasyon, güvenlik ve izlenebilirlik           |

> Audit verileri genellikle **silinmez** veya **çok uzun süre** tutulur.

---

## 6. Retention Süresi Nasıl Uygulanır?

Retention, **partition seviyesinde** uygulanır.

### Örnek Senaryo – `game_log`

- Partition tipi: **Daily**
- Retention süresi: **14 gün**
- Bugünün tarihi: **2026-02-10**

#### Saklanacak partition’lar

## 7. Archive Gerekir mi?

Retention stratejisinde **archive**, log ve audit verileri için **farklı ele alınmalıdır**.

### 7.1 Log Verileri İçin

- ❌ Archive **gerekmez**
- Log verileri **operasyonel pencere** içindir
- Incident, debugging ve kısa vadeli analiz amaçlı tutulur
- Retention süresi dolduğunda **tamamen silinir**

> Log verileri için arşivleme yapmak,  
> hem maliyet hem de operasyonel karmaşa yaratır.

---

### 7.2 Audit Verileri İçin

- 🟡 Archive **opsiyoneldir**
- Regülasyon veya hukuki gereksinimler varsa değerlendirilir
- Uzun vadeli saklama için uygun yaklaşımlar:
    - Cold storage (örn. S3, object storage)
    - Yedekleme sistemleri
    - Harici arşiv servisleri

> Audit verileri için **DB içinde archive table** oluşturulması **önerilmez**.

---

## 8. Operasyonel Sorumluluk

Retention ve partition DROP işlemleri **uygulama kodunun sorumluluğu değildir**.

### 8.1 Sorumlu Bileşenler

- ✅ DBA
- ✅ Altyapı / DevOps ekipleri

Uygulama sadece:

- Log üretir
- Partition yapısını kullanır

---

### 8.2 Uygulanabilecek Yöntemler

Partition lifecycle yönetimi aşağıdaki yöntemlerle otomatikleştirilmelidir:

- Daily cron job
- CI/CD pipeline maintenance adımı
- Flyway / Liquibase scheduled task
- Altyapı otomasyon script’leri

> DROP işlemleri **manuel** yapılmamalıdır.

---

## 9. Güvenlik Önlemleri

Retention ve DROP süreçleri **yüksek riskli operasyonlardır**.  
Bu nedenle aşağıdaki güvenlik önlemleri zorunludur.

### 9.1 Minimum Retention

- Minimum retention süresi tanımlanmalıdır
- Örnek:
    - ERROR log’lar → **en az 7 gün**
    - WARN / INFO → iş ihtiyacına göre

---

### 9.2 Incident Durumu

- Aktif bir incident varsa:
    - DROP işlemleri **geçici olarak durdurulabilir**
    - İlgili partition’lar korunur

---

### 9.3 Doğrulama ve Kontrol

- Silinecek partition listesi önceden **validate edilir**
- Aktif (current) partition **asla DROP edilmez**
- Tarih aralıkları otomatik kontrol edilir

> Yanlış partition DROP edilmesi **geri dönüşü olmayan veri kaybı**na yol açar.

---

## 10. Altın Kural

> **“Log retention süresi dolduysa, partition silinir;  
> silinmeyen log teknik borçtur.”**

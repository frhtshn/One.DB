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

---
description: Projedeki tüm fonksiyon ve triggerları tarayarak DATABASE_FUNCTIONS.md dosyasını günceller
---

# Fonksiyon Dokümantasyonu Güncelleme İş Akışı

Bu iş akışı, projede bulunan tüm stored procedure ve trigger tanımlarını tarar ve `.docs/DATABASE_FUNCTIONS.md` dosyasını günceller.

## 1. Hazırlık ve Tarama

Proje kök dizinindeki veritabanı klasörlerini tara (`core`, `tenant`, vb.). Her birinin altında `functions` veya `triggers` klasörü olup olmadığını kontrol et.

### Hedef Klasörler:

- `*/functions` (Tüm veritabanı klasörleri altındaki functions klasörleri)
- `*/triggers` (Tüm veritabanı klasörleri altındaki triggers klasörleri)

Agent, proje kök dizinindeki tüm klasörleri taramalı ve içinde `functions` veya `triggers` alt klasörü olanları otomatik olarak işlemelidir. Sabit bir liste yerine dinamik keşif yapılmalıdır.

## 2. Analiz

Bulunan `.sql` dosyalarını oku ve aşağıdaki bilgileri çıkar:

1.  **Schema Adı**: Fonksiyon hangi şemaya ait? (örn: `create function security.login` -> `security`)
2.  **Fonksiyon Adı**: (örn: `login`)
3.  **Parametreler**: (örn: `username, password`)
4.  **Dönüş Tipi**: (örn: `RETURNS TRIGGER` veya `RETURNS JSONB`)
5.  **Açıklama**: SQL dosyasındaki yorum satırlarından veya fonksiyonun amacından çıkarım yap.

## 3. Dokümantasyon Güncelleme

`.docs/DATABASE_FUNCTIONS.md` dosyasını aşağıdaki yapıya uygun olarak güncelle:

1.  **Veritabanı Bazlı Gruplama**: Core, Tenant, Affiliate gibi üst başlıklar oluştur.
2.  **Şema Bazlı Alt Gruplama**: Her veritabanı altında şemaları listele.
3.  **Fonksiyon Listesi**: Her şema altında fonksiyonları madde madde açıkla.

### Örnek Format:

```markdown
## Core Veritabanı

### Security Şeması

- **`login(username, password)`**: Kullanıcı girişi yapar.

## Tenant Veritabanı

### Game Şeması

- **`calculate_rtp(game_id)`**: Oyunun RTP oranını hesaplar.
```

## 4. Kaydet ve Bitir

Değişiklikleri kaydet.

> **Not:** Eğer bir klasör (örn: `tenant/functions`) boşsa veya sadece `.gitkeep` varsa, o bölümü dokümanda "Henüz özel fonksiyon tanımlanmamıştır." şeklinde belirt veya o bölümü atla.

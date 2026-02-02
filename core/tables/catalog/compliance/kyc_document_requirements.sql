-- =============================================
-- KYC Document Requirements (KYC Belge Gereksinimleri)
-- Jurisdiction bazlı gerekli belgeler
-- Belge türleri ve geçerlilik süreleri
-- =============================================

DROP TABLE IF EXISTS catalog.kyc_document_requirements CASCADE;

CREATE TABLE catalog.kyc_document_requirements (
    id serial PRIMARY KEY,

    jurisdiction_id int NOT NULL,                 -- Hangi otorite için

    -- Belge türü
    document_type varchar(30) NOT NULL,           -- Belge tipi
    -- identity: Kimlik belgesi (TC, pasaport, ehliyet)
    -- proof_of_address: Adres kanıtı (fatura, banka ekstresi)
    -- selfie: Yüz fotoğrafı
    -- source_of_funds: Gelir kaynağı belgesi
    -- bank_statement: Banka hesap özeti

    -- Kabul edilen alt türler (JSON array)
    accepted_subtypes jsonb,                      -- ["passport", "national_id", "driving_license"]

    -- Zorunluluk
    is_required boolean NOT NULL DEFAULT true,    -- Zorunlu mu?
    required_for varchar(30) NOT NULL DEFAULT 'all', -- Ne için gerekli
    -- all: Her durumda
    -- deposit: Para yatırma için
    -- withdrawal: Para çekme için
    -- edd: Enhanced due diligence için

    -- Geçerlilik
    max_document_age_days int,                    -- Belge max yaşı (gün) - NULL = sınırsız
    expires_after_days int,                       -- Doğrulama geçerlilik süresi

    -- Doğrulama yöntemi
    verification_method varchar(30) DEFAULT 'manual', -- Doğrulama yöntemi
    -- manual: Manuel inceleme
    -- automated: Otomatik (OCR + veritabanı kontrolü)
    -- hybrid: Otomatik + manuel onay

    -- Sıralama
    display_order int DEFAULT 0,

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()


);

COMMENT ON TABLE catalog.kyc_document_requirements IS 'Required KYC documents per jurisdiction with validation rules';

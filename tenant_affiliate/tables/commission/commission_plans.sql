-- =============================================
-- Tablo: commission.commission_plans
-- Açıklama: Komisyon plan tanımları
-- Affiliate'lerin hangi oranlarla komisyon alacağını belirler
-- Sözleşme seviyesinde plan tanımları
-- =============================================

DROP TABLE IF EXISTS commission.commission_plans CASCADE;

CREATE TABLE commission.commission_plans (
    id bigserial PRIMARY KEY,                              -- Benzersiz plan kimliği
    code varchar(50) UNIQUE NOT NULL,                      -- Plan kodu (benzersiz tanımlayıcı)
    model varchar(20) NOT NULL,                            -- Komisyon modeli: REVSHARE, CPA, HYBRID
    base_currency char(3) NOT NULL,                        -- Baz para birimi (TRY, EUR, USD)
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

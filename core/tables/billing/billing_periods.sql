-- =============================================
-- Tablo: billing.billing_periods
-- Açıklama: Faturalama dönem tanımları
-- Aylık/haftalık faturalama dönemlerinin yönetimi
-- Dönem kapanış ve hesaplama durumu takibi
-- =============================================

DROP TABLE IF EXISTS billing.billing_periods CASCADE;

CREATE TABLE billing.billing_periods (
    id bigserial PRIMARY KEY,                              -- Benzersiz dönem kimliği

    -- Dönem bilgileri
    period_code varchar(20) NOT NULL UNIQUE,               -- Dönem kodu: 2026-01, 2026-W04
    period_type varchar(10) NOT NULL,                      -- Dönem tipi: MONTHLY, WEEKLY
    period_start date NOT NULL,                            -- Dönem başlangıcı
    period_end date NOT NULL,                              -- Dönem bitişi

    -- Durum
    status smallint NOT NULL DEFAULT 0,                    -- 0=Açık, 1=Hesaplandı, 2=Kapatıldı

    -- Hesaplama bilgileri
    calculated_at timestamp without time zone,             -- Hesaplama zamanı
    calculated_by bigint,                                  -- Hesaplayan kullanıcı ID

    -- Kapanış bilgileri
    closed_at timestamp without time zone,                 -- Kapanış zamanı
    closed_by bigint,                                      -- Kapatan kullanıcı ID

    -- İstatistikler (özet)
    total_tenants int NOT NULL DEFAULT 0,                  -- İşlem yapılan tenant sayısı
    total_commission_amount numeric(18,6) NOT NULL DEFAULT 0, -- Toplam komisyon tutarı

    notes text,                                            -- Dönem notları

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

-- =============================================
-- Tablo: presentation.contexts
-- Açıklama: UI Elemanları ve Yetki Davranışları
-- Alan, buton, aksiyon gibi elemanların yetkiye göre görünürlüğü
-- Öncelik: edit > readonly > mask > hide
-- =============================================

DROP TABLE IF EXISTS presentation.contexts CASCADE;

CREATE TABLE presentation.contexts (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz context kimliği
    page_id BIGINT NOT NULL,                               -- Sayfa ID
    code VARCHAR(100) NOT NULL,                            -- Context kodu
    context_type VARCHAR(20) NOT NULL,                     -- Tip: field, action, section, button
    label_localization_key VARCHAR(150),                   -- Etiket çeviri anahtarı
    permission_edit VARCHAR(100),                          -- Düzenleme yetkisi
    permission_readonly VARCHAR(100),                      -- Okuma yetkisi
    permission_mask VARCHAR(100),                          -- Maskeleme yetkisi
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Güncellenme zamanı
    is_active BOOLEAN NOT NULL DEFAULT true                -- Aktif/pasif durumu


);

COMMENT ON TABLE presentation.contexts IS 'UI elements (field, button, action, section) permission-based behavior';

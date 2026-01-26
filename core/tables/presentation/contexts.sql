-- =============================================
-- Tablo: presentation.contexts
-- Açıklama: Sayfa içi alan/eylem yetki kontrolleri
-- Belirli alanların veya butonların gösterimini kontrol eder
-- Davranış: hide (gizle), mask (maskele), readonly, edit
-- =============================================

DROP TABLE IF EXISTS presentation.contexts CASCADE;

CREATE TABLE presentation.contexts (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz context kimliği
    page_id BIGINT NOT NULL,                               -- Sayfa ID (FK: presentation.pages)
    code VARCHAR(100) NOT NULL,                            -- Context kodu: player.phone, player.balance
    context_type VARCHAR(20) NOT NULL CHECK (              -- Context tipi
        context_type IN ('field','action','section','button')
    ),
    label_localization_key VARCHAR(150),                   -- Etiket çeviri anahtarı: bo.field.player.phone
    required_permission VARCHAR(100) NOT NULL,             -- Gerekli yetki kodu
    behavior VARCHAR(20) NOT NULL DEFAULT 'hide'           -- Yetkisiz durumda davranış
        CHECK (behavior IN ('hide','mask','readonly','edit')),
    UNIQUE (page_id, code)                                 -- Sayfa başına benzersiz context kodu
);

COMMENT ON TABLE presentation.contexts IS 'Page field and action permission contexts controlling visibility and behavior of UI elements based on user permissions';

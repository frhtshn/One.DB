-- =============================================
-- Tablo: presentation.contexts
-- Açıklama: UI Elemanları ve Yetki Davranışları
-- Alan, buton, aksiyon gibi elemanların yetkiye göre görünürlüğü
-- Öncelik: edit > readonly > mask > hide
-- tab_id NULL ise tab'sız düz sayfa context'i
-- =============================================

DROP TABLE IF EXISTS presentation.contexts CASCADE;

CREATE TABLE presentation.contexts (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz context kimliği
    page_id BIGINT NOT NULL,                               -- Sayfa ID
    tab_id BIGINT,                                         -- Tab ID (NULL = tab'sız sayfa)
    code VARCHAR(100) NOT NULL,                            -- Context kodu
    context_type VARCHAR(20) NOT NULL,                     -- Tip: input, select, toggle, button, table, action, stat
    label_localization_key VARCHAR(150),                   -- Etiket çeviri anahtarı
    permission_edit VARCHAR(100),                          -- Düzenleme yetkisi
    permission_readonly VARCHAR(100),                      -- Okuma yetkisi
    permission_mask VARCHAR(100),                          -- Maskeleme yetkisi
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Güncellenme zamanı
    is_active BOOLEAN NOT NULL DEFAULT true,               -- Aktif/pasif durumu

    CONSTRAINT chk_contexts_type CHECK (context_type IN ('input', 'select', 'toggle', 'button', 'table', 'action', 'stat'))
);

COMMENT ON TABLE presentation.contexts IS 'UI elements (input, select, toggle, button, table, action, stat) with permission-based behavior. tab_id NULL = tabless page context.';

-- =============================================
-- Wallet Snapshots (Cüzdan Anlık Görüntüsü)
-- Cüzdanların güncel bakiye bilgisi
-- Performans için ayrı tablo olarak tutulur
-- Her işlemde güncellenir
-- =============================================

DROP TABLE IF EXISTS wallet.wallet_snapshots CASCADE;

CREATE TABLE wallet.wallet_snapshots (
    wallet_id bigint PRIMARY KEY,                 -- Cüzdan ID (1:1 ilişki)
    balance numeric(18,8) NOT NULL,               -- Güncel bakiye
    last_transaction_id bigint NOT NULL,          -- Son işlem ID (tutarlılık kontrolü için)
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

-- =============================================
-- Tablo: payout.payout_commissions
-- Açıklama: Ödeme-Komisyon ilişki tablosu
-- Hangi komisyonların hangi ödemede yer aldığı
-- Audit ve reconciliation için kritik
-- =============================================

DROP TABLE IF EXISTS payout.payout_commissions CASCADE;

CREATE TABLE payout.payout_commissions (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    payout_id bigint NOT NULL,                             -- Ödeme ID (FK: payout.payouts)
    commission_id bigint NOT NULL,                         -- Komisyon ID (FK: commission.commissions)
    amount numeric(18,2) NOT NULL,                         -- Komisyon tutarı (snapshot)
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE payout.payout_commissions IS 'Junction table linking payouts to their included commissions for audit and reconciliation';

-- =============================================
-- Örnek:
-- Payout #1 (Affiliate D, Ocak 2026):
--
-- | payout_id | commission_id | amount |
-- |-----------|---------------|--------|
-- | 1         | 101           | $500   | → Player X'den
-- | 1         | 102           | $800   | → Player Y'den
-- | 1         | 103           | $500   | → Player Z'den
-- |           |               | $1,800 | TOPLAM
-- =============================================

DROP TABLE IF EXISTS commission.commission_plans CASCADE;

-- Komisyon planları (Sözleşme Seviyesi)
-- Affiliate'lerin hangi oranlarla komisyon alacağını belirleyen planlar
CREATE TABLE commission.commission_plans (
    id bigserial PRIMARY KEY,
    code varchar(50) UNIQUE NOT NULL,       -- Plan kodu
    model varchar(20) NOT NULL,             -- REVSHARE / CPA / HYBRID
    base_currency char(3) NOT NULL,         -- Baz para birimi
    created_at timestamp without time zone NOT NULL DEFAULT now()
);

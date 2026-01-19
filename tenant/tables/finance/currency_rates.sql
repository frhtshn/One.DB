CREATE TABLE finance.currency_rates (
    id bigserial PRIMARY KEY,

    base_currency character(3) NOT NULL,     -- tenant base (TRY / EUR / vs)
    quote_currency character(3) NOT NULL,

    rate numeric(18,8) NOT NULL,
    rate_date date NOT NULL,

    source varchar(50) NOT NULL,              -- xe, layer, fixer, manual
    fetched_at timestamp NOT NULL,            -- API’den alındığı an

    created_at timestamp NOT NULL DEFAULT now()
);


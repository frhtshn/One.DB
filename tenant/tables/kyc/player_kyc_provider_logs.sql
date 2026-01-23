CREATE TABLE kyc.player_kyc_provider_logs (
    id BIGSERIAL PRIMARY KEY,

    kyc_case_id BIGINT NOT NULL,

    provider_code VARCHAR(50) NOT NULL,
    -- SUMSUB, ONFIDO, INTERNAL

    provider_reference VARCHAR(100),

    request_payload JSONB,
    response_payload JSONB,

    status VARCHAR(30),
    -- SUCCESS, FAILED, TIMEOUT

    created_at TIMESTAMP NOT NULL DEFAULT now()
);


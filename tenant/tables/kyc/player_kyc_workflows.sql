CREATE TABLE kyc.player_kyc_workflows (
    id BIGSERIAL PRIMARY KEY,

    kyc_case_id BIGINT NOT NULL,

    previous_status VARCHAR(30),
    current_status VARCHAR(30) NOT NULL,

    action VARCHAR(50),
    -- DOCUMENT_UPLOADED
    -- REVIEW_STARTED
    -- APPROVED
    -- REJECTED
    -- EXPIRED

    performed_by BIGINT,
    -- reviewer / system user

    reason VARCHAR(255),

    created_at TIMESTAMP NOT NULL DEFAULT now()
);


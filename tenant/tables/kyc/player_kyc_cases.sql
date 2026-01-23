CREATE TABLE kyc.player_kyc_cases (
    id BIGSERIAL PRIMARY KEY,

    player_id BIGINT NOT NULL,

    current_status VARCHAR(30) NOT NULL,
    -- NOT_STARTED
    -- IN_REVIEW
    -- APPROVED
    -- REJECTED
    -- SUSPENDED

    kyc_level VARCHAR(20),
    -- BASIC, STANDARD, ENHANCED

    risk_level VARCHAR(20),
    -- LOW, MEDIUM, HIGH

    assigned_reviewer_id BIGINT,

    last_decision_reason VARCHAR(255),

    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);


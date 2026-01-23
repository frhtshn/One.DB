CREATE TABLE kyc.player_documents (
    id BIGSERIAL PRIMARY KEY,

    player_id BIGINT NOT NULL,
    kyc_case_id BIGINT,

    document_type VARCHAR(30) NOT NULL,
    -- IDENTITY
    -- PASSPORT
    -- DRIVER_LICENSE
    -- PROOF_OF_ADDRESS
    -- SELFIE

    file_name VARCHAR(255),
    mime_type VARCHAR(50),

    storage_type VARCHAR(20) NOT NULL,
    -- DB
    -- OBJECT_STORAGE

    file_data BYTEA,
    storage_path VARCHAR(500),

    encryption_key_id VARCHAR(100),

    file_hash BYTEA NOT NULL,
    file_size BIGINT NOT NULL,

    status VARCHAR(30) NOT NULL,
    -- UPLOADED
    -- PENDING_REVIEW
    -- APPROVED
    -- REJECTED
    -- EXPIRED

    rejection_reason VARCHAR(255),

    uploaded_at TIMESTAMP NOT NULL DEFAULT now(),
    reviewed_at TIMESTAMP,
    expires_at TIMESTAMP,

    created_at TIMESTAMP NOT NULL DEFAULT now()
);


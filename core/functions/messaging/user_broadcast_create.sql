-- ================================================================
-- USER_BROADCAST_CREATE: Toplu kullanıcı mesajı oluşturur
-- Filtre bazlı alıcı çözümlemesi (AND kombinasyonu)
-- Filtreler: company, tenant, department, role (tümü opsiyonel)
-- Yetki kontrolü backend'de yapılır
-- Hybrid: subject/body sadece broadcasts tablosunda saklanır
-- ================================================================

DROP FUNCTION IF EXISTS messaging.user_broadcast_create(BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR, VARCHAR, BIGINT, TIMESTAMP, BIGINT);
DROP FUNCTION IF EXISTS messaging.user_broadcast_create(BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR, BIGINT, BIGINT, BIGINT, BIGINT, TIMESTAMP, BIGINT);

CREATE OR REPLACE FUNCTION messaging.user_broadcast_create(
    p_sender_id     BIGINT,                           -- Gönderen kullanıcı ID
    p_subject       VARCHAR(500),                     -- Mesaj konusu
    p_body          TEXT,                              -- Mesaj içeriği (HTML)
    p_message_type  VARCHAR(30) DEFAULT 'announcement', -- Mesaj tipi
    p_priority      VARCHAR(10) DEFAULT 'normal',     -- Öncelik seviyesi
    p_company_id    BIGINT DEFAULT NULL,              -- Şirket filtresi (NULL = tümü)
    p_tenant_id     BIGINT DEFAULT NULL,              -- Tenant filtresi (NULL = tümü)
    p_department_id BIGINT DEFAULT NULL,              -- Departman filtresi (NULL = tümü)
    p_role_id       BIGINT DEFAULT NULL,              -- Rol filtresi (NULL = tümü)
    p_expires_at    TIMESTAMP DEFAULT NULL,           -- Opsiyonel süre sonu
    p_created_by    BIGINT DEFAULT NULL               -- Oluşturan (NULL ise sender_id kullanılır)
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_broadcast_id INTEGER;
    v_recipient_count INTEGER;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_sender_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.sender-id-required';
    END IF;

    IF p_subject IS NULL OR p_subject = '' THEN
        RAISE EXCEPTION 'error.messaging.subject-required';
    END IF;

    IF p_body IS NULL OR p_body = '' THEN
        RAISE EXCEPTION 'error.messaging.body-required';
    END IF;

    -- 1. Broadcast kaydı oluştur
    INSERT INTO messaging.user_message_broadcasts (
        sender_id, subject, body, message_type, priority,
        company_id, tenant_id, department_id, role_id,
        expires_at, created_by
    ) VALUES (
        p_sender_id, p_subject, p_body, p_message_type, p_priority,
        p_company_id, p_tenant_id, p_department_id, p_role_id,
        p_expires_at, COALESCE(p_created_by, p_sender_id)
    )
    RETURNING id INTO v_broadcast_id;

    -- 2. Filtre bazlı alıcı çözümlemesi (AND kombinasyonu)
    WITH resolved_recipients AS (
        SELECT DISTINCT u.id AS recipient_id
        FROM security.users u
        WHERE u.status = 1
          AND u.id != p_sender_id

          -- Şirket filtresi
          AND (p_company_id IS NULL OR u.company_id = p_company_id)

          -- Tenant filtresi: açık erişim VEYA company superadmin (tenant kısıtlaması olmayan)
          AND (p_tenant_id IS NULL OR (
              EXISTS (
                  SELECT 1 FROM security.user_allowed_tenants uat
                  WHERE uat.user_id = u.id AND uat.tenant_id = p_tenant_id
              )
              OR (
                  EXISTS (
                      SELECT 1 FROM core.tenants t
                      WHERE t.id = p_tenant_id AND t.company_id = u.company_id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM security.user_allowed_tenants sat
                      WHERE sat.user_id = u.id
                  )
              )
          ))

          -- Departman filtresi
          AND (p_department_id IS NULL OR EXISTS (
              SELECT 1 FROM core.user_departments ud
              WHERE ud.user_id = u.id AND ud.department_id = p_department_id
          ))

          -- Rol filtresi (tenant varsa o tenant'taki veya global rol aranır)
          AND (p_role_id IS NULL OR EXISTS (
              SELECT 1 FROM security.user_roles ur
              WHERE ur.user_id = u.id
                AND ur.role_id = p_role_id
                AND (p_tenant_id IS NULL OR ur.tenant_id IS NULL OR ur.tenant_id = p_tenant_id)
          ))
    )
    -- Hybrid: subject/body broadcast tablosunda kalır, user_messages'a kopyalanmaz
    INSERT INTO messaging.user_messages (
        recipient_id, broadcast_id, sender_id,
        message_type, priority, expires_at
    )
    SELECT
        rr.recipient_id,
        v_broadcast_id,
        p_sender_id,
        p_message_type,
        p_priority,
        p_expires_at
    FROM resolved_recipients rr;

    -- 3. Alıcı sayısını güncelle
    GET DIAGNOSTICS v_recipient_count = ROW_COUNT;

    UPDATE messaging.user_message_broadcasts
    SET total_recipients = v_recipient_count
    WHERE id = v_broadcast_id;

    RETURN v_broadcast_id;
END;
$$;

COMMENT ON FUNCTION messaging.user_broadcast_create(BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR, BIGINT, BIGINT, BIGINT, BIGINT, TIMESTAMP, BIGINT) IS 'Create a broadcast with filter-based recipient resolution. Filters (company/tenant/department/role) are AND-combined. Hybrid storage: subject/body only in broadcasts table.';

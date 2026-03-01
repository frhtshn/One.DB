-- =============================================
-- Client Support Schema Indexes
-- =============================================

-- ================================================================
-- tickets indeksleri
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_support_tickets_player
    ON support.tickets (player_id);

CREATE INDEX IF NOT EXISTS idx_support_tickets_status
    ON support.tickets (status);

CREATE INDEX IF NOT EXISTS idx_support_tickets_assigned
    ON support.tickets (assigned_to_id)
    WHERE assigned_to_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_support_tickets_category
    ON support.tickets (category_id)
    WHERE category_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_support_tickets_channel
    ON support.tickets (channel);

CREATE INDEX IF NOT EXISTS idx_support_tickets_priority_created
    ON support.tickets (priority DESC, created_at ASC);

-- Kuyruk sorgusu: open/reopened ticketlar, priority'ye göre
CREATE INDEX IF NOT EXISTS idx_support_tickets_open_queue
    ON support.tickets (priority DESC, created_at ASC)
    WHERE status IN ('open', 'reopened');

CREATE INDEX IF NOT EXISTS idx_support_tickets_created
    ON support.tickets (created_at DESC);

-- ================================================================
-- ticket_actions indeksleri
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_support_ticket_actions_ticket
    ON support.ticket_actions (ticket_id);

CREATE INDEX IF NOT EXISTS idx_support_ticket_actions_ticket_created
    ON support.ticket_actions (ticket_id, created_at);

-- ================================================================
-- ticket_tag_assignments indeksleri
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_support_tag_assignments_ticket
    ON support.ticket_tag_assignments (ticket_id);

CREATE INDEX IF NOT EXISTS idx_support_tag_assignments_tag
    ON support.ticket_tag_assignments (tag_id);

-- ================================================================
-- player_notes indeksleri
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_support_player_notes_player
    ON support.player_notes (player_id)
    WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_support_player_notes_pinned
    ON support.player_notes (player_id, is_pinned DESC, created_at DESC)
    WHERE is_active = true;

-- ================================================================
-- agent_settings indeksleri
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_support_agent_settings_user
    ON support.agent_settings (user_id)
    WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_support_agent_settings_available
    ON support.agent_settings (is_available)
    WHERE is_active = true AND is_available = true;

-- ================================================================
-- player_representatives indeksleri
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_support_player_rep_player
    ON support.player_representatives (player_id);

CREATE INDEX IF NOT EXISTS idx_support_player_rep_representative
    ON support.player_representatives (representative_id);

-- ================================================================
-- player_representative_history indeksleri
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_support_player_rep_history_player
    ON support.player_representative_history (player_id, changed_at DESC);

CREATE INDEX IF NOT EXISTS idx_support_player_rep_history_representative
    ON support.player_representative_history (new_representative_id);

-- ================================================================
-- welcome_call_tasks indeksleri
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_support_welcome_tasks_status
    ON support.welcome_call_tasks (status);

-- Kuyruk: pending görevler, oluşturulma sırasına göre
CREATE INDEX IF NOT EXISTS idx_support_welcome_tasks_queue
    ON support.welcome_call_tasks (created_at ASC)
    WHERE status = 'pending';

CREATE INDEX IF NOT EXISTS idx_support_welcome_tasks_assigned
    ON support.welcome_call_tasks (assigned_to_id)
    WHERE assigned_to_id IS NOT NULL;

-- Yeniden planlanan görevler, sonraki deneme zamanına göre
CREATE INDEX IF NOT EXISTS idx_support_welcome_tasks_reschedule
    ON support.welcome_call_tasks (next_attempt_at ASC)
    WHERE status = 'rescheduled' AND next_attempt_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_support_welcome_tasks_player
    ON support.welcome_call_tasks (player_id);

-- ================================================================
-- canned_responses indeksleri
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_support_canned_responses_category
    ON support.canned_responses (category_id)
    WHERE is_active = true;

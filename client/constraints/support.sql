-- =============================================
-- Client Support Schema Foreign Key Constraints
-- =============================================

-- ticket_actions → tickets
ALTER TABLE support.ticket_actions
    ADD CONSTRAINT fk_ticket_actions_ticket
    FOREIGN KEY (ticket_id) REFERENCES support.tickets(id);

-- tickets → ticket_categories
ALTER TABLE support.tickets
    ADD CONSTRAINT fk_tickets_category
    FOREIGN KEY (category_id) REFERENCES support.ticket_categories(id);

-- ticket_tag_assignments → tickets
ALTER TABLE support.ticket_tag_assignments
    ADD CONSTRAINT fk_tag_assignments_ticket
    FOREIGN KEY (ticket_id) REFERENCES support.tickets(id);

-- ticket_tag_assignments → ticket_tags
ALTER TABLE support.ticket_tag_assignments
    ADD CONSTRAINT fk_tag_assignments_tag
    FOREIGN KEY (tag_id) REFERENCES support.ticket_tags(id);

-- canned_responses → ticket_categories (opsiyonel)
ALTER TABLE support.canned_responses
    ADD CONSTRAINT fk_canned_responses_category
    FOREIGN KEY (category_id) REFERENCES support.ticket_categories(id);

-- ticket_categories → ticket_categories (self-ref, hiyerarşi)
ALTER TABLE support.ticket_categories
    ADD CONSTRAINT fk_ticket_categories_parent
    FOREIGN KEY (parent_id) REFERENCES support.ticket_categories(id);

-- NOT: player_representatives, player_representative_history, welcome_call_tasks,
-- agent_settings tablolarındaki player_id, user_id, representative_id alanları
-- cross-DB referans olduğu için FK tanımlanmaz. Backend app-level bütünlük sağlar.

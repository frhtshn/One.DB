-- content_category_translations
ALTER TABLE content.content_category_translations
    ADD CONSTRAINT fk_content_category_trans_category
    FOREIGN KEY (category_id) REFERENCES content.content_categories(id) ON DELETE CASCADE;

ALTER TABLE content.content_category_translations
    ADD CONSTRAINT uq_content_category_trans UNIQUE (category_id, language_id);

-- content_types
ALTER TABLE content.content_types
    ADD CONSTRAINT fk_content_types_category
    FOREIGN KEY (category_id) REFERENCES content.content_categories(id) ON DELETE SET NULL;

-- content_type_translations
ALTER TABLE content.content_type_translations
    ADD CONSTRAINT fk_content_type_trans_type
    FOREIGN KEY (content_type_id) REFERENCES content.content_types(id) ON DELETE CASCADE;

ALTER TABLE content.content_type_translations
    ADD CONSTRAINT uq_content_type_trans UNIQUE (content_type_id, language_id);

-- contents
ALTER TABLE content.contents
    ADD CONSTRAINT fk_contents_type
    FOREIGN KEY (content_type_id) REFERENCES content.content_types(id);

ALTER TABLE content.contents
    ADD CONSTRAINT chk_contents_status CHECK (status IN ('draft', 'published', 'archived'));

-- content_translations
ALTER TABLE content.content_translations
    ADD CONSTRAINT fk_content_trans_content
    FOREIGN KEY (content_id) REFERENCES content.contents(id) ON DELETE CASCADE;

ALTER TABLE content.content_translations
    ADD CONSTRAINT uq_content_trans UNIQUE (content_id, language_id);

ALTER TABLE content.content_translations
    ADD CONSTRAINT chk_content_trans_status CHECK (status IN ('draft', 'published', 'needs_review'));

-- content_versions
ALTER TABLE content.content_versions
    ADD CONSTRAINT fk_content_versions_content
    FOREIGN KEY (content_id) REFERENCES content.contents(id) ON DELETE CASCADE;

ALTER TABLE content.content_versions
    ADD CONSTRAINT uq_content_versions UNIQUE (content_id, language_id, version);

-- content_attachments
ALTER TABLE content.content_attachments
    ADD CONSTRAINT fk_content_attachments_content
    FOREIGN KEY (content_id) REFERENCES content.contents(id) ON DELETE CASCADE;

-- faq_category_translations
ALTER TABLE content.faq_category_translations
    ADD CONSTRAINT fk_faq_category_trans_category
    FOREIGN KEY (category_id) REFERENCES content.faq_categories(id) ON DELETE CASCADE;

ALTER TABLE content.faq_category_translations
    ADD CONSTRAINT uq_faq_category_trans UNIQUE (category_id, language_id);

-- faq_items
ALTER TABLE content.faq_items
    ADD CONSTRAINT fk_faq_items_category
    FOREIGN KEY (category_id) REFERENCES content.faq_categories(id) ON DELETE SET NULL;

-- faq_item_translations
ALTER TABLE content.faq_item_translations
    ADD CONSTRAINT fk_faq_item_trans_item
    FOREIGN KEY (faq_item_id) REFERENCES content.faq_items(id) ON DELETE CASCADE;

ALTER TABLE content.faq_item_translations
    ADD CONSTRAINT uq_faq_item_trans UNIQUE (faq_item_id, language_id);

ALTER TABLE content.faq_item_translations
    ADD CONSTRAINT chk_faq_item_trans_status CHECK (status IN ('draft', 'published'));

-- promotions
ALTER TABLE content.promotions
    ADD CONSTRAINT chk_promotions_type CHECK (promo_type IN ('general', 'welcome', 'deposit', 'cashback', 'freespin', 'tournament', 'vip', 'seasonal'));

-- promotion_translations
ALTER TABLE content.promotion_translations
    ADD CONSTRAINT fk_promotion_trans_promotion
    FOREIGN KEY (promotion_id) REFERENCES content.promotions(id) ON DELETE CASCADE;

ALTER TABLE content.promotion_translations
    ADD CONSTRAINT uq_promotion_trans UNIQUE (promotion_id, language_id);

ALTER TABLE content.promotion_translations
    ADD CONSTRAINT chk_promotion_trans_status CHECK (status IN ('draft', 'published'));

-- promotion_banners
ALTER TABLE content.promotion_banners
    ADD CONSTRAINT fk_promotion_banners_promotion
    FOREIGN KEY (promotion_id) REFERENCES content.promotions(id) ON DELETE CASCADE;

ALTER TABLE content.promotion_banners
    ADD CONSTRAINT chk_promotion_banners_device CHECK (device_type IN ('desktop', 'mobile', 'tablet', 'app'));

-- promotion_display_locations
ALTER TABLE content.promotion_display_locations
    ADD CONSTRAINT fk_promotion_display_promotion
    FOREIGN KEY (promotion_id) REFERENCES content.promotions(id) ON DELETE CASCADE;

ALTER TABLE content.promotion_display_locations
    ADD CONSTRAINT uq_promotion_display UNIQUE (promotion_id, location_code);

ALTER TABLE content.promotion_display_locations
    ADD CONSTRAINT chk_promotion_display_location CHECK (location_code IN ('homepage', 'lobby', 'deposit', 'profile', 'promotions_page', 'slider', 'popup', 'sidebar'));

-- promotion_segments
ALTER TABLE content.promotion_segments
    ADD CONSTRAINT fk_promotion_segments_promotion
    FOREIGN KEY (promotion_id) REFERENCES content.promotions(id) ON DELETE CASCADE;

ALTER TABLE content.promotion_segments
    ADD CONSTRAINT chk_promotion_segments_type CHECK (segment_type IN ('player_category', 'player_group', 'vip_level', 'country', 'currency', 'registration_date', 'deposit_count', 'custom'));

-- promotion_games
ALTER TABLE content.promotion_games
    ADD CONSTRAINT fk_promotion_games_promotion
    FOREIGN KEY (promotion_id) REFERENCES content.promotions(id) ON DELETE CASCADE;

ALTER TABLE content.promotion_games
    ADD CONSTRAINT chk_promotion_games_filter CHECK (filter_type IN ('game', 'provider', 'category', 'tag'));

-- content_category_translations
ALTER TABLE content.content_category_translations
    ADD CONSTRAINT fk_content_category_trans_category
    FOREIGN KEY (category_id) REFERENCES content.content_categories(id) ON DELETE CASCADE;

ALTER TABLE content.content_category_translations
    ADD CONSTRAINT uq_content_category_trans UNIQUE (category_id, language_code);

-- content_types
ALTER TABLE content.content_types
    ADD CONSTRAINT fk_content_types_category
    FOREIGN KEY (category_id) REFERENCES content.content_categories(id) ON DELETE SET NULL;

-- content_type_translations
ALTER TABLE content.content_type_translations
    ADD CONSTRAINT fk_content_type_trans_type
    FOREIGN KEY (content_type_id) REFERENCES content.content_types(id) ON DELETE CASCADE;

ALTER TABLE content.content_type_translations
    ADD CONSTRAINT uq_content_type_trans UNIQUE (content_type_id, language_code);

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
    ADD CONSTRAINT uq_content_trans UNIQUE (content_id, language_code);

ALTER TABLE content.content_translations
    ADD CONSTRAINT chk_content_trans_status CHECK (status IN ('draft', 'published', 'needs_review'));

-- content_versions
ALTER TABLE content.content_versions
    ADD CONSTRAINT fk_content_versions_content
    FOREIGN KEY (content_id) REFERENCES content.contents(id) ON DELETE CASCADE;

ALTER TABLE content.content_versions
    ADD CONSTRAINT uq_content_versions UNIQUE (content_id, language_code, version);

-- content_attachments
ALTER TABLE content.content_attachments
    ADD CONSTRAINT fk_content_attachments_content
    FOREIGN KEY (content_id) REFERENCES content.contents(id) ON DELETE CASCADE;

-- faq_category_translations
ALTER TABLE content.faq_category_translations
    ADD CONSTRAINT fk_faq_category_trans_category
    FOREIGN KEY (category_id) REFERENCES content.faq_categories(id) ON DELETE CASCADE;

ALTER TABLE content.faq_category_translations
    ADD CONSTRAINT uq_faq_category_trans UNIQUE (category_id, language_code);

-- faq_items
ALTER TABLE content.faq_items
    ADD CONSTRAINT fk_faq_items_category
    FOREIGN KEY (category_id) REFERENCES content.faq_categories(id) ON DELETE SET NULL;

-- faq_item_translations
ALTER TABLE content.faq_item_translations
    ADD CONSTRAINT fk_faq_item_trans_item
    FOREIGN KEY (faq_item_id) REFERENCES content.faq_items(id) ON DELETE CASCADE;

ALTER TABLE content.faq_item_translations
    ADD CONSTRAINT uq_faq_item_trans UNIQUE (faq_item_id, language_code);

ALTER TABLE content.faq_item_translations
    ADD CONSTRAINT chk_faq_item_trans_status CHECK (status IN ('draft', 'published'));

-- NOTE: promotions tipi artık promotion_types tablosunda FK ile yönetiliyor (promo_type CHECK kaldırıldı)

-- promotion_translations
ALTER TABLE content.promotion_translations
    ADD CONSTRAINT fk_promotion_trans_promotion
    FOREIGN KEY (promotion_id) REFERENCES content.promotions(id) ON DELETE CASCADE;

ALTER TABLE content.promotion_translations
    ADD CONSTRAINT uq_promotion_trans UNIQUE (promotion_id, language_code);

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

-- =============================================
-- SLIDE MANAGEMENT CONSTRAINTS
-- =============================================

-- slide_category_translations
ALTER TABLE content.slide_category_translations
    ADD CONSTRAINT fk_slide_category_trans_category
    FOREIGN KEY (category_id) REFERENCES content.slide_categories(id) ON DELETE CASCADE;

-- slides
ALTER TABLE content.slides
    ADD CONSTRAINT fk_slides_placement
    FOREIGN KEY (placement_id) REFERENCES content.slide_placements(id);

ALTER TABLE content.slides
    ADD CONSTRAINT fk_slides_category
    FOREIGN KEY (category_id) REFERENCES content.slide_categories(id) ON DELETE SET NULL;

ALTER TABLE content.slides
    ADD CONSTRAINT chk_slides_link_target CHECK (link_target IN ('_self', '_blank', '_modal'));

ALTER TABLE content.slides
    ADD CONSTRAINT chk_slides_link_type CHECK (link_type IN ('url', 'game', 'promotion', 'page', 'deposit', 'register'));

ALTER TABLE content.slides
    ADD CONSTRAINT chk_slides_animation CHECK (animation_type IN ('fade', 'slide', 'zoom', 'none'));

-- slide_translations
ALTER TABLE content.slide_translations
    ADD CONSTRAINT fk_slide_trans_slide
    FOREIGN KEY (slide_id) REFERENCES content.slides(id) ON DELETE CASCADE;

-- slide_images
ALTER TABLE content.slide_images
    ADD CONSTRAINT fk_slide_images_slide
    FOREIGN KEY (slide_id) REFERENCES content.slides(id) ON DELETE CASCADE;

ALTER TABLE content.slide_images
    ADD CONSTRAINT chk_slide_images_device CHECK (device_type IN ('desktop', 'mobile', 'tablet', 'app'));

-- slide_schedules
ALTER TABLE content.slide_schedules
    ADD CONSTRAINT fk_slide_schedules_slide
    FOREIGN KEY (slide_id) REFERENCES content.slides(id) ON DELETE CASCADE;

-- =============================================
-- POPUP MANAGEMENT CONSTRAINTS
-- =============================================

-- popup_type_translations
ALTER TABLE content.popup_type_translations
    ADD CONSTRAINT fk_popup_type_trans_type
    FOREIGN KEY (popup_type_id) REFERENCES content.popup_types(id) ON DELETE CASCADE;

-- popups
ALTER TABLE content.popups
    ADD CONSTRAINT fk_popups_type
    FOREIGN KEY (popup_type_id) REFERENCES content.popup_types(id);

ALTER TABLE content.popups
    ADD CONSTRAINT chk_popups_trigger_type CHECK (trigger_type IN ('immediate', 'delay', 'scroll', 'exit_intent', 'click', 'login', 'first_visit', 'returning_visit'));

ALTER TABLE content.popups
    ADD CONSTRAINT chk_popups_frequency_type CHECK (frequency_type IN ('always', 'once_per_session', 'once_per_day', 'once_per_week', 'once_ever', 'custom'));

ALTER TABLE content.popups
    ADD CONSTRAINT chk_popups_link_target CHECK (link_target IN ('_self', '_blank'));

-- popup_translations
ALTER TABLE content.popup_translations
    ADD CONSTRAINT fk_popup_trans_popup
    FOREIGN KEY (popup_id) REFERENCES content.popups(id) ON DELETE CASCADE;

-- popup_images
ALTER TABLE content.popup_images
    ADD CONSTRAINT fk_popup_images_popup
    FOREIGN KEY (popup_id) REFERENCES content.popups(id) ON DELETE CASCADE;

ALTER TABLE content.popup_images
    ADD CONSTRAINT chk_popup_images_device CHECK (device_type IN ('desktop', 'mobile', 'tablet', 'app'));

ALTER TABLE content.popup_images
    ADD CONSTRAINT chk_popup_images_position CHECK (image_position IN ('top', 'bottom', 'left', 'right', 'background', 'full'));

ALTER TABLE content.popup_images
    ADD CONSTRAINT chk_popup_images_object_fit CHECK (object_fit IN ('cover', 'contain', 'fill', 'none'));

-- popup_schedules
ALTER TABLE content.popup_schedules
    ADD CONSTRAINT fk_popup_schedules_popup
    FOREIGN KEY (popup_id) REFERENCES content.popups(id) ON DELETE CASCADE;

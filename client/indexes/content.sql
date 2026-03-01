-- content_categories
CREATE INDEX idx_content_categories_active ON content.content_categories(is_active);
CREATE INDEX idx_content_categories_sort ON content.content_categories(sort_order);
CREATE UNIQUE INDEX idx_content_categories_code ON content.content_categories USING btree(code);

-- content_category_translations
CREATE INDEX idx_content_category_trans_category ON content.content_category_translations(category_id);
CREATE INDEX idx_content_category_trans_language ON content.content_category_translations(language_code);

-- content_types
CREATE INDEX idx_content_types_category ON content.content_types(category_id);
CREATE INDEX idx_content_types_active ON content.content_types(is_active);
CREATE INDEX idx_content_types_footer ON content.content_types(show_in_footer) WHERE show_in_footer = TRUE;
CREATE INDEX idx_content_types_menu ON content.content_types(show_in_menu) WHERE show_in_menu = TRUE;
CREATE UNIQUE INDEX idx_content_types_code ON content.content_types USING btree(code);

-- content_type_translations
CREATE INDEX idx_content_type_trans_type ON content.content_type_translations(content_type_id);
CREATE INDEX idx_content_type_trans_language ON content.content_type_translations(language_code);

-- contents
CREATE INDEX idx_contents_type ON content.contents(content_type_id);
CREATE UNIQUE INDEX idx_contents_slug_unique ON content.contents USING btree(slug);
CREATE INDEX idx_contents_status ON content.contents(status);
CREATE INDEX idx_contents_published ON content.contents(status, published_at) WHERE status = 'published';

-- content_translations
CREATE INDEX idx_content_trans_content ON content.content_translations(content_id);
CREATE INDEX idx_content_trans_language ON content.content_translations(language_code);
CREATE INDEX idx_content_trans_status ON content.content_translations(content_id, status);

-- content_versions
CREATE INDEX idx_content_versions_content ON content.content_versions(content_id);
CREATE INDEX idx_content_versions_lookup ON content.content_versions(content_id, language_code, version DESC);

-- content_attachments
CREATE INDEX idx_content_attachments_content ON content.content_attachments(content_id);
CREATE INDEX idx_content_attachments_featured ON content.content_attachments(content_id, is_featured) WHERE is_featured = TRUE;

-- faq_categories
CREATE INDEX idx_faq_categories_active ON content.faq_categories(is_active);
CREATE INDEX idx_faq_categories_sort ON content.faq_categories(sort_order);
CREATE UNIQUE INDEX idx_faq_categories_code ON content.faq_categories USING btree(code);

-- faq_category_translations
CREATE INDEX idx_faq_category_trans_category ON content.faq_category_translations(category_id);
CREATE INDEX idx_faq_category_trans_language ON content.faq_category_translations(language_code);

-- faq_items
CREATE INDEX idx_faq_items_category ON content.faq_items(category_id);
CREATE INDEX idx_faq_items_featured ON content.faq_items(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_faq_items_active ON content.faq_items(is_active);

-- faq_item_translations
CREATE INDEX idx_faq_item_trans_item ON content.faq_item_translations(faq_item_id);
CREATE INDEX idx_faq_item_trans_language ON content.faq_item_translations(language_code);
CREATE INDEX idx_faq_item_trans_status ON content.faq_item_translations(faq_item_id, status);

-- promotions
CREATE INDEX idx_promotions_active ON content.promotions(is_active);
CREATE INDEX idx_promotions_dates ON content.promotions(start_date, end_date);
CREATE INDEX idx_promotions_type ON content.promotions(promotion_type_id);
CREATE INDEX idx_promotions_featured ON content.promotions(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_promotions_bonus ON content.promotions(bonus_id) WHERE bonus_id IS NOT NULL;
CREATE UNIQUE INDEX idx_promotions_code ON content.promotions USING btree(code);

-- promotion_translations
CREATE INDEX idx_promotion_trans_promotion ON content.promotion_translations(promotion_id);
CREATE INDEX idx_promotion_trans_language ON content.promotion_translations(language_code);

-- promotion_banners
CREATE INDEX idx_promotion_banners_promotion ON content.promotion_banners(promotion_id);
CREATE INDEX idx_promotion_banners_device ON content.promotion_banners(promotion_id, device_type);

-- promotion_display_locations
CREATE INDEX idx_promotion_display_promotion ON content.promotion_display_locations(promotion_id);
CREATE INDEX idx_promotion_display_location ON content.promotion_display_locations(location_code);

-- promotion_segments
CREATE INDEX idx_promotion_segments_promotion ON content.promotion_segments(promotion_id);
CREATE INDEX idx_promotion_segments_type ON content.promotion_segments(segment_type, segment_value);

-- promotion_games
CREATE INDEX idx_promotion_games_promotion ON content.promotion_games(promotion_id);
CREATE INDEX idx_promotion_games_filter ON content.promotion_games(filter_type, filter_value);

-- =============================================
-- SLIDE MANAGEMENT INDEXES
-- =============================================

-- slide_placements
CREATE UNIQUE INDEX idx_slide_placements_code ON content.slide_placements(code);
CREATE INDEX idx_slide_placements_active ON content.slide_placements(is_active);

-- slide_categories
CREATE UNIQUE INDEX idx_slide_categories_code ON content.slide_categories(code);
CREATE INDEX idx_slide_categories_active ON content.slide_categories(is_active);
CREATE INDEX idx_slide_categories_sort ON content.slide_categories(sort_order);

-- slide_category_translations
CREATE INDEX idx_slide_category_trans_category ON content.slide_category_translations(category_id);
CREATE INDEX idx_slide_category_trans_language ON content.slide_category_translations(language_code);
CREATE UNIQUE INDEX idx_slide_category_trans_unique ON content.slide_category_translations USING btree(category_id, language_code);

-- slides
CREATE UNIQUE INDEX idx_slides_code ON content.slides(code) WHERE code IS NOT NULL;
CREATE INDEX idx_slides_placement ON content.slides(placement_id);
CREATE INDEX idx_slides_category ON content.slides(category_id);
CREATE INDEX idx_slides_active ON content.slides(is_active, is_deleted) WHERE is_active = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_slides_dates ON content.slides(start_date, end_date);
CREATE INDEX idx_slides_placement_order ON content.slides(placement_id, sort_order, priority DESC) WHERE is_active = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_slides_segments ON content.slides USING GIN(segment_ids) WHERE segment_ids IS NOT NULL;
CREATE INDEX idx_slides_countries ON content.slides USING GIN(country_codes) WHERE country_codes IS NOT NULL;

-- slide_translations
CREATE INDEX idx_slide_trans_slide ON content.slide_translations(slide_id);
CREATE INDEX idx_slide_trans_language ON content.slide_translations(language_code);
CREATE UNIQUE INDEX idx_slide_trans_unique ON content.slide_translations USING btree(slide_id, language_code);

-- slide_images
CREATE INDEX idx_slide_images_slide ON content.slide_images(slide_id);
CREATE INDEX idx_slide_images_device ON content.slide_images(slide_id, device_type);
CREATE INDEX idx_slide_images_language ON content.slide_images(slide_id, language_code) WHERE language_code IS NOT NULL;

-- slide_schedules
CREATE INDEX idx_slide_schedules_slide ON content.slide_schedules(slide_id);
CREATE INDEX idx_slide_schedules_active ON content.slide_schedules(slide_id, is_active) WHERE is_active = TRUE;

-- =============================================
-- POPUP MANAGEMENT INDEXES
-- =============================================

-- popup_types
CREATE UNIQUE INDEX idx_popup_types_code ON content.popup_types(code);
CREATE INDEX idx_popup_types_active ON content.popup_types(is_active);

-- popup_type_translations
CREATE INDEX idx_popup_type_trans_type ON content.popup_type_translations(popup_type_id);
CREATE INDEX idx_popup_type_trans_language ON content.popup_type_translations(language_code);
CREATE UNIQUE INDEX idx_popup_type_trans_unique ON content.popup_type_translations USING btree(popup_type_id, language_code);

-- popups
CREATE UNIQUE INDEX idx_popups_code ON content.popups(code) WHERE code IS NOT NULL;
CREATE INDEX idx_popups_type ON content.popups(popup_type_id);
CREATE INDEX idx_popups_active ON content.popups(is_active, is_deleted) WHERE is_active = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_popups_dates ON content.popups(start_date, end_date);
CREATE INDEX idx_popups_trigger ON content.popups(trigger_type);
CREATE INDEX idx_popups_priority ON content.popups(priority DESC) WHERE is_active = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_popups_segments ON content.popups USING GIN(segment_ids) WHERE segment_ids IS NOT NULL;
CREATE INDEX idx_popups_countries ON content.popups USING GIN(country_codes) WHERE country_codes IS NOT NULL;
CREATE INDEX idx_popups_pages ON content.popups USING GIN(page_urls) WHERE page_urls IS NOT NULL;

-- popup_translations
CREATE INDEX idx_popup_trans_popup ON content.popup_translations(popup_id);
CREATE INDEX idx_popup_trans_language ON content.popup_translations(language_code);
CREATE UNIQUE INDEX idx_popup_trans_unique ON content.popup_translations USING btree(popup_id, language_code);

-- popup_images
CREATE INDEX idx_popup_images_popup ON content.popup_images(popup_id);
CREATE INDEX idx_popup_images_device ON content.popup_images(popup_id, device_type);
CREATE INDEX idx_popup_images_language ON content.popup_images(popup_id, language_code) WHERE language_code IS NOT NULL;

-- popup_schedules
CREATE INDEX idx_popup_schedules_popup ON content.popup_schedules(popup_id);
CREATE INDEX idx_popup_schedules_active ON content.popup_schedules(popup_id, is_active) WHERE is_active = TRUE;

-- =============================================
-- trust_logos
-- =============================================
CREATE INDEX IF NOT EXISTS idx_trust_logos_type_active ON content.trust_logos(logo_type, is_active);
CREATE INDEX IF NOT EXISTS idx_trust_logos_display_order ON content.trust_logos(display_order) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_trust_logos_country_codes ON content.trust_logos USING GIN(country_codes);

-- =============================================
-- operator_licenses
-- =============================================
CREATE INDEX IF NOT EXISTS idx_operator_licenses_jurisdiction ON content.operator_licenses(jurisdiction_id, is_active);
CREATE INDEX IF NOT EXISTS idx_operator_licenses_expiry ON content.operator_licenses(expiry_date) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_operator_licenses_country_codes ON content.operator_licenses USING GIN(country_codes);

-- =============================================
-- seo_redirects
-- =============================================
CREATE INDEX IF NOT EXISTS idx_seo_redirects_active ON content.seo_redirects(is_active);

-- content_categories
CREATE INDEX idx_content_categories_active ON content.content_categories(is_active);
CREATE INDEX idx_content_categories_sort ON content.content_categories(sort_order);

-- content_category_translations
CREATE INDEX idx_content_category_trans_category ON content.content_category_translations(category_id);
CREATE INDEX idx_content_category_trans_language ON content.content_category_translations(language_id);

-- content_types
CREATE INDEX idx_content_types_category ON content.content_types(category_id);
CREATE INDEX idx_content_types_active ON content.content_types(is_active);
CREATE INDEX idx_content_types_footer ON content.content_types(show_in_footer) WHERE show_in_footer = TRUE;
CREATE INDEX idx_content_types_menu ON content.content_types(show_in_menu) WHERE show_in_menu = TRUE;

-- content_type_translations
CREATE INDEX idx_content_type_trans_type ON content.content_type_translations(content_type_id);
CREATE INDEX idx_content_type_trans_language ON content.content_type_translations(language_id);

-- contents
CREATE INDEX idx_contents_type ON content.contents(content_type_id);
CREATE INDEX idx_contents_slug ON content.contents(slug);
CREATE INDEX idx_contents_status ON content.contents(status);
CREATE INDEX idx_contents_published ON content.contents(status, published_at) WHERE status = 'published';

-- content_translations
CREATE INDEX idx_content_trans_content ON content.content_translations(content_id);
CREATE INDEX idx_content_trans_language ON content.content_translations(language_id);
CREATE INDEX idx_content_trans_status ON content.content_translations(content_id, status);

-- content_versions
CREATE INDEX idx_content_versions_content ON content.content_versions(content_id);
CREATE INDEX idx_content_versions_lookup ON content.content_versions(content_id, language_id, version DESC);

-- content_attachments
CREATE INDEX idx_content_attachments_content ON content.content_attachments(content_id);
CREATE INDEX idx_content_attachments_featured ON content.content_attachments(content_id, is_featured) WHERE is_featured = TRUE;

-- faq_categories
CREATE INDEX idx_faq_categories_active ON content.faq_categories(is_active);
CREATE INDEX idx_faq_categories_sort ON content.faq_categories(sort_order);

-- faq_category_translations
CREATE INDEX idx_faq_category_trans_category ON content.faq_category_translations(category_id);
CREATE INDEX idx_faq_category_trans_language ON content.faq_category_translations(language_id);

-- faq_items
CREATE INDEX idx_faq_items_category ON content.faq_items(category_id);
CREATE INDEX idx_faq_items_featured ON content.faq_items(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_faq_items_active ON content.faq_items(is_active);

-- faq_item_translations
CREATE INDEX idx_faq_item_trans_item ON content.faq_item_translations(faq_item_id);
CREATE INDEX idx_faq_item_trans_language ON content.faq_item_translations(language_id);
CREATE INDEX idx_faq_item_trans_status ON content.faq_item_translations(faq_item_id, status);

-- promotions
CREATE INDEX idx_promotions_active ON content.promotions(is_active);
CREATE INDEX idx_promotions_dates ON content.promotions(start_date, end_date);
CREATE INDEX idx_promotions_type ON content.promotions(promo_type);
CREATE INDEX idx_promotions_featured ON content.promotions(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_promotions_bonus ON content.promotions(bonus_id) WHERE bonus_id IS NOT NULL;

-- promotion_translations
CREATE INDEX idx_promotion_trans_promotion ON content.promotion_translations(promotion_id);
CREATE INDEX idx_promotion_trans_language ON content.promotion_translations(language_id);

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

-- Catalog Schema Indexes
-- FK indexes for optimal JOIN performance

-- providers.provider_type_id -> provider_types.id
CREATE INDEX IF NOT EXISTS idx_providers_provider_type_id ON catalog.providers USING btree(provider_type_id);

-- providers.provider_code (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_providers_provider_code ON catalog.providers USING btree(provider_code);

-- provider_settings.provider_id -> providers.id
CREATE INDEX IF NOT EXISTS idx_provider_settings_provider_id ON catalog.provider_settings USING btree(provider_id);

-- localization_values.localization_key_id -> localization_keys.id
CREATE INDEX IF NOT EXISTS idx_localization_values_key_id ON catalog.localization_values USING btree(localization_key_id);

-- localization_values.language_code (localization_messages_get, localization_export functions)
CREATE INDEX IF NOT EXISTS idx_localization_values_language ON catalog.localization_values USING btree(language_code);

-- localization_values (lookup by key + language)
CREATE UNIQUE INDEX IF NOT EXISTS idx_localization_values_key_lang ON catalog.localization_values USING btree(localization_key_id, language_code);

-- localization_keys.localization_key (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_localization_keys_key ON catalog.localization_keys USING btree(localization_key);

-- localization_keys (lookup by domain/category)
CREATE INDEX IF NOT EXISTS idx_localization_keys_domain ON catalog.localization_keys USING btree(domain);
CREATE INDEX IF NOT EXISTS idx_localization_keys_category ON catalog.localization_keys USING btree(category);

-- transaction_types indexes
CREATE UNIQUE INDEX IF NOT EXISTS idx_transaction_types_code ON catalog.transaction_types USING btree(code);
CREATE INDEX IF NOT EXISTS idx_transaction_types_category ON catalog.transaction_types USING btree(category);
CREATE INDEX IF NOT EXISTS idx_transaction_types_product ON catalog.transaction_types USING btree(product) WHERE product IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_transaction_types_active ON catalog.transaction_types USING btree(is_active) WHERE is_active = true;

-- operation_types indexes
CREATE UNIQUE INDEX IF NOT EXISTS idx_operation_types_code ON catalog.operation_types USING btree(code);
CREATE INDEX IF NOT EXISTS idx_operation_types_active ON catalog.operation_types USING btree(is_active) WHERE is_active = true;

-- jurisdictions
CREATE INDEX IF NOT EXISTS idx_jurisdictions_country ON catalog.jurisdictions USING btree(country_code);
CREATE INDEX IF NOT EXISTS idx_jurisdictions_active ON catalog.jurisdictions USING btree(is_active) WHERE is_active = true;

-- kyc_policies
CREATE INDEX IF NOT EXISTS idx_kyc_policies_jurisdiction ON catalog.kyc_policies USING btree(jurisdiction_id);
CREATE INDEX IF NOT EXISTS idx_kyc_policies_active ON catalog.kyc_policies USING btree(is_active) WHERE is_active = true;

-- kyc_document_requirements
CREATE INDEX IF NOT EXISTS idx_kyc_doc_req_jurisdiction ON catalog.kyc_document_requirements USING btree(jurisdiction_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_kyc_doc_req_lookup ON catalog.kyc_document_requirements USING btree(jurisdiction_id, document_type);

-- responsible_gaming_policies
CREATE INDEX IF NOT EXISTS idx_rg_policies_jurisdiction ON catalog.responsible_gaming_policies USING btree(jurisdiction_id);
CREATE INDEX IF NOT EXISTS idx_rg_policies_active ON catalog.responsible_gaming_policies USING btree(is_active) WHERE is_active = true;

-- =========================================================================================
-- GIN Indexes for JSONB Columns
-- =========================================================================================

-- catalog.widgets (default_props)
CREATE INDEX IF NOT EXISTS idx_widgets_props_gin ON catalog.widgets USING gin(default_props);

-- catalog.themes (default_config)
CREATE INDEX IF NOT EXISTS idx_themes_config_gin ON catalog.themes USING gin(default_config);

-- catalog.navigation_template_items (default_label)
CREATE INDEX IF NOT EXISTS idx_nav_template_items_label_gin ON catalog.navigation_template_items USING gin(default_label);

-- catalog.provider_settings (setting_value)
CREATE INDEX IF NOT EXISTS idx_provider_settings_value_gin ON catalog.provider_settings USING gin(setting_value);

-- catalog.responsible_gaming_policies (deposit_limit_options, loss_limit_options)
CREATE INDEX IF NOT EXISTS idx_rg_policies_deposit_limits_gin ON catalog.responsible_gaming_policies USING gin(deposit_limit_options);
CREATE INDEX IF NOT EXISTS idx_rg_policies_loss_limits_gin ON catalog.responsible_gaming_policies USING gin(loss_limit_options);

-- catalog.kyc_document_requirements (accepted_subtypes)
CREATE INDEX IF NOT EXISTS idx_kyc_req_subtypes_gin ON catalog.kyc_document_requirements USING gin(accepted_subtypes);

-- kyc_level_requirements
CREATE INDEX IF NOT EXISTS idx_kyc_level_req_jurisdiction ON catalog.kyc_level_requirements USING btree(jurisdiction_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_kyc_level_req_lookup ON catalog.kyc_level_requirements USING btree(jurisdiction_id, kyc_level);
CREATE INDEX IF NOT EXISTS idx_kyc_level_req_order ON catalog.kyc_level_requirements USING btree(jurisdiction_id, level_order);
CREATE INDEX IF NOT EXISTS idx_kyc_level_req_active ON catalog.kyc_level_requirements USING btree(is_active) WHERE is_active = true;

-- catalog.kyc_level_requirements JSONB columns
CREATE INDEX IF NOT EXISTS idx_kyc_level_req_docs_gin ON catalog.kyc_level_requirements USING gin(required_documents) WHERE required_documents IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_kyc_level_req_verif_gin ON catalog.kyc_level_requirements USING gin(required_verifications) WHERE required_verifications IS NOT NULL;

-- ip_geo_cache indexes
CREATE INDEX IF NOT EXISTS idx_ip_geo_cache_expires ON catalog.ip_geo_cache USING btree(expires_at);
CREATE INDEX IF NOT EXISTS idx_ip_geo_cache_country ON catalog.ip_geo_cache USING btree(country_code) WHERE country_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_ip_geo_cache_proxy ON catalog.ip_geo_cache USING btree(is_proxy) WHERE is_proxy = true;

-- cryptocurrencies indexes
CREATE UNIQUE INDEX IF NOT EXISTS idx_cryptocurrencies_symbol ON catalog.cryptocurrencies USING btree(symbol);
CREATE INDEX IF NOT EXISTS idx_cryptocurrencies_active ON catalog.cryptocurrencies USING btree(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_cryptocurrencies_sort ON catalog.cryptocurrencies USING btree(sort_order, symbol) WHERE is_active = true;

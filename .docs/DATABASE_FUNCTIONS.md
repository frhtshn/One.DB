# Database Functions & Triggers

This document lists all stored procedures, functions, and triggers defined in the project, categorized by database and schema.

## Core Database

### Catalog Schema

- **`country_list()`**: Country list.
- **`data_retention_policy_create(p_jurisdiction_id INT, p_data_category VARCHAR(50), p_retention_days INT, p_legal_reference VARCHAR(100) DEFAULT NULL, p_description VARCHAR(255) DEFAULT NULL)`**: Data retention policy create. Returns new ID.
- **`data_retention_policy_delete(p_id INT)`**: Data retention policy soft-delete (is_active = false).
- **`data_retention_policy_get(p_id INT)`**: Data retention policy get with jurisdiction info.
- **`data_retention_policy_list(p_jurisdiction_id INT DEFAULT NULL, p_data_category VARCHAR(50) DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Data retention policy list with filters.
- **`data_retention_policy_lookup(p_jurisdiction_id INT DEFAULT NULL)`**: Data retention policy lightweight lookup for dropdowns.
- **`data_retention_policy_update(p_id INT, p_data_category VARCHAR(50) DEFAULT NULL, p_retention_days INT DEFAULT NULL, p_legal_reference VARCHAR(100) DEFAULT NULL, p_description VARCHAR(255) DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Data retention policy update (COALESCE pattern).
- **`currency_create(p_code CHAR(3), p_name VARCHAR(100), p_symbol VARCHAR(10) DEFAULT NULL, p_numeric_code SMALLINT DEFAULT NULL)`**: Currency create.
- **`currency_delete(p_code CHAR(3))`**: Currency delete.
- **`currency_get(p_code CHAR(3))`**: Currency get.
- **`currency_list()`**: Currency list.
- **`currency_update(p_code CHAR(3), p_name VARCHAR(100), p_symbol VARCHAR(10), p_numeric_code SMALLINT, p_is_active BOOLEAN)`**: Currency update.
- **`jurisdiction_create(p_code VARCHAR(20), p_name VARCHAR(100), p_country_code CHAR(2), p_authority_type VARCHAR(30), p_region VARCHAR(50) DEFAULT NULL, p_website_url VARCHAR(255) DEFAULT NULL, p_license_prefix VARCHAR(20) DEFAULT NULL)`**: Jurisdiction create.
- **`jurisdiction_delete(p_id INT)`**: Jurisdiction delete.
- **`jurisdiction_get(p_id INT)`**: Jurisdiction get.
- **`jurisdiction_list(p_country_code CHAR(2) DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Jurisdiction list.
- **`jurisdiction_lookup()`**: Jurisdiction lookup.
- **`jurisdiction_update(p_id INT, p_code VARCHAR(20) DEFAULT NULL, p_name VARCHAR(100) DEFAULT NULL, p_country_code CHAR(2) DEFAULT NULL, p_region VARCHAR(50) DEFAULT NULL, p_authority_type VARCHAR(30) DEFAULT NULL, p_website_url VARCHAR(255) DEFAULT NULL, p_license_prefix VARCHAR(20) DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Jurisdiction update.
- **`kyc_document_requirement_create(p_jurisdiction_id INT, p_document_type VARCHAR(30), p_accepted_subtypes JSONB DEFAULT NULL, p_is_required BOOLEAN DEFAULT TRUE, p_required_for VARCHAR(30) DEFAULT 'all', p_max_document_age_days INT DEFAULT NULL, p_expires_after_days INT DEFAULT NULL, p_verification_method VARCHAR(30) DEFAULT 'manual', p_display_order INT DEFAULT 0)`**: Kyc document requirement create.
- **`kyc_document_requirement_delete(p_id INT)`**: Kyc document requirement delete.
- **`kyc_document_requirement_get(p_id INT)`**: Kyc document requirement get.
- **`kyc_document_requirement_list(p_jurisdiction_id INT DEFAULT NULL)`**: Kyc document requirement list.
- **`kyc_document_requirement_update(p_id INT, p_document_type VARCHAR(30) DEFAULT NULL, p_accepted_subtypes JSONB DEFAULT NULL, p_is_required BOOLEAN DEFAULT NULL, p_required_for VARCHAR(30) DEFAULT NULL, p_max_document_age_days INT DEFAULT NULL, p_expires_after_days INT DEFAULT NULL, p_verification_method VARCHAR(30) DEFAULT NULL, p_display_order INT DEFAULT NULL)`**: Kyc document requirement update.
- **`kyc_level_requirement_create(p_jurisdiction_id INT, p_kyc_level VARCHAR(20), p_level_order INT, p_trigger_cumulative_deposit DECIMAL(18,2) DEFAULT NULL, p_trigger_cumulative_withdrawal DECIMAL(18,2) DEFAULT NULL, p_trigger_single_deposit DECIMAL(18,2) DEFAULT NULL, p_trigger_single_withdrawal DECIMAL(18,2) DEFAULT NULL, p_trigger_balance_threshold DECIMAL(18,2) DEFAULT NULL, p_trigger_threshold_currency CHAR(3) DEFAULT 'EUR', p_trigger_days_since_registration INT DEFAULT NULL, p_trigger_on_first_withdrawal BOOLEAN DEFAULT FALSE, p_max_single_deposit DECIMAL(18,2) DEFAULT NULL, p_max_single_withdrawal DECIMAL(18,2) DEFAULT NULL, p_max_daily_deposit DECIMAL(18,2) DEFAULT NULL, p_max_daily_withdrawal DECIMAL(18,2) DEFAULT NULL, p_max_monthly_deposit DECIMAL(18,2) DEFAULT NULL, p_max_monthly_withdrawal DECIMAL(18,2) DEFAULT NULL, p_limit_currency CHAR(3) DEFAULT 'EUR', p_required_documents JSONB DEFAULT NULL, p_required_verifications JSONB DEFAULT NULL, p_verification_deadline_hours INT DEFAULT NULL, p_grace_period_hours INT DEFAULT 0, p_on_deadline_action VARCHAR(30) DEFAULT 'block_deposits')`**: Kyc level requirement create.
- **`kyc_level_requirement_delete(p_id INT)`**: Kyc level requirement delete.
- **`kyc_level_requirement_get(p_id INT)`**: Kyc level requirement get.
- **`kyc_level_requirement_list(p_jurisdiction_id INT DEFAULT NULL, p_kyc_level VARCHAR(20) DEFAULT NULL)`**: Kyc level requirement list.
- **`kyc_level_requirement_update(p_id INT, p_kyc_level VARCHAR(20) DEFAULT NULL, p_level_order INT DEFAULT NULL, p_trigger_cumulative_deposit DECIMAL(18,2) DEFAULT NULL, p_trigger_cumulative_withdrawal DECIMAL(18,2) DEFAULT NULL, p_trigger_single_deposit DECIMAL(18,2) DEFAULT NULL, p_trigger_single_withdrawal DECIMAL(18,2) DEFAULT NULL, p_trigger_balance_threshold DECIMAL(18,2) DEFAULT NULL, p_trigger_threshold_currency CHAR(3) DEFAULT NULL, p_trigger_days_since_registration INT DEFAULT NULL, p_trigger_on_first_withdrawal BOOLEAN DEFAULT NULL, p_max_single_deposit DECIMAL(18,2) DEFAULT NULL, p_max_single_withdrawal DECIMAL(18,2) DEFAULT NULL, p_max_daily_deposit DECIMAL(18,2) DEFAULT NULL, p_max_daily_withdrawal DECIMAL(18,2) DEFAULT NULL, p_max_monthly_deposit DECIMAL(18,2) DEFAULT NULL, p_max_monthly_withdrawal DECIMAL(18,2) DEFAULT NULL, p_limit_currency CHAR(3) DEFAULT NULL, p_required_documents JSONB DEFAULT NULL, p_required_verifications JSONB DEFAULT NULL, p_verification_deadline_hours INT DEFAULT NULL, p_grace_period_hours INT DEFAULT NULL, p_on_deadline_action VARCHAR(30) DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Kyc level requirement update.
- **`kyc_policy_create(p_jurisdiction_id INT, p_verification_timing VARCHAR(30), p_verification_deadline_hours INT DEFAULT NULL, p_grace_period_hours INT DEFAULT 0, p_edd_deposit_threshold DECIMAL(18,2) DEFAULT NULL, p_edd_withdrawal_threshold DECIMAL(18,2) DEFAULT NULL, p_edd_cumulative_threshold DECIMAL(18,2) DEFAULT NULL, p_edd_threshold_currency CHAR(3) DEFAULT 'EUR', p_min_age INT DEFAULT 18, p_age_verification_required BOOLEAN DEFAULT TRUE, p_address_verification_required BOOLEAN DEFAULT TRUE, p_address_document_max_age_days INT DEFAULT 90, p_sof_threshold DECIMAL(18,2) DEFAULT NULL, p_sof_required_above_threshold BOOLEAN DEFAULT FALSE, p_pep_screening_required BOOLEAN DEFAULT TRUE, p_sanctions_screening_required BOOLEAN DEFAULT TRUE)`**: Kyc policy create.
- **`kyc_policy_delete(p_id INT)`**: Kyc policy delete.
- **`kyc_policy_get(p_id INT)`**: Kyc policy get.
- **`kyc_policy_list(p_jurisdiction_id INT DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Kyc policy list.
- **`kyc_policy_update(p_id INT, p_verification_timing VARCHAR(30) DEFAULT NULL, p_verification_deadline_hours INT DEFAULT NULL, p_grace_period_hours INT DEFAULT NULL, p_edd_deposit_threshold DECIMAL(18,2) DEFAULT NULL, p_edd_withdrawal_threshold DECIMAL(18,2) DEFAULT NULL, p_edd_cumulative_threshold DECIMAL(18,2) DEFAULT NULL, p_edd_threshold_currency CHAR(3) DEFAULT NULL, p_min_age INT DEFAULT NULL, p_age_verification_required BOOLEAN DEFAULT NULL, p_address_verification_required BOOLEAN DEFAULT NULL, p_address_document_max_age_days INT DEFAULT NULL, p_sof_threshold DECIMAL(18,2) DEFAULT NULL, p_sof_required_above_threshold BOOLEAN DEFAULT NULL, p_pep_screening_required BOOLEAN DEFAULT NULL, p_sanctions_screening_required BOOLEAN DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Kyc policy update.
- **`language_create(p_code CHAR(2), p_name VARCHAR(50))`**: Language create.
- **`language_delete(p_code CHAR(2))`**: Language delete.
- **`language_get(p_code CHAR(2))`**: Language get.
- **`language_list()`**: Language list.
- **`language_update(p_code CHAR(2), p_name VARCHAR(50), p_is_active BOOLEAN)`**: Language update.
- **`localization_category_list(p_domain VARCHAR DEFAULT NULL)`**: Localization category list.
- **`localization_domain_list()`**: Localization domain list.
- **`localization_export(p_lang CHAR(2))`**: Localization export.
- **`localization_import(p_lang CHAR(2), p_translations JSONB)`**: Localization import.
- **`localization_key_create(p_key VARCHAR, p_domain VARCHAR, p_category VARCHAR, p_description VARCHAR DEFAULT NULL)`**: Localization key create.
- **`localization_key_delete(p_id BIGINT)`**: Localization key delete.
- **`localization_key_get(p_key VARCHAR)`**: Localization key get.
- **`localization_key_list(p_page INT DEFAULT 1, p_page_size INT DEFAULT 20, p_domain VARCHAR DEFAULT NULL, p_category VARCHAR DEFAULT NULL, p_search VARCHAR DEFAULT NULL)`**: Localization key list.
- **`localization_key_update(p_id BIGINT, p_domain VARCHAR, p_category VARCHAR, p_description VARCHAR)`**: Localization key update.
- **`localization_messages_get(p_lang CHAR(2))`**: Localization messages get.
- **`localization_value_delete(p_key_id BIGINT, p_lang CHAR(2))`**: Localization value delete.
- **`localization_value_upsert(p_key_id BIGINT, p_lang CHAR(2), p_text TEXT)`**: Localization value upsert.
- **`navigation_template_create(p_code VARCHAR(50), p_name VARCHAR(100), p_description TEXT DEFAULT NULL, p_is_default BOOLEAN DEFAULT FALSE)`**: Navigation template create.
- **`navigation_template_delete(p_id INT)`**: Navigation template delete.
- **`navigation_template_get(p_id INT)`**: Navigation template get.
- **`navigation_template_item_create(p_template_id INT, p_menu_location VARCHAR(50), p_translation_key VARCHAR(100) DEFAULT NULL, p_default_label JSONB DEFAULT NULL, p_icon VARCHAR(50) DEFAULT NULL, p_target_type VARCHAR(20) DEFAULT 'INTERNAL', p_target_url VARCHAR(255) DEFAULT NULL, p_target_action VARCHAR(50) DEFAULT NULL, p_parent_id BIGINT DEFAULT NULL, p_display_order INT DEFAULT 0, p_is_locked BOOLEAN DEFAULT TRUE, p_is_mandatory BOOLEAN DEFAULT TRUE)`**: Navigation template item create.
- **`navigation_template_item_delete(p_id BIGINT)`**: Navigation template item delete.
- **`navigation_template_item_get(p_id BIGINT)`**: Navigation template item get.
- **`navigation_template_item_list(p_template_id INT, p_menu_location VARCHAR(50) DEFAULT NULL)`**: Navigation template item list.
- **`navigation_template_item_update(p_id BIGINT, p_menu_location VARCHAR(50) DEFAULT NULL, p_translation_key VARCHAR(100) DEFAULT NULL, p_default_label JSONB DEFAULT NULL, p_icon VARCHAR(50) DEFAULT NULL, p_target_type VARCHAR(20) DEFAULT NULL, p_target_url VARCHAR(255) DEFAULT NULL, p_target_action VARCHAR(50) DEFAULT NULL, p_parent_id BIGINT DEFAULT NULL, p_display_order INT DEFAULT NULL, p_is_locked BOOLEAN DEFAULT NULL, p_is_mandatory BOOLEAN DEFAULT NULL)`**: Navigation template item update.
- **`navigation_template_list(p_is_active BOOLEAN DEFAULT NULL)`**: Navigation template list.
- **`navigation_template_lookup()`**: Navigation template lookup for dropdowns.
- **`navigation_template_update(p_id INT, p_code VARCHAR(50) DEFAULT NULL, p_name VARCHAR(100) DEFAULT NULL, p_description TEXT DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL, p_is_default BOOLEAN DEFAULT NULL)`**: Navigation template update.
- **`operation_type_list()`**: Operation type list.
- **`payment_method_create(p_provider_id BIGINT, p_code VARCHAR(100), p_name VARCHAR(255), p_payment_type VARCHAR(50), p_external_method_id VARCHAR(100) DEFAULT NULL, p_description TEXT DEFAULT NULL, p_payment_subtype VARCHAR(50) DEFAULT NULL, p_channel VARCHAR(50) DEFAULT 'ONLINE', p_icon_url VARCHAR(500) DEFAULT NULL, p_logo_url VARCHAR(500) DEFAULT NULL, p_banner_url VARCHAR(500) DEFAULT NULL, p_supports_deposit BOOLEAN DEFAULT TRUE, p_supports_withdrawal BOOLEAN DEFAULT TRUE, p_supports_refund BOOLEAN DEFAULT FALSE, p_min_deposit DECIMAL(18,8) DEFAULT NULL, p_max_deposit DECIMAL(18,8) DEFAULT NULL, p_min_withdrawal DECIMAL(18,8) DEFAULT NULL, p_max_withdrawal DECIMAL(18,8) DEFAULT NULL, p_deposit_fee_percent DECIMAL(5,4) DEFAULT NULL, p_deposit_fee_fixed DECIMAL(18,8) DEFAULT NULL, p_withdrawal_fee_percent DECIMAL(5,4) DEFAULT NULL, p_withdrawal_fee_fixed DECIMAL(18,8) DEFAULT NULL, p_deposit_processing_time VARCHAR(50) DEFAULT NULL, p_withdrawal_processing_time VARCHAR(50) DEFAULT NULL, p_supported_currencies CHAR(3)[] DEFAULT '{}', p_blocked_countries CHAR(2)[] DEFAULT '{}', p_requires_kyc_level SMALLINT DEFAULT 0, p_requires_3ds BOOLEAN DEFAULT FALSE, p_requires_verification BOOLEAN DEFAULT FALSE, p_features VARCHAR(50)[] DEFAULT '{}', p_supports_recurring BOOLEAN DEFAULT FALSE, p_supports_tokenization BOOLEAN DEFAULT FALSE, p_supports_partial_refund BOOLEAN DEFAULT FALSE, p_is_mobile BOOLEAN DEFAULT TRUE, p_is_desktop BOOLEAN DEFAULT TRUE, p_is_app BOOLEAN DEFAULT TRUE, p_sort_order INTEGER DEFAULT 0)`**: Payment method create.
- **`payment_method_delete(p_id BIGINT)`**: Payment method delete.
- **`payment_method_get(p_id BIGINT)`**: Payment method get.
- **`payment_method_list(p_provider_id BIGINT DEFAULT NULL, p_payment_type VARCHAR(50) DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Payment method list.
- **`payment_method_lookup(p_provider_id BIGINT DEFAULT NULL)`**: Payment method lookup.
- **`payment_method_update(p_id BIGINT, p_provider_id BIGINT DEFAULT NULL, p_code VARCHAR(100) DEFAULT NULL, p_name VARCHAR(255) DEFAULT NULL, p_payment_type VARCHAR(50) DEFAULT NULL, p_external_method_id VARCHAR(100) DEFAULT NULL, p_description TEXT DEFAULT NULL, p_payment_subtype VARCHAR(50) DEFAULT NULL, p_channel VARCHAR(50) DEFAULT NULL, p_icon_url VARCHAR(500) DEFAULT NULL, p_logo_url VARCHAR(500) DEFAULT NULL, p_banner_url VARCHAR(500) DEFAULT NULL, p_supports_deposit BOOLEAN DEFAULT NULL, p_supports_withdrawal BOOLEAN DEFAULT NULL, p_supports_refund BOOLEAN DEFAULT NULL, p_min_deposit DECIMAL(18,8) DEFAULT NULL, p_max_deposit DECIMAL(18,8) DEFAULT NULL, p_min_withdrawal DECIMAL(18,8) DEFAULT NULL, p_max_withdrawal DECIMAL(18,8) DEFAULT NULL, p_deposit_fee_percent DECIMAL(5,4) DEFAULT NULL, p_deposit_fee_fixed DECIMAL(18,8) DEFAULT NULL, p_withdrawal_fee_percent DECIMAL(5,4) DEFAULT NULL, p_withdrawal_fee_fixed DECIMAL(18,8) DEFAULT NULL, p_deposit_processing_time VARCHAR(50) DEFAULT NULL, p_withdrawal_processing_time VARCHAR(50) DEFAULT NULL, p_supported_currencies CHAR(3)[] DEFAULT NULL, p_blocked_countries CHAR(2)[] DEFAULT NULL, p_requires_kyc_level SMALLINT DEFAULT NULL, p_requires_3ds BOOLEAN DEFAULT NULL, p_requires_verification BOOLEAN DEFAULT NULL, p_features VARCHAR(50)[] DEFAULT NULL, p_supports_recurring BOOLEAN DEFAULT NULL, p_supports_tokenization BOOLEAN DEFAULT NULL, p_supports_partial_refund BOOLEAN DEFAULT NULL, p_is_mobile BOOLEAN DEFAULT NULL, p_is_desktop BOOLEAN DEFAULT NULL, p_is_app BOOLEAN DEFAULT NULL, p_sort_order INTEGER DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Payment method update.
- **`provider_create(p_type_id BIGINT, p_code VARCHAR(50), p_name VARCHAR(255))`**: Provider create.
- **`provider_delete(p_id BIGINT)`**: Provider delete.
- **`provider_get(p_id BIGINT)`**: Provider get.
- **`provider_list(p_type_id BIGINT DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Provider list.
- **`provider_lookup(p_type_id BIGINT DEFAULT NULL)`**: Provider lookup.
- **`provider_setting_delete(p_provider_id BIGINT, p_key VARCHAR(100))`**: Provider setting delete.
- **`provider_setting_get(p_provider_id BIGINT, p_key VARCHAR(100))`**: Provider setting get.
- **`provider_setting_list(p_provider_id BIGINT)`**: Provider setting list.
- **`provider_setting_upsert(p_provider_id BIGINT, p_key VARCHAR(100), p_value JSONB, p_description VARCHAR(255) DEFAULT NULL)`**: Provider setting upsert.
- **`provider_type_create(p_code VARCHAR(30), p_name VARCHAR(100))`**: Provider type create.
- **`provider_type_delete(p_id BIGINT)`**: Provider type delete.
- **`provider_type_get(p_id BIGINT)`**: Provider type get.
- **`provider_type_list()`**: Provider type list.
- **`provider_type_lookup()`**: Provider type lookup.
- **`provider_type_update(p_id BIGINT, p_code VARCHAR(30), p_name VARCHAR(100))`**: Provider type update.
- **`provider_update(p_id BIGINT, p_type_id BIGINT, p_code VARCHAR(50), p_name VARCHAR(255), p_is_active BOOLEAN)`**: Provider update.
- **`responsible_gaming_policy_create(p_jurisdiction_id INT, p_deposit_limit_required BOOLEAN DEFAULT FALSE, p_deposit_limit_options TEXT DEFAULT NULL, p_deposit_limit_max_increase_wait_hours INT DEFAULT NULL, p_loss_limit_required BOOLEAN DEFAULT FALSE, p_loss_limit_options TEXT DEFAULT NULL, p_session_limit_required BOOLEAN DEFAULT FALSE, p_session_limit_max_hours INT DEFAULT NULL, p_session_break_required BOOLEAN DEFAULT FALSE, p_session_break_after_hours INT DEFAULT NULL, p_session_break_duration_minutes INT DEFAULT NULL, p_reality_check_required BOOLEAN DEFAULT FALSE, p_reality_check_interval_minutes INT DEFAULT NULL, p_cooling_off_available BOOLEAN DEFAULT TRUE, p_cooling_off_min_days INT DEFAULT 1, p_cooling_off_max_days INT DEFAULT 42, p_cooling_off_revocable BOOLEAN DEFAULT FALSE, p_self_exclusion_available BOOLEAN DEFAULT TRUE, p_self_exclusion_min_months INT DEFAULT 6, p_self_exclusion_permanent_option BOOLEAN DEFAULT TRUE, p_self_exclusion_revocable BOOLEAN DEFAULT FALSE, p_central_exclusion_system VARCHAR(50) DEFAULT NULL, p_central_exclusion_integration_required BOOLEAN DEFAULT FALSE, p_central_exclusion_api_endpoint VARCHAR(255) DEFAULT NULL, p_anonymous_payments_allowed BOOLEAN DEFAULT TRUE, p_crypto_payments_allowed BOOLEAN DEFAULT TRUE, p_credit_card_gambling_allowed BOOLEAN DEFAULT TRUE, p_payment_method_ownership_verification BOOLEAN DEFAULT FALSE)`**: Responsible gaming policy create.
- **`responsible_gaming_policy_delete(p_id INT)`**: Responsible gaming policy delete.
- **`responsible_gaming_policy_get(p_id INT)`**: Responsible gaming policy get.
- **`responsible_gaming_policy_list(p_jurisdiction_id INT DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Responsible gaming policy list.
- **`responsible_gaming_policy_update(p_id INT, p_deposit_limit_required BOOLEAN DEFAULT NULL, p_deposit_limit_options TEXT DEFAULT NULL, p_deposit_limit_max_increase_wait_hours INT DEFAULT NULL, p_loss_limit_required BOOLEAN DEFAULT NULL, p_loss_limit_options TEXT DEFAULT NULL, p_session_limit_required BOOLEAN DEFAULT NULL, p_session_limit_max_hours INT DEFAULT NULL, p_session_break_required BOOLEAN DEFAULT NULL, p_session_break_after_hours INT DEFAULT NULL, p_session_break_duration_minutes INT DEFAULT NULL, p_reality_check_required BOOLEAN DEFAULT NULL, p_reality_check_interval_minutes INT DEFAULT NULL, p_cooling_off_available BOOLEAN DEFAULT NULL, p_cooling_off_min_days INT DEFAULT NULL, p_cooling_off_max_days INT DEFAULT NULL, p_cooling_off_revocable BOOLEAN DEFAULT NULL, p_self_exclusion_available BOOLEAN DEFAULT NULL, p_self_exclusion_min_months INT DEFAULT NULL, p_self_exclusion_permanent_option BOOLEAN DEFAULT NULL, p_self_exclusion_revocable BOOLEAN DEFAULT NULL, p_central_exclusion_system VARCHAR(50) DEFAULT NULL, p_central_exclusion_integration_required BOOLEAN DEFAULT NULL, p_central_exclusion_api_endpoint VARCHAR(255) DEFAULT NULL, p_anonymous_payments_allowed BOOLEAN DEFAULT NULL, p_crypto_payments_allowed BOOLEAN DEFAULT NULL, p_credit_card_gambling_allowed BOOLEAN DEFAULT NULL, p_payment_method_ownership_verification BOOLEAN DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Responsible gaming policy update.
- **`theme_create(p_code VARCHAR(50), p_name VARCHAR(100), p_description TEXT DEFAULT NULL, p_version VARCHAR(20) DEFAULT '1.0.0', p_thumbnail_url VARCHAR(255) DEFAULT NULL, p_default_config JSONB DEFAULT '{}', p_is_premium BOOLEAN DEFAULT FALSE)`**: Theme create.
- **`theme_delete(p_id INT)`**: Theme delete.
- **`theme_get(p_id INT)`**: Theme get.
- **`theme_list(p_is_active BOOLEAN DEFAULT NULL, p_is_premium BOOLEAN DEFAULT NULL)`**: Theme list.
- **`theme_lookup()`**: Theme lookup.
- **`theme_update(p_id INT, p_code VARCHAR(50) DEFAULT NULL, p_name VARCHAR(100) DEFAULT NULL, p_description TEXT DEFAULT NULL, p_version VARCHAR(20) DEFAULT NULL, p_thumbnail_url VARCHAR(255) DEFAULT NULL, p_default_config JSONB DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL, p_is_premium BOOLEAN DEFAULT NULL)`**: Theme update.
- **`timezone_list()`**: Timezone list.
- **`transaction_type_list()`**: Transaction type list.
- **`ui_position_create(p_code VARCHAR(50), p_name VARCHAR(100), p_is_global BOOLEAN DEFAULT FALSE)`**: Ui position create.
- **`ui_position_delete(p_id INT)`**: Ui position delete.
- **`ui_position_get(p_id INT)`**: Ui position get.
- **`ui_position_list(p_is_global BOOLEAN DEFAULT NULL)`**: Ui position list.
- **`ui_position_update(p_id INT, p_code VARCHAR(50) DEFAULT NULL, p_name VARCHAR(100) DEFAULT NULL, p_is_global BOOLEAN DEFAULT NULL)`**: Ui position update.
- **`widget_create(p_code VARCHAR(50), p_name VARCHAR(100), p_category VARCHAR(30), p_component_name VARCHAR(100), p_description TEXT DEFAULT NULL, p_default_props JSONB DEFAULT '{}')`**: Widget create.
- **`widget_delete(p_id INT)`**: Widget delete.
- **`widget_get(p_id INT)`**: Widget get.
- **`widget_list(p_category VARCHAR(30) DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Widget list.
- **`widget_update(p_id INT, p_code VARCHAR(50) DEFAULT NULL, p_name VARCHAR(100) DEFAULT NULL, p_description TEXT DEFAULT NULL, p_category VARCHAR(30) DEFAULT NULL, p_component_name VARCHAR(100) DEFAULT NULL, p_default_props JSONB DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Widget update.

### Core Schema

- **`company_create(p_company_code VARCHAR, p_company_name VARCHAR, p_country_code CHARACTER(2), p_timezone VARCHAR DEFAULT NULL)`**: Company create.
- **`company_delete(p_id BIGINT)`**: Company delete.
- **`company_get(p_id BIGINT)`**: Company get.
- **`company_list(p_page INTEGER DEFAULT 1, p_page_size INTEGER DEFAULT 20, p_search TEXT DEFAULT NULL)`**: Company list.
- **`company_lookup(p_caller_id BIGINT)`**: Company lookup.
- **`company_update(p_id BIGINT, p_company_code VARCHAR, p_company_name VARCHAR, p_status SMALLINT, p_country_code CHARACTER(2), p_timezone VARCHAR)`**: Company update.
- **`department_create(p_caller_id BIGINT, p_company_id BIGINT, p_code VARCHAR(50), p_name TEXT, p_parent_id BIGINT DEFAULT NULL, p_description TEXT DEFAULT NULL)`**: Creates a new department. Code stored uppercase, unique per company. name/description are multi-language JSONB received as TEXT. IDOR protected.
- **`department_delete(p_caller_id BIGINT, p_company_id BIGINT, p_id BIGINT)`**: Soft deletes a department (is_active=FALSE). Fails if active child departments exist. IDOR protected.
- **`department_get(p_caller_id BIGINT, p_company_id BIGINT, p_id BIGINT)`**: Returns department details with parent name. name/description/parentName are multi-language JSONB. IDOR protected.
- **`department_list(p_caller_id BIGINT, p_company_id BIGINT, p_parent_id BIGINT DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL, p_search TEXT DEFAULT NULL)`**: Lists departments. Search works across all language values in JSONB name and code. IDOR protected.
- **`department_lookup(p_caller_id BIGINT, p_company_id BIGINT, p_lang CHAR(2) DEFAULT NULL)`**: Returns active departments for dropdowns. p_lang=NULL returns full JSONB name, p_lang='tr' returns resolved string with 'en' fallback. IDOR protected.
- **`department_update(p_caller_id BIGINT, p_company_id BIGINT, p_id BIGINT, p_code VARCHAR(50) DEFAULT NULL, p_name TEXT DEFAULT NULL, p_parent_id BIGINT DEFAULT NULL, p_description TEXT DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Updates department (COALESCE pattern). name/description are multi-language JSONB received as TEXT. IDOR protected.
- **`tenant_create(p_caller_id BIGINT, p_company_id BIGINT, p_tenant_code VARCHAR, p_tenant_name VARCHAR, p_environment VARCHAR DEFAULT 'prod', p_base_currency CHAR(3) DEFAULT NULL, p_default_language CHAR(2) DEFAULT NULL, p_default_country CHAR(2) DEFAULT NULL, p_timezone VARCHAR DEFAULT NULL, p_supported_currencies VARCHAR[] DEFAULT NULL, -- Array of currency codes p_supported_languages VARCHAR[] DEFAULT NULL -- Array of language codes)`**: Tenant create.
- **`tenant_currency_list(p_caller_id BIGINT, p_tenant_id BIGINT)`**: Tenant currency list.
- **`tenant_currency_upsert(p_caller_id BIGINT, p_tenant_id BIGINT, p_currency_code CHAR(3), p_is_enabled BOOLEAN DEFAULT TRUE)`**: Tenant currency upsert.
- **`tenant_delete(p_caller_id BIGINT, p_id BIGINT)`**: Tenant delete.
- **`tenant_get(p_caller_id BIGINT, p_id BIGINT)`**: Tenant get.
- **`tenant_language_list(p_caller_id BIGINT, p_tenant_id BIGINT)`**: Tenant language list.
- **`tenant_language_upsert(p_caller_id BIGINT, p_tenant_id BIGINT, p_language_code CHAR(2), p_is_enabled BOOLEAN DEFAULT TRUE)`**: Tenant language upsert.
- **`tenant_list(p_caller_id BIGINT, p_page INTEGER DEFAULT 1, p_page_size INTEGER DEFAULT 20, p_company_id BIGINT DEFAULT NULL, p_search TEXT DEFAULT NULL, p_status INTEGER DEFAULT NULL)`**: Tenant list.
- **`tenant_lookup(p_caller_id BIGINT, p_company_id BIGINT DEFAULT NULL)`**: Tenant lookup.
- **`tenant_setting_delete(p_caller_id BIGINT, p_tenant_id BIGINT, p_key VARCHAR)`**: Tenant setting delete.
- **`tenant_setting_get(p_caller_id BIGINT, p_tenant_id BIGINT, p_key VARCHAR)`**: Tenant setting get.
- **`tenant_setting_list(p_caller_id BIGINT, p_tenant_id BIGINT, p_category VARCHAR DEFAULT NULL -- Optional filter)`**: Tenant setting list.
- **`tenant_setting_upsert(p_caller_id BIGINT, p_tenant_id BIGINT, p_key VARCHAR, p_value JSONB, p_description VARCHAR DEFAULT NULL, p_category VARCHAR DEFAULT 'General')`**: Tenant setting upsert.
- **`tenant_update(p_caller_id BIGINT, p_id BIGINT, p_company_id BIGINT DEFAULT NULL, p_tenant_code VARCHAR DEFAULT NULL, p_tenant_name VARCHAR DEFAULT NULL, p_environment VARCHAR DEFAULT NULL, p_base_currency CHAR(3) DEFAULT NULL, p_default_language CHAR(2) DEFAULT NULL, p_default_country CHAR(2) DEFAULT NULL, p_timezone VARCHAR DEFAULT NULL, p_status SMALLINT DEFAULT NULL, p_supported_currencies VARCHAR[] DEFAULT NULL, -- Full list to sync p_supported_languages VARCHAR[] DEFAULT NULL -- Full list to sync)`**: Tenant update.
- **`user_department_assign(p_caller_id BIGINT, p_user_id BIGINT, p_department_id BIGINT, p_is_primary BOOLEAN DEFAULT FALSE)`**: Assigns user to department. Idempotent. If is_primary=TRUE, unsets previous primary. User and department must be in same company. IDOR protected.
- **`user_department_list(p_caller_id BIGINT, p_user_id BIGINT)`**: Lists all departments assigned to a user. Primary department listed first. departmentName/parentName are multi-language JSONB. IDOR protected.
- **`user_department_remove(p_caller_id BIGINT, p_user_id BIGINT, p_department_id BIGINT)`**: Removes user from department (hard delete on junction table). IDOR protected.

### Outbox Schema

- **`outbox_cleanup(p_retention_days INT DEFAULT 7)`**: Outbox cleanup.
- **`outbox_create(p_action_type VARCHAR(50), p_aggregate_type VARCHAR(100), p_aggregate_id VARCHAR(100), p_payload TEXT, p_tenant_id BIGINT DEFAULT NULL, p_correlation_id UUID DEFAULT NULL, p_max_retries INT DEFAULT 5)`**: Outbox create.
- **`outbox_create_batch(p_messages TEXT -- JSON array string)`**: Outbox create batch.
- **`outbox_get_pending(p_batch_size INT DEFAULT 100)`**: Outbox get pending.
- **`outbox_mark_completed(p_id UUID)`**: Outbox mark completed.
- **`outbox_mark_completed_batch(p_ids UUID[])`**: Outbox mark completed batch.
- **`outbox_mark_failed(p_id UUID, p_error TEXT)`**: Outbox mark failed.
- **`outbox_mark_failed_batch(p_ids UUID[], p_error TEXT)`**: Outbox mark failed batch.
- **`outbox_stats()`**: Outbox stats.

### Presentation Schema

- **`build_page_json(p_page_id BIGINT)`**: Build page json.
- **`context_create(p_page_id BIGINT, p_code VARCHAR, p_type VARCHAR, p_label VARCHAR DEFAULT NULL, p_permission_edit VARCHAR DEFAULT NULL, p_permission_readonly VARCHAR DEFAULT NULL, p_permission_mask VARCHAR DEFAULT NULL)`**: Context create.
- **`context_delete(p_id BIGINT)`**: Context delete.
- **`context_list(p_page_id BIGINT)`**: Context list.
- **`context_update(p_id BIGINT, p_page_id BIGINT DEFAULT NULL, p_code VARCHAR DEFAULT NULL, p_type VARCHAR DEFAULT NULL, p_label VARCHAR DEFAULT NULL, p_permission_edit VARCHAR DEFAULT NULL, p_permission_readonly VARCHAR DEFAULT NULL, p_permission_mask VARCHAR DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Context update.
- **`menu_create(p_menu_group_id BIGINT, p_code TEXT, p_title_localization_key TEXT, p_order_index INT, p_required_permission TEXT DEFAULT NULL, p_icon TEXT DEFAULT NULL, p_is_active BOOLEAN DEFAULT TRUE)`**: Menu create.
- **`menu_delete(p_menu_id BIGINT)`**: Menu delete.
- **`menu_get(p_menu_id BIGINT)`**: Menu get.
- **`menu_group_create(p_code TEXT, p_title TEXT, p_order INT, p_is_active BOOLEAN DEFAULT TRUE)`**: Menu group create.
- **`menu_group_delete(p_menu_group_id BIGINT)`**: Menu group delete.
- **`menu_group_get(p_menu_group_id BIGINT)`**: Menu group get.
- **`menu_group_list()`**: Menu group list.
- **`menu_group_update(p_menu_group_id BIGINT, p_title TEXT DEFAULT NULL, p_order INT DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Menu group update.
- **`menu_list(p_menu_group_id BIGINT)`**: Menu list.
- **`menu_structure()`**: Menu structure.
- **`menu_update(p_menu_id BIGINT, p_menu_group_id BIGINT DEFAULT NULL, p_title_localization_key TEXT DEFAULT NULL, p_icon TEXT DEFAULT NULL, p_order_index INT DEFAULT NULL, p_required_permission TEXT DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Menu update.
- **`page_create(p_menu_id BIGINT DEFAULT NULL, p_submenu_id BIGINT DEFAULT NULL, p_code TEXT DEFAULT NULL, p_route TEXT DEFAULT NULL, p_title_localization_key TEXT DEFAULT NULL, p_required_permission TEXT DEFAULT NULL, p_is_active BOOLEAN DEFAULT TRUE)`**: Page create.
- **`page_delete(p_page_id BIGINT)`**: Page delete.
- **`page_get(p_page_id BIGINT)`**: Page get.
- **`page_list(p_menu_id BIGINT DEFAULT NULL, p_submenu_id BIGINT DEFAULT NULL)`**: Page list.
- **`page_update(p_page_id BIGINT, p_menu_id BIGINT DEFAULT NULL, p_submenu_id BIGINT DEFAULT NULL, p_route TEXT DEFAULT NULL, p_title_localization_key TEXT DEFAULT NULL, p_required_permission TEXT DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Page update.
- **`submenu_create(p_menu_id BIGINT, p_code TEXT, p_title_localization_key TEXT, p_route TEXT DEFAULT NULL, p_order_index INT DEFAULT NULL, p_required_permission TEXT DEFAULT NULL)`**: Submenu create.
- **`submenu_delete(p_submenu_id BIGINT)`**: Submenu delete.
- **`submenu_list(p_menu_id BIGINT)`**: Submenu list.
- **`submenu_update(p_submenu_id BIGINT, p_menu_id BIGINT DEFAULT NULL, p_title_localization_key TEXT DEFAULT NULL, p_route TEXT DEFAULT NULL, p_order_index INT DEFAULT NULL, p_required_permission TEXT DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Submenu update.
- **`tab_create(p_page_id BIGINT, p_code TEXT, p_title_localization_key TEXT, p_order_index INT, p_required_permission TEXT, p_is_active BOOLEAN DEFAULT TRUE)`**: Tab create.
- **`tab_delete(p_tab_id BIGINT)`**: Tab delete.
- **`tab_list(p_page_id BIGINT)`**: Tab list.
- **`tab_update(p_tab_id BIGINT, p_title_localization_key TEXT DEFAULT NULL, p_order_index INT DEFAULT NULL, p_required_permission TEXT DEFAULT NULL, p_is_active BOOLEAN DEFAULT NULL)`**: Tab update.
- **`tenant_layout_delete(p_caller_id BIGINT, p_tenant_id BIGINT, p_id BIGINT)`**: Deletes a tenant layout. IDOR protected.
- **`tenant_layout_get(p_caller_id BIGINT, p_tenant_id BIGINT, p_id BIGINT DEFAULT NULL, p_page_id BIGINT DEFAULT NULL, p_layout_name VARCHAR(50) DEFAULT NULL)`**: Gets tenant layout by ID, page_id, or layout_name.
- **`tenant_layout_list(p_caller_id BIGINT, p_tenant_id BIGINT)`**: Lists all tenant layouts (widget placements).
- **`tenant_layout_upsert(p_caller_id BIGINT, p_tenant_id BIGINT, p_layout_name VARCHAR(50), p_structure TEXT, p_page_id BIGINT DEFAULT NULL, p_is_active BOOLEAN DEFAULT TRUE)`**: Creates or updates tenant layout. layout_name is unique per tenant. Structure is received as TEXT and cast to JSONB internally.
- **`tenant_navigation_create(p_caller_id BIGINT, p_tenant_id BIGINT, p_menu_location VARCHAR(50), p_translation_key VARCHAR(100) DEFAULT NULL, p_custom_label TEXT DEFAULT NULL, p_icon VARCHAR(50) DEFAULT NULL, p_badge_text VARCHAR(20) DEFAULT NULL, p_badge_color VARCHAR(20) DEFAULT NULL, p_target_type VARCHAR(20) DEFAULT 'internal', p_target_url VARCHAR(255) DEFAULT NULL, p_target_action VARCHAR(50) DEFAULT NULL, p_open_in_new_tab BOOLEAN DEFAULT FALSE, p_parent_id BIGINT DEFAULT NULL, p_display_order INT DEFAULT 0, p_is_visible BOOLEAN DEFAULT TRUE, p_requires_auth BOOLEAN DEFAULT FALSE, p_requires_guest BOOLEAN DEFAULT FALSE, p_required_roles VARCHAR(50)[] DEFAULT NULL, p_device_visibility VARCHAR(20) DEFAULT 'all', p_custom_css_class VARCHAR(100) DEFAULT NULL)`**: Creates a new custom navigation item. custom_label is received as TEXT and cast to JSONB internally. Custom items have is_locked=FALSE, is_readonly=FALSE.
- **`tenant_navigation_delete(p_caller_id BIGINT, p_tenant_id BIGINT, p_id BIGINT)`**: Deletes navigation item. Locked items (from template) cannot be deleted.
- **`tenant_navigation_get(p_caller_id BIGINT, p_tenant_id BIGINT, p_id BIGINT)`**: Gets a single navigation item.
- **`tenant_navigation_init_from_template(p_caller_id BIGINT, p_tenant_id BIGINT, p_template_id INT, p_force BOOLEAN DEFAULT FALSE)`**: Initializes tenant navigation from a catalog template. Copies all template items with parent-child relationships.
- **`tenant_navigation_list(p_caller_id BIGINT, p_tenant_id BIGINT, p_menu_location VARCHAR(50) DEFAULT NULL)`**: Lists tenant navigation items, optionally filtered by menu_location.
- **`tenant_navigation_reorder(p_caller_id BIGINT, p_tenant_id BIGINT, p_menu_location VARCHAR(50), p_item_ids BIGINT[])`**: Reorders navigation items within a menu_location.
- **`tenant_navigation_update(p_caller_id BIGINT, p_tenant_id BIGINT, p_id BIGINT, p_custom_label TEXT DEFAULT NULL, p_icon VARCHAR(50) DEFAULT NULL, p_badge_text VARCHAR(20) DEFAULT NULL, p_badge_color VARCHAR(20) DEFAULT NULL, p_display_order INT DEFAULT NULL, p_is_visible BOOLEAN DEFAULT NULL, p_requires_auth BOOLEAN DEFAULT NULL, p_requires_guest BOOLEAN DEFAULT NULL, p_required_roles VARCHAR(50)[] DEFAULT NULL, p_device_visibility VARCHAR(20) DEFAULT NULL, p_custom_css_class VARCHAR(100) DEFAULT NULL, p_menu_location VARCHAR(50) DEFAULT NULL, p_translation_key VARCHAR(100) DEFAULT NULL, p_target_type VARCHAR(20) DEFAULT NULL, p_target_url VARCHAR(255) DEFAULT NULL, p_target_action VARCHAR(50) DEFAULT NULL, p_open_in_new_tab BOOLEAN DEFAULT NULL, p_parent_id BIGINT DEFAULT NULL)`**: Updates navigation item. custom_label is received as TEXT and cast to JSONB internally. Readonly items can only have visibility fields updated.
- **`tenant_theme_activate(p_caller_id BIGINT, p_tenant_id BIGINT, p_theme_id INT)`**: Activates a theme for the tenant, deactivating others.
- **`tenant_theme_get(p_caller_id BIGINT, p_tenant_id BIGINT, p_theme_id INT DEFAULT NULL)`**: Gets tenant theme config. Returns merged config (default + override). NULL returns active theme.
- **`tenant_theme_list(p_caller_id BIGINT, p_tenant_id BIGINT)`**: Lists all available themes with tenant configuration status.
- **`tenant_theme_upsert(p_caller_id BIGINT, p_tenant_id BIGINT, p_theme_id INT, p_config TEXT DEFAULT '{}', p_custom_css TEXT DEFAULT NULL, p_set_active BOOLEAN DEFAULT FALSE)`**: Creates or updates tenant theme configuration. Config is received as TEXT and cast to JSONB internally.

#### Consumer Functions (Frontend App)
- **`get_active_theme(p_tenant_id BIGINT)`**: Returns active theme with merged config for frontend rendering.
- **`get_layout(p_tenant_id BIGINT, p_layout_name VARCHAR(50) DEFAULT NULL, p_page_id BIGINT DEFAULT NULL)`**: Returns active layout structure for frontend rendering.
- **`get_navigation(p_tenant_id BIGINT, p_menu_location VARCHAR(50) DEFAULT NULL)`**: Returns visible navigation items as nested tree structure for frontend rendering.

### Security Schema

#### Access Helper Functions (IDOR Protection)

These functions provide centralized access control for IDOR (Insecure Direct Object Reference) protection across the application.

**Foundation Functions:**
- **`user_get_access_level(p_caller_id BIGINT)`**: Returns caller's access level including `is_platform_admin`, `company_id`, `allowed_company_ids`, and `allowed_tenant_ids`. Foundation for all access checks.

**Boolean Check Functions:**
- **`user_can_access_tenant(p_caller_id BIGINT, p_tenant_id BIGINT)`**: Returns TRUE if caller can access the specified tenant.
- **`user_can_access_company(p_caller_id BIGINT, p_company_id BIGINT)`**: Returns TRUE if caller can access the specified company.
- **`user_can_manage_user(p_caller_id BIGINT, p_target_user_id BIGINT)`**: Returns TRUE if caller can manage (update/delete) the target user.

**Guard Clause Functions (Raise Exception on Failure):**
- **`user_assert_access_tenant(p_caller_id BIGINT, p_tenant_id BIGINT)`**: Raises P0403 exception if caller cannot access the tenant.
- **`user_assert_access_company(p_caller_id BIGINT, p_company_id BIGINT)`**: Raises P0403 exception if caller cannot access the company.
- **`user_assert_manage_user(p_caller_id BIGINT, p_target_user_id BIGINT)`**: Raises P0403 exception if caller cannot manage the target user.

#### Other Security Functions

- **`is_system_role(p_role_code VARCHAR)`**: Is system role.
- **`permission_category_list()`**: Permission category list.
- **`permission_check(p_user_id BIGINT, p_permission_code VARCHAR(100), p_tenant_id BIGINT DEFAULT NULL)`**: Permission check.
- **`permission_cleanup_expired()`**: Permission cleanup expired.
- **`permission_create(p_code VARCHAR(100), p_name VARCHAR(150), p_description VARCHAR(500) DEFAULT NULL, p_category VARCHAR(50) DEFAULT 'general')`**: Permission create.
- **`permission_delete(p_id BIGINT)`**: Permission delete.
- **`permission_exists(p_permission_code VARCHAR(100))`**: Permission exists.
- **`permission_get(p_code VARCHAR(100))`**: Permission get.
- **`permission_list(p_page INT DEFAULT 1, p_page_size INT DEFAULT 20, p_category VARCHAR(50) DEFAULT NULL, p_search VARCHAR(100) DEFAULT NULL, p_status SMALLINT DEFAULT 1)`**: Permission list.
- **`permission_update(p_id BIGINT, p_name VARCHAR(150) DEFAULT NULL, p_description VARCHAR(500) DEFAULT NULL, p_category VARCHAR(50) DEFAULT NULL, p_status SMALLINT DEFAULT NULL)`**: Permission update.
- **`role_create(p_code VARCHAR, p_name VARCHAR, p_description VARCHAR DEFAULT NULL, p_created_by BIGINT DEFAULT NULL)`**: Role create.
- **`role_delete(p_id BIGINT, p_deleted_by BIGINT DEFAULT NULL)`**: Role delete.
- **`role_get(p_code VARCHAR)`**: Role get.
- **`role_list(p_page INT DEFAULT 1, p_page_size INT DEFAULT 20, p_search VARCHAR DEFAULT NULL, p_status SMALLINT DEFAULT NULL)`**: Role list.
- **`role_permission_assign(p_role_id BIGINT, p_permission_code VARCHAR)`**: Role permission assign.
- **`role_permission_bulk_assign(p_role_id BIGINT, p_permission_codes VARCHAR[], p_replace_existing BOOLEAN DEFAULT FALSE)`**: Role permission bulk assign.
- **`role_permission_list(p_role_id BIGINT)`**: Role permission list.
- **`role_permission_remove(p_role_id BIGINT, p_permission_code VARCHAR)`**: Role permission remove.
- **`role_update(p_id BIGINT, p_name VARCHAR DEFAULT NULL, p_description VARCHAR DEFAULT NULL, p_updated_by BIGINT DEFAULT NULL, p_status SMALLINT DEFAULT NULL)`**: Role update.
- **`session_belongs_to_user(p_session_id VARCHAR(50), p_user_id BIGINT)`**: Checks if a session belongs to the specified user.
- **`session_cleanup_expired(p_batch_size INT DEFAULT 1000, p_revoked_retention_days INT DEFAULT 7, p_inactivity_days INT DEFAULT 5)`**: Session cleanup expired.
- **`session_list(p_user_id BIGINT)`**: Session list.
- **`session_revoke(p_session_id VARCHAR(50), p_reason VARCHAR(200) DEFAULT 'User requested')`**: Session revoke.
- **`session_revoke_all(p_user_id BIGINT, p_reason VARCHAR(200) DEFAULT 'User requested logout all', p_except_session_id VARCHAR(50) DEFAULT NULL)`**: Session revoke all.
- **`session_save(p_session_id VARCHAR(50), p_user_id BIGINT, p_refresh_token_id VARCHAR(100), p_ip_address VARCHAR(50), p_user_agent VARCHAR(500), p_device_name VARCHAR(100), p_expires_at TIMESTAMPTZ)`**: Session save.
- **`session_update_activity(p_session_id VARCHAR(50))`**: Updates session last activity timestamp. Called when refresh token is used.
- **`user_authenticate(p_email VARCHAR(255))`**: User authenticate. Returns user info with `requirePasswordChange` (true if password expired or flag set), `passwordChangedAt`, and `primaryDepartment` (JSONB multi-language name).
- **`user_check_email_exists(p_email TEXT, p_exclude_user_id BIGINT DEFAULT NULL)`**: User check email exists.
- **`user_check_username_exists(p_username TEXT, p_company_id BIGINT, p_exclude_user_id BIGINT DEFAULT NULL)`**: User check username exists.
- **`user_create(p_caller_id BIGINT, p_email TEXT, p_username TEXT, p_password TEXT, p_first_name TEXT, p_last_name TEXT, p_company_id BIGINT, p_language CHAR(2) DEFAULT NULL, p_timezone VARCHAR(50) DEFAULT NULL, p_currency CHAR(3) DEFAULT NULL, p_department_id BIGINT DEFAULT NULL)`**: User create. Optional `p_department_id` assigns user to department as primary.
- **`user_delete(p_caller_id BIGINT, p_user_id BIGINT)`**: User delete.
- **`user_get(p_caller_id BIGINT, p_user_id BIGINT)`**: User get. Includes `departments` array (JSONB multi-language departmentName/parentName, isPrimary).
- **`user_list(p_caller_id BIGINT, p_company_id BIGINT, p_tenant_id BIGINT DEFAULT NULL, p_page INT DEFAULT 1, p_page_size INT DEFAULT 10, p_search TEXT DEFAULT NULL, p_status SMALLINT DEFAULT NULL, p_sort_by TEXT DEFAULT 'id', p_sort_order TEXT DEFAULT 'ASC')`**: User list. Includes `primaryDepartment` (JSONB multi-language name) per user.
- **`user_login_failed_increment(p_user_id BIGINT, p_lock_threshold INT DEFAULT 5, p_lock_duration_minutes INT DEFAULT 30)`**: User login failed increment.
- **`user_login_failed_reset(p_user_id BIGINT)`**: User login failed reset.
- **`user_permission_list(p_user_id BIGINT, p_tenant_id BIGINT DEFAULT NULL)`**: User permission list.
- **`user_permission_override_list(p_caller_id BIGINT, p_user_id BIGINT, p_tenant_id BIGINT DEFAULT NULL)`**: User permission override list.
- **`user_permission_override_load(p_user_id BIGINT, p_tenant_id BIGINT DEFAULT NULL)`**: User permission override load.
- **`user_permission_remove(p_caller_id BIGINT, p_user_id BIGINT, p_permission_code VARCHAR(100), p_tenant_id BIGINT DEFAULT NULL)`**: User permission remove.
- **`user_permission_set(p_user_id BIGINT, p_permission_code VARCHAR(100), p_is_granted BOOLEAN, p_tenant_id BIGINT DEFAULT NULL, p_reason VARCHAR(500) DEFAULT NULL, p_assigned_by BIGINT DEFAULT NULL, p_expires_at TIMESTAMPTZ DEFAULT NULL)`**: User permission set.
- **`user_permission_set_with_outbox(p_user_id BIGINT, p_permission_code VARCHAR(100), p_is_granted BOOLEAN, p_tenant_id BIGINT DEFAULT NULL, p_reason VARCHAR(500) DEFAULT NULL, p_assigned_by BIGINT DEFAULT NULL, p_expires_at TIMESTAMPTZ DEFAULT NULL, p_outbox_messages TEXT DEFAULT '[]')`**: User permission set with outbox. `p_outbox_messages` is sent as TEXT from Dapper and cast to JSONB internally.
- **`company_password_policy_get(p_caller_id BIGINT, p_company_id BIGINT)`**: Returns company password policy with IDOR protection. Platform Admin can view any company, CompanyAdmin only their own. Returns `hasCustomPolicy` flag to indicate if using defaults (expiryDays=30, historyCount=3).
- **`company_password_policy_upsert(p_caller_id BIGINT, p_company_id BIGINT, p_expiry_days INT DEFAULT 30, p_history_count INT DEFAULT 3)`**: Creates or updates company password policy with IDOR protection. Platform Admin can edit any company, CompanyAdmin only their own. Validates expiryDays >= 0, historyCount 0-10.
- **`user_change_password(p_user_id BIGINT, p_current_password_hash TEXT, p_new_password_hash TEXT)`**: User changes own password. Validates current password, checks against recent passwords (from `company_password_policy.history_count` with platform default 3), saves old password to history, sets `require_password_change = FALSE`.
- **`user_reset_password(p_caller_id BIGINT, p_user_id BIGINT, p_new_password TEXT)`**: Admin resets user password (IDOR protected). Saves old password to history, sets `require_password_change = TRUE` (user must change on next login). Uses target user's company policy for history cleanup.
- **`user_role_assign(p_caller_id BIGINT, p_user_id BIGINT, p_role_code VARCHAR, p_tenant_id BIGINT DEFAULT NULL, p_assigned_by BIGINT DEFAULT NULL)`**: User role assign.
- **`user_role_list(p_caller_id BIGINT, p_user_id BIGINT, p_tenant_id BIGINT DEFAULT NULL)`**: User role list.
- **`user_role_remove(p_caller_id BIGINT, p_user_id BIGINT, p_role_code VARCHAR, p_tenant_id BIGINT DEFAULT NULL)`**: User role remove.
- **`user_unlock(p_caller_id BIGINT, p_user_id BIGINT)`**: User unlock.
- **`user_update(p_caller_id BIGINT, p_user_id BIGINT, p_first_name TEXT DEFAULT NULL, p_last_name TEXT DEFAULT NULL, p_email TEXT DEFAULT NULL, p_username TEXT DEFAULT NULL, p_status SMALLINT DEFAULT NULL, p_language CHAR(2) DEFAULT NULL, p_timezone VARCHAR(50) DEFAULT NULL, p_currency CHAR(3) DEFAULT NULL, p_two_factor_enabled BOOLEAN DEFAULT NULL, p_require_password_change BOOLEAN DEFAULT NULL, p_department_id BIGINT DEFAULT NULL)`**: User update. Optional `p_department_id` changes primary department.

### Triggers

- **`trigger_menu_groups_updated_at`**: Trigger trigger_menu_groups_updated_at
- **`trigger_users_updated_at`**: Trigger trigger_users_updated_at
- **`update_updated_at_column`**: UPDATE_UPDATED_AT_COLUMN Generic trigger function to update 'updated_at' column to NOW()

## Core Audit Database

### Backoffice Schema

- **`auth_audit_create(p_user_id BIGINT, p_company_id BIGINT, p_tenant_id BIGINT, p_event_type VARCHAR(50), p_event_data TEXT DEFAULT NULL, p_ip_address VARCHAR(50) DEFAULT NULL, p_user_agent VARCHAR(500) DEFAULT NULL, p_success BOOLEAN DEFAULT TRUE, p_error_message VARCHAR(500) DEFAULT NULL)`**: Auth audit create.
- **`auth_audit_failed_logins(p_user_id BIGINT, p_hours INT DEFAULT 1)`**: Auth audit failed logins.
- **`auth_audit_list_by_type(p_event_type VARCHAR(50), p_from_date TIMESTAMPTZ DEFAULT NULL, p_to_date TIMESTAMPTZ DEFAULT NULL, p_limit INT DEFAULT 100)`**: Auth audit list by type.
- **`auth_audit_list_by_user(p_user_id BIGINT, p_limit INT DEFAULT 50)`**: Auth audit list by user.

## Core Log Database

### Backoffice Schema

- **`audit_create(p_event_id VARCHAR(255) DEFAULT NULL, p_original_event_id VARCHAR(255) DEFAULT NULL, p_tenant_id VARCHAR(100) DEFAULT NULL, p_user_id VARCHAR(255) DEFAULT NULL, p_action VARCHAR(100) DEFAULT NULL, p_entity_type VARCHAR(100) DEFAULT NULL, p_entity_id VARCHAR(255) DEFAULT NULL, p_old_value TEXT DEFAULT NULL, p_new_value TEXT DEFAULT NULL, p_ip_address VARCHAR(50) DEFAULT NULL, p_correlation_id VARCHAR(255) DEFAULT NULL, p_forwarded_at TIMESTAMPTZ DEFAULT NULL)`**: Audit create.
- **`audit_get(p_id UUID)`**: Get entity audit log by ID
- **`audit_list(p_tenant_id VARCHAR(100) DEFAULT NULL, p_user_id VARCHAR(255) DEFAULT NULL, p_action VARCHAR(100) DEFAULT NULL, p_entity_type VARCHAR(100) DEFAULT NULL, p_entity_id VARCHAR(255) DEFAULT NULL, p_from_date TIMESTAMPTZ DEFAULT NULL, p_to_date TIMESTAMPTZ DEFAULT NULL, p_page INT DEFAULT 1, p_page_size INT DEFAULT 20)`**: Get paginated entity audit logs

### Logs Schema

- **`core_audit_create(p_event_id VARCHAR(255), p_user_id VARCHAR(255) DEFAULT NULL, p_action VARCHAR(100) DEFAULT NULL, p_entity_type VARCHAR(100) DEFAULT NULL, p_entity_id VARCHAR(255) DEFAULT NULL, p_old_value TEXT DEFAULT NULL, p_new_value TEXT DEFAULT NULL, p_ip_address VARCHAR(50) DEFAULT NULL, p_correlation_id VARCHAR(255) DEFAULT NULL)`**: Core audit create.
- **`core_audit_list(p_user_id VARCHAR(255) DEFAULT NULL, p_action VARCHAR(100) DEFAULT NULL, p_entity_type VARCHAR(100) DEFAULT NULL, p_entity_id VARCHAR(255) DEFAULT NULL, p_from_date TIMESTAMPTZ DEFAULT NULL, p_to_date TIMESTAMPTZ DEFAULT NULL, p_page INT DEFAULT 1, p_page_size INT DEFAULT 20)`**: Get core audit logs with filtering
- **`dead_letter_create(p_event_id VARCHAR(255), p_event_type VARCHAR(255), p_tenant_id VARCHAR(100) DEFAULT NULL, p_payload JSONB DEFAULT NULL, p_exception_message TEXT DEFAULT NULL, p_exception_stack_trace TEXT DEFAULT NULL, p_retry_count INT DEFAULT 0, p_status VARCHAR(50) DEFAULT 'pending')`**: Dead letter create.
- **`dead_letter_get(p_id UUID)`**: Get dead letter by ID
- **`dead_letter_list_pending(p_limit INT DEFAULT 100)`**: Get pending dead letters for retry
- **`dead_letter_retry(p_id UUID)`**: Increment retry count and set status to retrying
- **`dead_letter_stats()`**: Get dead letter statistics
- **`dead_letter_update_status(p_id UUID, p_status VARCHAR(50), p_resolved_by VARCHAR(255) DEFAULT NULL, p_resolution_notes TEXT DEFAULT NULL)`**: Update dead letter status
- **`error_get(p_id BIGINT)`**: Get error by ID
- **`error_list(p_tenant_id BIGINT DEFAULT NULL, p_error_code TEXT DEFAULT NULL, p_from_date TIMESTAMPTZ DEFAULT NULL, p_to_date TIMESTAMPTZ DEFAULT NULL, p_limit INT DEFAULT 100)`**: Get recent errors with filtering
- **`error_log(p_error_code TEXT, p_error_message TEXT, p_exception_type TEXT DEFAULT NULL, p_http_status_code INT DEFAULT 500, p_is_retryable BOOLEAN DEFAULT FALSE, p_tenant_id BIGINT DEFAULT NULL, p_user_id TEXT DEFAULT NULL, p_correlation_id TEXT DEFAULT NULL, p_request_path TEXT DEFAULT NULL, p_request_method TEXT DEFAULT NULL, p_resource_type TEXT DEFAULT NULL, p_resource_key TEXT DEFAULT NULL, p_error_metadata TEXT DEFAULT NULL, p_stack_trace TEXT DEFAULT NULL, p_cluster_name TEXT DEFAULT NULL, p_occurred_at TIMESTAMPTZ DEFAULT NOW())`**: Error log.
- **`error_stats(p_tenant_id BIGINT DEFAULT NULL, p_hours INT DEFAULT 24)`**: Get error statistics

## Tenant Database

> **Note:** Tenant database functions do NOT perform IDOR (access control) checks.
> Authorization is handled in Core DB via `user_assert_access_tenant(caller_id, tenant_id)` before calling tenant functions.
> This follows the cross-database security pattern: **Core DB (auth) → Tenant DB (business logic)**.

### Content Schema

> Functions will be documented here as they are implemented.

### Bonus Schema

> Functions will be documented here as they are implemented.

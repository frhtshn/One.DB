# Client Functions & Triggers

Client katmanındaki tüm stored procedure, function ve trigger'ları içerir.

**Veritabanı:** `client` (birleşik DB — 30 schema: core business, log, audit, report, affiliate)
**Toplam:** 337 fonksiyon

---

## Client Database (292 fonksiyon)

> **Note:** Client database functions do NOT perform IDOR (access control) checks.
> Authorization is handled in Core DB via `user_assert_access_client(caller_id, client_id)` before calling client functions.
> This follows the cross-database security pattern: **Core DB (auth) → Client DB (business logic)**.

### Auth Schema (31)

> **Detaylı rehber:** [PLAYER_AUTH_KYC_GUIDE.md](../guides/PLAYER_AUTH_KYC_GUIDE.md)

#### Shadow Test (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `shadow_tester_add` | Shadow test kullanıcısı ekle (idempotent) → VOID |
| `shadow_tester_remove` | Shadow test kullanıcısını kaldır → VOID |
| `shadow_tester_list` | Tüm shadow tester'ları listele (username dahil) → JSONB |
| `shadow_tester_get` | player_id bazlı shadow tester detayı → JSONB |

#### Player Category CRUD (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_category_create` | Yeni oyuncu kategorisi oluştur. Kod UPPER(TRIM) ile normalize edilir → BIGINT |
| `player_category_update` | Oyuncu kategorisini güncelle. Partial update (COALESCE) → VOID |
| `player_category_get` | Kategori detayı + playerCount → JSONB |
| `player_category_list` | Kategorileri listele. Opsiyonel is_active filtresi, level sıralı → JSONB |
| `player_category_delete` | Soft delete (is_active = false) → VOID |

#### Player Group CRUD (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_group_create` | Yeni oyuncu grubu oluştur. Kod UPPER(TRIM) ile normalize edilir → BIGINT |
| `player_group_update` | Oyuncu grubunu güncelle. Partial update (COALESCE) → VOID |
| `player_group_get` | Grup detayı + playerCount → JSONB |
| `player_group_list` | Grupları listele. Opsiyonel is_active filtresi, level sıralı → JSONB |
| `player_group_delete` | Soft delete (is_active = false) → VOID |

#### Player Classification (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_classification_assign` | Oyuncuya kategori/grup ata. Kategori tek (upsert), grup çoklu (idempotent) → VOID |
| `player_classification_remove` | Oyuncudan kategori/grup kaldır → VOID |
| `player_classification_list` | Oyuncunun kategori + gruplarını getir → JSONB |
| `player_classification_bulk_assign` | Toplu kategori/grup atama → INT |

#### Player Segmentation (1)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_get_segmentation` | Bonus eligibility için oyuncu segmentasyon verisi. Tek giriş noktası → JSONB |

#### Player Registration & Email Verification (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_register` | Oyuncu kayıt. Username/email uniqueness, email_verification_token oluştur → JSONB |
| `player_verify_email` | Email doğrulama tokenı ile email onaylama. status=0→1 geçişi → JSONB |
| `player_resend_verification` | Yeni doğrulama tokeni oluştur. Eski tokenları sil → VOID |

#### Player Authentication (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_authenticate` | Email hash ile oyuncu bilgilerini getir (STABLE). Backend Argon2id doğrular → JSONB |
| `player_login_failed_increment` | Başarısız giriş sayacını artır. Eşik aşılınca hesabı kilitle → JSONB |
| `player_login_failed_reset` | Başarısız giriş sayacını sıfırla → VOID |

#### Password Management (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_change_password` | Şifre değiştir. Geçmiş kontrol (history_count) → VOID |
| `player_reset_password_request` | Şifre sıfırlama tokeni oluştur. Mevcut tokenları sil → VOID |
| `player_reset_password_confirm` | Token ile şifre sıfırla. Token doğrulama + expire kontrolü → JSONB |

#### BO Player Management (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_get` | Oyuncu detay: profil, kimlik, KYC, sınıflandırma, cüzdanlar, kısıtlamalar → JSONB |
| `player_list` | Sayfalı oyuncu listesi. Hash-based filtreler, LEFT JOIN LATERAL sınıflandırma → JSONB |
| `player_update_status` | Oyuncu durumunu güncelle (aktif/askı/kapalı). Sebep zorunlu → VOID |

### Profile Schema (5)

> **Detaylı rehber:** [PLAYER_AUTH_KYC_GUIDE.md](../guides/PLAYER_AUTH_KYC_GUIDE.md)

#### Player Profile (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_profile_create` | Profil oluştur. BYTEA (AES-256) şifreli PII alanları → BIGINT |
| `player_profile_get` | Profil getir. BYTEA→base64 encode. STABLE → JSONB |
| `player_profile_update` | Profil güncelle. COALESCE partial update → VOID |

#### Player Identity (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_identity_upsert` | Kimlik belgesi oluştur/güncelle. Şifreli no + hash → BIGINT |
| `player_identity_get` | Kimlik belgesi getir. Bulunamazsa NULL (hata değil). STABLE → JSONB |

### KYC Schema (35)

> **Detaylı rehber:** [PLAYER_AUTH_KYC_GUIDE.md](../guides/PLAYER_AUTH_KYC_GUIDE.md)

#### KYC Case (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `kyc_case_create` | KYC vakası oluştur. Oyuncu durum kontrolü → BIGINT |
| `kyc_case_update_status` | Vaka durumunu güncelle. kyc_workflows tarihçe kaydı → VOID |
| `kyc_case_assign_reviewer` | İnceleyici ata. kyc_workflows tarihçe kaydı → VOID |
| `kyc_case_get` | Vaka detay: belgeler, kısıtlamalar, workflow tarihçesi dahil. STABLE → JSONB |
| `kyc_case_list` | Sayfalı vaka listesi. Status/level/reviewer filtreleri → JSONB |

#### KYC Document (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `document_upload` | Belge kaydı oluştur. Vaka kontrolü, storage bilgileri → BIGINT |
| `document_review` | **DEPRECATED** → `document_decision_create()` kullanın. Geriye uyumluluk → VOID |
| `document_get` | Belge detayı + son analiz + son karar özeti. STABLE → JSONB |
| `document_list` | Oyuncunun belgelerini listele → JSONB |

#### KYC Document Analysis — IDManager (4)

> **Detaylı spec:** [SPEC_IDMANAGER_INTEGRATION.md](../guides/SPEC_IDMANAGER_INTEGRATION.md)

| Fonksiyon | Açıklama |
|-----------|----------|
| `document_analysis_save` | IDManager analiz sonucunu kaydet. Kimlik + adres pipeline → BIGINT |
| `document_analysis_get` | Belgenin tüm analiz kayıtları (en yeniden eskiye) → JSONB |
| `document_analysis_list_by_case` | Case'e ait tüm belgelerin analizleri → JSONB |
| `document_request_reanalysis` | Tekrar analiz talebi. Status → analyzing → VOID |

#### KYC Document Decision (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `document_decision_create` | Operatör kararı (approved/rejected). Workflow kaydı → BIGINT |
| `document_decision_list` | Belgenin karar geçmişi → JSONB |
| `document_decision_list_by_case` | Case'e ait tüm kararlar → JSONB |

#### KYC Restriction (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `restriction_create` | Kısıtlama oluştur. Tip (deposit/withdrawal/login/gameplay) → BIGINT |
| `restriction_revoke` | Kısıtlamayı kaldır. Min süre kontrolü → VOID |
| `restriction_get` | Kısıtlama detayı. STABLE → JSONB |
| `restriction_list` | Oyuncunun kısıtlamaları. Opsiyonel aktif/pasif filtresi → JSONB |

#### KYC Limit (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `limit_set` | Limit ata. Oyuncu azaltma=anında, artırma=24s bekleme, admin=anında → BIGINT |
| `limit_remove` | Limiti kaldır (soft delete) → VOID |
| `limit_activate_pending` | 24 saati dolmuş bekleyen limitleri aktifleştir. Batch → INT |
| `limit_get` | Mevcut aktif limitler. STABLE → JSONB |
| `limit_history_list` | Limit değişiklik tarihçesi → JSONB |

#### KYC AML (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `aml_flag_create` | AML işareti oluştur. Tip/ciddiyet/açıklama → BIGINT |
| `aml_flag_assign` | AML işaretini soruşturmacıya ata → VOID |
| `aml_flag_update_status` | Durum güncelle (open→investigating→closed) → VOID |
| `aml_flag_add_decision` | Karar ekle. SAR bilgileri opsiyonel → VOID |
| `aml_flag_get` | AML işaret detayı. STABLE → JSONB |
| `aml_flag_list` | Sayfalı AML işaret listesi. Durum/tip/ciddiyet filtreleri → JSONB |

#### KYC Jurisdiction (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `jurisdiction_create` | Oyuncu yetki alanı kaydı oluştur → BIGINT |
| `jurisdiction_update` | Yetki alanı bilgilerini güncelle. COALESCE partial update → VOID |
| `jurisdiction_update_geo` | GeoIP verileri güncelle (backend çağrısı) → VOID |
| `jurisdiction_get` | Yetki alanı detayı. STABLE → JSONB |

### Finance Schema (20)

#### Döviz Kurları (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `crypto_rates_bulk_upsert` | Bulk upsert crypto rates from CryptoGrain. History + latest in single transaction |
| `crypto_rates_latest_list` | Latest crypto rates for a base currency with 24h/7d change |
| `currency_rates_bulk_upsert` | Bulk upsert currency rates from CurrencyGrain. History + latest in single transaction |
| `currency_rates_latest_list` | Latest fiat currency rates with change tracking |

#### Ödeme Yöntemi Ayarları (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `payment_method_settings_sync` | Ödeme yöntemi ayarlarını Core DB'den senkronize et |
| `payment_method_settings_remove` | Ödeme yöntemi ayarlarını kaldır |
| `payment_method_settings_get` | ID ile ödeme yöntemi ayarı getir |
| `payment_method_settings_update` | Ödeme yöntemi ayarını güncelle |
| `payment_method_settings_list` | Ödeme yöntemi ayarları listesi |

#### Ödeme Limitleri (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `payment_method_limits_sync` | Ödeme yöntemi limitlerini Core DB'den senkronize et |
| `payment_method_limit_upsert` | Ödeme yöntemi limiti oluştur/güncelle |
| `payment_method_limit_list` | Ödeme yöntemi limitleri listesi |
| `payment_provider_rollout_sync` | Ödeme sağlayıcı rollout durumunu senkronize et |

#### Oyuncu Ödeme Limitleri (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `payment_player_limit_set` | Oyuncu bazlı ödeme yöntemi limiti ata |
| `payment_player_limit_get` | Oyuncu ödeme yöntemi limitini getir |
| `payment_player_limit_list` | Oyuncu ödeme yöntemi limitleri listesi |

#### Oyuncu Genel Finansal Limitleri (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_financial_limit_set` | Oyuncu genel finansal limit ata (yöntemden bağımsız) |
| `player_financial_limit_get` | Oyuncu genel finansal limitini getir |
| `player_financial_limit_list` | Oyuncu genel finansal limitleri listesi |

#### Ücret Hesaplama (1)

| Fonksiyon | Açıklama |
|-----------|----------|
| `calculate_fee` | Ödeme yöntemi ücreti hesapla. Formül: MAX(min, MIN(max, amount * percent + fixed)) → JSONB |

### Game Schema (25)

#### Oyun Ayarları (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `game_settings_sync` | Core DB→Client oyun kataloğu senkronizasyonu (UPSERT, client override'ları korur) |
| `game_settings_remove` | Oyunu devre dışı bırak (soft delete, is_enabled=FALSE) |
| `game_settings_get` | Oyun ayarı detay. Returns JSONB |
| `game_settings_update` | Client özelleştirmelerini güncelle (COALESCE, 14 parametre). Returns VOID |
| `game_settings_list` | Cursor pagination, provider/tip/arama filtreli, shadow mode destekli. Returns JSONB |

#### Oyun Limitleri (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `game_limits_sync` | Core DB'den oyun limiti senkronizasyonu (UPSERT, artık desteklenmeyen → is_active=FALSE) |
| `game_limit_upsert` | Para birimi bazlı oyun limiti oluştur/güncelle. Returns BIGINT |
| `game_limit_list` | Oyun limitleri listesi. Returns JSONB |
| `game_provider_rollout_sync` | Provider rollout durumunu güncelle (production/shadow/disabled). Returns VOID |

#### Lobi Bölümleri (8)

| Fonksiyon | Açıklama |
|-----------|----------|
| `upsert_lobby_section` | Lobi bölümü oluştur/güncelle (UPSERT by code). Returns BIGINT |
| `upsert_lobby_section_translation` | Lobi bölümü çevirisi oluştur/güncelle. Returns BIGINT |
| `list_lobby_sections` | Bölümler + iç içe çeviriler. Returns JSONB |
| `delete_lobby_section` | Soft delete (oyun atamaları CASCADE). Returns VOID |
| `reorder_lobby_sections` | Toplu sıralama güncelle. Returns VOID |
| `add_game_to_lobby_section` | Manual bölüme oyun ekle (section_type='manual' kontrolü). Returns BIGINT |
| `remove_game_from_lobby_section` | Bölümden oyun çıkar (soft delete). Returns VOID |
| `list_lobby_section_games` | Bölümdeki oyun ID listesi. Returns JSONB |

#### Oyun Etiketleri (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `upsert_game_label` | Oyun etiketi oluştur/güncelle (UPSERT by game_id+label_type). Returns BIGINT |
| `list_game_labels` | Oyuna ait aktif etiketler, süresi dolmuş filtresi. Returns JSONB |
| `delete_game_label` | Soft delete. Returns VOID |

#### Game Sessions (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `game_session_create` | Yeni oyun oturumu oluştur. Token üret, oyuncu durum kontrolü → JSONB |
| `game_session_validate` | Session token doğrula. Expire kontrolü, last_activity güncelle → JSONB |
| `game_session_end` | Oyun oturumunu kapat. İdempotent (zaten kapalı ise sessizce true) → BOOL |

#### FE: Public Game APIs (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `get_public_lobby` | Aktif lobi bölümleri + çeviriler + manual game_id listesi. auto_* → boş array (backend doldurur). Returns JSONB |
| `get_public_game_list` | Oyuncu oyun listesi: is_enabled+is_visible zorlanır, shadow mode, bölüm filtresi, etiketler dahil, cursor pagination. Returns JSONB |

### Transaction Schema (19)

#### Lookup Sync (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `transaction_types_sync` | Core→Client işlem tipi kataloğu senkronizasyonu (UPSERT by id) |
| `operation_types_sync` | Core→Client operasyon tipi kataloğu senkronizasyonu (UPSERT by id) |

#### Payment Sessions (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `payment_session_create` | Ödeme oturumu oluştur. UUID token üret, TTL expiry → JSONB |
| `payment_session_get` | Token ile oturum getir. Expire kontrolü, otomatik status güncelleme → JSONB |
| `payment_session_update` | Oturum güncelle. COALESCE ile kısmi güncelleme, completed_at otomatik → VOID |

#### Workflow Operations (9)

| Fonksiyon | Açıklama |
|-----------|----------|
| `workflow_create` | Onay akışı başlat. Tip: WITHDRAWAL, ADJUSTMENT, HIGH_VALUE, SUSPICIOUS, KYC_REQUIRED → BIGINT |
| `workflow_assign` | BO kullanıcısına ata. PENDING → IN_REVIEW, `assigned_to_id` güncelle → VOID |
| `workflow_approve` | Onayla. IN_REVIEW → APPROVED → VOID |
| `workflow_reject` | Reddet. IN_REVIEW → REJECTED, red sebebi kaydedilir → VOID |
| `workflow_cancel` | İptal et. PENDING → CANCELLED (oyuncu iptali) → VOID |
| `workflow_escalate` | Üst seviyeye yükselt. IN_REVIEW kalır, `assigned_to_id` değişir → VOID |
| `workflow_add_note` | Workflow'a not ekle. Durumu değiştirmez, audit trail → VOID |
| `workflow_list` | Filtrelemeli + sayfalı liste (status, assigned_to, workflow_type filtresi) → JSONB |
| `workflow_get` | Detay + action geçmişi + transaction bilgisi → JSONB |

#### Account Adjustment (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `adjustment_create` | Hesap düzeltme talebi oluştur. PENDING kayıt, workflow beklenir → BIGINT |
| `adjustment_apply` | Workflow onayı sonrası wallet'a uygula. CREDIT veya DEBIT → JSONB |
| `adjustment_cancel` | Workflow reddi sonrası iptal et. Wallet değişmez → VOID |
| `adjustment_get` | Düzeltme detayı + workflow durumu → JSONB |
| `adjustment_list` | Filtrelemeli + sayfalı liste (status, player, adjustment_type) → JSONB |

### Wallet Schema (23)

#### Wallet Setup (1)

| Fonksiyon | Açıklama |
|-----------|----------|
| `wallet_create` | REAL + BONUS cüzdan oluştur. Oyuncu aktiflik kontrolü, idempotent (ON CONFLICT DO NOTHING) → JSONB |

#### Balance & Info (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_info_get` | Oyuncu bilgisi getir (Hub88 /user/info). STABLE → JSONB |
| `player_balance_get` | REAL + BONUS cüzdan bakiyesi. STABLE → JSONB |
| `player_balance_per_game_get` | PP getBalancePerGame. Oyun bazlı bakiye (aynı bakiye) → JSONB |

#### Wallet Operations (7)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bet_process` | Bahis işlemi. FOR UPDATE kilit, bakiye kontrolü, debit → JSONB |
| `win_process` | Kazanç işlemi. Credit, amount=0 geçerli (kayıp round) → JSONB |
| `rollback_process` | Bahis iadesi / kazanç geri alma. PP+Hub88 spec: bulunamazsa başarılı → JSONB |
| `jackpot_win_process` | Jackpot kazancı. win_process wrapper (tx_type=70) → JSONB |
| `bonus_win_process` | Bonus kazancı. win_process wrapper (tx_type=72) → JSONB |
| `promo_win_process` | Promosyon kazancı. win_process wrapper (tx_type=71) → JSONB |
| `adjustment_process` | Bakiye düzeltme. Pozitif=credit, negatif=debit (tx_type=26) → JSONB |

#### Deposit Operations (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `deposit_initiate` | Para yatırma başlat. PENDING tx oluştur, bakiye DEĞİŞMEZ → JSONB |
| `deposit_confirm` | Para yatırma onayla. FOR UPDATE kilit, bakiye ARTAR. İdempotent → JSONB |
| `deposit_fail` | Para yatırma başarısız işaretle. Bakiye değişmez → BOOLEAN |
| `deposit_manual_process` | Manuel para yatırma. Tek adım credit (tx_type=81) → JSONB |

#### Withdrawal Operations (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `withdrawal_initiate` | Para çekme başlat. FOR UPDATE kilit, bakiye HEMEN düşer, çevrim kontrolü → JSONB |
| `withdrawal_confirm` | Para çekme onayla. confirmed_at güncelle, bakiye değişmez → BOOLEAN |
| `withdrawal_cancel` | Para çekme iptal. Reversal tx ile bakiye geri eklenir → JSONB |
| `withdrawal_fail` | Para çekme başarısız (PSP red). Reversal tx ile bakiye geri eklenir → JSONB |
| `withdrawal_manual_process` | Manuel para çekme. Tek adım debit (tx_type=86) → JSONB |

### Bonus Schema (30)

#### Bonus Award (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bonus_award_create` | Oyuncuya bonus ver. BONUS wallet credit + transaction kaydı. Worker veya bonus_request_approve tarafından çağrılır. `p_bonus_request_id` opsiyonel |
| `bonus_award_get` | ID ile bonus award detayı getir |
| `bonus_award_list` | Oyuncu bonus award listesi (durum filtreleme) |
| `bonus_award_cancel` | Aktif bonusu iptal et. Kalan bakiye BONUS wallet'tan düşülür |
| `bonus_award_complete` | Çevrimi tamamlanan bonusu REAL wallet'a aktar. max_withdrawal_amount limiti uygulanır |
| `bonus_award_expire` | Batch expire: süresi dolmuş bonusları expire et. SKIP LOCKED ile concurrent worker güvenliği |

#### Promo Redemption (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `promo_redeem` | Promosyon kodu kullan. Kullanım limiti ve süre kontrolü |
| `promo_redemption_list` | Promosyon kullanım geçmişi listesi |

#### Provider Bonus Mapping (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `provider_bonus_mapping_create` | Provider tarafı bonus eşleştirmesi oluştur (free spin/free bet). Provider bonus ID ve request ID ile → BIGINT |
| `provider_bonus_mapping_get` | Provider code + provider bonus ID ile eşleştirme getir. STABLE, bulunamazsa NULL → JSONB |
| `provider_bonus_mapping_update_status` | Provider bonus eşleştirme durumunu güncelle (active/completed/cancelled/expired) → VOID |

#### Bonus Request Settings (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bonus_request_setting_upsert` | Bonus talep ayarı oluştur/güncelle. JSONB parse (display_name, rules_content, eligible_groups/categories). ON CONFLICT upsert → BIGINT |
| `bonus_request_setting_list` | Aktif bonus talep ayarları listesi. display_order sıralı → JSONB |
| `bonus_request_setting_get` | bonus_type_code ile tekil ayar getir → JSONB |
| `player_requestable_bonus_types` | FE-facing: oyuncu için talep edilebilir bonus tipleri. Eligibility + cooldown filtresi, lokalize display_name/rules_content → JSONB |

#### Bonus Request BO (10)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bonus_request_create` | Bonus talebi oluştur (player/operator source). Operatör: amount+currency zorunlu → BIGINT |
| `bonus_request_get` | Talep detay + actions array → JSONB |
| `bonus_request_list` | Sayfalı liste (status, source, player, assignee, type, priority filtreleri) → JSONB |
| `bonus_request_assign` | pending\|assigned → assigned. Operatöre ata → VOID |
| `bonus_request_start_review` | pending\|assigned\|on_hold → in_progress. İnceleme başlat/devam et → VOID |
| `bonus_request_hold` | in_progress → on_hold. hold_reason zorunlu → VOID |
| `bonus_request_approve` | in_progress → completed (atomik). bonus_award_create() çağrılır. Award ID döner → BIGINT |
| `bonus_request_reject` | assigned\|in_progress → rejected. review_note zorunlu → VOID |
| `bonus_request_cancel` | pending\|assigned → cancelled → VOID |
| `bonus_request_rollback` | completed\|rejected → in_progress. Completed: bonus_award_cancel() çağrılır → VOID |

#### Bonus Request Player (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_bonus_request_create` | Oyuncu bonus talebi. Eligibility (grup/kategori, OR mantığı) + cooldown + pending limit kontrolü → BIGINT |
| `player_bonus_request_list` | Oyuncu talep listesi. Güvenli alanlar, completed ise wagering bilgisi → JSONB |
| `player_bonus_request_cancel` | Oyuncu kendi pending talebini iptal. Sahiplik kontrolü → VOID |

#### Bonus Request Maintenance (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bonus_request_expire` | Süresi dolmuş pending/assigned talepleri expire et. SKIP LOCKED batch → INT |
| `bonus_request_cleanup` | cancelled/expired talepleri retention sonrası sil. completed/rejected asla silinmez → INT |

### Content Schema (67)

> **Detaylı rehber:** [SITE_MANAGEMENT_GUIDE.md](../guides/SITE_MANAGEMENT_GUIDE.md)

#### BO: CMS Kategori (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `content_category_upsert` | Kategori oluştur/güncelle (çeviriler dahil). NULL id → create. Returns INT |
| `content_category_delete` | Aktif tipleri varsa engelle, yoksa soft delete. Returns VOID |
| `content_category_list` | Tüm kategoriler, aktiflik filtreli + çeviriler. Returns JSONB |

#### BO: CMS Tip (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `content_type_upsert` | İçerik tipi oluştur/güncelle (çeviriler dahil). Returns INT |
| `content_type_delete` | Aktif içerik varsa engelle, yoksa soft delete. Returns VOID |
| `content_type_list` | Tipler, kategori/aktiflik filtreli + çeviriler. Returns JSONB |

#### BO: CMS İçerik (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `content_create` | İçerik oluştur (çeviriler + ekler). status=draft. Returns INT |
| `content_update` | İçerik güncelle (DELETE+INSERT çeviriler/ekler). Returns VOID |
| `content_get` | Detay: çeviriler + ekler + versiyon geçmişi. Returns JSONB |
| `content_list` | Sayfalanmış liste, tip/durum/arama filtreli. Returns JSONB |
| `content_publish` | Versiyon artır, content_versions'a snapshot al. Returns VOID |

#### BO: FAQ (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `faq_category_upsert` | FAQ kategori oluştur/güncelle + çeviriler. Returns INT |
| `faq_category_delete` | Aktif öğeleri varsa engelle. Returns VOID |
| `faq_category_list` | Kategoriler + öğe sayısı. Returns JSONB |
| `faq_item_upsert` | FAQ öğesi oluştur/güncelle + çeviriler. Returns INT |
| `faq_item_delete` | Soft delete. Returns VOID |

#### BO: Popup (8)

| Fonksiyon | Açıklama |
|-----------|----------|
| `popup_type_upsert` | Popup tipi oluştur/güncelle + çeviriler. Returns INT |
| `popup_type_list` | Tüm popup tipleri. Returns JSONB |
| `popup_create` | Popup oluştur (config + targeting + çeviriler + görseller + zamanlama). Returns INT |
| `popup_update` | Popup güncelle (DELETE+INSERT alt kayıtlar). Returns VOID |
| `popup_get` | Detay: çeviriler + görseller + zamanlama. Returns JSONB |
| `popup_list` | Sayfalanmış liste, tip/aktiflik filtreli. Returns JSONB |
| `popup_delete` | Soft delete (is_deleted). Returns VOID |
| `popup_toggle_active` | Aktif/pasif toggle. Returns JSONB |

#### BO: Promosyon (8)

| Fonksiyon | Açıklama |
|-----------|----------|
| `promotion_type_upsert` | Promosyon tipi oluştur/güncelle + çeviriler. Returns INT |
| `promotion_type_list` | Tüm promosyon tipleri. Returns JSONB |
| `promotion_create` | Promosyon oluştur (çeviriler + bannerlar + segmentler + oyunlar + lokasyonlar). Returns INT |
| `promotion_update` | Promosyon güncelle (DELETE+INSERT 5 alt kayıt tipi). Returns VOID |
| `promotion_get` | Detay: tüm alt kayıtlar dahil. Returns JSONB |
| `promotion_list` | Sayfalanmış liste, tip/aktiflik/öne çıkan filtreli. Returns JSONB |
| `promotion_delete` | Soft delete (is_deleted). Returns VOID |
| `promotion_toggle_featured` | Öne çıkan toggle. Returns JSONB |

#### BO: Slide/Banner (10)

| Fonksiyon | Açıklama |
|-----------|----------|
| `slide_placement_upsert` | Placement oluştur/güncelle. Returns INT |
| `slide_placement_list` | Placementler + slide sayısı. Returns JSONB |
| `slide_category_upsert` | Slide kategorisi oluştur/güncelle + çeviriler. Returns INT |
| `slide_category_list` | Tüm slide kategorileri. Returns JSONB |
| `slide_create` | Slide oluştur (config + targeting + çeviriler + görseller + zamanlama). Returns INT |
| `slide_update` | Slide güncelle (DELETE+INSERT alt kayıtlar). Returns VOID |
| `slide_get` | Detay: çeviriler + görseller + zamanlama. Returns JSONB |
| `slide_list` | Sayfalanmış liste, placement/kategori/aktiflik filtreli. Returns JSONB |
| `slide_delete` | Soft delete (is_deleted). Returns VOID |
| `slide_reorder` | Placement içi sıralama güncelle (array index → sort_order). Returns VOID |

#### BO: Güven Logoları (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `upsert_trust_logo` | Logo oluştur/güncelle (UPSERT by code). Returns BIGINT |
| `list_trust_logos` | Logo listesi, tip ve aktiflik filtreli. Returns JSONB |
| `delete_trust_logo` | Soft delete. Returns VOID |
| `reorder_trust_logos` | Toplu sıralama güncelle (JSONB array). Returns VOID |

#### BO: Operatör Lisansları (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `upsert_operator_license` | Lisans oluştur/güncelle (UPSERT by jurisdiction+number). Returns BIGINT |
| `list_operator_licenses` | Lisans listesi, ülke ve aktiflik filtreli. Returns JSONB |
| `get_operator_license` | Lisans detay. Returns JSONB |
| `delete_operator_license` | Soft delete. Returns VOID |

#### BO: SEO Yönlendirme (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `upsert_seo_redirect` | Yönlendirme oluştur/güncelle, döngüsel redirect kontrolü. Returns BIGINT |
| `list_seo_redirects` | Sayfalanmış liste, slug/URL arama destekli. Returns JSONB |
| `get_seo_redirect_by_slug` | Middleware lookup: slug → {toUrl, redirectType} veya NULL. Returns JSONB |
| `delete_seo_redirect` | Soft delete. Returns VOID |
| `bulk_import_seo_redirects` | JSONB array toplu içe aktar. Returns {inserted, updated, skipped} JSONB |

#### BO: İçerik SEO Meta (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `update_content_seo_meta` | İçerik çevirisine SEO meta alanlarını yaz (COALESCE ile kısmi güncelleme). Returns VOID |
| `get_content_seo_meta` | İçerik çevirisi + slug + SEO meta detay. Returns JSONB |
| `list_contents_seo_status` | İçerik SEO tamamlanma durumu (0–100 puan). Returns JSONB |

#### FE: Public Content APIs (9)

| Fonksiyon | Açıklama |
|-----------|----------|
| `public_content_get` | Slug ile yayınlanmış içerik getir + dil çevirisi. Returns JSONB |
| `public_content_list` | Tip kodu ile içerik listesi, sayfalanmış. Returns JSONB |
| `public_faq_list` | FAQ listesi: kategori/öne çıkan/arama filtreli. Returns JSONB |
| `public_faq_get` | FAQ öğesi detay + view_count artır. Returns JSONB |
| `public_popup_list` | Aktif popuplar: ülke, segment, sayfa URL, zamanlama filtreli. Returns JSONB |
| `public_promotion_list` | Aktif promosyonlar: ülke, segment filtreli. Returns JSONB |
| `public_promotion_get` | Promosyon detay: çeviriler + bannerlar. Returns JSONB |
| `public_slide_list` | Placement slide'ları: max_slides + targeting + zamanlama filtreli. Returns JSONB |
| `get_public_trust_elements` | Aktif güven logoları + lisanslar ülke filtreli, tip bazlı gruplu. Returns JSONB |

### Presentation Schema (30)

> **Detaylı rehber:** [SITE_MANAGEMENT_GUIDE.md](../guides/SITE_MANAGEMENT_GUIDE.md)

#### BO: Sosyal Medya Bağlantıları (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `upsert_social_link` | Sosyal medya bağlantısı oluştur/güncelle (UPSERT by platform). Returns BIGINT |
| `list_social_links` | Bağlantılar listesi, is_contact filtreli. Returns JSONB |
| `delete_social_link` | Soft delete. Returns VOID |
| `reorder_social_links` | Toplu sıralama güncelle. Returns VOID |

#### BO: Site Ayarları (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `upsert_site_settings` | Tek satır site ayarları oluştur/güncelle (UPDATE-then-INSERT pattern). Returns BIGINT |
| `get_site_settings` | Site ayarları getir. Returns JSONB (boş ise `{}`) |
| `update_site_settings_partial` | Tek JSONB alanı güncelle (analyticsConfig, cookieConsentConfig vb.). Returns VOID |

#### BO: Duyuru Çubukları (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `upsert_announcement_bar` | Duyuru çubuğu oluştur/güncelle (UPSERT by code). Returns BIGINT |
| `upsert_announcement_bar_translation` | Duyuru çubuğu çevirisi oluştur/güncelle. Returns BIGINT |
| `list_announcement_bars` | Liste + iç içe çeviriler. Returns JSONB |
| `delete_announcement_bar` | Soft delete (çeviriler CASCADE). Returns VOID |

#### BO: Navigation (7)

| Fonksiyon | Açıklama |
|-----------|----------|
| `navigation_create` | Navigasyon öğesi oluştur. is_locked/is_readonly her zaman FALSE. Returns BIGINT |
| `navigation_update` | Güncelle. is_readonly ise target_type/url/action korunur. Returns VOID |
| `navigation_delete` | Sil. is_locked engeli + alt öğe kontrolü. Returns VOID |
| `navigation_get` | Detay: tüm alanlar + koruma bayrakları. Returns JSONB |
| `navigation_list` | Recursive CTE ile hiyerarşik ağaç (children[] iç içe). Returns JSONB |
| `navigation_reorder` | Sıralama güncelle (array index → display_order). Returns VOID |
| `navigation_toggle_visible` | Görünürlük toggle + yeni durum dön. Returns JSONB |

#### BO: Theme (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `theme_upsert` | Tema config oluştur/güncelle. ON CONFLICT (theme_id). Returns BIGINT |
| `theme_activate` | Tüm temaları pasifle, seçileni aktifle. Returns VOID |
| `theme_get` | ID veya aktif tema getir (dual mod). Returns JSONB |
| `theme_list` | Tüm temalar, aktif önce sıralı. Returns JSONB |

#### BO: Layout (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `layout_upsert` | Layout oluştur/güncelle (JSONB structure). Returns BIGINT |
| `layout_delete` | Hard delete. Returns VOID |
| `layout_get` | Layout detay. Returns JSONB |
| `layout_list` | Tüm layoutlar, global önce sıralı. Returns JSONB |

#### FE: Public Presentation APIs (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `public_navigation_get` | Konum bazlı menü: auth/guest/cihaz filtreleme + dil çözümleme. Returns JSONB |
| `public_theme_get` | Aktif tema config. Tema yoksa boş config dön. Returns JSONB |
| `public_layout_get` | Layout getir: page_id → layout_name → 'default' fallback zinciri. Returns JSONB |
| `get_active_announcement_bars` | Aktif duyuru çubukları: zaman penceresi + ülke + hedef kitle filtreli, dil fallback. Returns JSONB |

### Messaging Schema (23)

#### Admin Campaign (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `admin_campaign_create` | Create campaign with translations and segments. Returns INT |
| `admin_campaign_update` | Update draft/scheduled campaign. Returns BOOL |
| `admin_campaign_publish` | Publish draft → scheduled/processing. Backend pushes to RabbitMQ. Returns BOOL |
| `admin_campaign_cancel` | Cancel draft/scheduled. Processing cannot be cancelled. Returns BOOL |
| `admin_campaign_get` | Get campaign with translations and segments. Returns JSONB |
| `admin_campaign_list` | Paginated list with channel/status/search filters. Returns JSONB |

#### Admin Template (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `admin_template_create` | Create template with multilingual translations. Returns INT |
| `admin_template_update` | Update template with translations. Returns BOOL |
| `admin_template_get` | Get template with translations. Returns JSONB |
| `admin_template_list` | Paginated list with channel/status/search filters. Returns JSONB |

#### Admin Player Message (1)

| Fonksiyon | Açıklama |
|-----------|----------|
| `admin_player_message_send` | Send message to player inbox. Used by system services and BO users. Returns BIGINT |

#### Player Message (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_message_list` | Inbox messages with read/unread filter. Returns JSONB (total + unread counts) |
| `player_message_read` | Mark message as read. Owning player only. Returns BOOL |
| `player_message_delete` | Soft delete from inbox. Owning player only. Data preserved for audit. Returns BOOL |

#### Player Message Preferences (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_message_preference_get` | Oyuncu kanal tercihlerini getir (email/sms/local varsayılanlarla). Returns JSONB |
| `player_message_preference_upsert` | Oyuncu kanal tercihi oluştur/güncelle. ON CONFLICT (player_id, channel_type). Returns VOID |
| `player_message_preference_bo_get` | BO için oyuncu kanal tercihlerini getir. Returns JSONB |

#### Message Template (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `admin_message_template_create` | Create client message template with multilingual translations. Validates channel-specific requirements → INT |
| `admin_message_template_update` | Update template metadata and translations. Channel type immutable → BOOL |
| `admin_message_template_get` | Get template details with all translations. Returns JSONB |
| `admin_message_template_list` | Paginated list with channel/category/status/search filters. Returns JSONB |
| `admin_message_template_delete` | Soft delete template. System templates cannot be deleted → VOID |
| `message_template_get_by_code` | Get active template by code and language. Backend internal use. Returns JSONB |

### Support Schema (43)

> **Detaylı rehber:** [CALL_CENTER_GUIDE.md](../guides/CALL_CENTER_GUIDE.md)

#### Ticket BO (11)

| Fonksiyon | Açıklama |
|-----------|----------|
| `ticket_create` | Ticket oluştur (BO adına, anti-abuse yok). channel, priority, category_id → BIGINT |
| `ticket_get` | Tekil ticket detay + actions + tags → JSONB |
| `ticket_list` | Filtreli + sayfalı listeleme (status, channel, priority, assigned_to, player_id) → JSONB |
| `ticket_update` | Priority ve/veya category güncelle. Aksiyon logu kaydedilir → VOID |
| `ticket_assign` | Temsilciye ata / devret. Yeniden atamada REASSIGNED logu → VOID |
| `ticket_add_note` | İç not ekle (is_internal=true) → BIGINT |
| `ticket_reply_player` | Oyuncuya yanıt gönder → BIGINT |
| `ticket_resolve` | Çöz. resolution_note zorunlu → VOID |
| `ticket_close` | Kapat (final durum) → VOID |
| `ticket_reopen` | Tekrar aç (resolved → reopened) → VOID |
| `ticket_cancel` | İptal et (final durum) → VOID |

#### Ticket Oyuncu (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_ticket_create` | Oyuncu ticket oluştur. Anti-abuse: max_open + cooldown kontrolü → BIGINT |
| `player_ticket_list` | Kendi ticketlarını listele (internal notlar gizli) → JSONB |
| `player_ticket_get` | Ticket detay (is_internal=true gizlenir) → JSONB |
| `player_ticket_reply` | Oyuncu yanıt. pending_player → in_progress → BIGINT |

#### Player Notes (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_note_create` | Not oluştur (general/warning/vip/compliance tipi) → BIGINT |
| `player_note_update` | İçerik, tip, pin durumu güncelle (COALESCE) → VOID |
| `player_note_delete` | Soft delete (is_active = false) → VOID |
| `player_note_list` | Sayfalı liste. Pinned önce, sonra created_at DESC → JSONB |

#### Agent Settings (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `agent_setting_upsert` | Agent profili oluştur/güncelle. ON CONFLICT upsert → BIGINT |
| `agent_setting_get` | Tekil agent ayarı → JSONB |
| `agent_setting_list` | Agent listesi + mevcut açık ticket sayısı (workload) → JSONB |

#### Canned Responses (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `canned_response_create` | Hazır yanıt oluştur → BIGINT |
| `canned_response_update` | Güncelle (COALESCE) → VOID |
| `canned_response_delete` | Soft delete → VOID |
| `canned_response_list` | Kategoriye göre filtreli + ILIKE arama → JSONB |

#### Representative (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_representative_assign` | Temsilci ata/değiştir. Zorunlu neden, immutable tarihçe → VOID |
| `player_representative_get` | Mevcut temsilci bilgisi → JSONB |
| `player_representative_history_list` | Atama değişiklik tarihçesi → JSONB |

#### Welcome Call (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `welcome_call_task_list` | Görev kuyruğu (pending → created_at, rescheduled → next_attempt_at) → JSONB |
| `welcome_call_task_assign` | Görevi al (pending/rescheduled → assigned) → VOID |
| `welcome_call_task_complete` | Tamamla (answered/declined → completed, wrong_number → failed) → VOID |
| `welcome_call_task_reschedule` | Tekrar planla (no_answer/busy/voicemail). Max aşılınca → failed → VOID |

#### Ticket Category (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `ticket_category_create` | Hiyerarşik kategori oluştur. JSONB çoklu dil desteği → BIGINT |
| `ticket_category_update` | Kategori güncelle (name, description, display_order) → VOID |
| `ticket_category_delete` | Soft delete. Alt kategorisi varsa hata → VOID |
| `ticket_category_list` | Hiyerarşik ağaç yapısında listele. Dil parametresi → JSONB |

#### Ticket Tag (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `ticket_tag_create` | Etiket oluştur (ad + HEX renk) → BIGINT |
| `ticket_tag_update` | Ad ve/veya renk güncelle → VOID |
| `ticket_tag_list` | Tüm aktif etiketler + ticket kullanım sayısı → JSONB |

#### Dashboard (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `ticket_queue_list` | Atanmamış ticketlar (open/reopened). priority DESC, created_at ASC → JSONB |
| `ticket_dashboard_stats` | Status/priority/channel dağılımı + hoşgeldin arama özeti → JSONB |

#### Support Maintenance (1)

| Fonksiyon | Açıklama |
|-----------|----------|
| `welcome_call_task_cleanup` | Tamamlanan/başarısız görevleri sil (180 gün, batch, SKIP LOCKED) → INT |

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Monthly partitions for transactions + player_messages. Idempotent |
| `drop_expired_partitions` | Drop expired. Transactions: indefinite, player_messages: 180d |
| `partition_info` | Partition status report (count, size, oldest/newest) |
| `run_maintenance` | Main cron job: create + drop |

---

## Client Log Database (12 fonksiyon)

### Game Log Schema (6)

#### Round (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `round_upsert` | Round kaydı oluştur/güncelle. Kümülatif bet/win. round_closed flag ile otomatik kapatma → BIGINT |
| `round_close` | PP endRound callback. Round'u kapat, duration hesapla. İdempotent → VOID |
| `round_cancel` | Round iptal/refund. Durum: cancelled veya refunded. İdempotent → VOID |

#### Reconciliation (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `reconciliation_report_create` | Günlük reconciliation raporu oluştur/güncelle. game_rounds tablosundan aggregate hesaplar → BIGINT |
| `reconciliation_mismatch_upsert` | Round bazlı mismatch kaydı oluştur/güncelle → BIGINT |
| `reconciliation_report_list` | Raporları filtrele ve listele. Mismatch sayısı dahil, pagination destekli. STABLE → JSONB |

### KYC Log Schema (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `provider_log_create` | KYC sağlayıcı API istek/yanıt logu oluştur → BIGINT |
| `provider_log_list` | Sayfalı KYC sağlayıcı log listesi. Vaka/oyuncu/sağlayıcı filtreleri → JSONB |

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Daily partitions. Look-ahead: today + N days. Idempotent |
| `drop_expired_partitions` | Drop partitions older than retention period. Safety-first |
| `partition_info` | Partition status report |
| `run_maintenance` | Main cron job: create + drop |

---

## Client Report Database (4 fonksiyon)

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Monthly partitions for report tables. Idempotent |
| `drop_expired_partitions` | Drop expired. Default: ~100 years (business data) |
| `partition_info` | Partition status report |
| `run_maintenance` | Main cron job: create + drop |

---

## Client Audit Database (19 fonksiyon)

### Player Audit Schema (8)

#### Login Attempts (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `login_attempt_create` | Record login attempt with full GeoIP data. Returns BIGINT |
| `login_attempt_list` | List login attempts for a player. Returns JSONB array |
| `login_attempt_failed_list` | Failed attempts within time window for brute-force detection. Returns JSONB |

#### Login Sessions (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `login_session_create` | Create player session with full GeoIP data. Returns BIGINT |
| `login_session_update_activity` | Update last activity timestamp |
| `login_session_end` | End player session. Returns BOOL |
| `login_session_list` | List sessions with optional active-only filter. Returns JSONB array |
| `login_session_end_all` | End all active sessions (optional exclude one). Returns INT (count) |

### KYC Audit Schema (7)

#### Screening Results (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `screening_result_create` | PEP/Sanctions tarama sonucu oluştur. Sağlayıcı bilgileri + match detayları → BIGINT |
| `screening_result_review` | Tarama sonucunu incele. Karar + notlar → VOID |
| `screening_result_get` | Tarama sonucu detayı. İnceleme bilgileri dahil. STABLE → JSONB |
| `screening_result_list` | Sayfalı tarama sonuçları. Durum/tip/sağlayıcı filtreleri → JSONB |

#### Risk Assessment (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `risk_assessment_create` | Risk değerlendirmesi oluştur. Skor + faktörler + öneri → BIGINT |
| `risk_assessment_get` | Risk değerlendirmesi detayı. STABLE → JSONB |
| `risk_assessment_list` | Sayfalı risk değerlendirmesi listesi. Tip/seviye filtreleri → JSONB |

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Hybrid: daily for login_attempts, monthly for login_sessions. Idempotent |
| `drop_expired_partitions` | Drop expired. Daily: 365d, Monthly: 5 years |
| `partition_info` | Partition status report |
| `run_maintenance` | Main cron job: hybrid daily+monthly strategies |

---

## Client Affiliate Database (4 fonksiyon)

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Monthly partitions for tracking tables. Idempotent |
| `drop_expired_partitions` | Drop expired. Default: indefinite (business data) |
| `partition_info` | Partition status report |
| `run_maintenance` | Main cron job: create + drop |

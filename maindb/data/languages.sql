INSERT INTO catalog.languages (language_code, language_name, is_active) VALUES
('en', 'English', true),
('tr', 'Turkish', true),
('de', 'German', true),
('fr', 'French', true),
('es', 'Spanish', true),
('it', 'Italian', true),
('pt', 'Portuguese', true),
('ru', 'Russian', true),
('ar', 'Arabic', true),
('zh', 'Chinese', true)
ON CONFLICT (language_code) DO NOTHING;

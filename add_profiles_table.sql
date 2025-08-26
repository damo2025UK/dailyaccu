-- 添加profiles配置表
-- 请在 Supabase SQL 编辑器中执行以下 SQL 语句

-- 创建profiles配置表
CREATE TABLE IF NOT EXISTS profiles_config (
  id SERIAL PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  label TEXT NOT NULL,
  settings_key TEXT NOT NULL,
  bets_key TEXT NOT NULL,
  export_name TEXT NOT NULL,
  color TEXT DEFAULT '#94a3b8',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_profiles_config_slug ON profiles_config(slug);

-- 启用行级安全策略
ALTER TABLE profiles_config ENABLE ROW LEVEL SECURITY;

-- 创建安全策略
CREATE POLICY "Allow all operations on profiles_config" ON profiles_config
  FOR ALL USING (true) WITH CHECK (true);

-- 插入默认的profiles配置
INSERT INTO profiles_config (slug, label, settings_key, bets_key, export_name, color) VALUES
('under95', 'Under 95', 'bet_settings_under95', 'bet_records_under95', 'under 95.csv', '#60a5fa'),
('hoods-web', 'Hoods Web', 'bet_settings_hoods-web', 'bet_records_hoods-web', 'hoods-web.csv', '#f59e0b'),
('hoods-whatsapp', 'Hoods WhatsApp', 'bet_settings_hoods-whatsapp', 'bet_records_hoods-whatsapp', 'hoods-whatsapp.csv', '#10b981'),
('supertips', 'SuperTips', 'bet_settings_supertips', 'bet_records_supertips', 'supertips.csv', '#ef4444')
ON CONFLICT (slug) DO NOTHING;

-- 执行完成后，profiles配置将存储在数据库中！
-- 体育博彩记录系统数据库表结构
-- 请在 Supabase SQL 编辑器中执行以下 SQL 语句

-- 1. 创建投注记录表
CREATE TABLE IF NOT EXISTS betting_records (
  id SERIAL PRIMARY KEY,
  profile_key TEXT NOT NULL,
  date DATE NOT NULL,
  league TEXT,
  match TEXT,
  description TEXT NOT NULL,
  odds DECIMAL(10,2) NOT NULL,
  stake DECIMAL(10,2) NOT NULL,
  result TEXT CHECK (result IN ('pending', 'win', 'loss')) DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 创建用户设置表
CREATE TABLE IF NOT EXISTS user_settings (
  id SERIAL PRIMARY KEY,
  profile_key TEXT UNIQUE NOT NULL,
  initial_balance DECIMAL(10,2) DEFAULT 0,
  currency TEXT DEFAULT 'CNY',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_betting_records_profile_key ON betting_records(profile_key);
CREATE INDEX IF NOT EXISTS idx_betting_records_date ON betting_records(date);
CREATE INDEX IF NOT EXISTS idx_betting_records_created_at ON betting_records(created_at);
CREATE INDEX IF NOT EXISTS idx_user_settings_profile_key ON user_settings(profile_key);

-- 4. 启用行级安全策略（RLS）
ALTER TABLE betting_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- 5. 创建安全策略（允许所有操作，您可以根据需要调整）
CREATE POLICY "Allow all operations on betting_records" ON betting_records
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on user_settings" ON user_settings
  FOR ALL USING (true) WITH CHECK (true);

-- 执行完成后，您的数据库就可以与应用程序配合使用了！
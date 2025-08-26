-- 联赛管理数据库表结构
-- 请在 Supabase SQL 编辑器中执行以下 SQL 语句

-- 创建联赛表
CREATE TABLE IF NOT EXISTS leagues (
  id SERIAL PRIMARY KEY,
  profile_key TEXT NOT NULL,
  name TEXT NOT NULL, -- 联赛名称
  country TEXT, -- 国家/地区
  description TEXT, -- 联赛描述
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(profile_key, name) -- 同一用户下联赛名称不能重复
);

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_leagues_profile_key ON leagues(profile_key);
CREATE INDEX IF NOT EXISTS idx_leagues_name ON leagues(name);
CREATE INDEX IF NOT EXISTS idx_leagues_country ON leagues(country);

-- 启用行级安全策略（RLS）
ALTER TABLE leagues ENABLE ROW LEVEL SECURITY;

-- 创建安全策略（允许所有操作，您可以根据需要调整）
CREATE POLICY "Allow all operations on leagues" ON leagues
  FOR ALL USING (true) WITH CHECK (true);

-- 插入默认联赛数据
INSERT INTO leagues (profile_key, name, country, description) VALUES
('default', '英超', '英格兰', '英格兰足球超级联赛'),
('default', '西甲', '西班牙', '西班牙足球甲级联赛'),
('default', '德甲', '德国', '德国足球甲级联赛'),
('default', '意甲', '意大利', '意大利足球甲级联赛'),
('default', '法甲', '法国', '法国足球甲级联赛'),
('default', 'NBA', '美国', '美国职业篮球联赛'),
('default', 'CBA', '中国', '中国男子篮球职业联赛'),
('default', 'ATP', '国际', 'ATP男子职业网球巡回赛'),
('default', 'WTA', '国际', 'WTA女子职业网球巡回赛'),
('default', '中超', '中国', '中国足球协会超级联赛')
ON CONFLICT (profile_key, name) DO NOTHING;

-- 执行完成后，联赛管理数据库表结构就创建完成了！
-- 表结构说明：
-- leagues: 存储联赛信息（名称、国家、描述等）
-- 支持按用户配置文件分离数据
-- 包含常见的足球、篮球、网球联赛作为默认数据
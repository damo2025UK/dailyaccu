-- 多重彩数据库表结构
-- 请在 Supabase SQL 编辑器中执行以下 SQL 语句

-- 1. 创建多重彩分类表
CREATE TABLE IF NOT EXISTS multi_bet_categories (
  id SERIAL PRIMARY KEY,
  profile_key TEXT NOT NULL,
  name TEXT NOT NULL, -- 分类名称
  description TEXT, -- 分类描述
  color TEXT DEFAULT '#3b82f6', -- 分类颜色
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(profile_key, name)
);

-- 2. 创建多重彩组表（存储多重彩的整体信息）
CREATE TABLE IF NOT EXISTS multi_bet_groups (
  id SERIAL PRIMARY KEY,
  profile_key TEXT NOT NULL,
  category_id INTEGER NOT NULL REFERENCES multi_bet_categories(id) ON DELETE RESTRICT, -- 必选分类
  group_name TEXT, -- 多重彩名称（可选）
  total_odds DECIMAL(10,4) NOT NULL, -- 总赔率（各单场赔率乘积）
  total_stake DECIMAL(10,2) NOT NULL, -- 总投注金额
  result TEXT CHECK (result IN ('pending', 'win', 'loss')) DEFAULT 'pending',
  match_count INTEGER NOT NULL DEFAULT 0, -- 包含的比赛场次数
  win_count INTEGER NOT NULL DEFAULT 0, -- 已赢的比赛场次数
  loss_count INTEGER NOT NULL DEFAULT 0, -- 已输的比赛场次数
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  settled_at TIMESTAMP WITH TIME ZONE -- 结算时间
);

-- 3. 创建多重彩单场比赛表（存储多重彩中每场比赛的详细信息）
CREATE TABLE IF NOT EXISTS multi_bet_matches (
  id SERIAL PRIMARY KEY,
  group_id INTEGER NOT NULL REFERENCES multi_bet_groups(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  league TEXT,
  match TEXT,
  description TEXT NOT NULL,
  odds DECIMAL(10,4) NOT NULL,
  result TEXT CHECK (result IN ('pending', 'win', 'loss')) DEFAULT 'pending',
  match_order INTEGER NOT NULL DEFAULT 1, -- 在多重彩中的顺序
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_multi_bet_categories_profile_key ON multi_bet_categories(profile_key);
CREATE INDEX IF NOT EXISTS idx_multi_bet_groups_profile_key ON multi_bet_groups(profile_key);
CREATE INDEX IF NOT EXISTS idx_multi_bet_groups_category_id ON multi_bet_groups(category_id);
CREATE INDEX IF NOT EXISTS idx_multi_bet_groups_created_at ON multi_bet_groups(created_at);
CREATE INDEX IF NOT EXISTS idx_multi_bet_groups_result ON multi_bet_groups(result);
CREATE INDEX IF NOT EXISTS idx_multi_bet_matches_group_id ON multi_bet_matches(group_id);
CREATE INDEX IF NOT EXISTS idx_multi_bet_matches_date ON multi_bet_matches(date);
CREATE INDEX IF NOT EXISTS idx_multi_bet_matches_result ON multi_bet_matches(result);

-- 5. 启用行级安全策略（RLS）
ALTER TABLE multi_bet_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE multi_bet_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE multi_bet_matches ENABLE ROW LEVEL SECURITY;

-- 6. 创建安全策略（允许所有操作，您可以根据需要调整）
CREATE POLICY "Allow all operations on multi_bet_categories" ON multi_bet_categories
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on multi_bet_groups" ON multi_bet_groups
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on multi_bet_matches" ON multi_bet_matches
  FOR ALL USING (true) WITH CHECK (true);

-- 7. 插入默认分类数据
INSERT INTO multi_bet_categories (profile_key, name, description, color) VALUES
('default', '足球', '足球相关的多重彩投注', '#22c55e'),
('default', '篮球', '篮球相关的多重彩投注', '#f97316'),
('default', '网球', '网球相关的多重彩投注', '#8b5cf6'),
('default', '其他', '其他体育项目的多重彩投注', '#6b7280')
ON CONFLICT (profile_key, name) DO NOTHING;

-- 6. 创建触发器函数，用于自动更新多重彩组的统计信息
CREATE OR REPLACE FUNCTION update_multi_bet_group_stats()
RETURNS TRIGGER AS $$
BEGIN
  -- 更新多重彩组的统计信息
  UPDATE multi_bet_groups 
  SET 
    win_count = (
      SELECT COUNT(*) 
      FROM multi_bet_matches 
      WHERE group_id = COALESCE(NEW.group_id, OLD.group_id) 
        AND result = 'win'
    ),
    loss_count = (
      SELECT COUNT(*) 
      FROM multi_bet_matches 
      WHERE group_id = COALESCE(NEW.group_id, OLD.group_id) 
        AND result = 'loss'
    ),
    match_count = (
      SELECT COUNT(*) 
      FROM multi_bet_matches 
      WHERE group_id = COALESCE(NEW.group_id, OLD.group_id)
    )
  WHERE id = COALESCE(NEW.group_id, OLD.group_id);
  
  -- 检查是否需要更新多重彩组的整体结果
  UPDATE multi_bet_groups 
  SET 
    result = CASE 
      WHEN loss_count > 0 THEN 'loss' -- 任一场输即整体失败
      WHEN win_count = match_count AND match_count > 0 THEN 'win' -- 全部赢才算成功
      ELSE 'pending' -- 其他情况为待定
    END,
    settled_at = CASE 
      WHEN (loss_count > 0 OR (win_count = match_count AND match_count > 0)) 
        AND settled_at IS NULL 
      THEN NOW() 
      ELSE settled_at 
    END
  WHERE id = COALESCE(NEW.group_id, OLD.group_id);
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 7. 创建触发器
CREATE TRIGGER trigger_update_multi_bet_group_stats
  AFTER INSERT OR UPDATE OR DELETE ON multi_bet_matches
  FOR EACH ROW
  EXECUTE FUNCTION update_multi_bet_group_stats();

-- 执行完成后，多重彩数据库表结构就创建完成了！
-- 表结构说明：
-- multi_bet_groups: 存储多重彩的整体信息（总赔率、总金额、整体结果等）
-- multi_bet_matches: 存储多重彩中每场比赛的详细信息
-- 触发器会自动维护多重彩组的统计信息和结果状态
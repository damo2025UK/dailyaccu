-- 为现有的 multi_bet_groups 表添加 category_id 字段
-- 请在 Supabase SQL 编辑器中执行以下 SQL 语句

-- 1. 首先创建分类表（如果不存在）
CREATE TABLE IF NOT EXISTS multi_bet_categories (
  id SERIAL PRIMARY KEY,
  profile_key TEXT NOT NULL,
  name TEXT NOT NULL, -- 分类名称
  description TEXT, -- 分类描述
  color TEXT DEFAULT '#3b82f6', -- 分类颜色
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(profile_key, name)
);

-- 2. 插入默认分类数据
INSERT INTO multi_bet_categories (profile_key, name, description, color) VALUES
('default', '足球', '足球相关的多重彩投注', '#22c55e'),
('default', '篮球', '篮球相关的多重彩投注', '#f97316'),
('default', '网球', '网球相关的多重彩投注', '#8b5cf6'),
('default', '其他', '其他体育项目的多重彩投注', '#6b7280')
ON CONFLICT (profile_key, name) DO NOTHING;

-- 3. 为 multi_bet_groups 表添加 category_id 字段
ALTER TABLE multi_bet_groups 
ADD COLUMN IF NOT EXISTS category_id INTEGER;

-- 4. 为现有记录设置默认分类（设置为"其他"分类）
UPDATE multi_bet_groups 
SET category_id = (
  SELECT id FROM multi_bet_categories 
  WHERE profile_key = 'default' AND name = '其他' 
  LIMIT 1
)
WHERE category_id IS NULL;

-- 5. 添加外键约束
ALTER TABLE multi_bet_groups 
ADD CONSTRAINT fk_multi_bet_groups_category 
FOREIGN KEY (category_id) REFERENCES multi_bet_categories(id) ON DELETE RESTRICT;

-- 6. 设置字段为非空
ALTER TABLE multi_bet_groups 
ALTER COLUMN category_id SET NOT NULL;

-- 7. 创建索引
CREATE INDEX IF NOT EXISTS idx_multi_bet_categories_profile_key ON multi_bet_categories(profile_key);
CREATE INDEX IF NOT EXISTS idx_multi_bet_groups_category_id ON multi_bet_groups(category_id);

-- 8. 启用行级安全策略（如果尚未启用）
ALTER TABLE multi_bet_categories ENABLE ROW LEVEL SECURITY;

-- 9. 创建安全策略（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'multi_bet_categories' 
        AND policyname = 'Allow all operations on multi_bet_categories'
    ) THEN
        CREATE POLICY "Allow all operations on multi_bet_categories" ON multi_bet_categories
          FOR ALL USING (true) WITH CHECK (true);
    END IF;
END
$$;

-- 执行完成后，multi_bet_groups 表就有了 category_id 字段，并且所有现有记录都被分配到"其他"分类中
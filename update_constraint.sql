-- 更新betting_records表的result字段约束
-- 请在 Supabase SQL 编辑器中执行以下 SQL 语句

-- 1. 删除现有的约束
ALTER TABLE betting_records DROP CONSTRAINT IF EXISTS betting_records_result_check;

-- 2. 添加新的约束（允许 'pending', 'win', 'loss'）
ALTER TABLE betting_records ADD CONSTRAINT betting_records_result_check 
  CHECK (result IN ('pending', 'win', 'loss'));

-- 执行完成后，应用程序就可以正常使用 'win' 和 'loss' 作为结果值了！
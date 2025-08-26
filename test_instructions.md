# 体育博彩记录系统 - 测试说明

## 当前状态
系统已完成从localStorage到Supabase的迁移，但由于Supabase配置为占位符，目前运行在本地存储模式下。

## 测试步骤

### 1. 基本功能测试（本地存储模式）
- 打开 http://localhost:8000
- 系统会显示"请先配置 Supabase 连接信息"的提示，这是正常的
- 点击确定后，系统将使用本地存储模式运行

### 2. CRUD功能测试

#### 创建（Create）- 添加投注记录
1. 填写投注表单：
   - 日期：选择日期
   - 联赛：输入联赛名称
   - 比赛：输入比赛信息
   - 下注内容：输入具体投注内容（必填）
   - 赔率：输入赔率（必须≥1）
   - 金额：输入投注金额（必须>0）
   - 结果：选择pending/won/lost
2. 点击"添加"按钮
3. 验证记录是否出现在列表中

#### 读取（Read）- 查看投注记录
1. 验证记录列表是否正确显示
2. 测试分页功能
3. 测试排序功能（点击表头）
4. 测试筛选功能

#### 更新（Update）- 修改投注记录
1. 双击任意记录的可编辑字段（赔率、金额等）
2. 修改数值
3. 按回车确认
4. 验证修改是否生效
5. 测试结果更新（点击"胜"、"负"、"待定"按钮）

#### 删除（Delete）- 删除投注记录
1. 点击记录行的"删除"按钮
2. 确认删除操作
3. 验证记录是否从列表中移除

### 3. 设置功能测试
1. 点击右上角设置按钮
2. 修改初始资金和货币单位
3. 点击保存
4. 验证设置是否生效

### 4. 导入导出功能测试
1. 测试CSV导出功能
2. 测试CSV导入功能

## Supabase配置（生产环境）

要启用Supabase模式，需要：

1. 在Supabase控制台创建项目
2. 创建以下数据表：

```sql
-- 投注记录表
CREATE TABLE betting_records (
  id SERIAL PRIMARY KEY,
  profile_key TEXT NOT NULL,
  date DATE NOT NULL,
  league TEXT,
  match TEXT,
  description TEXT NOT NULL,
  odds DECIMAL(10,2) NOT NULL,
  stake DECIMAL(10,2) NOT NULL,
  result TEXT CHECK (result IN ('pending', 'won', 'lost')) DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 用户设置表
CREATE TABLE user_settings (
  id SERIAL PRIMARY KEY,
  profile_key TEXT UNIQUE NOT NULL,
  initial_balance DECIMAL(10,2) DEFAULT 0,
  currency TEXT DEFAULT 'CNY',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

3. 在index.html中替换配置：
```javascript
const SUPABASE_URL = 'https://your-project-id.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
```

## 预期结果
- 所有CRUD操作应该正常工作
- 在本地存储模式下，数据保存在浏览器localStorage中
- 配置Supabase后，数据将保存到云端数据库
- 错误处理机制应该正常工作，显示适当的用户反馈
- 加载指示器应该在异步操作期间显示
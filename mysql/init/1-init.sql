-- EverNight 数据库初始化（MySQL 8）
-- 本文件包含：
-- 1）数据库与表结构（不建外键；跨模块关联统一使用 *_code）
-- 2）系统必要的最小种子数据（字典/配置）
--    - 扫描字典数据已拆分到 sql/dict.sql（subdomain/common_ports/admin_path/sensitive_path/high_risk_ports）
--
-- 约定：
-- - `id` 为内部自增主键（仅内部使用）
-- - `*_code` 为业务编号/编码（对外/跨模块使用）
-- - 时间字段使用 DATETIME（时区由应用层处理）
-- 为避免 Windows/容器初始化时出现中文乱码，强制本会话使用 utf8mb4
SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS evernight DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE evernight;

-- ASCII-PADDING: 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ

-- =============================================================================
-- 认证与访问控制
-- =============================================================================
CREATE TABLE IF NOT EXISTS sys_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  username VARCHAR(64) NOT NULL UNIQUE COMMENT '登录用户名',
  password_hash VARCHAR(128) NOT NULL COMMENT '密码哈希（bcrypt）',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户';

CREATE TABLE IF NOT EXISTS sys_api_key (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  api_key VARCHAR(128) NOT NULL UNIQUE COMMENT 'API Key 值（请求头 X-API-Key）',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
  note VARCHAR(255) NULL COMMENT '备注',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='OpenAPI 访问密钥（/openapi/**）';

-- =============================================================================
-- 内置字典（规则库）
-- =============================================================================
CREATE TABLE IF NOT EXISTS dict_meta (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  dict_code VARCHAR(64) NOT NULL UNIQUE COMMENT '字典代码（唯一）',
  dict_name VARCHAR(128) NOT NULL COMMENT '字典名称',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
  version VARCHAR(32) NOT NULL COMMENT '版本号',
  updated_by VARCHAR(64) NULL COMMENT '操作人',
  updated_at DATETIME NOT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典元数据';

CREATE TABLE IF NOT EXISTS dict_subdomain (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  subdomain VARCHAR(100) NOT NULL COMMENT '子域名条目',
  UNIQUE KEY uk_subdomain (subdomain)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='子域名字典项';

CREATE TABLE IF NOT EXISTS dict_admin_path (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  path_value VARCHAR(255) NOT NULL COMMENT '管理路径（如 /admin）',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
  rule_text VARCHAR(255) NULL COMMENT '规则说明',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间',
  UNIQUE KEY uk_admin_path (path_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理路径字典项';

CREATE TABLE IF NOT EXISTS dict_sensitive_path (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
    path_value VARCHAR(255) NOT NULL COMMENT '敏感路径（如 /.env）',
    enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
    rule_text VARCHAR(255) NULL COMMENT '规则说明',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    updated_at DATETIME NOT NULL COMMENT '更新时间',
    UNIQUE KEY uk_sensitive_path (path_value)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='敏感路径字典项';

CREATE TABLE IF NOT EXISTS dict_cdn_fingerprint (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
    fingerprint_value VARCHAR(255) NOT NULL COMMENT 'CDN 指纹（如 cloudfront.net）',
    enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
    rule_text VARCHAR(255) NULL COMMENT '规则说明',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    updated_at DATETIME NOT NULL COMMENT '更新时间',
    UNIQUE KEY uk_cdn_fingerprint (fingerprint_value)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CDN 指纹字典项';

CREATE TABLE IF NOT EXISTS dict_common_port (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  port_spec VARCHAR(64) NOT NULL COMMENT '端口表达式（如 22 / 22-25 / 80,443）',
  UNIQUE KEY uk_common_port (port_spec)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='常见端口字典项';

CREATE TABLE IF NOT EXISTS dict_high_risk_port (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  port_spec VARCHAR(64) NOT NULL COMMENT '端口表达式（如 22 / 22-25 / 80,443）',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
  rule_text VARCHAR(255) NULL COMMENT '规则说明',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间',
  UNIQUE KEY uk_high_risk_port (port_spec)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='高危端口字典项';

-- =============================================================================
-- 指纹库
-- =============================================================================
CREATE TABLE IF NOT EXISTS cms_fingerprint (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  cms_name VARCHAR(255) NOT NULL COMMENT 'CMS/产品名称',
  keyword_header JSON NULL COMMENT 'Header 关键字匹配（JSON）',
  keyword_title JSON NULL COMMENT 'Title 关键字匹配（JSON）',
  keyword_body JSON NULL COMMENT 'Body 关键字匹配（JSON）',
  favicon_hash JSON NULL COMMENT 'Favicon 哈希匹配（JSON）',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
  updated_by VARCHAR(64) NULL COMMENT '操作人',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间',
  UNIQUE KEY uk_cms_name (cms_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CMS 指纹';

-- =============================================================================
-- 业务字典（用于展示/筛选）
-- =============================================================================
CREATE TABLE IF NOT EXISTS biz_dict_meta (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  dict_code VARCHAR(64) NOT NULL UNIQUE COMMENT '字典代码',
  dict_name VARCHAR(128) NOT NULL COMMENT '字典名称',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
  remark VARCHAR(255) NULL COMMENT '备注',
  updated_by VARCHAR(64) NULL COMMENT '操作人',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业务字典（元信息）';

CREATE TABLE IF NOT EXISTS biz_dict_item (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  dict_code VARCHAR(64) NOT NULL COMMENT '字典代码（关联 biz_dict_meta.dict_code）',
  item_code VARCHAR(64) NOT NULL COMMENT '字典项代码',
  item_name VARCHAR(128) NOT NULL COMMENT '字典项名称',
  sort_order INT NOT NULL DEFAULT 0 COMMENT '排序（升序）',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
  updated_by VARCHAR(64) NULL COMMENT '操作人',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间',
  UNIQUE KEY uk_biz_dict_item (dict_code, item_code),
  INDEX idx_biz_dict_code (dict_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业务字典（字典项）';

-- =============================================================================
-- 资产与认领
-- =============================================================================
CREATE TABLE IF NOT EXISTS asset (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  asset_code VARCHAR(32) NOT NULL UNIQUE COMMENT '资产编码',
  asset_name VARCHAR(128) NOT NULL COMMENT '资产名称',
  asset_type VARCHAR(32) NOT NULL COMMENT '资产类型（WEB_APP/API/DOMAIN/IP/DB）',
  asset_address VARCHAR(255) NOT NULL COMMENT '资产地址（URL/域名/IP:端口）',
  importance VARCHAR(32) NOT NULL COMMENT '重要性（业务字典）',
  asset_status VARCHAR(32) NOT NULL COMMENT '资产状态（业务字典）',
  owner VARCHAR(64) NULL COMMENT '负责人',
  department VARCHAR(64) NULL COMMENT '部门',
  tech_stack VARCHAR(255) NULL COMMENT '技术栈',
  asset_desc VARCHAR(512) NULL COMMENT '描述',
  geo_location VARCHAR(255) NULL COMMENT '地理位置（文本）',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产';

CREATE TABLE IF NOT EXISTS asset_claim_pool (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  claim_code VARCHAR(32) NOT NULL UNIQUE COMMENT '待认领资产编码',
  discovered_type VARCHAR(32) NOT NULL COMMENT '发现类型（PORT/DNS/CRT/FOFA/...）',
  discovered_address VARCHAR(255) NOT NULL COMMENT '发现地址（host/ip/url）',
  discovered_title VARCHAR(255) NULL COMMENT '页面标题（仅 Web）',
  discovered_ip VARCHAR(64) NULL COMMENT '参考 IP（地理位置来源）',
  source_task_code VARCHAR(32) NULL COMMENT '来源任务编码（可空）',
  geo_location VARCHAR(255) NULL COMMENT '地理位置（文本）',
  claimed TINYINT NOT NULL DEFAULT 0 COMMENT '1=已认领，0=未认领',
  claimed_at DATETIME NULL COMMENT '认领时间',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间',
  UNIQUE KEY uk_discovered_unique (discovered_type, discovered_address)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='待认领资产池';

CREATE TABLE IF NOT EXISTS asset_revive_event (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  revive_code VARCHAR(32) NOT NULL UNIQUE COMMENT '复活事件编码',
  asset_code VARCHAR(32) NOT NULL COMMENT '资产编码',
  asset_name VARCHAR(128) NULL COMMENT '资产名称（快照）',
  asset_address VARCHAR(255) NOT NULL COMMENT '资产地址',
  asset_status VARCHAR(32) NOT NULL COMMENT '发现时资产状态',
  discovered_address VARCHAR(255) NOT NULL COMMENT '扫描命中地址',
  source_task_code VARCHAR(32) NULL COMMENT '来源任务编码',
  source_scan_kind VARCHAR(32) NULL COMMENT '来源扫描类型（PORT/DNS/CRT/FOFA/...）',
  status VARCHAR(16) NOT NULL COMMENT '状态（PENDING/RESTORED/IGNORED）',
  note VARCHAR(255) NULL COMMENT '处理备注',
  detected_at DATETIME NOT NULL COMMENT '发现时间',
  handled_at DATETIME NULL COMMENT '处理时间',
  handled_by VARCHAR(64) NULL COMMENT '处理人',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间',
  UNIQUE KEY uk_revive_unique (asset_code, discovered_address, status),
  INDEX idx_revive_status (status),
  INDEX idx_revive_asset (asset_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='停用资产复活事件';

-- =============================================================================
-- 操作日志
-- =============================================================================
CREATE TABLE IF NOT EXISTS ops_asset_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  log_code VARCHAR(32) NOT NULL COMMENT '日志编码',
  asset_code VARCHAR(32) NOT NULL COMMENT '资产编码',
  asset_name VARCHAR(128) NULL COMMENT '资产名称（快照，便于列表展示）',
  action VARCHAR(32) NOT NULL COMMENT '操作类型（CREATE/UPDATE/...）',
  request_method VARCHAR(16) NULL COMMENT '请求方法（GET/POST/.../JOB）',
  request_path VARCHAR(255) NULL COMMENT '请求路径（如 /api/assets）',
  cost_ms INT NULL COMMENT '耗时（毫秒）',
  success TINYINT NOT NULL DEFAULT 1 COMMENT '1=成功，0=失败',
  error_code VARCHAR(64) NULL COMMENT '错误码（可选）',
  error_message VARCHAR(255) NULL COMMENT '错误摘要（可选）',
  detail_json JSON NULL COMMENT '详情（JSON，可包含UA等扩展字段）',
  before_json MEDIUMTEXT NULL COMMENT '变更前快照（JSON）',
  after_json MEDIUMTEXT NULL COMMENT '变更后快照（JSON）',
  operator VARCHAR(64) NULL COMMENT '操作人用户名',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  UNIQUE KEY uk_ops_asset_log_code (log_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产操作审计日志';

-- =============================================================================
-- 任务与调度
-- =============================================================================
CREATE TABLE IF NOT EXISTS task (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  task_code VARCHAR(32) NOT NULL UNIQUE COMMENT '任务编码',
  task_type VARCHAR(32) NOT NULL COMMENT '任务类型（SCAN/ASSESS/ALARM/...）',
  task_kind VARCHAR(32) NULL COMMENT '任务子类型（PORT/DNS/CRT/FOFA/...）',
  task_name VARCHAR(128) NOT NULL COMMENT '任务名称',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
  schedule_frequency VARCHAR(16) NOT NULL COMMENT '调度频率（ONCE/DAILY/...）',
  schedule_time VARCHAR(8) NOT NULL COMMENT '调度时间（HH:mm）',
  last_run_at DATETIME NULL COMMENT '上次执行时间',
  next_run_at DATETIME NULL COMMENT '下次执行时间',
  last_status VARCHAR(16) NULL COMMENT '上次状态（SUCCESS/FAILED/...）',
  last_summary VARCHAR(255) NULL COMMENT '上次摘要',
  params_json MEDIUMTEXT NULL COMMENT '任务参数（JSON）',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='调度任务';

CREATE TABLE IF NOT EXISTS task_run_history (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  event_code VARCHAR(32) NOT NULL UNIQUE COMMENT '事件编码',
  task_code VARCHAR(32) NOT NULL COMMENT '任务编码',
  task_type VARCHAR(32) NOT NULL COMMENT '任务类型（SCAN/ASSESS/...）',
  status VARCHAR(16) NOT NULL COMMENT '运行状态（SUCCESS/FAILED/...）',
  started_at DATETIME NOT NULL COMMENT '开始时间',
  finished_at DATETIME NULL COMMENT '结束时间',
  summary VARCHAR(255) NULL COMMENT '摘要',
  detail MEDIUMTEXT NULL COMMENT '详情（文本/JSON）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务运行历史';

-- =============================================================================
-- 风险
-- =============================================================================
CREATE TABLE IF NOT EXISTS risk_item (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  risk_code VARCHAR(32) NOT NULL UNIQUE COMMENT '风险编码',
  asset_code VARCHAR(32) NOT NULL COMMENT '资产编码',
  risk_type VARCHAR(32) NOT NULL COMMENT '风险类型代码',
  title VARCHAR(255) NOT NULL COMMENT '标题（用于去重）',
  detail MEDIUMTEXT NULL COMMENT '详情',
  request_data MEDIUMTEXT NULL COMMENT '请求包',
  response_data MEDIUMTEXT NULL COMMENT '返回包',
  status VARCHAR(16) NOT NULL COMMENT '状态（UNHANDLED/IGNORED/RESOLVED）',
  first_detected_at DATETIME NOT NULL COMMENT '首次发现时间',
  detected_at DATETIME NOT NULL COMMENT '发现时间',
  updated_at DATETIME NOT NULL COMMENT '更新时间',
  UNIQUE KEY uk_asset_risk_dedup (asset_code, risk_type, title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='风险项';

CREATE TABLE IF NOT EXISTS risk_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  risk_code VARCHAR(32) NOT NULL COMMENT '风险编码',
  from_status VARCHAR(16) NOT NULL COMMENT '原状态',
  to_status VARCHAR(16) NOT NULL COMMENT '新状态',
  operator VARCHAR(64) NULL COMMENT '操作人用户名',
  remark VARCHAR(255) NULL COMMENT '备注',
  created_at DATETIME NOT NULL COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='风险日志';

-- =============================================================================
-- 告警
-- =============================================================================
CREATE TABLE IF NOT EXISTS alarm_config (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  name VARCHAR(64) NOT NULL COMMENT '配置名称',
  channel_type VARCHAR(32) NOT NULL COMMENT '渠道类型（DINGTALK/...）',
  enabled TINYINT NOT NULL DEFAULT 0 COMMENT '1=启用，0=停用',
  dingtalk_webhook VARCHAR(512) NULL COMMENT '钉钉 webhook',
  dingtalk_secret VARCHAR(128) NULL COMMENT '钉钉 secret（可空）',
  subscribed_alarm_types JSON NULL COMMENT '订阅类型（JSON 数组）',
  merge_window_minutes INT NOT NULL DEFAULT 60 COMMENT '合并窗口（分钟）',
  updated_at DATETIME NOT NULL COMMENT '更新时间',
  UNIQUE KEY uk_alarm_config_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='告警配置';

CREATE TABLE IF NOT EXISTS alarm_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  log_code VARCHAR(32) NOT NULL COMMENT '日志编码',
  config_id BIGINT NULL COMMENT '告警配置 id',
  alarm_type VARCHAR(32) NOT NULL COMMENT '告警类型',
  content MEDIUMTEXT NOT NULL COMMENT '内容',
  request_method VARCHAR(16) NULL COMMENT '请求方法（GET/POST/.../JOB）',
  request_path VARCHAR(255) NULL COMMENT '请求路径/来源（如 job://sendPendingAlarms）',
  cost_ms INT NULL COMMENT '耗时（毫秒）',
  sent_at DATETIME NOT NULL COMMENT '发送时间',
  success TINYINT NOT NULL DEFAULT 0 COMMENT '1=成功，0=失败',
  error_code VARCHAR(64) NULL COMMENT '错误码（可选）',
  error_message VARCHAR(255) NULL COMMENT '错误摘要（可选）',
  detail_json JSON NULL COMMENT '详情（JSON，可包含HTTP状态等扩展字段）',
  response_text MEDIUMTEXT NULL COMMENT '下游响应',
  UNIQUE KEY uk_alarm_log_code (log_code),
  INDEX idx_alarm_dedup (config_id, alarm_type, success)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='告警发送日志';

-- =============================================================================
-- 审计日志
-- =============================================================================
CREATE TABLE IF NOT EXISTS login_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  log_code VARCHAR(32) NOT NULL COMMENT '日志编码',
  username VARCHAR(64) NOT NULL COMMENT '登录用户名',
  ip VARCHAR(64) NULL COMMENT 'IP',
  user_agent VARCHAR(255) NULL COMMENT 'User-Agent',
  request_method VARCHAR(16) NULL COMMENT '请求方法（GET/POST/...）',
  request_path VARCHAR(255) NULL COMMENT '请求路径（如 /api/auth/login）',
  cost_ms INT NULL COMMENT '耗时（毫秒）',
  success TINYINT NOT NULL COMMENT '1=成功，0=失败',
  error_code VARCHAR(64) NULL COMMENT '错误码（可选）',
  error_message VARCHAR(255) NULL COMMENT '错误摘要（可选）',
  detail_json JSON NULL COMMENT '详情（JSON，可包含扩展字段）',
  created_at DATETIME NOT NULL COMMENT '创建时间',
  UNIQUE KEY uk_login_log_code (log_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='登录日志';

-- =============================================================================
-- 系统配置
-- =============================================================================
CREATE TABLE IF NOT EXISTS scan_config (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内部自增主键',
  config_key VARCHAR(128) NOT NULL UNIQUE COMMENT '配置键（唯一）',
  config_value MEDIUMTEXT NULL COMMENT '配置值（字符串/JSON）',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=启用，0=停用',
  updated_by VARCHAR(64) NULL COMMENT '操作人',
  updated_at DATETIME NOT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='扫描配置';

-- =============================================================================
-- 种子数据（最小默认值）
-- =============================================================================
INSERT INTO alarm_config (name, channel_type, enabled, dingtalk_webhook, dingtalk_secret, subscribed_alarm_types, merge_window_minutes, updated_at)
VALUES ('默认告警配置', 'DINGTALK', 0, NULL, NULL, JSON_ARRAY('CLAIM_PENDING','RISK_UNHANDLED','ASSET_REVIVE'), 60, NOW())
ON DUPLICATE KEY UPDATE updated_at=VALUES(updated_at);

INSERT INTO dict_meta (dict_code, dict_name, enabled, version, updated_by, updated_at)
  VALUES
    ('subdomain', '子域名字典', 1, 'v1', 'system', NOW()),
    ('sensitive_path', '敏感路径字典', 1, 'v1', 'system', NOW()),
    ('admin_path', '管理路径字典', 1, 'v1', 'system', NOW()),
    ('cdn_fingerprint', 'CDN 指纹字典', 1, 'v1', 'system', NOW()),
    ('common_ports', '常见端口字典', 1, 'v1', 'system', NOW()),
    ('high_risk_ports', '高危端口字典', 1, 'v1', 'system', NOW())
ON DUPLICATE KEY UPDATE updated_at=VALUES(updated_at);

-- Seeds for dict_admin_path moved to sql/dict.sql

-- Seeds for dict_sensitive_path moved to sql/dict.sql

-- Seeds for dict_cdn_fingerprint moved to sql/dict.sql

-- Seeds for dict_common_port moved to sql/dict.sql

-- Seeds for dict_high_risk_port moved to sql/dict.sql

-- Seeds for dict_subdomain moved to sql/dict.sql

INSERT INTO biz_dict_meta (dict_code, dict_name, enabled, remark, updated_by, created_at, updated_at)
VALUES
  ('ASSET_TYPE', '资产类型', 1, '用于资产管理展示与录入', 'system', NOW(), NOW()),
  ('ASSET_IMPORTANCE', '业务重要性', 1, '用于资产管理展示与录入', 'system', NOW(), NOW()),
  ('ASSET_STATUS', '资产状态', 1, '用于资产管理展示与录入', 'system', NOW(), NOW()),
  ('RISK_STATUS', '风险状态', 1, '用于风险列表展示', 'system', NOW(), NOW()),
  ('RISK_TYPE', '风险类型', 1, '用于风险类型展示（大屏/列表）', 'system', NOW(), NOW()),
  ('TASK_STATUS', '任务状态', 1, '用于任务/历史展示', 'system', NOW(), NOW()),
  ('CLAIM_DISCOVERED_TYPE', '扫描模块', 1, '用于资产认领展示与筛选', 'system', NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at=VALUES(updated_at);

INSERT INTO biz_dict_item (dict_code, item_code, item_name, sort_order, enabled, updated_by, created_at, updated_at)
VALUES
  ('ASSET_TYPE', 'WEB_APP', 'Web 应用', 10, 1, 'system', NOW(), NOW()),
  ('ASSET_TYPE', 'API', 'API 接口', 20, 1, 'system', NOW(), NOW()),
  ('ASSET_TYPE', 'DOMAIN', '域名', 30, 1, 'system', NOW(), NOW()),
  ('ASSET_TYPE', 'IP', 'IP地址', 40, 1, 'system', NOW(), NOW()),
  ('ASSET_TYPE', 'DB', '数据库', 50, 1, 'system', NOW(), NOW()),
  ('ASSET_TYPE', 'OTHER', '其他', 60, 1, 'system', NOW(), NOW()),

  ('ASSET_IMPORTANCE', '核心业务', '核心业务', 10, 1, 'system', NOW(), NOW()),
  ('ASSET_IMPORTANCE', '重要业务', '重要业务', 20, 1, 'system', NOW(), NOW()),
  ('ASSET_IMPORTANCE', '一般业务', '一般业务', 30, 1, 'system', NOW(), NOW()),
  ('ASSET_IMPORTANCE', '辅助业务', '辅助业务', 40, 1, 'system', NOW(), NOW()),

  ('ASSET_STATUS', '可用', '可用', 10, 1, 'system', NOW(), NOW()),
  ('ASSET_STATUS', '停用', '停用', 20, 1, 'system', NOW(), NOW()),

  ('RISK_STATUS', 'UNHANDLED', '未处理', 10, 1, 'system', NOW(), NOW()),
  ('RISK_STATUS', 'IGNORED', '已忽略', 20, 1, 'system', NOW(), NOW()),
  ('RISK_STATUS', 'RESOLVED', '已解决', 30, 1, 'system', NOW(), NOW()),

  ('RISK_TYPE', 'HIGH_RISK_PORT_OPEN', '高危端口开放', 10, 1, 'system', NOW(), NOW()),
  ('RISK_TYPE', 'ADMIN_PATH_EXPOSED', '管理路径暴露', 20, 1, 'system', NOW(), NOW()),
  ('RISK_TYPE', 'SENSITIVE_PATH_EXPOSED', '敏感路径暴露', 30, 1, 'system', NOW(), NOW()),
  ('RISK_TYPE', 'FRAMEWORK_FINGERPRINT_EXPOSED', '框架指纹暴露', 40, 1, 'system', NOW(), NOW()),

  ('TASK_STATUS', 'RUNNING', '运行中', 10, 1, 'system', NOW(), NOW()),
  ('TASK_STATUS', 'SUCCESS', '成功', 20, 1, 'system', NOW(), NOW()),
  ('TASK_STATUS', 'FAILED', '失败', 30, 1, 'system', NOW(), NOW()),

  ('CLAIM_DISCOVERED_TYPE', 'PORT', '端口扫描', 10, 1, 'system', NOW(), NOW()),
  ('CLAIM_DISCOVERED_TYPE', 'DNS', 'DNS爆破', 20, 1, 'system', NOW(), NOW()),
  ('CLAIM_DISCOVERED_TYPE', 'CRT', 'CT查询', 30, 1, 'system', NOW(), NOW()),
  ('CLAIM_DISCOVERED_TYPE', 'FOFA', '网络空间搜索', 40, 1, 'system', NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at=VALUES(updated_at);

INSERT INTO sys_user (username, password_hash, enabled, created_at, updated_at)
VALUES ('admin', '$2a$10$YfrlCiAxdivRuZ7GjTT5Z.jKw4jgt/NgieyerGvbGzgJpetCk.f4S', 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at=VALUES(updated_at);

INSERT INTO sys_api_key (api_key, enabled, note, created_at, updated_at)
VALUES ('CHANGE_ME_API_KEY', 0, '外部只读 API Key（请启用并替换）', NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at=VALUES(updated_at);

INSERT INTO scan_config (config_key, config_value, enabled, updated_by, updated_at)
VALUES
  ('fofa_api_key', '', 0, 'system', NOW()),
  ('fofa_email', '', 0, 'system', NOW()),
  ('cdn_suspect_ip_threshold', '5', 1, 'system', NOW())
ON DUPLICATE KEY UPDATE updated_at=VALUES(updated_at);


SET NAMES utf8mb4;
USE evernight;

INSERT INTO cms_fingerprint (cms_name, keyword_header, keyword_title, keyword_body, favicon_hash, enabled, updated_by, created_at, updated_at)
VALUES (
  '用友GRP-A++',
  '[]',
  '[]',
  '["用友政务", "/pf/portal/login/css/fonts/style.css", "pf/portal/login/img/list1.png"]',
  '[]',
  1,
  'system',
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  keyword_header=VALUES(keyword_header),
  keyword_title=VALUES(keyword_title),
  keyword_body=VALUES(keyword_body),
  favicon_hash=VALUES(favicon_hash),
  enabled=VALUES(enabled),
  updated_by=VALUES(updated_by),
  updated_at=VALUES(updated_at);

INSERT INTO cms_fingerprint (cms_name, keyword_header, keyword_title, keyword_body, favicon_hash, enabled, updated_by, created_at, updated_at)
VALUES (
  '用友GRP-U8内控管理软件',
  '[]',
  '[]',
  '["用友GRP-U8行政", "用友GRP-U8 高校", "用友GRP-U8 行政", "用友GRP-U8高校", "/dialog_moreUser_check.jsp", "内控管理软件", "用友GRP-U8"]',
  '["b41be1ccc6f9f2894e0cfcf23acf5fc0"]',
  1,
  'system',
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  keyword_header=VALUES(keyword_header),
  keyword_title=VALUES(keyword_title),
  keyword_body=VALUES(keyword_body),
  favicon_hash=VALUES(favicon_hash),
  enabled=VALUES(enabled),
  updated_by=VALUES(updated_by),
  updated_at=VALUES(updated_at);

INSERT INTO cms_fingerprint (cms_name, keyword_header, keyword_title, keyword_body, favicon_hash, enabled, updated_by, created_at, updated_at)
VALUES (
  '用友时空KSOA',
  '[]',
  '["企业信息系统门户"]',
  '["images_index/mainlogo.jpg", "productKSOA.jpg"]',
  '[]',
  1,
  'system',
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  keyword_header=VALUES(keyword_header),
  keyword_title=VALUES(keyword_title),
  keyword_body=VALUES(keyword_body),
  favicon_hash=VALUES(favicon_hash),
  enabled=VALUES(enabled),
  updated_by=VALUES(updated_by),
  updated_at=VALUES(updated_at);

INSERT INTO cms_fingerprint (cms_name, keyword_header, keyword_title, keyword_body, favicon_hash, enabled, updated_by, created_at, updated_at)
VALUES (
  '用友移动管理系统',
  '["102-1379069896000"]',
  '[]',
  '["location.href=\\"mobsm/\\"", "js/pushRegisterCtr.js"]',
  '[]',
  1,
  'system',
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  keyword_header=VALUES(keyword_header),
  keyword_title=VALUES(keyword_title),
  keyword_body=VALUES(keyword_body),
  favicon_hash=VALUES(favicon_hash),
  enabled=VALUES(enabled),
  updated_by=VALUES(updated_by),
  updated_at=VALUES(updated_at);

INSERT INTO cms_fingerprint (cms_name, keyword_header, keyword_title, keyword_body, favicon_hash, enabled, updated_by, created_at, updated_at)
VALUES (
  '用友NC UFIDA',
  '[]',
  '["YONYOU NC", "Yonyou UAP"]',
  '["logo/images/ufida_nc.png", "img/logo_small.ico", "http-equiv=refresh content=0;url=index.jsp"]',
  '["a5dccf6af79f420f7ea2f2becb6fafa5"]',
  1,
  'system',
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  keyword_header=VALUES(keyword_header),
  keyword_title=VALUES(keyword_title),
  keyword_body=VALUES(keyword_body),
  favicon_hash=VALUES(favicon_hash),
  enabled=VALUES(enabled),
  updated_by=VALUES(updated_by),
  updated_at=VALUES(updated_at);

INSERT INTO cms_fingerprint (cms_name, keyword_header, keyword_title, keyword_body, favicon_hash, enabled, updated_by, created_at, updated_at)
VALUES (
  '用友NC',
  '[]',
  '["YONYOU NC", "Yonyou UAP"]',
  '["<meta http-equiv=refresh content=0;url=nccloud>", "platform/pub/welcome.do", "platform/api/index.js", "logo/images/ufida_nc.png", "img/logo_small.ico", "http-equiv=refresh content=0;url=index.jsp"]',
  '["b0cb782f31c4ca81c836c440681f59c9", "a5dccf6af79f420f7ea2f2becb6fafa5"]',
  1,
  'system',
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  keyword_header=VALUES(keyword_header),
  keyword_title=VALUES(keyword_title),
  keyword_body=VALUES(keyword_body),
  favicon_hash=VALUES(favicon_hash),
  enabled=VALUES(enabled),
  updated_by=VALUES(updated_by),
  updated_at=VALUES(updated_at);

INSERT INTO cms_fingerprint (cms_name, keyword_header, keyword_title, keyword_body, favicon_hash, enabled, updated_by, created_at, updated_at)
VALUES (
  '用友NC Cloud',
  '[]',
  '[]',
  '["<meta http-equiv=refresh content=0;url=nccloud>", "platform/pub/welcome.do", "platform/api/index.js"]',
  '["b0cb782f31c4ca81c836c440681f59c9"]',
  1,
  'system',
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  keyword_header=VALUES(keyword_header),
  keyword_title=VALUES(keyword_title),
  keyword_body=VALUES(keyword_body),
  favicon_hash=VALUES(favicon_hash),
  enabled=VALUES(enabled),
  updated_by=VALUES(updated_by),
  updated_at=VALUES(updated_at);

INSERT INTO cms_fingerprint (cms_name, keyword_header, keyword_title, keyword_body, favicon_hash, enabled, updated_by, created_at, updated_at)
VALUES (
  '用友智石开PLM研发创新平台',
  '[]',
  '["智石开PLM"]',
  '["智石开工业软件有限公司", "/login/pcweb/", "TPL_password_1"]',
  '[]',
  1,
  'system',
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  keyword_header=VALUES(keyword_header),
  keyword_title=VALUES(keyword_title),
  keyword_body=VALUES(keyword_body),
  favicon_hash=VALUES(favicon_hash),
  enabled=VALUES(enabled),
  updated_by=VALUES(updated_by),
  updated_at=VALUES(updated_at);

INSERT INTO cms_fingerprint (cms_name, keyword_header, keyword_title, keyword_body, favicon_hash, enabled, updated_by, created_at, updated_at)
VALUES (
  '用友YonBIP R5旗舰版',
  '["_WorkbenchCross_=Ultraman"]',
  '["数字化工作台"]',
  '["/iuap-tinper/ucf-wh/next/tinper-next.css", "/iuap-apcom-workbench/ucf-wh/vendor/workbench-babelPolyfill.min.js", "/iuap-apcom-workbench/ucf-wh/vendor/"]',
  '["61f67fee0c476bbb00c8a503a716c80a"]',
  1,
  'system',
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  keyword_header=VALUES(keyword_header),
  keyword_title=VALUES(keyword_title),
  keyword_body=VALUES(keyword_body),
  favicon_hash=VALUES(favicon_hash),
  enabled=VALUES(enabled),
  updated_by=VALUES(updated_by),
  updated_at=VALUES(updated_at);

INSERT INTO cms_fingerprint (cms_name, keyword_header, keyword_title, keyword_body, favicon_hash, enabled, updated_by, created_at, updated_at)
VALUES (
  '用友U8Cloud',
  '[]',
  '["U8C"]',
  '["开启U8 cloud云端之旅", "uclient.yonyou.com/api/uclient/public/download/windows", "/api/uclient/public/"]',
  '[]',
  1,
  'system',
  NOW(),
  NOW()
)
ON DUPLICATE KEY UPDATE
  keyword_header=VALUES(keyword_header),
  keyword_title=VALUES(keyword_title),
  keyword_body=VALUES(keyword_body),
  favicon_hash=VALUES(favicon_hash),
  enabled=VALUES(enabled),
  updated_by=VALUES(updated_by),
  updated_at=VALUES(updated_at);
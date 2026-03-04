-- Initialize EFAK H2 database with schema and default data
-- This script is idempotent (uses IF NOT EXISTS / MERGE INTO)

-- Create MySQL-compatible DATE_FORMAT function for H2
CREATE ALIAS IF NOT EXISTS DATE_FORMAT AS '
String dateFormat(java.sql.Timestamp ts, String fmt) {
    if (ts == null) return null;
    String jf = fmt
        .replace("%Y", "yyyy")
        .replace("%m", "MM")
        .replace("%d", "dd")
        .replace("%H", "HH")
        .replace("%i", "mm")
        .replace("%s", "ss");
    return new java.text.SimpleDateFormat(jf).format(ts);
}
';

-- Cluster info table
CREATE TABLE IF NOT EXISTS ke_cluster (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  cluster_id TEXT NOT NULL UNIQUE,
  cluster_name TEXT NOT NULL,
  cluster_type TEXT DEFAULT 'Dev',
  cluster_number INTEGER DEFAULT 0,
  auth TEXT DEFAULT 'N',
  auth_config TEXT,
  online_nodes INTEGER DEFAULT 0,
  total_nodes INTEGER DEFAULT 0,
  availability REAL DEFAULT 0.00,
  created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Broker info table
CREATE TABLE IF NOT EXISTS ke_broker_info (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  cluster_id TEXT NOT NULL,
  broker_id INTEGER NOT NULL,
  host_ip TEXT NOT NULL,
  port INTEGER NOT NULL DEFAULT 9092,
  jmx_port INTEGER,
  status TEXT NOT NULL DEFAULT 'offline',
  cpu_usage REAL,
  memory_usage REAL,
  startup_time TIMESTAMP,
  version TEXT,
  created_by TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User info table
CREATE TABLE IF NOT EXISTS ke_users_info (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  username TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  origin_password TEXT,
  roles TEXT DEFAULT 'ROLE_USER',
  status TEXT DEFAULT 'ACTIVE',
  modify_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Login persistence table
CREATE TABLE IF NOT EXISTS persistent_logins (
  username TEXT NOT NULL,
  series TEXT PRIMARY KEY,
  token TEXT NOT NULL,
  last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Alert channels table
CREATE TABLE IF NOT EXISTS ke_alert_channels (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  cluster_id TEXT NOT NULL DEFAULT '',
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  api_url TEXT NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by TEXT
);

-- Alert type configs table
CREATE TABLE IF NOT EXISTS ke_alert_type_configs (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  cluster_id TEXT NOT NULL DEFAULT '',
  type TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  enabled INTEGER NOT NULL DEFAULT 1,
  threshold REAL,
  unit TEXT,
  target TEXT,
  channel_id TEXT,
  created_by TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Alerts table
CREATE TABLE IF NOT EXISTS ke_alerts (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  alert_task_id INTEGER NOT NULL,
  cluster_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  channel_id INTEGER NOT NULL,
  duration TEXT,
  status INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Broker metrics table
CREATE TABLE IF NOT EXISTS ke_broker_metrics (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  broker_id INTEGER NOT NULL,
  host_ip TEXT NOT NULL,
  port INTEGER NOT NULL,
  cpu_usage REAL DEFAULT 0,
  memory_usage REAL DEFAULT 0,
  collect_time DATETIME NOT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  cluster_id TEXT
);

-- Chat message table
CREATE TABLE IF NOT EXISTS ke_chat_message (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  session_id TEXT NOT NULL,
  username TEXT NOT NULL,
  sender TEXT NOT NULL,
  content TEXT NOT NULL,
  model_name TEXT,
  message_type INTEGER DEFAULT 1,
  enable_markdown INTEGER DEFAULT 1,
  enable_charts INTEGER DEFAULT 1,
  enable_highlight INTEGER DEFAULT 1,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  status INTEGER DEFAULT 1
);

-- Chat session table
CREATE TABLE IF NOT EXISTS ke_chat_session (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  username TEXT NOT NULL,
  session_id TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  model_name TEXT,
  message_count INTEGER DEFAULT 0,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  status INTEGER DEFAULT 1
);

-- Consumer group topic table
CREATE TABLE IF NOT EXISTS ke_consumer_group_topic (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  cluster_id TEXT NOT NULL,
  group_id TEXT NOT NULL,
  topic_name TEXT NOT NULL,
  state TEXT NOT NULL DEFAULT 'UNKNOWN',
  logsize INTEGER DEFAULT 0,
  offsets INTEGER DEFAULT 0,
  lags INTEGER DEFAULT 0,
  collect_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  collect_date TEXT NOT NULL
);

-- Model config table
CREATE TABLE IF NOT EXISTS ke_model_config (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  model_name TEXT NOT NULL UNIQUE,
  api_type TEXT NOT NULL,
  endpoint TEXT NOT NULL,
  api_key TEXT,
  system_prompt TEXT,
  timeout INTEGER DEFAULT 30,
  description TEXT,
  enabled INTEGER DEFAULT 1,
  status INTEGER DEFAULT 0,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  create_by TEXT,
  update_by TEXT
);

-- Performance monitor table
CREATE TABLE IF NOT EXISTS ke_performance_monitor (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  cluster_id TEXT NOT NULL,
  kafka_host TEXT NOT NULL DEFAULT '',
  message_in REAL NOT NULL DEFAULT 0.00,
  byte_in REAL NOT NULL DEFAULT 0.00,
  byte_out REAL NOT NULL DEFAULT 0.00,
  time_ms_produce REAL NOT NULL DEFAULT 0.00,
  time_ms_consumer REAL NOT NULL DEFAULT 0.00,
  memory_usage REAL NOT NULL DEFAULT 0.00,
  cpu_usage REAL NOT NULL DEFAULT 0.00,
  collect_time DATETIME NOT NULL,
  collect_date TEXT NOT NULL
);

-- Task execution history table
CREATE TABLE IF NOT EXISTS ke_task_execution_history (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  task_id INTEGER NOT NULL,
  task_name TEXT NOT NULL,
  task_type TEXT NOT NULL,
  execution_status TEXT NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME,
  duration INTEGER,
  result_message TEXT,
  error_message TEXT,
  executor_node TEXT,
  trigger_type TEXT DEFAULT 'SCHEDULED',
  trigger_user TEXT,
  input_params TEXT,
  output_result TEXT,
  created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Task scheduler table
CREATE TABLE IF NOT EXISTS ke_task_scheduler (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  task_name TEXT NOT NULL UNIQUE,
  task_type TEXT NOT NULL,
  cron_expression TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'enabled',
  last_execute_time TEXT,
  next_execute_time TEXT,
  execute_count INTEGER NOT NULL DEFAULT 0,
  success_count INTEGER NOT NULL DEFAULT 0,
  fail_count INTEGER NOT NULL DEFAULT 0,
  last_execute_result TEXT,
  error_message TEXT,
  created_by TEXT NOT NULL,
  create_time DATETIME NOT NULL,
  updated_by TEXT,
  update_time DATETIME NOT NULL,
  config TEXT,
  timeout INTEGER DEFAULT 300,
  node_id TEXT,
  cluster_name TEXT
);

-- Topic info table
CREATE TABLE IF NOT EXISTS ke_topic_info (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  topic_name TEXT NOT NULL,
  partitions INTEGER NOT NULL DEFAULT 0,
  replicas INTEGER NOT NULL DEFAULT 0,
  broker_spread TEXT,
  broker_skewed TEXT,
  leader_skewed TEXT,
  retention_time TEXT,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  create_by TEXT,
  update_by TEXT,
  icon TEXT DEFAULT 'database',
  cluster_id TEXT
);

-- Topic instant metrics table
CREATE TABLE IF NOT EXISTS ke_topic_instant_metrics (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  cluster_id TEXT NOT NULL,
  topic_name TEXT NOT NULL,
  metric_type TEXT NOT NULL,
  metric_value TEXT NOT NULL DEFAULT '0',
  last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Topic metrics table
CREATE TABLE IF NOT EXISTS ke_topics_metrics (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  topic_name TEXT NOT NULL,
  record_count INTEGER NOT NULL DEFAULT 0,
  record_count_diff INTEGER NOT NULL DEFAULT 0,
  capacity INTEGER NOT NULL DEFAULT 0,
  capacity_diff INTEGER NOT NULL DEFAULT 0,
  write_speed REAL NOT NULL DEFAULT 0.00,
  read_speed REAL NOT NULL DEFAULT 0.00,
  collect_time DATETIME NOT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  cluster_id TEXT
);

-- Insert default admin user
MERGE INTO ke_users_info (username, password, origin_password, roles, status)
KEY (username)
VALUES ('admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'ROLE_ADMIN', 'ACTIVE');

-- Insert default cluster (env vars substituted at runtime)
MERGE INTO ke_cluster (cluster_id, cluster_name, cluster_type)
KEY (cluster_id)
VALUES ('${EFAK_CLUSTER_ID}', '${EFAK_CLUSTER_NAME}', '${EFAK_CLUSTER_TYPE}');

-- Insert default broker(s)
MERGE INTO ke_broker_info (cluster_id, broker_id, host_ip, port, jmx_port, status)
KEY (cluster_id, broker_id, host_ip, port)
VALUES ('${EFAK_CLUSTER_ID}', ${EFAK_BROKER_ID}, '${EFAK_BROKER_HOST}', ${EFAK_BROKER_PORT}, ${EFAK_BROKER_JMX_PORT}, 'online');

-- Insert default task scheduler entries
MERGE INTO ke_task_scheduler (task_name, task_type, cron_expression, description, status, created_by, create_time, update_time, cluster_name)
KEY (task_name)
VALUES
  ('Topic Monitor', 'topic_monitor', '0 */1 * * * ?', 'Monitor Kafka topic status', 'disabled', 'admin', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '${EFAK_CLUSTER_NAME}');
MERGE INTO ke_task_scheduler (task_name, task_type, cron_expression, description, status, created_by, create_time, update_time, cluster_name)
KEY (task_name)
VALUES
  ('Consumer Group Monitor', 'consumer_monitor', '0 */1 * * * ?', 'Monitor consumer group lag', 'disabled', 'admin', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '${EFAK_CLUSTER_NAME}');
MERGE INTO ke_task_scheduler (task_name, task_type, cron_expression, description, status, created_by, create_time, update_time, cluster_name)
KEY (task_name)
VALUES
  ('Cluster Health Check', 'cluster_monitor', '0 */1 * * * ?', 'Check cluster health', 'enabled', 'admin', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '${EFAK_CLUSTER_NAME}');
MERGE INTO ke_task_scheduler (task_name, task_type, cron_expression, description, status, created_by, create_time, update_time, cluster_name)
KEY (task_name)
VALUES
  ('Alert Monitor', 'alert_monitor', '0 */1 * * * ?', 'Monitor alerts', 'disabled', 'admin', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '${EFAK_CLUSTER_NAME}');
MERGE INTO ke_task_scheduler (task_name, task_type, cron_expression, description, status, created_by, create_time, update_time, cluster_name)
KEY (task_name)
VALUES
  ('Data Cleanup', 'data_cleanup', '0 */1 * * * ?', 'Clean up expired data', 'disabled', 'admin', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '${EFAK_CLUSTER_NAME}');
MERGE INTO ke_task_scheduler (task_name, task_type, cron_expression, description, status, created_by, create_time, update_time, cluster_name)
KEY (task_name)
VALUES
  ('Performance Stats', 'performance_stats', '0 */1 * * * ?', 'Collect performance stats', 'enabled', 'admin', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '${EFAK_CLUSTER_NAME}');

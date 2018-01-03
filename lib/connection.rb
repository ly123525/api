db_config_file = YAML.load_file(File.join('config', 'database.yml'))

ActiveRecord::Base.raise_in_transactional_callbacks = true

ActiveRecord::Base.establish_connection(
  adapter: db_config_file['adapter'],
  encoding: 'utf8mb4',
  charset: 'utf8mb4',
  collation: 'utf8mb4_general_ci',
  host: db_config_file['host'],
  username: db_config_file['username'],
  password: db_config_file['password'],
  database: db_config_file['database'],
  pool: 5,
  reconnect: true
)

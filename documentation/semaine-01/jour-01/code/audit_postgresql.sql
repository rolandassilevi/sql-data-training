SELECT
    current_database() AS database_name,
    current_user AS connected_user,
    inet_server_addr() AS server_address,
    inet_server_port() AS server_port,
    version() AS postgresql_version;
CREATE DATABASE IF NOT EXISTS firstsun_wp CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE DATABASE IF NOT EXISTS kirbyhsiao_wp CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE DATABASE IF NOT EXISTS bamboo333_wp CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
-- CREATE DATABASE IF NOT EXISTS beta00_wp CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- grant access rights to user
GRANT ALL PRIVILEGES ON kirbyhsiao_wp.* TO 'wp_user'@'%';
GRANT ALL PRIVILEGES ON firstsun_wp.* TO 'wp_user'@'%';
GRANT ALL PRIVILEGES ON bamboo333_wp.* TO 'wp_user'@'%';
-- GRANT ALL PRIVILEGES ON beta00_wp.* TO 'wp_user'@'%';
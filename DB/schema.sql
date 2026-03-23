-- Academic English Practice Platform Schema
-- MySQL 8.0+
CREATE DATABASE IF NOT EXISTS acadbeat DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE acadbeat;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS checkin_records;
DROP TABLE IF EXISTS checkin_partnerships;

DROP TABLE IF EXISTS forum_post_labels;
DROP TABLE IF EXISTS forum_labels;
DROP TABLE IF EXISTS forum_comment_media;
DROP TABLE IF EXISTS forum_comments;
DROP TABLE IF EXISTS forum_post_media;
DROP TABLE IF EXISTS forum_posts;

DROP TABLE IF EXISTS training_responses;
DROP TABLE IF EXISTS training_attempts;
DROP TABLE IF EXISTS training_item_configs;
DROP TABLE IF EXISTS training_items;
DROP TABLE IF EXISTS training_modules;

DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================
-- 1. users
-- =========================================
CREATE TABLE users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 2. training_modules
-- =========================================
CREATE TABLE training_modules (
    module_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    skill_type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_training_modules_skill_type
        CHECK (skill_type IN ('listening', 'speaking', 'integrated')),

    CONSTRAINT chk_training_modules_status
        CHECK (status IN ('draft', 'published', 'archived'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 3. training_items
-- =========================================
CREATE TABLE training_items (
    item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    module_id BIGINT NOT NULL,
    item_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NULL,
    prompt_text TEXT NULL,
    order_index INT NOT NULL,
    points INT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_training_items_module
        FOREIGN KEY (module_id)
        REFERENCES training_modules(module_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_training_items_module_order
        UNIQUE (module_id, order_index),

    CONSTRAINT chk_training_items_points
        CHECK (points IS NULL OR points >= 0),

    CONSTRAINT chk_training_items_item_type
        CHECK (item_type IN ('audio_comprehension', 'listen_retell'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 4. training_item_configs
-- =========================================
CREATE TABLE training_item_configs (
    config_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    item_id BIGINT NOT NULL,
    content_data JSON NOT NULL,
    answer_data JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_training_item_configs_item
        FOREIGN KEY (item_id)
        REFERENCES training_items(item_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_training_item_configs_item UNIQUE (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 5. training_attempts
-- =========================================
CREATE TABLE training_attempts (
    attempt_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    module_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'in_progress',
    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    submitted_at DATETIME NULL,
    total_score DECIMAL(6,2) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_training_attempts_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_training_attempts_module
        FOREIGN KEY (module_id)
        REFERENCES training_modules(module_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_training_attempts_status
        CHECK (status IN ('in_progress', 'submitted', 'graded')),

    CONSTRAINT chk_training_attempts_total_score
        CHECK (total_score IS NULL OR total_score >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 6. training_responses
-- =========================================
CREATE TABLE training_responses (
    response_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    attempt_id BIGINT NOT NULL,
    item_id BIGINT NOT NULL,
    response_data JSON NOT NULL,
    score DECIMAL(6,2) NULL,
    submitted_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_training_responses_attempt
        FOREIGN KEY (attempt_id)
        REFERENCES training_attempts(attempt_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_training_responses_item
        FOREIGN KEY (item_id)
        REFERENCES training_items(item_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_training_responses_attempt_item
        UNIQUE (attempt_id, item_id),

    CONSTRAINT chk_training_responses_score
        CHECK (score IS NULL OR score >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 7. forum_posts
-- =========================================
CREATE TABLE forum_posts (
    post_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content_text TEXT NULL,
    view_count INT NOT NULL DEFAULT 0,
    comment_count INT NOT NULL DEFAULT 0,
    last_commented_at DATETIME NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_forum_posts_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_forum_posts_status
        CHECK (status IN ('active', 'hidden', 'deleted')),

    CONSTRAINT chk_forum_posts_view_count
        CHECK (view_count >= 0),

    CONSTRAINT chk_forum_posts_comment_count
        CHECK (comment_count >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 8. forum_post_media
-- =========================================
CREATE TABLE forum_post_media (
    media_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,
    media_type VARCHAR(20) NOT NULL,
    media_url VARCHAR(1000) NOT NULL,
    order_index INT NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_forum_post_media_post
        FOREIGN KEY (post_id)
        REFERENCES forum_posts(post_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_forum_post_media_type
        CHECK (media_type IN ('image', 'video', 'audio', 'link')),

    CONSTRAINT chk_forum_post_media_order
        CHECK (order_index > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 9. forum_comments
-- =========================================
CREATE TABLE forum_comments (
    comment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    parent_comment_id BIGINT NULL,
    content_text TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_forum_comments_post
        FOREIGN KEY (post_id)
        REFERENCES forum_posts(post_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_forum_comments_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_forum_comments_parent
        FOREIGN KEY (parent_comment_id)
        REFERENCES forum_comments(comment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_forum_comments_status
        CHECK (status IN ('active', 'hidden', 'deleted'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 10. forum_comment_media
-- =========================================
CREATE TABLE forum_comment_media (
    comment_media_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    comment_id BIGINT NOT NULL,
    media_type VARCHAR(20) NOT NULL,
    media_url VARCHAR(1000) NOT NULL,
    order_index INT NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_forum_comment_media_comment
        FOREIGN KEY (comment_id)
        REFERENCES forum_comments(comment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_forum_comment_media_type
        CHECK (media_type IN ('image', 'video', 'audio', 'link')),

    CONSTRAINT chk_forum_comment_media_order
        CHECK (order_index > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 11. forum_labels
-- =========================================
CREATE TABLE forum_labels (
    label_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_forum_labels_name UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 12. forum_post_labels
-- =========================================
CREATE TABLE forum_post_labels (
    post_label_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,
    label_id BIGINT NOT NULL,

    CONSTRAINT fk_forum_post_labels_post
        FOREIGN KEY (post_id)
        REFERENCES forum_posts(post_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_forum_post_labels_label
        FOREIGN KEY (label_id)
        REFERENCES forum_labels(label_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_forum_post_labels_post_label UNIQUE (post_id, label_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 13. checkin_partnerships
-- =========================================
CREATE TABLE checkin_partnerships (
    partnership_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_one_id BIGINT NOT NULL,
    user_two_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_checkin_partnerships_user_one
        FOREIGN KEY (user_one_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_checkin_partnerships_user_two
        FOREIGN KEY (user_two_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_checkin_partnerships_status
        CHECK (status IN ('active', 'ended'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- 14. checkin_records
-- =========================================
CREATE TABLE checkin_records (
    record_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    partnership_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    checkin_date DATE NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_checkin_records_partnership
        FOREIGN KEY (partnership_id)
        REFERENCES checkin_partnerships(partnership_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_checkin_records_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_checkin_records_unique_daily
        UNIQUE (partnership_id, user_id, checkin_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================
-- Indexes
-- =========================================

CREATE INDEX idx_training_items_module_id
    ON training_items(module_id);

CREATE INDEX idx_training_attempts_user_id
    ON training_attempts(user_id);

CREATE INDEX idx_training_attempts_module_id
    ON training_attempts(module_id);

CREATE INDEX idx_training_responses_attempt_id
    ON training_responses(attempt_id);

CREATE INDEX idx_training_responses_item_id
    ON training_responses(item_id);

CREATE INDEX idx_forum_posts_user_id
    ON forum_posts(user_id);

CREATE INDEX idx_forum_posts_last_commented_at
    ON forum_posts(last_commented_at);

CREATE INDEX idx_forum_posts_created_at
    ON forum_posts(created_at);

CREATE INDEX idx_forum_post_media_post_id
    ON forum_post_media(post_id);

CREATE INDEX idx_forum_comments_post_id
    ON forum_comments(post_id);

CREATE INDEX idx_forum_comments_user_id
    ON forum_comments(user_id);

CREATE INDEX idx_forum_comments_parent_comment_id
    ON forum_comments(parent_comment_id);

CREATE INDEX idx_forum_comment_media_comment_id
    ON forum_comment_media(comment_id);

CREATE INDEX idx_forum_post_labels_post_id
    ON forum_post_labels(post_id);

CREATE INDEX idx_forum_post_labels_label_id
    ON forum_post_labels(label_id);

CREATE INDEX idx_checkin_partnerships_user_one_id
    ON checkin_partnerships(user_one_id);

CREATE INDEX idx_checkin_partnerships_user_two_id
    ON checkin_partnerships(user_two_id);

CREATE INDEX idx_checkin_records_partnership_id
    ON checkin_records(partnership_id);

CREATE INDEX idx_checkin_records_user_id
    ON checkin_records(user_id);
-- =====================================================
-- Fix credentials rows with id = 0 (broken AUTO_INCREMENT)
-- Run in phpMyAdmin AFTER backing up your database.
-- =====================================================

-- 1. Check current state
SELECT id, title, created_by, workspace_id, created_at FROM credentials ORDER BY created_at;

-- 2. Assign unique IDs to rows stuck at id = 0
SET @next_id := (SELECT COALESCE(MAX(id), 0) FROM credentials WHERE id > 0);

UPDATE credentials
SET id = (@next_id := @next_id + 1)
WHERE id = 0
ORDER BY created_at ASC;

-- 3. Bump AUTO_INCREMENT past the highest id
SET @ai := (SELECT COALESCE(MAX(id), 0) + 1 FROM credentials);
SET @sql = CONCAT('ALTER TABLE credentials AUTO_INCREMENT = ', @ai);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 4. Verify — each row should have a unique id > 0
SELECT id, title, created_at FROM credentials ORDER BY id;

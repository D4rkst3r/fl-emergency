-- ================================
-- 🚨 FL EMERGENCY SERVICES - KOMPATIBLE DATABASE SCHEMA
-- ================================

-- Erstelle Database falls nicht vorhanden
CREATE DATABASE IF NOT EXISTS `fl_emergency` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `fl_emergency`;

-- ================================
-- 🗃️ HAUPT-TABELLE (Flexibles JSON-System)
-- ================================

CREATE TABLE IF NOT EXISTS `fl_emergency_data` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `citizenid` VARCHAR(50) NOT NULL,
    `type` ENUM('duty', 'call', 'vehicle', 'equipment', 'stats', 'log', 'whitelist', 'settings') NOT NULL,
    `service` ENUM('fire', 'police', 'ems', 'system', 'admin') NOT NULL DEFAULT 'system',
    `data` JSON NOT NULL,
    `metadata` JSON DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NULL DEFAULT NULL,
    `active` BOOLEAN DEFAULT TRUE,
    
    -- Basis-Indizes für Performance
    INDEX `idx_citizen_type` (`citizenid`, `type`),
    INDEX `idx_service_type` (`service`, `type`),
    INDEX `idx_active_expires` (`active`, `expires_at`),
    INDEX `idx_created` (`created_at`),
    INDEX `idx_updated` (`updated_at`),
    INDEX `idx_type_service` (`type`, `service`),
    INDEX `idx_citizen_service_type` (`citizenid`, `service`, `type`),
    INDEX `idx_active_type_created` (`active`, `type`, `created_at`)
    
    -- FULLTEXT INDEX entfernt für Kompatibilität
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================
-- 🔐 WHITELIST-TABELLE (Optional)
-- ================================

CREATE TABLE IF NOT EXISTS `fl_emergency_whitelist` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `citizenid` VARCHAR(50) NOT NULL,
    `service` ENUM('fire', 'police', 'ems') NOT NULL,
    `rank` INT DEFAULT 0,
    `added_by` VARCHAR(50) NOT NULL,
    `added_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NULL DEFAULT NULL,
    `active` BOOLEAN DEFAULT TRUE,
    `notes` TEXT DEFAULT NULL,
    
    -- Unique constraint
    UNIQUE KEY `unique_citizen_service` (`citizenid`, `service`),
    
    -- Indizes
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_service` (`service`),
    INDEX `idx_active` (`active`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================
-- 📊 STATISTICS VIEW (Für bessere Performance)
-- ================================

CREATE OR REPLACE VIEW `fl_emergency_stats` AS
SELECT 
    `service`,
    `type`,
    COUNT(*) as `total_records`,
    COUNT(CASE WHEN `active` = 1 THEN 1 END) as `active_records`,
    COUNT(CASE WHEN DATE(`created_at`) = CURDATE() THEN 1 END) as `today_records`,
    COUNT(CASE WHEN DATE(`created_at`) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN 1 END) as `week_records`,
    COUNT(CASE WHEN DATE(`created_at`) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 1 END) as `month_records`,
    MIN(`created_at`) as `first_record`,
    MAX(`created_at`) as `last_record`
FROM `fl_emergency_data`
GROUP BY `service`, `type`;

-- ================================
-- 🎯 DUTY STATISTICS VIEW
-- ================================

CREATE OR REPLACE VIEW `fl_duty_stats` AS
SELECT 
    `citizenid`,
    `service`,
    COUNT(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.action')) = 'start' THEN 1 END) as `total_shifts`,
    SUM(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.action')) = 'end' THEN 
        CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.duration')) AS UNSIGNED) ELSE 0 END) as `total_duration`,
    AVG(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.action')) = 'end' THEN 
        CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.duration')) AS UNSIGNED) ELSE NULL END) as `avg_duration`,
    MAX(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.action')) = 'start' THEN `created_at` END) as `last_duty_start`,
    MAX(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.action')) = 'end' THEN `created_at` END) as `last_duty_end`,
    COUNT(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.action')) = 'start' AND DATE(`created_at`) = CURDATE() THEN 1 END) as `today_shifts`,
    COUNT(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.action')) = 'start' AND DATE(`created_at`) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN 1 END) as `week_shifts`
FROM `fl_emergency_data`
WHERE `type` = 'duty' AND `active` = 1
GROUP BY `citizenid`, `service`;

-- ================================
-- 📞 CALL STATISTICS VIEW
-- ================================

CREATE OR REPLACE VIEW `fl_call_stats` AS
SELECT 
    `service`,
    JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.type')) as `call_type`,
    CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.priority')) AS UNSIGNED) as `priority`,
    COUNT(*) as `total_calls`,
    COUNT(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.status')) = 'completed' THEN 1 END) as `completed_calls`,
    COUNT(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.status')) = 'cancelled' THEN 1 END) as `cancelled_calls`,
    AVG(CASE WHEN JSON_EXTRACT(`data`, '$.responseTime') IS NOT NULL THEN 
        CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.responseTime')) AS UNSIGNED) END) as `avg_response_time`,
    AVG(CASE WHEN JSON_EXTRACT(`data`, '$.completedTime') IS NOT NULL THEN 
        CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.completedTime')) AS UNSIGNED) - 
        CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.created')) AS UNSIGNED)
    END) as `avg_completion_time`,
    COUNT(CASE WHEN DATE(`created_at`) = CURDATE() THEN 1 END) as `today_calls`,
    COUNT(CASE WHEN DATE(`created_at`) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN 1 END) as `week_calls`
FROM `fl_emergency_data`
WHERE `type` = 'call' AND `active` = 1
GROUP BY `service`, JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.type')), CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.priority')) AS UNSIGNED);

-- ================================
-- 🚗 VEHICLE STATISTICS VIEW
-- ================================

CREATE OR REPLACE VIEW `fl_vehicle_stats` AS
SELECT 
    `citizenid`,
    `service`,
    JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.model')) as `vehicle_model`,
    JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.plate')) as `vehicle_plate`,
    COUNT(*) as `spawn_count`,
    SUM(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.spawned')) = 'true' THEN 1 ELSE 0 END) as `currently_spawned`,
    MAX(`created_at`) as `last_spawn`,
    AVG(CASE WHEN JSON_EXTRACT(`data`, '$.duration') IS NOT NULL THEN 
        CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.duration')) AS UNSIGNED)
    END) as `avg_usage_time`
FROM `fl_emergency_data`
WHERE `type` = 'vehicle' AND `active` = 1
GROUP BY `citizenid`, `service`, 
         JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.model')), 
         JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.plate'));

-- ================================
-- 📈 PERFORMANCE VIEWS
-- ================================

-- Aktive Spieler im Dienst
CREATE OR REPLACE VIEW `fl_active_players` AS
SELECT DISTINCT
    d1.`citizenid`,
    d1.`service`,
    JSON_UNQUOTE(JSON_EXTRACT(d1.`data`, '$.station')) as `station`,
    CAST(JSON_UNQUOTE(JSON_EXTRACT(d1.`data`, '$.timestamp')) AS UNSIGNED) as `duty_start`,
    d1.`created_at` as `duty_start_real`,
    TIMESTAMPDIFF(MINUTE, d1.`created_at`, NOW()) as `minutes_on_duty`
FROM `fl_emergency_data` d1
WHERE d1.`type` = 'duty' 
    AND d1.`active` = 1
    AND JSON_UNQUOTE(JSON_EXTRACT(d1.`data`, '$.action')) = 'start'
    AND NOT EXISTS (
        SELECT 1 FROM `fl_emergency_data` d2 
        WHERE d2.`citizenid` = d1.`citizenid` 
            AND d2.`service` = d1.`service` 
            AND d2.`type` = 'duty'
            AND d2.`active` = 1
            AND JSON_UNQUOTE(JSON_EXTRACT(d2.`data`, '$.action')) = 'end'
            AND d2.`created_at` > d1.`created_at`
    )
    AND d1.`created_at` >= DATE_SUB(NOW(), INTERVAL 12 HOUR);

-- Aktive Einsätze
CREATE OR REPLACE VIEW `fl_active_calls` AS
SELECT 
    `id`,
    `service`,
    JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.id')) as `call_id`,
    JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.type')) as `call_type`,
    CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.priority')) AS UNSIGNED) as `priority`,
    JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.status')) as `status`,
    JSON_EXTRACT(`data`, '$.coords') as `coords`,
    JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.description')) as `description`,
    JSON_EXTRACT(`data`, '$.assigned') as `assigned_units`,
    CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.created')) AS UNSIGNED) as `call_created`,
    `created_at`,
    `expires_at`,
    TIMESTAMPDIFF(MINUTE, `created_at`, NOW()) as `minutes_active`
FROM `fl_emergency_data`
WHERE `type` = 'call' 
    AND `active` = 1
    AND (`expires_at` IS NULL OR `expires_at` > NOW())
    AND JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.status')) NOT IN ('completed', 'cancelled')
ORDER BY CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.priority')) AS UNSIGNED) ASC, `created_at` ASC;

-- ================================
-- 🔧 STORED PROCEDURES
-- ================================

-- Bereinige abgelaufene Daten
DELIMITER //
CREATE PROCEDURE `CleanupExpiredData`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE expired_count INT DEFAULT 0;
    DECLARE log_count INT DEFAULT 0;
    
    -- Lösche abgelaufene Einträge
    DELETE FROM `fl_emergency_data` 
    WHERE `expires_at` IS NOT NULL AND `expires_at` < NOW();
    
    SET expired_count = ROW_COUNT();
    
    -- Lösche alte Logs (älter als 30 Tage)
    DELETE FROM `fl_emergency_data` 
    WHERE `type` = 'log' AND `created_at` < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    SET log_count = ROW_COUNT();
    
    -- Log die Bereinigung
    INSERT INTO `fl_emergency_data` (`citizenid`, `type`, `service`, `data`) 
    VALUES ('system', 'log', 'system', JSON_OBJECT(
        'action', 'cleanup',
        'expired_records', expired_count,
        'old_logs', log_count,
        'timestamp', UNIX_TIMESTAMP()
    ));
    
    SELECT expired_count as `expired_cleaned`, log_count as `logs_cleaned`;
END //
DELIMITER ;

-- Erstelle Backup
DELIMITER //
CREATE PROCEDURE `CreateBackup`(IN `backup_type` VARCHAR(20))
BEGIN
    DECLARE backup_id VARCHAR(50);
    DECLARE record_count INT DEFAULT 0;
    
    SET backup_id = CONCAT('backup_', DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s'));
    
    -- Zähle Einträge
    SELECT COUNT(*) INTO record_count FROM `fl_emergency_data` WHERE `active` = 1;
    
    -- Erstelle Backup-Eintrag
    INSERT INTO `fl_emergency_data` (`citizenid`, `type`, `service`, `data`) 
    VALUES ('system', 'log', 'system', JSON_OBJECT(
        'action', 'backup_created',
        'backup_id', backup_id,
        'backup_type', backup_type,
        'record_count', record_count,
        'timestamp', UNIX_TIMESTAMP()
    ));
    
    SELECT backup_id as `backup_id`, record_count as `records_backed_up`;
END //
DELIMITER ;

-- Spieler-Statistiken
DELIMITER //
CREATE PROCEDURE `GetPlayerStats`(IN `player_citizenid` VARCHAR(50))
BEGIN
    SELECT 
        `citizenid`,
        `service`,
        `total_shifts`,
        `total_duration`,
        `avg_duration`,
        `last_duty_start`,
        `last_duty_end`,
        `today_shifts`,
        `week_shifts`,
        CASE 
            WHEN `last_duty_start` > `last_duty_end` OR `last_duty_end` IS NULL THEN 'ON_DUTY'
            ELSE 'OFF_DUTY'
        END as `current_status`
    FROM `fl_duty_stats`
    WHERE `citizenid` = player_citizenid
    ORDER BY `service`;
END //
DELIMITER ;

-- Service-Statistiken
DELIMITER //
CREATE PROCEDURE `GetServiceStats`(IN `service_name` VARCHAR(20), IN `days` INT)
BEGIN
    SELECT 
        DATE(`created_at`) as `date`,
        COUNT(DISTINCT CASE WHEN `type` = 'duty' AND JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.action')) = 'start' THEN `citizenid` END) as `active_players`,
        COUNT(CASE WHEN `type` = 'call' THEN 1 END) as `total_calls`,
        COUNT(CASE WHEN `type` = 'call' AND JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.status')) = 'completed' THEN 1 END) as `completed_calls`,
        COUNT(CASE WHEN `type` = 'call' AND JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.status')) = 'cancelled' THEN 1 END) as `cancelled_calls`,
        AVG(CASE WHEN `type` = 'call' AND JSON_EXTRACT(`data`, '$.responseTime') IS NOT NULL THEN 
            CAST(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.responseTime')) AS UNSIGNED)
        END) as `avg_response_time`
    FROM `fl_emergency_data`
    WHERE `service` = service_name 
        AND `created_at` >= DATE_SUB(NOW(), INTERVAL days DAY)
        AND `active` = 1
    GROUP BY DATE(`created_at`)
    ORDER BY DATE(`created_at`) DESC;
END //
DELIMITER ;

-- ================================
-- 🔄 TRIGGERS (Vereinfacht)
-- ================================

-- Update Trigger für Metadaten
DELIMITER //
CREATE TRIGGER `update_metadata` 
BEFORE UPDATE ON `fl_emergency_data`
FOR EACH ROW
BEGIN
    SET NEW.`updated_at` = NOW();
    
    -- Füge Update-Info zu Metadaten hinzu
    SET NEW.`metadata` = JSON_SET(
        IFNULL(NEW.`metadata`, '{}'),
        '$.last_updated', UNIX_TIMESTAMP(NOW()),
        '$.update_count', IFNULL(CAST(JSON_UNQUOTE(JSON_EXTRACT(NEW.`metadata`, '$.update_count')) AS UNSIGNED), 0) + 1
    );
END //
DELIMITER ;

-- ================================
-- 🎯 EXAMPLE DATA (für Development)
-- ================================

-- Beispiel-Einsätze für Testing
INSERT INTO `fl_emergency_data` (`citizenid`, `type`, `service`, `data`, `expires_at`) VALUES
('system', 'call', 'fire', JSON_OBJECT(
    'id', 'FW-1234-5678',
    'type', 'structure_fire',
    'priority', 1,
    'status', 'pending',
    'coords', JSON_OBJECT('x', 213.5, 'y', -810.0, 'z', 31.0),
    'description', 'Gebäudebrand in Downtown',
    'created', UNIX_TIMESTAMP(),
    'assigned', JSON_ARRAY(),
    'requiredUnits', 2
), DATE_ADD(NOW(), INTERVAL 1 HOUR)),

('system', 'call', 'police', JSON_OBJECT(
    'id', 'POL-1234-9876',
    'type', 'robbery',
    'priority', 1,
    'status', 'pending',
    'coords', JSON_OBJECT('x', 441.0, 'y', -982.0, 'z', 30.0),
    'description', 'Raub in der Mission Row',
    'created', UNIX_TIMESTAMP(),
    'assigned', JSON_ARRAY(),
    'requiredUnits', 2
), DATE_ADD(NOW(), INTERVAL 1 HOUR)),

('system', 'call', 'ems', JSON_OBJECT(
    'id', 'RD-1234-4321',
    'type', 'car_accident',
    'priority', 1,
    'status', 'pending',
    'coords', JSON_OBJECT('x', 298.0, 'y', -584.0, 'z', 43.0),
    'description', 'Verkehrsunfall vor Pillbox Medical',
    'created', UNIX_TIMESTAMP(),
    'assigned', JSON_ARRAY(),
    'requiredUnits', 1
), DATE_ADD(NOW(), INTERVAL 1 HOUR));

-- ================================
-- 📊 FINAL OPTIMIZATION
-- ================================

-- Optimiere Tabellen
ANALYZE TABLE `fl_emergency_data`;
ANALYZE TABLE `fl_emergency_whitelist`;

-- ================================
-- ✅ INSTALLATION COMPLETE
-- ================================

SELECT 
    'FL Emergency Services Database' as `System`,
    'Successfully Installed (Compatible Version)' as `Status`,
    NOW() as `Installation_Time`,
    (SELECT COUNT(*) FROM `fl_emergency_data`) as `Total_Records`,
    (SELECT COUNT(*) FROM `fl_emergency_whitelist`) as `Whitelist_Entries`,
    VERSION() as `MySQL_Version`;

-- Ende der Installation
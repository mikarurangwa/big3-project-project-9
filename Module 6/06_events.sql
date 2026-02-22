-- Module 6: Events - Automated Project Archiving
-- Purpose: Automatically archive completed projects older than 1 year

-- STEP 1: Create archive table
CREATE TABLE IF NOT EXISTS archived_projects (
    archived_project_id INT AUTO_INCREMENT PRIMARY KEY,
    original_project_id VARCHAR(10) NOT NULL,
    project_name VARCHAR(200) NOT NULL,
    client_id INT,
    site_address VARCHAR(255),
    site_city VARCHAR(100),
    start_date DATE,
    end_date DATE,
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_original_project_id (original_project_id),
    INDEX idx_archived_at (archived_at)
);

-- STEP 2: Enable MySQL Event Scheduler
SET GLOBAL event_scheduler = ON;

-- STEP 3: Create automated archiving event
DELIMITER $$

CREATE EVENT IF NOT EXISTS ev_archive_completed_projects
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- Use transaction to ensure data integrity
    START TRANSACTION;
    
    -- Insert completed projects older than 1 year into archive
    -- Only archive projects not already archived (prevent duplicates)
    INSERT INTO archived_projects (
        original_project_id,
        project_name,
        client_id,
        site_address,
        site_city,
        start_date,
        end_date
    )
    SELECT 
        p.project_id,
        p.project_name,
        p.client_id,
        p.site_address,
        p.site_city,
        p.start_date,
        p.end_date
    FROM projects p
    WHERE p.end_date IS NOT NULL
      AND p.end_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
      AND NOT EXISTS (
          SELECT 1 
          FROM archived_projects ap 
          WHERE ap.original_project_id = p.project_id
      );
    
    -- Delete archived projects from main table
    DELETE p
    FROM projects p
    INNER JOIN archived_projects ap
        ON ap.original_project_id = p.project_id
    WHERE p.end_date IS NOT NULL
      AND p.end_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
    
    COMMIT;
END$$

DELIMITER ;

-- Module 5: Triggers — Automatic Rule-Enforcer


-- Create the audit log table to track all changes to worker skills
CREATE TABLE IF NOT EXISTS worker_skills_audit_log (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    worker_id INT NOT NULL,
    skill_id INT NOT NULL,
    old_certification_date DATE,
    new_certification_date DATE,
    old_expiry_date DATE,
    new_expiry_date DATE,
    action VARCHAR(10) NOT NULL,  -- 'INSERT', 'UPDATE' or 'DELETE'
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (worker_id) REFERENCES workers(worker_id),
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id)
);

-- Create an AFTER UPDATE trigger to log all changes to worker_skills
DELIMITER $$

CREATE TRIGGER trg_audit_worker_skills_update
AFTER UPDATE ON worker_skills
FOR EACH ROW
BEGIN
    INSERT INTO worker_skills_audit_log
    (worker_id, skill_id, old_certification_date, new_certification_date, 
     old_expiry_date, new_expiry_date, action)
    VALUES
    (OLD.worker_id, OLD.skill_id, OLD.certification_date, NEW.certification_date,
     OLD.expiry_date, NEW.expiry_date, 'UPDATE');
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER trg_validate_cert_before_assignment
BEFORE INSERT ON project_assignments
FOR EACH ROW
BEGIN
    DECLARE v_expired_count INT;
    DECLARE v_error_message VARCHAR(255);
    
    -- Check if the worker has any expired certifications for skills
    -- that might be required for projects (if such a relationship exists)
    SELECT COUNT(*)
    INTO v_expired_count
    FROM worker_skills ws
    WHERE ws.worker_id = NEW.worker_id
      AND ws.expiry_date IS NOT NULL
      AND ws.expiry_date < CURDATE();
    
    -- If the worker has expired certifications, block the assignment
    IF v_expired_count > 0 THEN
        SET v_error_message = CONCAT(
            'Error: Worker ID ', NEW.worker_id, 
            ' has ', v_expired_count, ' expired certification(s) and cannot be assigned to projects.'
        );
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;
END$$

DELIMITER ;

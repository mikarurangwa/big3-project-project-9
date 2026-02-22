DELIMITER $$

CREATE PROCEDURE sp_add_worker_with_skill(
	IN p_first_name VARCHAR(100), IN p_last_name VARCHAR(100), IN p_phone VARCHAR(20),
	IN p_salary DECIMAL(10,2), IN p_skill_name VARCHAR(100)
)
BEGIN
	DECLARE v_worker_id INT;
	DECLARE v_skill_id INT;
	START TRANSACTION;
	INSERT INTO workers(first_name,last_name,phone,salary)
		VALUES (p_first_name,p_last_name,p_phone,p_salary);
	SET v_worker_id = LAST_INSERT_ID();
	SELECT skill_id INTO v_skill_id FROM skills WHERE skill_name = p_skill_name LIMIT 1;
	IF v_skill_id IS NOT NULL THEN
		INSERT INTO worker_skills(worker_id,skill_id) VALUES (v_worker_id,v_skill_id);
	END IF;
	COMMIT;
END$$

DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_assign_worker_to_project(
	IN p_worker_id INT, IN p_project_id VARCHAR(10), OUT p_message VARCHAR(255)
)
BEGIN
	IF EXISTS(SELECT 1 FROM project_assignments WHERE worker_id = p_worker_id AND project_id = p_project_id) THEN
		SET p_message = 'Error: Worker already assigned to this project.';
	ELSE
		INSERT INTO project_assignments(worker_id,project_id,assignment_date)
			VALUES (p_worker_id,p_project_id,CURDATE());
		SET p_message = 'Success: Worker assigned.';
	END IF;
END$$

DELIMITER ;

CALL sp_add_worker_with_skill('Alice','Smith','555-1234',75000.00,'Project Management');
CALL sp_assign_worker_to_project(1,'P001',@message);
SELECT @message;

# Module 5: Triggers — Automatic Rule-Enforcer

## Overview
This module implements two critical triggers to enforce business rules and maintain data integrity:

1. **Guided Activity**: An audit log table and AFTER UPDATE trigger that tracks all modifications to worker certifications
2. **Challenge Task**: A BEFORE INSERT validation trigger that prevents workers with expired certifications from being assigned to projects

---

## Guided Activity: Audit Log Trigger

### Implementation Details
- **Audit Table**: `worker_skills_audit_log` stores historical changes with timestamps
- **Trigger**: `trg_audit_worker_skills_update` fires AFTER each UPDATE on `worker_skills`
- **Tracked Fields**: Certification dates and expiry dates (old and new values)

### Why This Approach?
The AFTER UPDATE trigger is ideal for audit logging because:
- It fires after the change is committed ensuring data consistency
- It captures both old and new values providing a complete change history
- Timestamps are automatic creating a complete audit trail for compliance and debugging

---

## Challenge Task: Certification Validation Trigger

### Implementation Details
- **Trigger**: `trg_validate_cert_before_assignment` fires BEFORE INSERT on `project_assignments`
- **Logic**: 
  - Counts how many worker skills have an `expiry_date` in the past
  - If any expired certifications exist the SIGNAL statement blocks the insert with a descriptive error
- **Error Handling**: Uses `SIGNAL SQLSTATE '45000'` for proper MySQL error handling

### Why This Approach Works
1. **BEFORE vs AFTER**: BEFORE INSERT prevents invalid data from entering the database in the first place rather than catching it afterward
2. **Expiry Check**: Uses `expiry_date < CURDATE()` to identify truly expired certifications
3. **Worker Safety**: Ensures only workers with current certifications are assigned to projects supporting business compliance and safety standards
4. **Graceful Failure**: Returns a clear error message including the worker ID and count of expired certs

### Testing Strategy
1. Insert an assignment with a worker who has valid certifications
2. Manually update a worker's skill to have an expiry date in the past
3. Attempt to insert an assignment for that worker 
4. View the audit log to verify update operations were recorded

---

## Key Design Decisions

- **Comprehensive Validation**: The trigger counts ALL expired certifications not just one to catch complex scenarios
- **Non-NULL expiry_date Check**: `WHERE ... expiry_date IS NOT NULL` ensures we only validate when an expiry date is actually set
- **User-Friendly Error**: The SIGNAL message includes context (worker ID and count) for easy debugging
- **CURRENT_DATE Alternative**: Used `CURDATE()` for maximum MySQL compatibility

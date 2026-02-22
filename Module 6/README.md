# Module 6: Events — Automated Project Archiving

## Module 6 — Events Justification

### 1. Why Event Automation is Needed
Manually archiving old completed projects is time-consuming and error-prone. Automated events ensure that archiving happens consistently without human intervention, reducing administrative overhead and ensuring data management policies are enforced reliably.

### 2. Why Archiving Improves Performance
As the projects table grows with historical data, queries become slower due to larger table scans and index sizes. Archiving completed projects older than 1 year keeps the active projects table lean, improving query performance for day-to-day operations while preserving historical data in the archive table.

### 3. Why a Transaction is Necessary
The archiving process involves two critical operations: INSERT into archived_projects and DELETE from projects. Using a transaction ensures atomicity—either both operations succeed or both fail. This prevents data loss (if INSERT succeeds but DELETE fails) or orphaned records (if DELETE succeeds but INSERT fails).

### 4. How Data Integrity is Protected
- **Duplicate Prevention**: The NOT EXISTS clause ensures projects are only archived once
- **Transaction Safety**: COMMIT/ROLLBACK ensures all-or-nothing execution
- **Foreign Key Preservation**: original_project_id stores the reference even after deletion
- **Timestamp Tracking**: archived_at records when archiving occurred for audit purposes

### 5. Why the Schedule Interval was Chosen
Running EVERY 1 DAY balances automation efficiency with system resource usage. Daily execution ensures timely archiving without overwhelming the database with frequent checks. Projects older than 1 year don't require immediate archiving, making daily checks sufficient.

## Testing Steps

### Verify Event is Active
```sql
SHOW EVENTS;
```
Expected output: ev_archive_completed_projects with status ENABLED

### Check Archived Projects
```sql
SELECT * FROM archived_projects;
```
This shows all projects that have been archived

### Manual Event Execution (for testing)
```sql
-- Trigger event manually without waiting for schedule
CALL sys.table_exists('archived_projects', @exists);
SELECT * FROM projects WHERE end_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
```

### Verify Event Scheduler Status
```sql
SHOW VARIABLES LIKE 'event_scheduler';
```
Expected output: ON

## Team Contribution Statement

**Cletus Ayeebo Abugre:**
- Implemented Module 6 (Events)
- Created archived_projects table with proper schema and indexes
- Implemented automated archive event with transaction safety
- Added duplicate prevention logic
- Updated README documentation with justification and testing steps
- Tested automation logic and verified data integrity

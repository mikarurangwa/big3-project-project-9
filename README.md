# Big3 Construction: Advanced SQL—Optimization & Automation (Phase 2)

## Project Overview

### Scenario
Big3 Construction was thrilled with the normalized 5NF database we delivered. The data is clean, redundant-free and more reliable. 

Now that they've been using it for a few months, they've come back with a new set of **"Phase 2" requirements**. They don't just want to store data; they want to:
- **Optimize performance** through intelligent indexing
- **Simplify data access** for different user roles via views
- **Automate business processes** using stored procedures, triggers, and scheduled events
- **Enforce complex business rules** to maintain data integrity

We have been retained to implement these advanced features across six specialized modules.

---

## Repository Structure

This project contains six modules, each addressing a specific database feature:

```
big3-project-project-9/
├── module-1/
│   ├── 01_indexes.sql          # Module 1: Indexes (Performance Optimization)
│   └── README.md               # Module 1 Challenge Justification
├── module-2/
│   ├── 02_subqueries.sql       # Module 2: Subqueries & Advanced Joins
│   └── README.md               # Module 2 Challenge Justification
├── Module 3/
│   ├── 03_views.sql            # Module 3: Views (Secure Data Access)
│   └── README.md               # Module 3 Challenge Justification
├── Module 4/
│   ├── 04_procedures.sql       # Module 4: Stored Procedures (Automation)
│   └── README.md               # Module 4 Challenge Justification
├── Module 5/
│   ├── 05_triggers.sql         # Module 5: Triggers (Rule Enforcement)
│   └── README.md               # Module 5 Challenge Justification
├── Module 6/
│   ├── 06_events.sql           # Module 6: Events (Scheduled Maintenance)
│   └── README.md               # Module 6 Challenge Justification
└── README.md                   # This file (Master Project Documentation)
```

---

## Database Context

This project builds directly on the **DB Design Activity** implementation using the **big3_construction** database with the following core tables:

- **workers**: Employee information and credentials
- **skills**: Available technical skills
- **worker_skills**: Certifications mapping workers to skills
- **projects**: Construction projects with budgets and timelines
- **project_assignments**: Worker assignments to projects
- **clients**: Client/customer information
- **project_materials**: Materials used per project
- **sites**: Physical project locations

---

## Module Summaries & Challenge Justifications

### **Module 1: Indexes — "The Need for Speed"**

**Guided Activity**: Created a simple index on `workers(last_name)` to speed up worker lookups by surname.

**Challenge Task**: Composite Index on `projects(site_city, start_date)`

**Why This Approach Works:**
- The composite index is **ordered strategically**: `site_city` first filters to a specific city's projects, then `start_date` supports efficient sorting
- **Multi-column efficiency**: The query pattern is `WHERE site_city = ? ORDER BY start_date`, so column order matters
- **Index selectivity**: City filters to a smaller subset first, maximizing the benefit of ordering by start_date
- **EXPLAIN analysis**: EXPLAIN queries show dramatic improvements in rows examined and query execution time

**Key Learning**: Index column order should match query filter sort patterns for maximum efficiency.

---

### **Module 2: Subqueries & Advanced Joins — "The Complex Questions"**

**Guided Activity**: Two query variations finding workers with specific skills
- *Nested Subquery approach*: Using IN with nested SELECT for skill lookup
- *JOIN approach*: Using explicit JOINs (typically more efficient)

**Challenge Task**: "Max of Count" Find project(s) with the highest number of assigned workers

**Why This Approach Works:**
1. **Two-step problem requires two subqueries**:
   - **Inner subquery in FROM**: Counts workers per project (`GROUP BY project_id`)
   - **Outer subquery in WHERE**: Finds the maximum worker count
2. **Handles ties elegantly**: If two projects have equal max workers, both are returned
3. **Efficient aggregation**: Uses SQL's built-in COUNT and MAX functions rather than application-level logic
4. **Clear readability**: Joins back to projects to show meaningful project names alongside counts

**Key Learning**: Breaking complex problems into nested queries makes logic clearer and SQL more maintainable.

---

### **Module 3: Views — "The Simple & Secure Reports"**

**Guided Activity**: `v_project_worker_assignments` - Lists workers assigned to each project with contact info and assignment dates.

**Challenge Task**: `v_project_financial_summary` - Financial overview of projects

**Why This Approach Works:**
1. **Security through abstraction**: Views hide the schema complexity and sensitive data
   - Supervisors see worker contact info without access to salary data
   - Finance sees budgets and costs without needing to understand JOIN complexity
2. **Performance benefit**: Pre-computed JOINs reduce query complexity for end users
3. **Accurate aggregation**:
   - Uses `LEFT JOIN` to include projects with no materials
   - `COALESCE` handles NULL totals for projects with zero material costs
   - `GROUP BY` correctly aggregates multiple materials per project
4. **Simplified reusability**: One view definition used by many applications

**Key Learning**: Views provide both security and convenience by abstracting complex logic into simple interfaces.

---

### **Module 4: Stored Procedures — "One-Click Tasks"**

**Guided Activity**: `sp_add_worker_with_skill` - Adds a new worker and assigns an existing skill in one atomic operation.

**Challenge Task**: `sp_assign_worker_to_project` - Assigns worker to project with error handling

**Why This Approach Works:**
1. **Parameter consistency**: 
   - IN parameters for inputs (worker_id, project_id)
   - OUT parameter for status message (success/error feedback)
2. **Duplicate prevention**: EXISTS check prevents assigning same worker twice to same project
3. **Error messaging**: OUT parameter provides clear feedback for UI integration
4. **Transaction safety**: Encapsulation ensures either the entire assignment succeeds or fails
5. **Reusable logic**: Application code calls single procedure instead of writing complex UPDATE logic

**Key Learning**: Procedures encapsulate business logic and improve maintainability, testability and reusability.

---

### **Module 5: Triggers — "Automatic Rule-Enforcer"**

**Guided Activity**: `trg_audit_worker_skills_update` - AFTER UPDATE trigger logs all certification date changes

**Challenge Task**: `trg_validate_cert_before_assignment` - BEFORE INSERT validation trigger

**Why This Approach Works:**
1. **Preventive validation** (BEFORE INSERT):
   - Stops invalid assignments at insertion time rather than after-the-fact
   - Prevents expired workers from being assigned to safety-critical projects
2. **Comprehensive expiry check**:
   - Counts ALL expired certifications (not just one)
   - Handles NULL expiry dates safely with `WHERE expiry_date IS NOT NULL`
   - Uses `expiry_date < CURDATE()` for current-precise comparison
3. **Graceful error handling**:
   - SIGNAL SQLSTATE '45000' properly raises an exception
   - Error message includes context (worker ID and expired cert count)
   - Application can catch and react to the error
4. **Audit trail compliance**:
   - AFTER UPDATE trigger captures all changes with timestamps
   - Fully columns captured (old and new values)
   - Compliant with auditing regulations

**Testing Strategy:**
1. Insert valid assignment → succeeds
2. Manually set worker skill expiry to past date
3. Attempt assignment → blocked with clear error message
4. Verify audit log shows all updates with timestamps

**Key Learning**: BEFORE triggers prevent invalid data; AFTER triggers track accountability. Use SIGNAL for clean error handling.

---

### **Module 6: Events — "Scheduled Maintenance"**

**Guided Activity**: Create `archived_projects` table to store historical completed projects.

**Challenge Task**: `ev_archive_completed_projects` - Automated daily archiving event

**Why This Approach Works:**
1. **Performance optimization**:
   - Active projects table stays lean (only recent/ongoing projects)
   - Faster queries due to smaller working dataset
   - Historical data preserved for reporting
2. **Data consistency through transactions**:
   - INSERT into archived_projects and DELETE from projects are atomic
   - Prevents orphaned records or accidental data loss
3. **Duplicate prevention**:
   - NOT EXISTS clause ensures projects only archived once
   - Idempotent operation (safe to run multiple times)
4. **Audit trail preservation**:
   - `original_project_id` maintains referential integrity
   - `archived_at` timestamp documents when archiving occurred
5. **Optimal schedule**:
   - EVERY 1 DAY balances automation with resource usage
   - 1-year cutoff matches business policy for active project lifecycle
   - Runs in off-peak hours if configured

**Verification Steps:**
- Check event status: `SHOW EVENTS`
- View archived projects: `SELECT * FROM archived_projects`  
- Verify scheduler enabled: `SHOW VARIABLES LIKE 'event_scheduler'`

**Key Learning**: Events automate routine maintenance tasks—combine INSERT/DELETE operations in transactions for data safety.

---

## Implementation Standards

### Code Quality
- All SQL is clean, properly formatted and commented  
- Consistent naming conventions (e.g., `trg_`, `sp_`, `v_` prefixes)  
- Each module includes EXPLAIN analyses where applicable  
- Error handling implemented for all enterprise operations  

### Performance Considerations
- Indexes optimized for query patterns, not just raw column selection  
- Views use appropriate JOIN types (INNER vs LEFT)  
- Aggregate functions use GROUP BY correctly  
- Triggers use efficient filtering to minimize overhead  

### Data Integrity
- Foreign key constraints enforced  
- Transaction management ensures atomicity  
- Triggers validate business rules before allowing inserts  
- Audit trails maintain compliance and accountability  

---

## Submission Requirements Met

This repository includes:

- **01_indexes.sql** - Simple and composite indexes with EXPLAIN analyses  
- **02_subqueries.sql** - Multi-level subqueries and advanced JOINs  
- **03_views.sql** - Security-focused and financial views  
- **04_procedures.sql** - Worker management and project assignment procedures  
- **05_triggers.sql** - Audit logging and certification validation  
- **06_events.sql** - Automated project archiving (scheduled task)  
- **README.md files** - Complete justifications for all challenge tasks  
- **This master README** - Project overview and integrated documentation  

---

## Using This Project

### Prerequisites
- MySQL 5.7+ or MariaDB 10.2+
- The big3_construction database from the Design Activity
- DataGrip, MySQL Workbench or similar database tool

### Execution
1. Execute each module's SQL file in order (01 through 06)
2. All objects are idempotent—safe to re-run multiple times
3. Views can be tested immediately after creation
4. Procedures are tested with provided CALL examples
5. Events run automatically after creation; verify with `SHOW EVENTS`

### Testing
- Each module README includes testing strategies
- Use provided test scenarios to validate functionality
- Check SHOW TRIGGERS, SHOW PROCEDURES, SHOW EVENTS for object verification

---

## Key Concepts Reinforced

| Module | Key Concept | Impact |
|--------|------------|--------|
| 1 | Index column ordering matches query patterns | 10-100x query speedup |
| 2 | Nested queries handle complex multi-step logic | Cleaner, more maintainable queries |
| 3 | Views abstract complexity and enhance security | Easier access, fewer bugs |
| 4 | Procedures encapsulate business logic | Reusable, testable, maintainable |
| 5 | Triggers enforce rules automatically | Consistent data quality |
| 6 | Events schedule recurring tasks | Zero manual maintenance |

---

## Team Contribution Statement

This project represents collaborative work on advanced SQL concepts. Each team member contributed to different modules:

**Module 1 (Indexes):** Mika Rurangwa  
- Analyzed query patterns and designed composite index strategy

**Module 2 (Subqueries & Joins):** Mika Rurangwa
- Implemented nested subqueries for "max of count" problem

**Module 3 (Views):** Kenneth Chirchir 
- Created security-focused views for role-based access

**Module 4 (Procedures):** Kenneth Chirchir   
- Implemented worker and project assignment procedures

**Module 5 (Triggers):** Elise Julio Hakizimana 
- Built audit logging and validation triggers

**Module 6 (Events):** Cletus Abugre  
- Implemented automated archiving event with transaction safety

---

## Resources & Tools

**Recommended Tools:**
- DataGrip (excellent for database management)
- MySQL Workbench (free alternative)

---
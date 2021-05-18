CREATE & SET DATABASE - CREATE & ALTER TABLE - SHOW CREATE


These CREATE & SET DATABASE commands

```
CREATE DATABASE crdb_uni;
SET database = crdb_uni;
```

are fast:

```
Time: 10ms total (execution 10ms / network 0ms)

Time: 20ms total (execution 19ms / network 0ms)
```


Notice the command prompt show typically show the new database 

```
root@localhost:26257/crdb_uni>
```

Next lets add a `students` table and review DDL 


```
CREATE TABLE students (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name STRING);
SHOW CREATE students;


Time: 16ms total (execution 16ms / network 0ms)

root@localhost:26257/crdb_uni> SHOW CREATE students;
  table_name |                create_statement
-------------+--------------------------------------------------
  students   | CREATE TABLE public.students (
             |     id UUID NOT NULL DEFAULT gen_random_uuid(),
             |     name STRING NULL,
             |     CONSTRAINT "primary" PRIMARY KEY (id ASC),
             |     FAMILY "primary" (id, name)
             | )
(1 row)

Time: 37ms total (execution 36ms / network 0ms)
```

and a `courses` table:

```
CREATE TABLE courses (sys_id UUID DEFAULT gen_random_uuid(), course_id INT, name STRING, PRIMARY KEY (sys_id, course_id));
SHOW CREATE TABLE courses;


CREATE TABLE

Time: 8ms total (execution 8ms / network 0ms)

  table_name |                         create_statement
-------------+--------------------------------------------------------------------
  courses    | CREATE TABLE public.courses (
             |     sys_id UUID NOT NULL DEFAULT gen_random_uuid(),
             |     course_id INT8 NOT NULL,
             |     name STRING NULL,
             |     CONSTRAINT "primary" PRIMARY KEY (sys_id ASC, course_id ASC),
             |     FAMILY "primary" (sys_id, course_id, name)
             | )
(1 row)

Time: 23ms total (execution 23ms / network 0ms)
```


and finally an example of the alter command

```
ALTER TABLE courses ADD COLUMN schedule STRING;
SHOW CREATE TABLE courses;


ALTER TABLE

Time: 119ms total (execution 16ms / network 104ms)

  table_name |                         create_statement
-------------+--------------------------------------------------------------------
  courses    | CREATE TABLE public.courses (
             |     sys_id UUID NOT NULL DEFAULT gen_random_uuid(),
             |     course_id INT8 NOT NULL,
             |     name STRING NULL,
             |     schedule STRING NULL,
             |     CONSTRAINT "primary" PRIMARY KEY (sys_id ASC, course_id ASC),
             |     FAMILY "primary" (sys_id, course_id, name, schedule)
             | )
(1 row)

Time: 10ms total (execution 10ms / network 0ms)
```



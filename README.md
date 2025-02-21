## Requirements

1. You'll need docker desktop
2. You'll need vscode with the docker extension

## Replication Steps

the following will build the two containers

```
docker-compose up -d
```

### Postgres setup

Make tables and load data

```
docker exec -it postgres_db psql -U dbt_user -d dbt_db -f /tmp/make_tables.sql
docker exec -it postgres_db psql -U dbt_user -d dbt_db -f /tmp/load_data.sql
```

access the container

```
docker exec -it postgres_db psql -U dbt_user -d dbt_db
```

list the tables

```
\dt
```

Use \q to quit

### dbt container setup

now we need to access the dbt container

```
docker exec -it dbt_container bash
```

now we need to cd into our project-- novellia

```
cd novellia
```

now run the dbt setup steps

```
dbt init
```

```yml
novellia:
  outputs:
    dev:
      type: postgres
      host: postgres_db
      user: dbt_user
      password: dbt_password
      port: 5432
      dbname: dbt_db
      schema: public
      threads: 4
  target: dev
```

run dbt debug and all checks should pass

### Accessing Query terminal

Open your browser.
Navigate to:
http://localhost:5050
Log in with:
Email: admin@admin.com
Password: admin

Set up the connection:

In pgAdmin, go to the "Servers" section.
Right-click "Servers" → "Create" → "Server".
In the General tab:
Set Name to Postgres DB (or any name you prefer).
In the Connection tab:
Host name/address: postgres_db (since both containers are in the same db_network)
Port: 5432
Maintenance Database: dbt_db
Username: dbt_user
Password: dbt_password
Click "Save".

### answering Questions

3. Write queries to answer

- How many patients had the influenza vaccine?

```
select * from fct__vaccine_count
where vc_name ilike '%nfluenza%'
```

- What are the top 5 most common vaccines?

```
with ranked as (
    select *,
           rank() over (order by vc_count desc) as num
    from fct__vaccine_count
)
select vc_count,vc_name, num
from ranked
where num <= 5
```

- Calculate the average number of vital signs measured per patient.

```
with base as (
select
*
from stg__observation
where category = 'vital-signs'
),
vitals_count as (
select count(observation_id) as cnt,
patient_id
from base
group by patient_id
)
select avg(cnt) from vitals_count

```

- Find the most recent report with a recorded cholesterol lab result for each patient.

```
select
patient_id,
max(effective_date_time) as  most_recent_chol_reading --the docs say I should use this timestamp over the other
from stg__observation
where category = 'laboratory'
and lab_test_name like '%holesterol%'
group by 1
```

- Share two interesting facts about a specific patient.
  id =
  a4a401d1-a46a-eb4a-8a38-760d5d79d6ec
  is the only divorced patient in my 13 patient sample and his mothers maiden name is Lakin and although he lives in kansas has never smoked cigarettes

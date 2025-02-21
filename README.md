## TLDR

My basic approach to this was to make a complete dbt dev enviornment that anyone can deploy and test out while demonstrating my abilities in sql/dbt modelling. There were LOTs of landmines in this. From dealing with crazy escape characters in loading patient's data and the connected URL's, to looping through each of the columns to deal with variable length and depth arrays, to extracting and transfroming all the objects. This was not easy.

At some points I just gave up on trying to make this flexible for all future use cases and statically typed values. The biggest one is after I got to staging, I wanted to automagically print each single value array as a string, but that caused all sorts of problems so I gave up.

If I had to model out [every FHIR resource](https://www.hl7.org/fhir/resourcelist.html) maintaining the keys of these arrays would be a maintinence nightmare, so my inclination would be to try to implement loops to handle for changing keys, even if it's less performant.

For modelling structure I opted to using what is really a 5 part modelling structure because of how complex HL7 FHIR is. I generally view the 6 (including untransformed raw data) layers as follows:

raw -- completely untransformed arrived from source
base-- raw data with least amount of transforms required to be brought into stg
base_int -- any helper tables or other models needed to get the staging layer right
stg-- a complete base dataset with every column in the right naming convention, timezone, datatype. columns in this layer should be ready to go on your path to value added marts. There should be no changes or business logic added to the data itself, but the completed staging table should be the starting point for all business logic related transforms that is traditionally done in dbt
int-- whatever you have to do to arrive at value added marts. crunch that data here.
marts (fct/dim) -- models that are ready for consumption for analysis. Final aggregations, unions/joins of ints, etc

What this doesn't have, but any final dbt product should--

- tests
- yml files for each model with docs
- a real pipeline to bring in each data source, ideally with contracts with source for things that will break what you have downstream

What I didn't figure out

- the data load issue in patients.....sometimes it magically works and sometimes it just refuses to accept the ndjson data although I have checked like 3 different online json validators.

## Requirements

1. You'll need docker desktop
2. You'll need vscode with the docker extension

## Replication Steps

the following will build the two containers

```
docker-compose up -d
```

## Postgres setup

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

## dbt container setup

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
dbt deps
dbt run

## Accessing Query terminal

Open your browser.
Navigate to:
http://localhost:5050
Log in with:
Email: admin@admin.com
Password: admin

Set up the connection:

Click "add new server" in the shortcuts
In the General tab:
Set Name to Postgres DB (or any name you prefer).
In the Connection tab:
Host name/address: postgres_db (since both containers are in the same db_network)
Port: 5432
Maintenance Database: dbt_db
Username: dbt_user
Password: dbt_password
Click "Save".

servers > postgres db > databases > dbt_db > schemas > public
right click views
click query tool

### answering Questions

3. Write queries to answer

- How many patients had the influenza vaccine?

```
select * from fct__vaccine_count
where vc_name ilike '%nfluenza%'
```

All 13

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

there's actually 7 because there's ties in the rank -- flu, tetanus, covid 30 and 100 mcg/ml, meningococcal, hpv, tdap

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

180.53

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

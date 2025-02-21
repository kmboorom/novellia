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

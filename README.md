## Requirements

1. You'll need docker desktop
2. You'll need vscode with the docker extension

## Replication Steps

the following will build the two containers

```
docker-compose up -d
```

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
1
5432
dbt_user
dbt_password
dbt_db
prod
4
```

run dbt debug and all checks should pass

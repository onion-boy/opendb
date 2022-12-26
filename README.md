# BuildingDB
An open-source database

### Postgres Database
- Make a .env file in the root and fill in the `DATABASE_URL` variable with your postgres connection URI
- Use `migration.sql` to create a database called `buildingDB` with the schemas/tables the API expects.
    + If you want to copy the database you can run (or similar for windows)
        ```bash
        psql -h localhost -U USERNAME -a -f migration.sql
        ```
    + The script assumes that you *already* have a user in your Postgres Database named `buildingDB` with superuser privileges. If you would like to change that you can always edit the `migration.sql` file with your own username/privileges.
    + PgAdmin generates the script so it may not be perfect; please report any issues.
- The API should work correctly without any other configuration steps
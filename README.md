# OpenDB
An open-source database

### Postgres Database
- Make a .env file in the root and fill in the `DATABASE_URL` variable with your postgres connection URI
- Use `migration.sql` to create a database called `openDB` with the schemas/tables the API expects.
    + If you want to copy the database you can run (or similar for windows)
        ```bash
        psql -h HOSTNAME -U USERNAME -a -f migration.sql -v ON_ERROR_STOP=1
        ```
    + Do not run the script as a user named `openDB`
    + The script assumes that you *already* have a user in your Postgres Database named `openDB`. If you would like to change that you can always edit the `migration.sql` file with your own username/privileges.
    + Make sure you do not have a database already called `openDB`, as the script runs both a `DROP IF EXISTS` and `CREATE` query.
- The API should work correctly without any other configuration steps
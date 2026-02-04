In DBeaver you can tell every SQLite session to run PRAGMA foreign_keys = ON as soon as the connection is opened:

In the Database Navigator, right‑click your SQLite connection and choose Edit Connection.
Go to the Initialization (or Connection initialization) tab.
Under SQL scripts to execute on connect, add a new entry and type:
sql 
```sql 
PRAGMA foreign_keys = ON;
```
Apply/OK, then reconnect.
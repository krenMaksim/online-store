import os
import sqlite3

def main() -> None:
    base_dir = os.path.dirname(__file__)
    sql_path = os.path.join(base_dir, "store.sql")
    db_path = os.path.join(base_dir, "store.db")

    with open(sql_path, "r", encoding="utf-8") as f:
        sql = f.read()

    conn = sqlite3.connect(db_path)
    try:
        conn.executescript(sql)
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM customers")
        customers = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) FROM orders")
        orders = cur.fetchone()[0]
        print(f"customers={customers}, orders={orders}")
    finally:
        conn.commit()
        conn.close()

if __name__ == "__main__":
    main()

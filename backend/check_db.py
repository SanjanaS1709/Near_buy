import sqlite3

def check():
    conn = sqlite3.connect('nearbuy.db')
    cursor = conn.cursor()
    cursor.execute("SELECT id, email, role FROM users WHERE email='sanju@gmail.com'")
    print(cursor.fetchone())
    conn.close()

if __name__ == "__main__":
    check()

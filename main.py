import os
from lxml import etree

XML_DIR = "data"  # folder with XMLs
NS = {"txc": "http://www.transxchange.org.uk/"}

import os
import psycopg2

# Read connection info from environment variables
host = os.getenv("POSTGRES_HOST", "localhost")
port = int(os.getenv("POSTGRES_PORT", 5432))
db = os.getenv("POSTGRES_DB", "txc_db")
user = os.getenv("POSTGRES_USER", "txc_user")
password = os.getenv("POSTGRES_PASSWORD", "txc_pass")


def load_xmls(xml_dir):
    for filename in os.listdir(xml_dir):
        if filename.endswith(".xml"):
            with open(os.path.join(xml_dir, filename), "rb") as f:
                yield f.read()


def main():
    try:
        conn = psycopg2.connect(
            host=host,
            port=port,
            database=db,
            user=user,
            password=password
        )
        cur = conn.cursor()
        cur.execute("SELECT 1;")
        result = cur.fetchone()
        print(f"Database test query result: {result[0]}")
        cur.close()
        conn.close()
    except Exception as e:
        print(f"Error connecting to database: {e}")

    for xml_bytes in load_xmls(XML_DIR):
        root = etree.fromstring(xml_bytes)
        # services = root.xpath("//txc:Service", namespaces=NS)
        # print(f"Found {len(services)} services in {xml_bytes[:30]}...")
        print(root)


if __name__ == "__main__":
    main()

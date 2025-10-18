# Donor Registry – Database (Sprint 1)

This folder contains the **relational schema** and **seed data** for the Donor Registry project.

## Quick start (local)

```bash
cd db
cp .env.example .env
docker compose up -d



# macOS/Linux (Docker Desktop includes mysql client if you have it locally)
mysql -h 127.0.0.1 -P 3306 -uroot -p${MYSQL_ROOT_PASSWORD} < schema.sql
mysql -h 127.0.0.1 -P 3306 -uroot -p${MYSQL_ROOT_PASSWORD} < seed.sql



USE donor_registry;
SHOW TABLES;
SELECT * FROM organ_types;
SELECT * FROM donations;


Suggested resource paths to align with your OpenAPI:
GET /donors, POST /donors, GET /donors/{id}, PUT /donors/{id}, DELETE /donors/{id}
GET /recipients, POST /recipients
GET /donations, POST /donations
GET /matches, POST /matches
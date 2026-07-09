from pathlib import Path
import duckdb

SOURCE_DB = r"Z:\Bundesliga_23_24\Bundesliga_2023_2024.duckdb"
TARGET_DB = "demo_bundesliga.duckdb"

MATCH_ID = "DFL-MAT-J03YLO"

# Neue kleine DB öffnen
dst = duckdb.connect(TARGET_DB)

# Große DB anhängen
dst.execute(f"""
ATTACH DATABASE '{SOURCE_DB}' AS src;
""")

print("Kopiere match_information...")
dst.execute(f"""
CREATE TABLE match_information AS
SELECT *
FROM src.match_information
WHERE match_id = '{MATCH_ID}'
""")

print("Kopiere tracking_raw_observed...")
dst.execute(f"""
CREATE TABLE tracking_raw_observed AS
SELECT *
FROM src.tracking_raw_observed
WHERE match_id = '{MATCH_ID}'
""")

print("Kopiere teams...")
dst.execute(f"""
CREATE TABLE teams AS
SELECT DISTINCT t.*
FROM src.teams t
JOIN src.tracking_raw_observed tr
ON t.id = tr.team_id
WHERE tr.match_id = '{MATCH_ID}'
""")

print("Kopiere players...")
dst.execute(f"""
CREATE TABLE players AS
SELECT DISTINCT p.*
FROM src.players p
JOIN src.tracking_raw_observed tr
ON p.id = tr.player_id
WHERE tr.match_id = '{MATCH_ID}'
""")

print("Fertig.")
print("Neue DB:", TARGET_DB)

dst.close()
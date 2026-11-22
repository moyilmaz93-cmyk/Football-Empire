#!/usr/bin/env python3
"""Convert OpenFootballBase Parquet releases to compact Turkish squad JSON."""
from __future__ import annotations
import argparse
import json
from pathlib import Path
from urllib.parse import quote
import duckdb

DEFAULT_SEASONS = ("2024/25", "2025/26", "2026/27")

def find_one(root: Path, pattern: str) -> Path:
    matches = sorted(root.rglob(pattern))
    if not matches:
        raise FileNotFoundError(f"Required Parquet file not found: {pattern}")
    return matches[0]

def source_url(language: str, title: str, revision: int) -> str:
    lang = language.strip() or "en"
    safe_title = quote(title.replace(" ", "_"), safe="")
    return f"https://{lang}.wikipedia.org/w/index.php?title={safe_title}&oldid={revision}"

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--seasons", nargs="*", default=list(DEFAULT_SEASONS))
    args = parser.parse_args()

    root = Path(args.input).resolve()
    manifest_path = find_one(root, "manifest.json")
    data_root = manifest_path.parent
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

    squad_files = []
    for season in args.seasons:
        squad_files.extend(sorted((data_root / "squad").glob(f"{season.replace('/', '-') }.*.parquet")))
    if not squad_files:
        raise FileNotFoundError("No squad Parquet files found for requested seasons")

    club_file = find_one(data_root, "club.*.parquet")
    profile_file = find_one(data_root, "player_profile.*.parquet")
    birth_file = find_one(data_root, "birth.*.parquet")
    con = duckdb.connect(":memory:")
    query = """
        SELECT s.season, s.competition, s.club,
            COALESCE(NULLIF(c.name_local, ''), NULLIF(c.name_en, ''), s.club) AS club_name,
            COALESCE(c.wikidata_qid, '') AS club_qid,
            COALESCE(c.city, '') AS club_city,
            COALESCE(c.stadium, '') AS club_stadium,
            COALESCE(c.colors_hex, '') AS club_colors,
            COALESCE(s.player, '') AS player,
            COALESCE(s.player_qid, '') AS player_qid,
            s.shirt_number, COALESCE(s.position, '') AS position,
            COALESCE(s.nationality, '') AS nationality,
            COALESCE(s.stint, 'unknown') AS stint,
            COALESCE(s.confidence, '') AS confidence,
            COALESCE(s.source_lang, '') AS source_lang,
            COALESCE(s.source_title, '') AS source_title,
            COALESCE(s.source_revid, 0) AS source_revid,
            COALESCE(b.birth_date, '') AS birth_date,
            COALESCE(b.precision, 0) AS birth_precision,
            COALESCE(p.birth_place, '') AS birth_place,
            COALESCE(p.height_cm, 0) AS height_cm
        FROM read_parquet(?) AS s
        LEFT JOIN read_parquet(?) AS c ON c.wikipedia_title = s.club
        LEFT JOIN read_parquet(?) AS p ON p.player_qid = s.player_qid
        LEFT JOIN read_parquet(?) AS b ON b.player_qid = s.player_qid
        WHERE s.competition IN ('TUR-SL', 'TUR-L1')
        ORDER BY s.season, s.competition, club_name, s.shirt_number NULLS LAST, player
    """
    rows = con.execute(query, [list(map(str, squad_files)), str(club_file), str(profile_file), str(birth_file)]).fetchall()
    columns = [column[0] for column in con.description]
    records = []
    for values in rows:
        row = dict(zip(columns, values))
        revision = int(row.get("source_revid") or 0)
        row["source_revid"] = revision
        row["source_url"] = source_url(str(row.get("source_lang") or "en"), str(row.get("source_title") or ""), revision) if revision and row.get("source_title") else ""
        for key, value in list(row.items()):
            if value is None:
                row[key] = None
            elif hasattr(value, "isoformat"):
                row[key] = value.isoformat()
            elif key in ("shirt_number", "birth_precision", "height_cm"):
                row[key] = int(value)
        records.append(row)

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "schema_version": 1,
        "data_release": manifest.get("generated_at", ""),
        "source_repository": "https://github.com/florentfougeres/OpenFootballBase-Data",
        "data_license": "CC BY-SA 4.0",
        "attribution": {
            "text": "Squad data derived from Wikipedia (CC BY-SA 4.0); club and birth metadata from Wikidata (CC0).",
            "source_note": "Each squad record retains source_lang, source_title, source_revid and source_url.",
            "share_alike": "Redistributed adaptations of the squad database must remain available under CC BY-SA 4.0."
        },
        "coverage_note": "Only source records actually present in the release are included. Missing club squads are not reconstructed.",
        "records": records
    }
    output.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"Wrote {len(records)} squad entries to {output}")

if __name__ == "__main__":
    main()

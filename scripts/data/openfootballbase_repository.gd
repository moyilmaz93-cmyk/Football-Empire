extends Node
class_name OpenFootballBaseRepository

signal squads_loaded(entries: Array[SquadEntry], season: String, competition: String)
signal load_failed(message: String)

const DATA_PATH := "res://data/openfootballbase/turkey_squads.json"
const DATA_LICENSE := "CC BY-SA 4.0"

var last_attribution: Dictionary = {}

func load_turkey_squads(season: String, competition: String = "TUR-SL") -> void:
	if season.is_empty() or competition.is_empty():
		load_failed.emit("Sezon ve lig kodu belirtilmeli.")
		return
	if not FileAccess.file_exists(DATA_PATH):
		load_failed.emit("Türkiye kadro veri dosyası henüz projeye aktarılmadı. GitHub Actions bölümünden Refresh open football data iş akışını çalıştırın.")
		return

	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		load_failed.emit("Kadro veri dosyası açılamadı.")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		load_failed.emit("Kadro veri dosyası geçerli JSON değil.")
		return

	var records: Variant = parsed.get("records", [])
	if not (records is Array):
		load_failed.emit("Kadro veri dosyasında records listesi bulunamadı.")
		return

	var entries: Array[SquadEntry] = []
	for raw_record in records:
		if not (raw_record is Dictionary):
			continue
		if str(raw_record.get("season", "")) != season:
			continue
		if str(raw_record.get("competition", "")) != competition:
			continue
		entries.append(SquadEntry.from_dictionary(raw_record))

	if entries.is_empty():
		load_failed.emit("Bu sezon ve lig için kaynakta kadro kaydı bulunamadı. Eksik kadro uydurulmadı.")
		return

	last_attribution = parsed.get("attribution", {}).duplicate(true)
	squads_loaded.emit(entries, season, competition)

func get_last_attribution() -> Dictionary:
	return last_attribution.duplicate(true)

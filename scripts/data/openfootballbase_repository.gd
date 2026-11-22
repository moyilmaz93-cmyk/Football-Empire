extends Node
class_name OpenFootballBaseRepository

signal squads_loaded(entries: Array[SquadEntry], season: String, competition: String)
signal load_failed(message: String)

const TURKEY_DATA_PATH := "res://data/openfootballbase/turkey_squads.json"
const DATA_LICENSE := "CC BY-SA 4.0"

var last_attribution: Dictionary = {}
var last_dataset_path: String = ""

# Generic loader: new countries/leagues can use their own JSON file without
# changing the game code. Dataset records share the same schema.
func load_squads(dataset_path: String, season: String, competition: String) -> void:
	if dataset_path.is_empty() or season.is_empty() or competition.is_empty():
		load_failed.emit("Veri dosyası, sezon ve lig kodu belirtilmeli.")
		return
	if not FileAccess.file_exists(dataset_path):
		load_failed.emit("Seçilen lig için kadro veri dosyası bulunamadı: " + dataset_path)
		return

	var file := FileAccess.open(dataset_path, FileAccess.READ)
	if file == null:
		load_failed.emit("Kadro veri dosyası açılamadı: " + dataset_path)
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

	last_dataset_path = dataset_path
	last_attribution = parsed.get("attribution", {}).duplicate(true)
	squads_loaded.emit(entries, season, competition)

# Backward-compatible helper for the currently imported Turkish dataset.
func load_turkey_squads(season: String, competition: String = "TUR-SL") -> void:
	load_squads(TURKEY_DATA_PATH, season, competition)

func get_last_attribution() -> Dictionary:
	return last_attribution.duplicate(true)

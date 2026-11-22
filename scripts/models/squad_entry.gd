extends RefCounted
class_name SquadEntry

var season: String = ""
var competition: String = ""
var club_id: String = ""
var club_name: String = ""
var club_city: String = ""
var club_stadium: String = ""
var club_colors: String = ""
var player_id: String = ""
var player_qid: String = ""
var player_name: String = ""
var shirt_number: int = -1
var position: String = ""
var nationality: String = ""
var stint: String = "unknown"
var confidence: String = ""
var source_language: String = ""
var source_title: String = ""
var source_revision: int = 0
var source_url: String = ""
var birth_date: String = ""
var birth_precision: int = 0
var birth_place: String = ""
var height_cm: int = 0

static func from_dictionary(data: Dictionary) -> SquadEntry:
	var entry := SquadEntry.new()
	entry.season = str(data.get("season", ""))
	entry.competition = str(data.get("competition", ""))
	entry.club_id = str(data.get("club_qid", ""))
	entry.club_name = str(data.get("club_name", data.get("club", "")))
	entry.club_city = str(data.get("club_city", ""))
	entry.club_stadium = str(data.get("club_stadium", ""))
	entry.club_colors = str(data.get("club_colors", ""))
	entry.player_qid = str(data.get("player_qid", ""))
	entry.player_name = str(data.get("player", ""))
	entry.player_id = entry.player_qid if not entry.player_qid.is_empty() else "name:" + entry.player_name
	entry.shirt_number = int(data.get("shirt_number", -1)) if data.get("shirt_number", null) != null else -1
	entry.position = str(data.get("position", ""))
	entry.nationality = str(data.get("nationality", ""))
	entry.stint = str(data.get("stint", "unknown"))
	entry.confidence = str(data.get("confidence", ""))
	entry.source_language = str(data.get("source_lang", ""))
	entry.source_title = str(data.get("source_title", ""))
	entry.source_revision = int(data.get("source_revid", 0))
	entry.source_url = str(data.get("source_url", ""))
	entry.birth_date = str(data.get("birth_date", ""))
	entry.birth_precision = int(data.get("birth_precision", 0))
	entry.birth_place = str(data.get("birth_place", ""))
	entry.height_cm = int(data.get("height_cm", 0))
	return entry

func to_player_data() -> PlayerData:
	var player := PlayerData.new()
	player.id = player_id
	player.name = player_name
	player.position = position
	player.club_id = club_id
	player.nationality = nationality
	player.birth_date = birth_date if birth_precision == 11 else ""
	player.birth_place = birth_place
	player.height_m = float(height_cm) / 100.0 if height_cm > 0 else 0.0
	return player

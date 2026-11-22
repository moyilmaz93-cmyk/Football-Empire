extends RefCounted
class_name PlayerData

var id: String = ""
var name: String = ""
var position: String = "UNK"
var shirt_number: int = -1
var source_positions: Array[String] = []
var club_id: String = ""
var nationality: String = ""
var birth_date: String = ""
var birth_place: String = ""
var height_m: float = 0.0
var attributes: Dictionary = {}

static func from_dictionary(data: Dictionary) -> PlayerData:
	var player := PlayerData.new()
	player.id = str(data.get("id", ""))
	player.name = str(data.get("name", "Bilinmeyen oyuncu"))
	player.position = str(data.get("position", "UNK"))
	player.shirt_number = int(data.get("shirt_number", -1))
	player.club_id = str(data.get("club_id", ""))
	player.nationality = str(data.get("nationality", ""))
	player.birth_date = str(data.get("birth_date", ""))
	player.birth_place = str(data.get("birth_place", ""))
	player.height_m = float(data.get("height_m", 0.0))
	player.attributes = data.get("attributes", {}).duplicate(true)
	for source_position in data.get("source_positions", []):
		player.source_positions.append(str(source_position))
	return player

func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"position": position,
		"shirt_number": shirt_number,
		"source_positions": source_positions.duplicate(),
		"club_id": club_id,
		"nationality": nationality,
		"birth_date": birth_date,
		"birth_place": birth_place,
		"height_m": height_m,
		"attributes": attributes.duplicate(true)
	}

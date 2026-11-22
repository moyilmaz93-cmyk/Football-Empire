extends RefCounted
class_name PlayerData

var id: String = ""
var name: String = ""
var position: String = "UNK"
var club_id: String = ""
var birth_date: String = ""
var height_m: float = 0.0
var attributes: Dictionary = {}

static func from_dictionary(data: Dictionary) -> PlayerData:
	var player := PlayerData.new()
	player.id = str(data.get("id", ""))
	player.name = str(data.get("name", "Bilinmeyen oyuncu"))
	player.position = str(data.get("position", "UNK"))
	player.club_id = str(data.get("club_id", ""))
	player.birth_date = str(data.get("birth_date", ""))
	player.height_m = float(data.get("height_m", 0.0))
	player.attributes = data.get("attributes", {}).duplicate(true)
	return player

func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"position": position,
		"club_id": club_id,
		"birth_date": birth_date,
		"height_m": height_m,
		"attributes": attributes.duplicate(true)
	}

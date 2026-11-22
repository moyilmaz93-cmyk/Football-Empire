extends RefCounted
class_name ClubData

var id: String = ""
var name: String = ""
var country: String = ""
var city: String = ""
var league_id: String = ""
var primary_color: Color = Color.WHITE
var secondary_color: Color = Color.BLACK
var player_ids: Array[String] = []

static func from_dictionary(data: Dictionary) -> ClubData:
	var club := ClubData.new()
	club.id = str(data.get("id", ""))
	club.name = str(data.get("name", "Bilinmeyen kulüp"))
	club.country = str(data.get("country", ""))
	club.city = str(data.get("city", ""))
	club.league_id = str(data.get("league_id", ""))
	club.primary_color = Color.from_string(str(data.get("primary_color", "#ffffff")), Color.WHITE)
	club.secondary_color = Color.from_string(str(data.get("secondary_color", "#202020")), Color.BLACK)
	for player_id in data.get("player_ids", []):
		club.player_ids.append(str(player_id))
	return club

func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"country": country,
		"city": city,
		"league_id": league_id,
		"primary_color": primary_color.to_html(false),
		"secondary_color": secondary_color.to_html(false),
		"player_ids": player_ids.duplicate()
	}

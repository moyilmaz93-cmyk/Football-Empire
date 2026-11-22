extends RefCounted
class_name FootballDataCatalog

# Converts raw season squad entries into reusable club/player objects.
# The same catalog works for any country or competition using this schema.
static func build_clubs(entries: Array[SquadEntry], country: String, league_id: String) -> Array[ClubData]:
	var by_club: Dictionary = {}
	for entry in entries:
		var club_key := entry.club_id if not entry.club_id.is_empty() else entry.club_name.strip_edges().to_lower()
		if club_key.is_empty():
			continue
		if not by_club.has(club_key):
			var club := ClubData.new()
			club.id = club_key
			club.name = entry.club_name
			club.country = country
			club.city = entry.club_city
			club.league_id = league_id
			by_club[club_key] = club
		var current: ClubData = by_club[club_key]
		if not entry.player_id.is_empty() and not current.player_ids.has(entry.player_id):
			current.player_ids.append(entry.player_id)
	var clubs: Array[ClubData] = []
	for value in by_club.values():
		clubs.append(value)
	clubs.sort_custom(func(a: ClubData, b: ClubData) -> bool: return a.name.naturalcasecmp_to(b.name) < 0)
	return clubs

static func build_players(entries: Array[SquadEntry]) -> Array[PlayerData]:
	var by_player: Dictionary = {}
	for entry in entries:
		if entry.player_id.is_empty() or entry.player_name.is_empty():
			continue
		if not by_player.has(entry.player_id):
			by_player[entry.player_id] = entry.to_player_data()
	var players: Array[PlayerData] = []
	for value in by_player.values():
		players.append(value)
	players.sort_custom(func(a: PlayerData, b: PlayerData) -> bool: return a.name.naturalcasecmp_to(b.name) < 0)
	return players

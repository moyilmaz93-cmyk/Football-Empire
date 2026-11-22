extends SceneTree

func _initialize() -> void:
	assert(SquadEntry.normalize_position("GK") == "GK")
	assert(SquadEntry.normalize_position("DF") == "DEF")
	assert(SquadEntry.normalize_position("MF") == "MID")
	assert(SquadEntry.normalize_position("FW") == "FWD")
	assert(SquadEntry.normalize_position("?") == "UNK")

	var first := SquadEntry.from_dictionary({
		"season": "2026/27", "competition": "TUR-SL",
		"club_qid": "Q1", "club_name": "Örnek FK", "club_city": "Samsun",
		"player_qid": "Q10", "player": "Ali Örnek", "position": "FW",
		"shirt_number": 9, "nationality": "Türkiye", "birth_date": "2001-02-03",
		"birth_precision": 11, "height_cm": 181
	})
	var second := SquadEntry.from_dictionary({
		"season": "2026/27", "competition": "TUR-SL",
		"club_qid": "Q1", "club_name": "Örnek FK",
		"player_qid": "Q11", "player": "Veli Örnek", "position": "GK"
	})
	var entries: Array[SquadEntry] = [first, second]
	var clubs := FootballDataCatalog.build_clubs(entries, "Türkiye", "TUR-SL")
	var players := FootballDataCatalog.build_players(entries)

	assert(clubs.size() == 1)
	assert(clubs[0].player_ids.size() == 2)
	assert(players.size() == 2)
	assert(players[0].position in ["FWD", "GK"])
	assert(first.to_player_data().position == "FWD")
	assert(first.to_player_data().shirt_number == 9)
	assert(is_equal_approx(first.to_player_data().height_m, 1.81))

	print("Football data catalog tests: PASS")
	quit(0)

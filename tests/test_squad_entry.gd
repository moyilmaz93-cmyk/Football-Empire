extends SceneTree

func _initialize() -> void:
	var entry := SquadEntry.from_dictionary({
		"season": "2024/25",
		"competition": "TUR-SL",
		"club_qid": "Q123",
		"club_name": "Test Spor Kulübü",
		"player_qid": "Q456",
		"player": "Örnek Futbolcu",
		"shirt_number": 10,
		"position": "FW",
		"nationality": "Türkiye",
		"birth_date": "2000-01-02",
		"birth_precision": 11,
		"height_cm": 180,
		"source_revid": 98765,
		"source_url": "https://tr.wikipedia.org/"
	})
	assert(entry.player_id == "Q456")
	assert(entry.club_id == "Q123")
	assert(entry.shirt_number == 10)
	assert(entry.position == "FW")
	assert(entry.source_revision == 98765)

	var player := entry.to_player_data()
	assert(player.name == "Örnek Futbolcu")
	assert(player.birth_date == "2000-01-02")
	assert(is_equal_approx(player.height_m, 1.8))

	entry.birth_precision = 9
	player = entry.to_player_data()
	assert(player.birth_date.is_empty(), "Only day-precision birth dates should be used for age calculation.")

	print("Squad entry model tests: PASS")
	quit(0)

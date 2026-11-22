extends SceneTree

const PlayerRepository = preload("res://scripts/data/openfootball_player_repository.gd")

func _initialize() -> void:
	var sample := """= Turkey
Emir Dadük,                   G,  1.91 m,  b. 13 Feb 2008 @ Hatay
Arda Ünyay,                   D,  1.84 m,  b. 18 Jan 2007 @ Ankara
Batuhan Çelik,                M|F,- ,      b. 12 Jan 2005 @ İstanbul
Oyuncu kaydı olmayan satır
"""
	var players: Array[PlayerData] = PlayerRepository.parse_players_text(sample)
	assert(players.size() == 3, "Üç geçerli oyuncu satırı ayrıştırılmalı.")
	assert(players[0].name == "Emir Dadük", "Oyuncu adı doğru okunmalı.")
	assert(players[0].position == "GK", "Kaleci pozisyonu GK olmalı.")
	assert(is_equal_approx(players[0].height_m, 1.91), "Boy bilgisi 1.91 m olmalı.")
	assert(players[1].position == "DEF", "Defans pozisyonu DEF olmalı.")
	assert(players[2].source_positions.size() == 2, "Çoklu pozisyonlar korunmalı.")
	assert(players[2].position == "MID", "Birincil pozisyon MID olmalı.")
	assert(players[0].club_id.is_empty(), "Kaynak kulüp vermediği için kulüp atanmamalı.")
	print("OpenFootball player parser tests: PASS")
	quit(0)

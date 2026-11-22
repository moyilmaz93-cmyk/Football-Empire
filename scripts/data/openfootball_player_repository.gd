extends Node
class_name OpenFootballPlayerRepository

signal players_loaded(players: Array[PlayerData])
signal load_failed(message: String)

const TURKEY_PLAYERS_URL := "https://raw.githubusercontent.com/openfootball/players/master/europe/turkey/tr.players.txt"
const SOURCE_NAME := "openfootball/players"
const SOURCE_LICENSE := "CC0-1.0"

var http: HTTPRequest
var request_in_progress: bool = false

func _ready() -> void:
	http = HTTPRequest.new()
	http.timeout = 30.0
	add_child(http)
	http.request_completed.connect(_on_request_completed)

func load_turkey_players() -> void:
	if request_in_progress:
		load_failed.emit("Başka bir oyuncu verisi isteği devam ediyor.")
		return
	request_in_progress = true
	var error := http.request(TURKEY_PLAYERS_URL)
	if error != OK:
		request_in_progress = false
		load_failed.emit("Oyuncu verisi isteği başlatılamadı. Hata: %s" % error)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	request_in_progress = false
	if result != HTTPRequest.RESULT_SUCCESS:
		load_failed.emit("Oyuncu verisi kaynağına ulaşılamadı.")
		return
	if response_code != 200:
		load_failed.emit("Oyuncu verisi bulunamadı. HTTP: %s" % response_code)
		return
	var players := parse_players_text(body.get_string_from_utf8())
	if players.is_empty():
		load_failed.emit("Kaynak açıldı ancak tanınan oyuncu kaydı bulunamadı.")
		return
	players_loaded.emit(players)

static func parse_players_text(source_text: String) -> Array[PlayerData]:
	var players: Array[PlayerData] = []
	var expression := RegEx.new()
	var compile_error := expression.compile("^(.+?),\\s*([GDMF](?:\\|[GDMF])?),\\s*(?:(\\d+(?:\\.\\d+)?)\\s*m|-),\\s*b\\.\\s*(\\d{1,2}\\s+[A-Za-z]{3}\\s+\\d{4})(?:\\s+@\\s*(.*))?$")
	if compile_error != OK:
		return players

	for raw_line in source_text.split("\n"):
		var line := raw_line.strip_edges()
		if line.is_empty() or line.begins_with("=") or line.begins_with("#"):
			continue
		var found := expression.search(line)
		if found == null:
			continue

		var player := PlayerData.new()
		player.name = found.get_string(1).strip_edges()
		var raw_positions := found.get_string(2).split("|", false)
		if raw_positions.is_empty():
			continue
		for raw_position in raw_positions:
			player.source_positions.append(raw_position)
		player.position = _map_position(raw_positions[0])
		var height_text := found.get_string(3)
		if not height_text.is_empty():
			player.height_m = float(height_text)
		player.birth_date = found.get_string(4)
		player.birth_place = found.get_string(5).strip_edges()
		player.nationality = "Türkiye"
		player.id = "of_tr_" + str((player.name + "|" + player.birth_date).hash())
		players.append(player)

	return players

static func _map_position(source_position: String) -> String:
	match source_position:
		"G":
			return "GK"
		"D":
			return "DEF"
		"M":
			return "MID"
		"F":
			return "FWD"
		_:
			return "UNK"

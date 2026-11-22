extends Node
class_name OpenFootballRepository

signal league_loaded(league: LeagueData)
signal load_failed(message: String)

const RAW_BASE_URL := "https://raw.githubusercontent.com/openfootball/football.json/master"

var http: HTTPRequest
var requested_season: String = ""
var requested_league_code: String = ""
var active_url: String = ""

func _ready() -> void:
	http = HTTPRequest.new()
	http.timeout = 25.0
	add_child(http)
	http.request_completed.connect(_on_request_completed)

# Example: load_league("2025-26", "tr.1") for Turkey Super Lig.
# Season and competition codes follow the openfootball/football.json repository.
func load_league(season_id: String, competition_code: String) -> void:
	if season_id.is_empty() or competition_code.is_empty():
		load_failed.emit("Sezon ve lig kodu boş olamaz.")
		return
	if http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		load_failed.emit("Başka bir veri isteği devam ediyor.")
		return

	requested_season = season_id
	requested_league_code = competition_code
	active_url = "%s/%s/%s.json" % [RAW_BASE_URL, season_id, competition_code]
	var error := http.request(active_url)
	if error != OK:
		load_failed.emit("Veri isteği başlatılamadı. Ağ bağlantısını kontrol edin. Hata: %s" % error)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		load_failed.emit("OpenFootball sunucusuna ulaşılamadı. İnternet bağlantısını kontrol edin.")
		return
	if response_code != 200:
		load_failed.emit("Kaynakta bu sezon/lig dosyası bulunamadı. HTTP: %s — %s" % [response_code, active_url])
		return

	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not parsed is Dictionary:
		load_failed.emit("Kaynak dosyası geçerli JSON değil.")
		return
	if not parsed.get("matches", null) is Array:
		load_failed.emit("JSON içinde maç listesi bulunamadı.")
		return

	var league := LeagueData.from_openfootball(parsed, requested_season, active_url)
	if league.fixtures.is_empty():
		load_failed.emit("Lig dosyası açıldı ancak maç kaydı bulunamadı.")
		return
	league_loaded.emit(league)

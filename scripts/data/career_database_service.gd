extends Node
class_name CareerDatabaseService

signal career_data_loaded(clubs: Array[ClubData], players: Array[PlayerData], season: String, competition: String)
signal career_data_failed(message: String)

const TURKEY_SQUADS_PATH := "res://data/openfootballbase/turkey_squads.json"

var squad_repository: OpenFootballBaseRepository
var active_clubs: Array[ClubData] = []
var active_players: Array[PlayerData] = []
var active_season: String = ""
var active_competition: String = ""
var active_country: String = ""
var selected_club: ClubData
var selected_players: Array[PlayerData] = []

func _ready() -> void:
	squad_repository = OpenFootballBaseRepository.new()
	add_child(squad_repository)
	squad_repository.squads_loaded.connect(_on_squads_loaded)
	squad_repository.load_failed.connect(_on_load_failed)

# Call from the career setup/club selection screen.
# Dataset path and competition are parameters, so this is not Turkey-only.
func load_career_data(dataset_path: String, season: String, competition: String, country: String) -> void:
	if country.strip_edges().is_empty():
		career_data_failed.emit("Ülke bilgisi boş olamaz.")
		return
	active_season = season
	active_competition = competition
	active_country = country
	squad_repository.load_squads(dataset_path, season, competition)

func load_turkey_super_league(season: String) -> void:
	load_career_data(TURKEY_SQUADS_PATH, season, "TUR-SL", "Türkiye")

func _on_squads_loaded(entries: Array[SquadEntry], season: String, competition: String) -> void:
	active_clubs = FootballDataCatalog.build_clubs(entries, active_country, competition)
	active_players = FootballDataCatalog.build_players(entries)
	if active_clubs.is_empty() or active_players.is_empty():
		career_data_failed.emit("Kadro verisi okundu ancak kullanılabilir kulüp veya oyuncu bulunamadı.")
		return
	career_data_loaded.emit(active_clubs, active_players, season, competition)

func _on_load_failed(message: String) -> void:
	career_data_failed.emit(message)

func get_clubs() -> Array[ClubData]:
	return active_clubs.duplicate()

func get_players() -> Array[PlayerData]:
	return active_players.duplicate()

func select_club(club: ClubData) -> void:
	selected_club = club
	selected_players.clear()
	for player in active_players:
		if player.club_id == club.id:
			selected_players.append(player)

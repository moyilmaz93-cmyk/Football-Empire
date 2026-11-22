extends Control

const MATCH_SCENE := "res://scenes/match.tscn"

var season_select: OptionButton
var league_select: OptionButton
var load_button: Button
var club_list: ItemList
var roster_list: ItemList
var status_label: Label
var start_button: Button
var clubs: Array[ClubData] = []
var players: Array[PlayerData] = []
var selected_club: ClubData

func _ready() -> void:
	_build_interface()
	CareerDatabase.career_data_loaded.connect(_on_career_data_loaded)
	CareerDatabase.career_data_failed.connect(_on_career_data_failed)

func _build_interface() -> void:
	var background := ColorRect.new()
	background.color = Color(0.035, 0.075, 0.065)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 24.0
	scroll.offset_top = 20.0
	scroll.offset_right = -24.0
	scroll.offset_bottom = -20.0
	add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

	var title := Label.new()
	title.text = "FOOTBALL EMPIRE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.93, 0.78, 0.28))
	content.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "KARİYER OLUŞTUR"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 20)
	content.add_child(subtitle)

	var selectors := HBoxContainer.new()
	selectors.add_theme_constant_override("separation", 12)
	content.add_child(selectors)

	var league_column := VBoxContainer.new()
	league_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selectors.add_child(league_column)
	_add_field_label(league_column, "LİG")
	league_select = OptionButton.new()
	league_select.add_item("Türkiye • Süper Lig", 0)
	league_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	league_column.add_child(league_select)

	var season_column := VBoxContainer.new()
	season_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selectors.add_child(season_column)
	_add_field_label(season_column, "SEZON")
	season_select = OptionButton.new()
	season_select.add_item("2026/27")
	season_select.add_item("2025/26")
	season_select.add_item("2024/25")
	season_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	season_column.add_child(season_select)

	load_button = Button.new()
	load_button.text = "KULÜPLERİ YÜKLE"
	load_button.custom_minimum_size.y = 48
	load_button.pressed.connect(_on_load_pressed)
	content.add_child(load_button)

	status_label = Label.new()
	status_label.text = "Şu anda kadro verisi bulunan ligler listelenir. Yeni ligler veri geldikçe eklenecek."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color(0.75, 0.79, 0.76))
	content.add_child(status_label)

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 12)
	content.add_child(columns)

	var club_column := VBoxContainer.new()
	club_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	club_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(club_column)
	_add_field_label(club_column, "KULÜPLER")
	club_list = ItemList.new()
	club_list.custom_minimum_size = Vector2(0, 260)
	club_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	club_list.item_selected.connect(_on_club_selected)
	club_column.add_child(club_list)

	var roster_column := VBoxContainer.new()
	roster_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(roster_column)
	_add_field_label(roster_column, "OYUNCU KADROSU")
	roster_list = ItemList.new()
	roster_list.custom_minimum_size = Vector2(0, 260)
	roster_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	roster_column.add_child(roster_list)

	start_button = Button.new()
	start_button.text = "SEÇİLEN KULÜPLE MAÇA GEÇ"
	start_button.custom_minimum_size.y = 52
	start_button.disabled = true
	start_button.pressed.connect(_on_start_match_pressed)
	content.add_child(start_button)

	var note := Label.new()
	note.text = "Not: Maç ekranı şu aşamada taktik ve maç motoru prototipidir. Seçilen gerçek kadronun maç motorundaki 11 oyuncuya aktarımı sonraki geliştirme aşamasıdır."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override("font_color", Color(0.88, 0.72, 0.38))
	content.add_child(note)

func _add_field_label(parent: Node, text_value: String) -> void:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(0.93, 0.78, 0.28))
	parent.add_child(label)

func _on_load_pressed() -> void:
	var season := season_select.get_item_text(season_select.selected)
	club_list.clear()
	roster_list.clear()
	clubs.clear()
	players.clear()
	selected_club = null
	start_button.disabled = true
	load_button.disabled = true
	status_label.text = "Kadro verisi yükleniyor..."
	CareerDatabase.load_turkey_super_league(season)

func _on_career_data_loaded(loaded_clubs: Array[ClubData], loaded_players: Array[PlayerData], season: String, competition: String) -> void:
	clubs = loaded_clubs
	players = loaded_players
	club_list.clear()
	roster_list.clear()
	selected_club = null
	start_button.disabled = true
	for club in clubs:
		club_list.add_item(club.name)
	status_label.text = "%s • %s • %d kulüp • %d oyuncu kaydı" % [season, competition, clubs.size(), players.size()]
	load_button.disabled = false

func _on_career_data_failed(message: String) -> void:
	status_label.text = "Veri yüklenemedi: " + message
	load_button.disabled = false

func _on_club_selected(index: int) -> void:
	if index < 0 or index >= clubs.size():
		return
	selected_club = clubs[index]
	roster_list.clear()
	var roster_count := 0
	for player in players:
		if player.club_id != selected_club.id:
			continue
		var shirt := "—" if player.shirt_number < 0 else str(player.shirt_number)
		var position := player.position if player.position != "UNK" else "Mevki bilinmiyor"
		roster_list.add_item("%s  |  %s  |  %s" % [shirt, player.name, position])
		roster_count += 1
	if roster_count == 0:
		roster_list.add_item("Bu kulüp için eşleşen oyuncu kaydı yok.")
	start_button.disabled = false

func _on_start_match_pressed() -> void:
	if selected_club == null:
		return
	CareerDatabase.select_club(selected_club)
	get_tree().change_scene_to_file(MATCH_SCENE)

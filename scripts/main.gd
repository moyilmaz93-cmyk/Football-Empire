extends Node3D

# Football Empire - 3D match prototype
# X: field length, Z: field width. Blue attacks +X, red attacks -X.

const FIELD_LENGTH := 100.0
const FIELD_WIDTH := 64.0
const GOAL_HALF_WIDTH := 4.0
const PLAYER_COUNT := 11
const PLAYER_SPEED := 6.0
const BALL_RADIUS := 0.45
const MATCH_LENGTH_SECONDS := 90.0 * 60.0
const MATCH_TIME_SCALE := 60.0 # One real second advances one in-game minute.

var blue_players: Array[Node3D] = []
var red_players: Array[Node3D] = []
var all_players: Array[Node3D] = []
var ball: Node3D
var ball_owner: Node3D
var possession_team := -1
var ball_velocity := Vector3.ZERO
var score_blue := 0
var score_red := 0
var match_seconds := 0.0
var match_running := true
var ai_clock := 0.0
var hud: Label
var status_label: Label
var pause_button: Button
var speed_button: Button
var match_speed := 1.0

func _ready() -> void:
	randomize()
	_build_environment()
	_build_pitch()
	_build_players()
	_build_ball()
	_build_camera()
	_build_hud()
	_set_possession(blue_players[6])

func _process(delta: float) -> void:
	if not match_running:
		return
	match_seconds = minf(match_seconds + delta * MATCH_TIME_SCALE * match_speed, MATCH_LENGTH_SECONDS)
	if match_seconds >= MATCH_LENGTH_SECONDS:
		match_running = false
		pause_button.text = "MAÇ BİTTİ"
		pause_button.disabled = true
	ai_clock += delta
	if ai_clock >= 0.8:
		ai_clock = 0.0
		_run_team_ai()
	_update_players(delta)
	_update_ball(delta)
	_update_hud()

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.055, 0.09, 0.075)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.76, 0.72)
	env.ambient_light_energy = 0.8
	world.environment = env
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -25.0, 0.0)
	sun.light_energy = 1.15
	add_child(sun)

func _make_box(parent: Node, node_name: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	instance.material_override = material
	instance.position = pos
	parent.add_child(instance)
	return instance

func _build_pitch() -> void:
	_make_box(self, "PitchBase", Vector3(FIELD_LENGTH, 0.2, FIELD_WIDTH), Vector3(0.0, -0.12, 0.0), Color(0.10, 0.34, 0.15))
	for i in range(10):
		var stripe_color := Color(0.12, 0.39, 0.17) if i % 2 == 0 else Color(0.105, 0.355, 0.15)
		_make_box(self, "GrassStripe_%02d" % i, Vector3(10.0, 0.025, FIELD_WIDTH), Vector3(-45.0 + float(i) * 10.0, 0.0, 0.0), stripe_color)

	var line_color := Color(0.92, 0.95, 0.9)
	_make_box(self, "HalfwayLine", Vector3(0.13, 0.035, FIELD_WIDTH), Vector3(0.0, 0.025, 0.0), line_color)
	_make_box(self, "TouchlineNorth", Vector3(FIELD_LENGTH, 0.035, 0.13), Vector3(0.0, 0.025, -32.0), line_color)
	_make_box(self, "TouchlineSouth", Vector3(FIELD_LENGTH, 0.035, 0.13), Vector3(0.0, 0.025, 32.0), line_color)
	_make_box(self, "GoalLineWest", Vector3(0.13, 0.035, FIELD_WIDTH), Vector3(-50.0, 0.025, 0.0), line_color)
	_make_box(self, "GoalLineEast", Vector3(0.13, 0.035, FIELD_WIDTH), Vector3(50.0, 0.025, 0.0), line_color)
	_make_box(self, "CenterSpot", Vector3(0.55, 0.04, 0.55), Vector3(0.0, 0.04, 0.0), line_color)

	# Penalty-area outlines and goal frames.
	for side in [-1.0, 1.0]:
		var x := side * 38.0
		_make_box(self, "PenaltyFront", Vector3(0.12, 0.035, 40.0), Vector3(x, 0.025, 0.0), line_color)
		_make_box(self, "PenaltyTop", Vector3(12.0, 0.035, 0.12), Vector3(side * 44.0, 0.025, -20.0), line_color)
		_make_box(self, "PenaltyBottom", Vector3(12.0, 0.035, 0.12), Vector3(side * 44.0, 0.025, 20.0), line_color)
		_make_box(self, "GoalCrossbar", Vector3(0.35, 0.25, GOAL_HALF_WIDTH * 2.0), Vector3(side * 50.0, 3.0, 0.0), Color.WHITE)
		for post_z in [-GOAL_HALF_WIDTH, GOAL_HALF_WIDTH]:
			_make_box(self, "GoalPost", Vector3(0.35, 3.0, 0.25), Vector3(side * 50.0, 1.5, post_z), Color.WHITE)

func _make_player(team_id: int, index: int, team_color: Color, start_pos: Vector3) -> Node3D:
	var player := Node3D.new()
	player.name = ("Blue_" if team_id == 0 else "Red_") + "%02d" % (index + 1)
	player.position = start_pos
	player.set_meta("team_id", team_id)
	player.set_meta("player_index", index)
	player.set_meta("shirt_number", index + 1)
	player.set_meta("base_position", start_pos)

	# Manager-style match marker: a flat team-colored disc, not a human character.
	var disc := MeshInstance3D.new()
	var disc_mesh := CylinderMesh.new()
	disc_mesh.top_radius = 0.82
	disc_mesh.bottom_radius = 0.82
	disc_mesh.height = 0.22
	disc.mesh = disc_mesh
	var disc_material := StandardMaterial3D.new()
	disc_material.albedo_color = team_color
	disc_material.roughness = 0.55
	disc.material_override = disc_material
	disc.position.y = 0.16
	player.add_child(disc)

	var number := Label3D.new()
	number.text = str(index + 1)
	number.font_size = 64
	number.pixel_size = 0.012
	number.position = Vector3(0.0, 0.34, 0.0)
	number.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	number.modulate = Color.WHITE
	number.outline_size = 8
	number.no_depth_test = true
	player.add_child(number)

	add_child(player)
	all_players.append(player)
	return player

func _build_players() -> void:
	var blue_color := Color(0.06, 0.24, 0.82)
	var red_color := Color(0.78, 0.08, 0.075)
	# 4-3-3: goalkeeper, four defenders, three midfielders, three forwards.
	var formation: Array[Vector3] = [
		Vector3(-45.0, 0.0, 0.0),
		Vector3(-33.0, 0.0, -22.0), Vector3(-35.0, 0.0, -8.0),
		Vector3(-35.0, 0.0, 8.0), Vector3(-33.0, 0.0, 22.0),
		Vector3(-18.0, 0.0, -14.0), Vector3(-20.0, 0.0, 0.0), Vector3(-18.0, 0.0, 14.0),
		Vector3(-7.0, 0.0, -21.0), Vector3(-5.0, 0.0, 0.0), Vector3(-7.0, 0.0, 21.0)
	]
	for i in range(PLAYER_COUNT):
		var blue_pos := formation[i]
		var red_pos := Vector3(-formation[i].x, 0.0, formation[i].z)
		blue_players.append(_make_player(0, i, blue_color, blue_pos))
		red_players.append(_make_player(1, i, red_color, red_pos))

func _build_ball() -> void:
	ball = Node3D.new()
	ball.name = "MatchBall"
	var sphere := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = BALL_RADIUS
	mesh.height = BALL_RADIUS * 2.0
	sphere.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.96, 0.96, 0.92)
	material.roughness = 0.45
	sphere.material_override = material
	ball.add_child(sphere)
	ball.position = Vector3(0.0, BALL_RADIUS, 0.0)
	add_child(ball)

func _build_camera() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 105.0, 0.01)
	camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	camera.current = true
	camera.fov = 48.0
	add_child(camera)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	hud = Label.new()
	hud.position = Vector2(24.0, 18.0)
	hud.add_theme_font_size_override("font_size", 26)
	hud.add_theme_color_override("font_color", Color.WHITE)
	layer.add_child(hud)

	status_label = Label.new()
	status_label.position = Vector2(24.0, 58.0)
	status_label.add_theme_font_size_override("font_size", 17)
	status_label.add_theme_color_override("font_color", Color(0.9, 0.92, 0.9))
	layer.add_child(status_label)

	pause_button = _make_hud_button(layer, "DURAKLAT", Vector2(24.0, 630.0), Vector2(160.0, 58.0))
	pause_button.pressed.connect(_on_pause_pressed)
	speed_button = _make_hud_button(layer, "HIZ: 1x", Vector2(196.0, 630.0), Vector2(150.0, 58.0))
	speed_button.pressed.connect(_on_speed_pressed)
	_update_hud()

func _make_hud_button(parent: Node, text_value: String, pos: Vector2, button_size: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = pos
	button.size = button_size
	button.add_theme_font_size_override("font_size", 20)
	parent.add_child(button)
	return button

func _get_team(team_id: int) -> Array[Node3D]:
	return blue_players if team_id == 0 else red_players

func _set_possession(player: Node3D) -> void:
	ball_owner = player
	if player == null:
		possession_team = -1
		return
	possession_team = int(player.get_meta("team_id"))
	ball_velocity = Vector3.ZERO
	ball.position = player.position + Vector3(0.0, BALL_RADIUS, -0.9)

func _run_team_ai() -> void:
	if ball_owner == null:
		return
	var owner_team := int(ball_owner.get_meta("team_id"))
	var attack_direction := 1.0 if owner_team == 0 else -1.0
	var distance_to_goal := (50.0 - ball_owner.position.x) if owner_team == 0 else (50.0 + ball_owner.position.x)
	var pressure := _nearest_opponent_distance(ball_owner)
	if distance_to_goal < 23.0 and absf(ball_owner.position.z) < 18.0 and randf() < 0.58:
		_shoot_ball()
	elif pressure < 3.5 or randf() < 0.22:
		_pass_ball()
	else:
		var dribble_target := ball_owner.position + Vector3(attack_direction * 5.0, 0.0, 0.0)
		ball_owner.position = ball_owner.position.move_toward(dribble_target, 1.0)

func _update_players(delta: float) -> void:
	if ball_owner != null:
		ball.position = ball_owner.position + Vector3(0.0, BALL_RADIUS, -0.9)
		ball.position.x = clampf(ball.position.x, -49.0, 49.0)
		ball.position.z = clampf(ball.position.z, -31.0, 31.0)

	for team_id in [0, 1]:
		var team := _get_team(team_id)
		var attacking := team_id == possession_team
		var nearest_index := _nearest_player_index(team, ball.position)
		for i in range(team.size()):
			var player := team[i]
			var base: Vector3 = player.get_meta("base_position")
			var target := base
			if i == 0:
				target.z = clampf(ball.position.z * 0.35, -6.0, 6.0)
				target.x = -45.0 if team_id == 0 else 45.0
			elif attacking:
				var direction := 1.0 if team_id == 0 else -1.0
				target.x += direction * clampf((ball.position.x * direction) * 0.12, -3.0, 8.0)
				if i >= 8:
					target.x += direction * 3.0
				if player == ball_owner:
					target = player.position + Vector3(direction * 4.0, 0.0, 0.0)
			elif i == nearest_index:
				target = ball.position
			else:
				target.x += (ball.position.x - base.x) * 0.12
				target.z += (ball.position.z - base.z) * 0.08
			target.x = clampf(target.x, -48.0, 48.0)
			target.z = clampf(target.z, -29.0, 29.0)
			_move_player(player, target, delta)

func _move_player(player: Node3D, target: Vector3, delta: float) -> void:
	target.y = 0.0
	var speed := PLAYER_SPEED
	if player == ball_owner:
		speed = 4.8
	player.position = player.position.move_toward(target, speed * delta)
	var look_target := Vector3(target.x, player.position.y + 1.0, target.z)
	if player.position.distance_to(target) > 0.2:
		player.look_at(look_target, Vector3.UP)

func _update_ball(delta: float) -> void:
	if ball_owner != null:
		return
	ball_velocity.y -= 9.8 * delta
	ball.position += ball_velocity * delta
	if ball.position.y < BALL_RADIUS:
		ball.position.y = BALL_RADIUS
		if absf(ball_velocity.y) > 1.0:
			ball_velocity.y = -ball_velocity.y * 0.28
		else:
			ball_velocity.y = 0.0
		ball_velocity.x *= 0.985
		ball_velocity.z *= 0.985
		ball_velocity = Vector3(ball_velocity.x, ball_velocity.y, ball_velocity.z)
	if ball_velocity.length() < 1.4:
		var closest := _nearest_player(all_players, ball.position)
		if closest != null and closest.position.distance_to(ball.position) < 1.8:
			_set_possession(closest)
	_check_ball_outcome()

func _check_ball_outcome() -> void:
	if ball.position.x >= 50.0:
		if absf(ball.position.z) <= GOAL_HALF_WIDTH and ball.position.y <= 3.0:
			_score_goal(0)
		else:
			_reset_ball(-1)
	elif ball.position.x <= -50.0:
		if absf(ball.position.z) <= GOAL_HALF_WIDTH and ball.position.y <= 3.0:
			_score_goal(1)
		else:
			_reset_ball(-1)
	elif absf(ball.position.z) > 32.0:
		_reset_ball(-1)

func _score_goal(scoring_team: int) -> void:
	if scoring_team == 0:
		score_blue += 1
	else:
		score_red += 1
	# The team that conceded restarts from the centre.
	_reset_ball(1 - scoring_team)

func _reset_ball(kickoff_team: int) -> void:
	ball.position = Vector3(0.0, BALL_RADIUS, 0.0)
	ball_velocity = Vector3.ZERO
	ball_owner = null
	possession_team = -1
	if kickoff_team >= 0:
		var team := _get_team(kickoff_team)
		_set_possession(team[6])

func _nearest_player(players: Array[Node3D], point: Vector3) -> Node3D:
	var closest: Node3D = null
	var best_distance := INF
	for player in players:
		var distance := player.position.distance_to(point)
		if distance < best_distance:
			best_distance = distance
			closest = player
	return closest

func _nearest_player_index(players: Array[Node3D], point: Vector3) -> int:
	var best_index := 1
	var best_distance := INF
	for i in range(1, players.size()):
		var distance := players[i].position.distance_to(point)
		if distance < best_distance:
			best_distance = distance
			best_index = i
	return best_index

func _nearest_opponent_distance(player: Node3D) -> float:
	var opponent_team := _get_team(1 - int(player.get_meta("team_id")))
	var nearest_distance := INF
	for opponent in opponent_team:
		nearest_distance = minf(nearest_distance, player.position.distance_to(opponent.position))
	return nearest_distance

func _pass_ball() -> void:
	if ball_owner == null:
		return
	var team_id := int(ball_owner.get_meta("team_id"))
	var direction := 1.0 if team_id == 0 else -1.0
	var teammates := _get_team(team_id)
	var best_player: Node3D = null
	var best_score := -INF
	for teammate in teammates:
		if teammate == ball_owner or int(teammate.get_meta("player_index")) == 0:
			continue
		var offset: Vector3 = teammate.position - ball_owner.position
		var forward_progress := offset.x * direction
		if forward_progress < -5.0:
			continue
		var pressure := _nearest_opponent_distance(teammate)
		var score := forward_progress * 0.45 - offset.length() * 0.08 + minf(pressure, 12.0) * 0.18
		if score > best_score:
			best_score = score
			best_player = teammate
	if best_player == null:
		_shoot_ball()
		return
	_kick_ball(best_player.position + Vector3(0.0, BALL_RADIUS, 0.0), 17.0, 1.1)

func _shoot_ball() -> void:
	if ball_owner == null:
		return
	var team_id := int(ball_owner.get_meta("team_id"))
	var target_x := 52.0 if team_id == 0 else -52.0
	var target := Vector3(target_x, 1.0, randf_range(-2.8, 2.8))
	_kick_ball(target, 25.0, 3.0)

func _kick_ball(target: Vector3, speed: float, lift: float) -> void:
	if ball_owner == null:
		return
	ball.position = ball_owner.position + Vector3(0.0, BALL_RADIUS, 0.0)
	var direction := (target - ball.position).normalized()
	ball_owner = null
	possession_team = -1
	ball_velocity = direction * speed
	ball_velocity.y = lift

func _on_pause_pressed() -> void:
	match_running = not match_running
	pause_button.text = "DEVAM ET" if not match_running else "DURAKLAT"

func _on_speed_pressed() -> void:
	if is_equal_approx(match_speed, 1.0):
		match_speed = 2.0
	elif is_equal_approx(match_speed, 2.0):
		match_speed = 4.0
	else:
		match_speed = 1.0
	speed_button.text = "HIZ: %dx" % int(match_speed)

func _update_hud() -> void:
	var total_minutes := int(match_seconds / 60.0)
	var minutes := total_minutes % 90
	var seconds := int(match_seconds) % 60
	hud.text = "FOOTBALL EMPIRE   |   MAVİ %d - %d KIRMIZI   |   %02d:%02d" % [score_blue, score_red, minutes, seconds]
	var team_text := "MAVİ TAKIM" if possession_team == 0 else ("KIRMIZI TAKIM" if possession_team == 1 else "TOP BOŞTA")
	status_label.text = "Top kontrolü: " + team_text + "   •   4-3-3   •   %s" % ("MAÇ DEVAM EDİYOR" if match_running else "DURAKLATILDI")


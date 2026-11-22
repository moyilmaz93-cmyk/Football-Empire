extends Node3D

const PITCH_LENGTH := 100.0
const PITCH_WIDTH := 64.0
const PLAYER_COUNT := 11

var players_a: Array[Node3D] = []
var players_b: Array[Node3D] = []
var ball: Node3D
var ball_velocity := Vector3.ZERO
var match_seconds := 0.0
var match_running := true
var score_a := 0
var score_b := 0
var hud: Label
var camera: Camera3D

func _ready() -> void:
    _build_environment()
    _build_pitch()
    _build_players()
    _build_ball()
    _build_camera()
    _build_hud()

func _process(delta: float) -> void:
    if not match_running:
        return
    match_seconds += delta * 2.0 # Prototype match clock: 2 game seconds per real second.
    _update_players(delta)
    _update_ball(delta)
    _update_hud()

func _build_environment() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.08, 0.12, 0.1)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.7, 0.75, 0.7)
    env.ambient_light_energy = 0.7
    world.environment = env
    add_child(world)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.2
    add_child(sun)

func _make_box(parent: Node, name: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = name
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.9
    mesh_instance.material_override = material
    mesh_instance.position = pos
    parent.add_child(mesh_instance)
    return mesh_instance

func _build_pitch() -> void:
    _make_box(self, "Pitch", Vector3(PITCH_LENGTH, 0.2, PITCH_WIDTH), Vector3.ZERO, Color(0.12, 0.42, 0.18))
    # Alternating mowing bands
    for i in range(10):
        var band_color := Color(0.14, 0.46, 0.2) if i % 2 == 0 else Color(0.11, 0.40, 0.17)
        _make_box(self, "GrassBand", Vector3(10.0, 0.025, PITCH_WIDTH), Vector3(-45.0 + i * 10.0, 0.112, 0), band_color)
    _make_box(self, "HalfwayLine", Vector3(0.12, 0.04, PITCH_WIDTH), Vector3(0, 0.14, 0), Color.WHITE)
    _make_box(self, "CenterMark", Vector3(0.5, 0.05, 0.5), Vector3(0, 0.15, 0), Color.WHITE)
    _make_box(self, "LeftGoalBar", Vector3(0.4, 3.0, 8.0), Vector3(-50.0, 1.6, 0), Color.WHITE)
    _make_box(self, "RightGoalBar", Vector3(0.4, 3.0, 8.0), Vector3(50.0, 1.6, 0), Color.WHITE)
    _make_box(self, "TouchlineTop", Vector3(PITCH_LENGTH, 0.04, 0.12), Vector3(0, 0.15, -32.0), Color.WHITE)
    _make_box(self, "TouchlineBottom", Vector3(PITCH_LENGTH, 0.04, 0.12), Vector3(0, 0.15, 32.0), Color.WHITE)

func _make_player(team_color: Color, pos: Vector3, label_text: String) -> Node3D:
    var player := Node3D.new()
    player.name = label_text
    player.position = pos
    var body := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.65
    capsule.height = 2.0
    body.mesh = capsule
    var mat := StandardMaterial3D.new()
    mat.albedo_color = team_color
    body.material_override = mat
    body.position.y = 1.15
    player.add_child(body)
    add_child(player)
    return player

func _build_players() -> void:
    var blue := Color(0.08, 0.28, 0.9)
    var red := Color(0.85, 0.12, 0.1)
    # 4-3-3 starting positions; goalkeeper + defenders + midfielders + forwards.
    var formation := [
        Vector3(-44, 0, 0),
        Vector3(-32, 0, -22), Vector3(-34, 0, -8), Vector3(-34, 0, 8), Vector3(-32, 0, 22),
        Vector3(-17, 0, -14), Vector3(-18, 0, 0), Vector3(-17, 0, 14),
        Vector3(-5, 0, -21), Vector3(-3, 0, 0), Vector3(-5, 0, 21)
    ]
    for i in range(PLAYER_COUNT):
        players_a.append(_make_player(blue, formation[i], "Blue_%02d" % (i + 1)))
        var away_pos := Vector3(-formation[i].x, 0, formation[i].z)
        players_b.append(_make_player(red, away_pos, "Red_%02d" % (i + 1)))

func _build_ball() -> void:
    ball = Node3D.new()
    ball.name = "Ball"
    var sphere := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.45
    mesh.height = 0.9
    sphere.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color.WHITE
    sphere.material_override = mat
    sphere.position.y = 0.55
    ball.add_child(sphere)
    ball.position = Vector3.ZERO
    add_child(ball)

func _build_camera() -> void:
    camera = Camera3D.new()
    camera.position = Vector3(0, 72, 82)
    camera.rotation_degrees = Vector3(-42, 0, 0)
    camera.current = true
    add_child(camera)

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    hud = Label.new()
    hud.position = Vector2(24, 20)
    hud.add_theme_font_size_override("font_size", 28)
    hud.add_theme_color_override("font_color", Color.WHITE)
    layer.add_child(hud)
    _update_hud()

func _update_players(delta: float) -> void:
    var target := ball.position
    for i in range(PLAYER_COUNT):
        _move_player(players_a[i], target, delta, i == 0)
        _move_player(players_b[i], target, delta, i == 0)

func _move_player(player: Node3D, target: Vector3, delta: float, goalkeeper: bool) -> void:
    var desired := target
    if goalkeeper:
        desired.x = clampf(desired.x, -46.0, -40.0) if player.position.x < 0 else clampf(desired.x, 40.0, 46.0)
        desired.z = clampf(desired.z, -7.0, 7.0)
    else:
        desired.x = clampf(desired.x, -47.0, 47.0)
        desired.z = clampf(desired.z, -29.0, 29.0)
    desired.y = 0.0
    var distance := player.position.distance_to(desired)
    if distance > 2.0:
        player.position = player.position.move_toward(desired, minf(7.0 * delta, distance * 0.08))
    player.look_at(Vector3(target.x, player.position.y + 1.0, target.z), Vector3.UP)

func _update_ball(delta: float) -> void:
    ball.position += ball_velocity * delta
    ball_velocity = ball_velocity.move_toward(Vector3.ZERO, delta * 2.0)
    # Possession prototype: nearest player nudges the ball toward the opposite goal.
    var nearest: Node3D = null
    var nearest_distance := 3.0
    for player in players_a + players_b:
        var d := player.position.distance_to(ball.position)
        if d < nearest_distance:
            nearest = player
            nearest_distance = d
    if nearest != null and ball_velocity.length() < 1.5:
        var direction := Vector3(1, 0, 0) if nearest.name.begins_with("Blue") else Vector3(-1, 0, 0)
        ball_velocity = direction * 8.0
    if absf(ball.position.x) > 50.0:
        if ball.position.x > 0:
            score_a += 1
        else:
            score_b += 1
        ball.position = Vector3.ZERO
        ball_velocity = Vector3.ZERO

func _update_hud() -> void:
    var minutes := int(match_seconds / 60.0)
    hud.text = "FOOTBALL EMPIRE   |   MAVİ %d - %d KIRMIZI   |   %02d'" % [score_a, score_b, minutes]

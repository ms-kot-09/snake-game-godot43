extends Node2D
# ─── Main Menu ────────────────────────────────────────────────────────────────

var _time      : float = 0.0
var _demo_snake: Array[Vector2] = []
var _demo_dir  : Vector2 = Vector2(1, 0)
var _demo_timer: float = 0.0
var _demo_food : Vector2 = Vector2(12, 10)
const DEMO_GRID := 24
const DEMO_CELL := 18.0

var _root : Control

func _ready() -> void:
	_build_demo_snake()
	_build_ui()

func _build_demo_snake() -> void:
	for i in 8:
		_demo_snake.append(Vector2(8 - i, 10))

func _build_ui() -> void:
	var vp := get_viewport_rect().size
	_root  = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	# Background gradient panel
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.047, 0.047, 0.075)
	_root.add_child(bg)

	# Title area
	var title_lbl := Label.new()
	title_lbl.text = "SNAKE"
	title_lbl.add_theme_font_size_override("font_size", 88)
	title_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.5))
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.position = Vector2(0, 80)
	title_lbl.size     = Vector2(vp.x, 120)
	_root.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "— with Skins & RGB Editor —"
	sub_lbl.add_theme_font_size_override("font_size", 22)
	sub_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.6, 0.8))
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.position = Vector2(0, 178)
	sub_lbl.size     = Vector2(vp.x, 40)
	_root.add_child(sub_lbl)

	# High score
	var hs_lbl := Label.new()
	hs_lbl.name = "HSLabel"
	hs_lbl.text = "Best: %d" % GameData.high_score
	hs_lbl.add_theme_font_size_override("font_size", 26)
	hs_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	hs_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hs_lbl.position = Vector2(0, 228)
	hs_lbl.size     = Vector2(vp.x, 40)
	_root.add_child(hs_lbl)

	# Skin preview strip (shows current skin name)
	var skin_strip := Label.new()
	skin_strip.name = "SkinStrip"
	var sk := SkinManager.get_active_skin()
	skin_strip.text = sk["emoji"] + "  " + sk["name"]
	skin_strip.add_theme_font_size_override("font_size", 24)
	skin_strip.add_theme_color_override("font_color", sk["body_end"])
	skin_strip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skin_strip.position = Vector2(0, 280)
	skin_strip.size     = Vector2(vp.x, 40)
	_root.add_child(skin_strip)

	# Buttons VBox
	var vbox := VBoxContainer.new()
	vbox.position = Vector2(vp.x * 0.5 - 160, 370)
	vbox.size     = Vector2(320, 400)
	vbox.add_theme_constant_override("separation", 18)
	_root.add_child(vbox)

	_add_btn(vbox, "▶  PLAY",     Color(0.15, 0.85, 0.45), _on_play)
	_add_btn(vbox, "🎨  SKINS",   Color(0.55, 0.25, 1.0),  _on_skins)
	_add_btn(vbox, "⚙️  SETTINGS", Color(0.2,  0.6,  1.0),  _on_settings)
	_add_btn(vbox, "✕  QUIT",     Color(0.8,  0.25, 0.25), _on_quit)

	# Version label
	var ver := Label.new()
	ver.text = "v1.0  •  Godot 4.3"
	ver.add_theme_font_size_override("font_size", 16)
	ver.add_theme_color_override("font_color", Color(1, 1, 1, 0.2))
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ver.position = Vector2(0, vp.y - 50)
	ver.size     = Vector2(vp.x, 30)
	_root.add_child(ver)

func _add_btn(parent: Control, txt: String, col: Color, cb: Callable) -> void:
	var btn := Button.new()
	btn.text = txt
	btn.custom_minimum_size = Vector2(320, 62)
	btn.add_theme_font_size_override("font_size", 24)

	var ns := StyleBoxFlat.new()
	ns.bg_color          = col.darkened(0.5)
	ns.border_color      = col
	ns.border_width_left = 2
	ns.border_width_right = 2
	ns.border_width_top = 2
	ns.border_width_bottom = 2
	ns.corner_radius_top_left = 12
	ns.corner_radius_top_right = 12
	ns.corner_radius_bottom_left = 12
	ns.corner_radius_bottom_right = 12
	btn.add_theme_stylebox_override("normal", ns)

	var hs := ns.duplicate() as StyleBoxFlat
	hs.bg_color = col.darkened(0.2)
	btn.add_theme_stylebox_override("hover",   hs)
	btn.add_theme_stylebox_override("pressed", hs)
	btn.add_theme_color_override("font_color", Color.WHITE)

	btn.pressed.connect(func():
		AudioManager.play_click()
		cb.call()
	)
	parent.add_child(btn)

# ─── Navigation ───────────────────────────────────────────────────────────────
func _on_play()     -> void: get_tree().change_scene_to_file("res://scenes/Game.tscn")
func _on_skins()    -> void: get_tree().change_scene_to_file("res://scenes/SkinSelect.tscn")
func _on_settings() -> void: get_tree().change_scene_to_file("res://scenes/Settings.tscn")
func _on_quit()     -> void: get_tree().quit()

# ─── Background demo snake animation ─────────────────────────────────────────
func _process(delta: float) -> void:
	_time       += delta
	_demo_timer += delta
	if _demo_timer >= 0.22:
		_demo_timer = 0.0
		_advance_demo()
	queue_redraw()

func _advance_demo() -> void:
	var head  := _demo_snake[0]
	var rng   := RandomNumberGenerator.new()
	rng.seed  = int(_time * 1000)
	# Bias toward food
	var to_food := (_demo_food - head).sign()
	if rng.randf() < 0.75:
		if abs(to_food.x) > abs(to_food.y) and to_food.x != 0:
			_demo_dir = Vector2(to_food.x, 0)
		elif to_food.y != 0:
			_demo_dir = Vector2(0, to_food.y)
	var next := head + _demo_dir
	# Wrap
	next.x = fmod(next.x + DEMO_GRID, DEMO_GRID)
	next.y = fmod(next.y + DEMO_GRID, DEMO_GRID)
	_demo_snake.push_front(next)
	if next == _demo_food:
		_demo_food = Vector2(rng.randi_range(1, DEMO_GRID - 2), rng.randi_range(1, DEMO_GRID - 2))
	else:
		_demo_snake.pop_back()

func _draw() -> void:
	var vp  := get_viewport_rect().size
	var off := Vector2(vp.x * 0.5 - DEMO_GRID * DEMO_CELL * 0.5,
	                   vp.y * 0.5 - DEMO_GRID * DEMO_CELL * 0.5 + 80)
	var skin := SkinManager.get_active_skin()
	var cs   := DEMO_CELL * 0.42
	# Draw food
	var fp := off + _demo_food * DEMO_CELL + Vector2(DEMO_CELL, DEMO_CELL) * 0.5
	draw_circle(fp, cs * 0.9, skin["food_color"] * Color(1,1,1,0.25))

	# Draw demo snake (faded background)
	for i in _demo_snake.size():
		var pos := off + _demo_snake[i] * DEMO_CELL + Vector2(DEMO_CELL, DEMO_CELL) * 0.5
		var col := SkinManager.get_segment_color(skin, i, _demo_snake.size(), _time)
		col.a   = 0.15
		draw_circle(pos, cs * 0.85, col)

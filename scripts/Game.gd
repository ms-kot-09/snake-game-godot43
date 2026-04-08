extends Node2D
# ─── Snake Game ───────────────────────────────────────────────────────────────
# Full gameplay: grid logic, _draw() rendering, swipe controls, particles.

# ── Grid ──────────────────────────────────────────────────────────────────────
var GRID_W  : int
var GRID_H  : int
var CELL    : float
var BOARD_X : float
var BOARD_Y : float
var BOARD_W : float
var BOARD_H : float

# ── Snake state ───────────────────────────────────────────────────────────────
var snake    : Array[Vector2i] = []
var dir      : Vector2i        = Vector2i(1, 0)
var next_dir : Vector2i        = Vector2i(1, 0)
var food     : Vector2i        = Vector2i(0, 0)
var score    : int             = 0
var alive    : bool            = true
var started  : bool            = false

# ── Timing ────────────────────────────────────────────────────────────────────
var _move_timer  : float = 0.0
var _time        : float = 0.0
var _flash_timer : float = 0.0

# ── Touch ─────────────────────────────────────────────────────────────────────
var _touch_start : Vector2 = Vector2.ZERO
var _touching    : bool    = false
const SWIPE_MIN  := 30.0

# ── Particles ─────────────────────────────────────────────────────────────────
class Particle:
	var pos   : Vector2
	var vel   : Vector2
	var color : Color
	var life  : float
	var max_life : float
	var size  : float

var _particles : Array = []

# ── UI nodes ──────────────────────────────────────────────────────────────────
var _score_lbl   : Label
var _best_lbl    : Label
var _overlay     : Control   # pause / game-over overlay
var _paused      : bool = false

var _skin : Dictionary

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_skin = SkinManager.get_active_skin()
	_calc_layout()
	_build_ui()
	_reset()

func _calc_layout() -> void:
	var vp  := get_viewport_rect().size
	GRID_W  = GameData.grid_size
	GRID_H  = GameData.grid_size
	# Leave room for HUD at top
	var hud_h  := 90.0
	var margin := 16.0
	var avail_w := vp.x - margin * 2
	var avail_h := vp.y - hud_h - margin * 2
	CELL    = min(avail_w / GRID_W, avail_h / GRID_H)
	BOARD_W = CELL * GRID_W
	BOARD_H = CELL * GRID_H
	BOARD_X = (vp.x - BOARD_W) * 0.5
	BOARD_Y = hud_h + (avail_h - BOARD_H) * 0.5 + margin

func _reset() -> void:
	snake.clear()
	_particles.clear()
	score    = 0
	alive    = true
	started  = false
	dir      = Vector2i(1, 0)
	next_dir = Vector2i(1, 0)
	_move_timer = 0.0
	_flash_timer = 0.0
	# Start snake in center
	var cx := GRID_W / 2
	var cy := GRID_H / 2
	for i in 4:
		snake.append(Vector2i(cx - i, cy))
	_place_food()
	_update_score_ui()
	if _overlay:
		_overlay.visible = false

# ─── UI ───────────────────────────────────────────────────────────────────────
func _build_ui() -> void:
	var vp   := get_viewport_rect().size
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# ── HUD bar ──────────────────────────────────────────────────────────────
	var hud := HBoxContainer.new()
	hud.position = Vector2(0, 0)
	hud.size     = Vector2(vp.x, 90)
	hud.add_theme_constant_override("separation", 0)
	root.add_child(hud)

	# Back button
	var back := _make_icon_btn("←", func():
		AudioManager.play_click()
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	)
	back.custom_minimum_size = Vector2(80, 80)
	hud.add_child(back)

	# Score / Best area
	var score_box := VBoxContainer.new()
	score_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_box.alignment = BoxContainer.ALIGNMENT_CENTER
	hud.add_child(score_box)

	_score_lbl = Label.new()
	_score_lbl.text = "0"
	_score_lbl.add_theme_font_size_override("font_size", 42)
	_score_lbl.add_theme_color_override("font_color", Color.WHITE)
	_score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_box.add_child(_score_lbl)

	_best_lbl = Label.new()
	_best_lbl.text = "Best %d" % GameData.high_score
	_best_lbl.add_theme_font_size_override("font_size", 18)
	_best_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.8))
	_best_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_box.add_child(_best_lbl)

	# Pause button
	var pause_btn := _make_icon_btn("⏸", _toggle_pause)
	pause_btn.custom_minimum_size = Vector2(80, 80)
	hud.add_child(pause_btn)

	# ── Overlay (pause / gameover) ───────────────────────────────────────────
	_overlay = Control.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	root.add_child(_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.72)
	_overlay.add_child(dim)

	var card := VBoxContainer.new()
	card.name = "Card"
	card.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_theme_constant_override("separation", 20)
	card.position = Vector2(vp.x * 0.5 - 175, vp.y * 0.5 - 200)
	card.size     = Vector2(350, 400)
	_overlay.add_child(card)

	var title := Label.new()
	title.name = "OverlayTitle"
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(title)

	var info := Label.new()
	info.name = "OverlayInfo"
	info.add_theme_font_size_override("font_size", 30)
	info.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(info)

	_add_overlay_btn(card, "▶  RESUME",   Color(0.15, 0.85, 0.45), _toggle_pause)
	_add_overlay_btn(card, "↺  RESTART",  Color(0.2,  0.6,  1.0),  func(): _reset(); )
	_add_overlay_btn(card, "⌂  MENU",     Color(0.6,  0.3,  1.0),  func():
		get_tree().change_scene_to_file("res://scenes/Main.tscn"))

	# ── Start hint ───────────────────────────────────────────────────────────
	var hint := Label.new()
	hint.name = "StartHint"
	hint.text = "Swipe or press arrow key to start"
	hint.add_theme_font_size_override("font_size", 22)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(0, vp.y - 80)
	hint.size     = Vector2(vp.x, 40)
	hint.name     = "StartHint"
	root.add_child(hint)

func _make_icon_btn(txt: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = txt
	btn.add_theme_font_size_override("font_size", 28)
	var ns := StyleBoxFlat.new()
	ns.bg_color = Color(0, 0, 0, 0)
	btn.add_theme_stylebox_override("normal", ns)
	btn.add_theme_stylebox_override("hover",  ns)
	btn.add_theme_stylebox_override("pressed", ns)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.pressed.connect(cb)
	return btn

func _add_overlay_btn(parent: Control, txt: String, col: Color, cb: Callable) -> void:
	var btn := Button.new()
	btn.text = txt
	btn.custom_minimum_size = Vector2(300, 60)
	btn.add_theme_font_size_override("font_size", 26)
	var ns := StyleBoxFlat.new()
	ns.bg_color = col.darkened(0.55)
	ns.border_color = col
	ns.border_width_left = 2
	ns.border_width_right = 2
	ns.border_width_top = 2
	ns.border_width_bottom = 2
	ns.corner_radius_top_left = 10
	ns.corner_radius_top_right = 10
	ns.corner_radius_bottom_left = 10
	ns.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal",  ns)
	var hs := ns.duplicate() as StyleBoxFlat
	hs.bg_color = col.darkened(0.3)
	btn.add_theme_stylebox_override("hover",   hs)
	btn.add_theme_stylebox_override("pressed", hs)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.pressed.connect(func():
		AudioManager.play_click()
		cb.call()
	)
	parent.add_child(btn)

func _update_score_ui() -> void:
	if _score_lbl:
		_score_lbl.text = str(score)
	if _best_lbl:
		_best_lbl.text = "Best %d" % GameData.high_score

# ─── Input ────────────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start = event.position
			_touching     = true
		else:
			_touching = false
	elif event is InputEventScreenDrag and _touching:
		var delta := event.position - _touch_start
		if delta.length() >= SWIPE_MIN:
			_apply_swipe(delta)
			_touch_start = event.position
	# Keyboard
	if event.is_action_pressed("ui_swipe_left"):  _try_dir(Vector2i(-1, 0))
	if event.is_action_pressed("ui_swipe_right"): _try_dir(Vector2i( 1, 0))
	if event.is_action_pressed("ui_swipe_up"):    _try_dir(Vector2i( 0,-1))
	if event.is_action_pressed("ui_swipe_down"):  _try_dir(Vector2i( 0, 1))
	if event.is_action_pressed("ui_cancel"):      _toggle_pause()

func _apply_swipe(delta: Vector2) -> void:
	if abs(delta.x) > abs(delta.y):
		_try_dir(Vector2i(sign(delta.x), 0))
	else:
		_try_dir(Vector2i(0, sign(delta.y)))

func _try_dir(d: Vector2i) -> void:
	if not alive: return
	# Cannot reverse
	if d + dir == Vector2i.ZERO: return
	next_dir = d
	if not started:
		started = true
		# Hide start hint
		var hint := get_node_or_null("*/StartHint")
		if hint: hint.visible = false

# ─── Process ──────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	_time        += delta
	_flash_timer += delta

	if not alive or _paused or not started:
		_update_particles(delta)
		queue_redraw()
		return

	_move_timer += delta
	if _move_timer >= GameData.get_speed_interval():
		_move_timer = 0.0
		_step()

	_update_particles(delta)
	queue_redraw()

func _step() -> void:
	dir = next_dir
	var head := snake[0] + dir

	# Wall collision
	if head.x < 0 or head.x >= GRID_W or head.y < 0 or head.y >= GRID_H:
		_die()
		return

	# Self collision
	if snake.has(head):
		_die()
		return

	snake.push_front(head)

	if head == food:
		score += 10
		GameData.total_eaten += 1
		GameData.update_high_score(score)
		_update_score_ui()
		AudioManager.play_eat()
		_spawn_food_particles()
		_place_food()
		# Animate score label
		var tw := create_tween()
		tw.tween_property(_score_lbl, "scale", Vector2(1.3, 1.3), 0.07)
		tw.tween_property(_score_lbl, "scale", Vector2(1.0, 1.0), 0.12)
	else:
		snake.pop_back()
		AudioManager.play_move()

func _die() -> void:
	alive = false
	AudioManager.play_die()
	if GameData.vibration and OS.get_name() == "Android":
		Input.vibrate_handheld(300)
	_spawn_death_particles()
	# Show game-over overlay after short delay
	var t := get_tree().create_timer(0.6)
	t.timeout.connect(_show_gameover)

func _show_gameover() -> void:
	_overlay.visible = true
	var card := _overlay.get_node("Card")
	(card.get_node("OverlayTitle") as Label).text = "GAME OVER"
	(card.get_node("OverlayInfo")  as Label).text = "Score: %d" % score

func _toggle_pause() -> void:
	if not alive: return
	_paused = !_paused
	_overlay.visible = _paused
	if _paused:
		var card := _overlay.get_node("Card")
		(card.get_node("OverlayTitle") as Label).text = "PAUSED"
		(card.get_node("OverlayInfo")  as Label).text = "Score: %d" % score

# ─── Food placement ───────────────────────────────────────────────────────────
func _place_food() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var attempts := 0
	while attempts < 200:
		var candidate := Vector2i(rng.randi_range(0, GRID_W - 1),
		                          rng.randi_range(0, GRID_H - 1))
		if not snake.has(candidate):
			food = candidate
			return
		attempts += 1

# ─── Particles ────────────────────────────────────────────────────────────────
func _spawn_food_particles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var center := _cell_center(food)
	for i in 18:
		var p     := Particle.new()
		p.pos      = center
		var ang    := rng.randf() * TAU
		var spd    := rng.randf_range(60, 220)
		p.vel      = Vector2(cos(ang), sin(ang)) * spd
		p.color    = _skin["food_color"]
		p.life     = rng.randf_range(0.3, 0.7)
		p.max_life = p.life
		p.size     = rng.randf_range(3, 9)
		_particles.append(p)

func _spawn_death_particles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for seg in snake:
		var center := _cell_center(seg)
		for i in 4:
			var p      := Particle.new()
			p.pos       = center + Vector2(rng.randf_range(-8,8), rng.randf_range(-8,8))
			var ang     := rng.randf() * TAU
			p.vel       = Vector2(cos(ang), sin(ang)) * rng.randf_range(30, 120)
			p.color     = _skin["body_end"]
			p.life      = rng.randf_range(0.4, 1.0)
			p.max_life  = p.life
			p.size      = rng.randf_range(2, 7)
			_particles.append(p)

func _update_particles(delta: float) -> void:
	var i := _particles.size() - 1
	while i >= 0:
		var p : Particle = _particles[i]
		p.pos  += p.vel * delta
		p.vel  *= pow(0.85, delta * 60)
		p.life -= delta
		if p.life <= 0:
			_particles.remove_at(i)
		i -= 1

# ─── Helpers ──────────────────────────────────────────────────────────────────
func _cell_center(cell: Vector2i) -> Vector2:
	return Vector2(BOARD_X + (cell.x + 0.5) * CELL,
	               BOARD_Y + (cell.y + 0.5) * CELL)

func _seg_radius() -> float:
	return CELL * 0.42

# ─── Rendering ────────────────────────────────────────────────────────────────
func _draw() -> void:
	_draw_board()
	if GameData.show_grid:
		_draw_grid()
	_draw_food()
	_draw_snake()
	_draw_particles()
	if not started and alive:
		_draw_start_arrows()

func _draw_board() -> void:
	var rect := Rect2(BOARD_X, BOARD_Y, BOARD_W, BOARD_H)
	draw_rect(rect, _skin["bg_tint"])
	# Subtle inner border
	draw_rect(rect, Color(1, 1, 1, 0.06), false, 2.0)

func _draw_grid() -> void:
	var col := Color(1, 1, 1, 0.05)
	for x in GRID_W + 1:
		var sx := BOARD_X + x * CELL
		draw_line(Vector2(sx, BOARD_Y), Vector2(sx, BOARD_Y + BOARD_H), col, 1.0)
	for y in GRID_H + 1:
		var sy := BOARD_Y + y * CELL
		draw_line(Vector2(BOARD_X, sy), Vector2(BOARD_X + BOARD_W, sy), col, 1.0)

func _draw_food() -> void:
	var center := _cell_center(food)
	var r      := _seg_radius()
	var pulse: float = sin(_time * 5.0) * 0.12 + 0.88
	var col    := _skin["food_color"]

	# Outer glow ring
	draw_circle(center, r * 1.5 * pulse, col * Color(1,1,1,0.15))
	draw_circle(center, r * 1.15 * pulse, col * Color(1,1,1,0.35))
	# Core
	draw_circle(center, r * 0.9 * pulse, col)
	# Shine dot
	draw_circle(center + Vector2(-r * 0.22, -r * 0.22), r * 0.22, Color(1,1,1,0.7))

func _draw_snake() -> void:
	if snake.is_empty(): return
	var n    := snake.size()
	var r    := _seg_radius()
	var skin := _skin

	# Draw body back → front so head is on top
	for i in range(n - 1, -1, -1):
		var center := _cell_center(snake[i])
		var col    := SkinManager.get_segment_color(skin, i, n, _time)
		var is_head := (i == 0)
		var seg_r   := r * (1.0 if is_head else lerp(0.92, 0.72, float(i) / float(n)))

		# Glow
		if skin["glow_on"] and i < 6:
			var glow_a: float = lerp(0.25, 0.05, float(i) / 6.0)
			draw_circle(center, seg_r * 1.6, skin["glow"] * Color(1,1,1,glow_a))

		# Segment
		match skin["shape"]:
			"rounded", "circle":
				draw_circle(center, seg_r, col)
			"diamond":
				_draw_diamond(center, seg_r, col)
			"sharp":
				_draw_square(center, seg_r * 0.95, col)
			_:
				draw_circle(center, seg_r, col)

		# Highlight shine
		if i < 3:
			draw_circle(center + Vector2(-seg_r * 0.28, -seg_r * 0.28),
			            seg_r * 0.25, Color(1,1,1,0.35))

		# Eyes (head only)
		if is_head:
			_draw_eyes(center, seg_r, skin)

	# Connect segments with lines for "body" feel
	for i in range(n - 1):
		var a := _cell_center(snake[i])
		var b := _cell_center(snake[i + 1])
		var col := SkinManager.get_segment_color(skin, i, n, _time)
		col.a   = 0.6
		draw_line(a, b, col, r * 1.55)

func _draw_eyes(center: Vector2, r: float, skin: Dictionary) -> void:
	var d      := dir
	var perp   := Vector2(-d.y, d.x)
	var fwd    := Vector2(d.x, d.y)
	var eye_r  := r * 0.22
	var eye_off := r * 0.38

	for side in [-1, 1]:
		var ep := center + perp * (side * eye_off) + fwd * (r * 0.2)
		draw_circle(ep, eye_r, skin["eye"])
		draw_circle(ep + fwd * eye_r * 0.4, eye_r * 0.5, Color(0, 0, 0))

func _draw_diamond(center: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array([
		center + Vector2(0,  -r),
		center + Vector2(r,   0),
		center + Vector2(0,   r),
		center + Vector2(-r,  0),
	])
	draw_colored_polygon(pts, col)

func _draw_square(center: Vector2, r: float, col: Color) -> void:
	draw_rect(Rect2(center - Vector2(r, r), Vector2(r * 2, r * 2)), col)

func _draw_particles() -> void:
	for p : Particle in _particles:
		var a   := p.life / p.max_life
		var col := p.color
		col.a   = a * a
		draw_circle(p.pos, p.size * a, col)

func _draw_start_arrows() -> void:
	var cx := BOARD_X + BOARD_W * 0.5
	var cy := BOARD_Y + BOARD_H * 0.5
	var alpha := abs(sin(_time * 2.0))
	var col   := Color(1, 1, 1, alpha * 0.6)
	var off   := 60.0
	# Draw four arrow indicators
	_draw_arrow(Vector2(cx, cy - off), Vector2(0, -1), col)
	_draw_arrow(Vector2(cx, cy + off), Vector2(0,  1), col)
	_draw_arrow(Vector2(cx - off, cy), Vector2(-1, 0), col)
	_draw_arrow(Vector2(cx + off, cy), Vector2(1,  0), col)

func _draw_arrow(pos: Vector2, direction: Vector2, col: Color) -> void:
	var perp := Vector2(-direction.y, direction.x)
	var tip  := pos + direction * 20
	var bl   := pos - direction * 5 + perp * 12
	var br   := pos - direction * 5 - perp * 12
	draw_colored_polygon(PackedVector2Array([tip, bl, br]), col)

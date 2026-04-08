extends Node2D
# ─── Settings Screen ─────────────────────────────────────────────────────────

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var vp := get_viewport_rect().size

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.047, 0.047, 0.075)
	root.add_child(bg)

	# Header
	var header := HBoxContainer.new()
	header.position = Vector2(0, 0)
	header.size     = Vector2(vp.x, 80)
	root.add_child(header)

	var back := Button.new()
	back.text = "←"
	back.custom_minimum_size = Vector2(80, 80)
	back.add_theme_font_size_override("font_size", 28)
	_flat_btn(back, Color(0,0,0,0))
	back.add_theme_color_override("font_color", Color.WHITE)
	back.pressed.connect(func():
		AudioManager.play_click()
		GameData.save_data()
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	)
	header.add_child(back)

	var title := Label.new()
	title.text = "SETTINGS"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_child(title)

	var spc := Control.new()
	spc.custom_minimum_size = Vector2(80, 0)
	header.add_child(spc)

	# Separator line
	var sep := ColorRect.new()
	sep.position = Vector2(0, 80)
	sep.size     = Vector2(vp.x, 2)
	sep.color    = Color(0.2, 1.0, 0.5, 0.3)
	root.add_child(sep)

	# Content scroll
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(0, 86)
	scroll.size     = Vector2(vp.x, vp.y - 86)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 0)
	scroll.add_child(vbox)

	# ── Sound FX Volume ─────────────────────────────────────────────────────
	_add_section(vbox, "🔊  Sound Effects")
	var sfx_slider := _add_slider(vbox, GameData.sfx_volume)
	sfx_slider.value_changed.connect(func(v: float):
		GameData.sfx_volume = v
		AudioManager.play_click()
	)

	# ── Music Volume ─────────────────────────────────────────────────────────
	_add_section(vbox, "🎵  Music Volume")
	var mus_slider := _add_slider(vbox, GameData.music_volume)
	mus_slider.value_changed.connect(func(v: float):
		GameData.music_volume = v
	)

	# ── Game Speed ───────────────────────────────────────────────────────────
	_add_section(vbox, "⚡  Game Speed")
	var speed_names := ["Slow", "Normal", "Fast", "Insane 💀"]
	var speed_row := _add_option_row(vbox, speed_names, GameData.speed_level)
	speed_row.item_selected.connect(func(i: int):
		GameData.speed_level = i
		AudioManager.play_click()
	)

	# ── Grid Size ────────────────────────────────────────────────────────────
	_add_section(vbox, "📐  Grid Size")
	var grid_names := ["15×15 (Large cells)", "20×20 (Normal)", "25×25 (Small)", "30×30 (Tiny)"]
	var grid_vals  := [15, 20, 25, 30]
	var cur_grid   := grid_vals.find(GameData.grid_size)
	if cur_grid < 0: cur_grid = 1
	var grid_row := _add_option_row(vbox, grid_names, cur_grid)
	grid_row.item_selected.connect(func(i: int):
		GameData.grid_size = grid_vals[i]
		AudioManager.play_click()
	)

	# ── Show Grid ────────────────────────────────────────────────────────────
	_add_section(vbox, "🔲  Show Grid Lines")
	_add_toggle(vbox, GameData.show_grid, func(v: bool):
		GameData.show_grid = v
		AudioManager.play_click()
	)

	# ── Vibration ────────────────────────────────────────────────────────────
	_add_section(vbox, "📳  Vibration (Android)")
	_add_toggle(vbox, GameData.vibration, func(v: bool):
		GameData.vibration = v
		AudioManager.play_click()
	)

	# ── Stats ────────────────────────────────────────────────────────────────
	_add_section(vbox, "📊  Statistics")
	var stats_lbl := Label.new()
	stats_lbl.text  = "High Score:   %d\nTotal Eaten:  %d" % [GameData.high_score, GameData.total_eaten]
	stats_lbl.add_theme_font_size_override("font_size", 22)
	stats_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left",  24)
	m.add_theme_constant_override("margin_right", 24)
	m.add_theme_constant_override("margin_top",   8)
	m.add_theme_constant_override("margin_bottom",16)
	m.add_child(stats_lbl)
	vbox.add_child(m)

	# Reset stats button
	var rst := Button.new()
	rst.text = "Reset Statistics"
	rst.add_theme_font_size_override("font_size", 20)
	rst.custom_minimum_size = Vector2(280, 52)
	_flat_btn(rst, Color(0.6, 0.15, 0.15))
	rst.add_theme_color_override("font_color", Color.WHITE)
	var rm := MarginContainer.new()
	rm.add_theme_constant_override("margin_left",  24)
	rm.add_theme_constant_override("margin_top",    4)
	rm.add_theme_constant_override("margin_bottom", 20)
	rm.add_child(rst)
	vbox.add_child(rm)
	rst.pressed.connect(func():
		AudioManager.play_click()
		GameData.high_score   = 0
		GameData.total_eaten  = 0
		GameData.save_data()
		stats_lbl.text = "High Score:   0\nTotal Eaten:  0"
	)

	# Bottom padding
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(pad)

# ─── Helpers ──────────────────────────────────────────────────────────────────
func _add_section(parent: Control, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", Color(0.5, 0.9, 0.7))
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left",  24)
	m.add_theme_constant_override("margin_top",   20)
	m.add_theme_constant_override("margin_bottom", 6)
	m.add_child(lbl)
	parent.add_child(m)

func _add_slider(parent: Control, init_val: float) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step      = 0.01
	slider.value     = init_val
	slider.custom_minimum_size = Vector2(0, 44)
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left",  24)
	m.add_theme_constant_override("margin_right", 24)
	m.add_theme_constant_override("margin_bottom", 4)
	m.add_child(slider)
	parent.add_child(m)
	return slider

func _add_option_row(parent: Control, items: Array, selected: int) -> OptionButton:
	var opt := OptionButton.new()
	for item in items:
		opt.add_item(item)
	opt.selected = selected
	opt.add_theme_font_size_override("font_size", 20)
	opt.custom_minimum_size = Vector2(0, 52)
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left",  24)
	m.add_theme_constant_override("margin_right", 24)
	m.add_theme_constant_override("margin_bottom", 4)
	m.add_child(opt)
	parent.add_child(m)
	return opt

func _add_toggle(parent: Control, init_val: bool, cb: Callable) -> CheckButton:
	var chk := CheckButton.new()
	chk.button_pressed = init_val
	chk.add_theme_font_size_override("font_size", 20)
	chk.add_theme_color_override("font_color", Color.WHITE)
	chk.toggled.connect(cb)
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left",  24)
	m.add_theme_constant_override("margin_bottom", 4)
	m.add_child(chk)
	parent.add_child(m)
	return chk

func _flat_btn(btn: Button, col: Color) -> void:
	var ns := StyleBoxFlat.new()
	ns.bg_color = col.darkened(0.3) if col.a > 0 else Color(0,0,0,0)
	ns.border_color = col if col.a > 0 else Color(0,0,0,0)
	ns.border_width_left = 1
	ns.border_width_right = 1
	ns.border_width_top = 1
	ns.border_width_bottom = 1
	ns.corner_radius_top_left = 10
	ns.corner_radius_top_right = 10
	ns.corner_radius_bottom_left = 10
	ns.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal", ns)
	var hs := ns.duplicate() as StyleBoxFlat
	hs.bg_color = col.darkened(0.1)
	btn.add_theme_stylebox_override("hover",   hs)
	btn.add_theme_stylebox_override("pressed", hs)

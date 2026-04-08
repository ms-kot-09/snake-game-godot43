extends Node2D
# ─── Skin Selection Screen ────────────────────────────────────────────────────
# Shows a 4-column grid of 15 preset skins + 1 custom slot.
# Tapping a skin selects it; tapping Custom opens the RGB editor.

var _time       : float = 0.0
var _hover_idx  : int   = -1
var _edit_open  : bool  = false
var _edit_panel : Control

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var vp := get_viewport_rect().size

	# Root control
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	# Background
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
	_style_flat_btn(back, Color(0,0,0,0))
	back.pressed.connect(func():
		AudioManager.play_click()
		GameData.save_data()
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	)
	header.add_child(back)

	var title := Label.new()
	title.text = "CHOOSE SKIN"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_child(title)

	# Spacer (mirror back btn for centering)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(80, 80)
	header.add_child(spacer)

	# Scroll area
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(0, 80)
	scroll.size     = Vector2(vp.x, vp.y - 80)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var grid_root := VBoxContainer.new()
	grid_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_root.add_theme_constant_override("separation", 0)
	scroll.add_child(grid_root)

	# Current selection label
	var sel_lbl := Label.new()
	sel_lbl.name = "SelLabel"
	var sk := SkinManager.skins[GameData.selected_skin]
	sel_lbl.text = "Selected: " + sk["emoji"] + " " + sk["name"]
	sel_lbl.add_theme_font_size_override("font_size", 22)
	sel_lbl.add_theme_color_override("font_color", Color(0.7, 1.0, 0.8))
	sel_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sel_lbl.custom_minimum_size = Vector2(vp.x, 48)
	grid_root.add_child(sel_lbl)

	# Grid of skins (4 per row)
	var COLS := 4
	var pad  := 10.0
	var card_w := (vp.x - pad * (COLS + 1)) / COLS
	var card_h := card_w * 1.15

	var row : HBoxContainer = null
	for i in SkinManager.skins.size():
		if i % COLS == 0:
			row = HBoxContainer.new()
			row.add_theme_constant_override("separation", int(pad))
			row.alignment = BoxContainer.ALIGNMENT_CENTER
			var margin := MarginContainer.new()
			margin.add_theme_constant_override("margin_left",   int(pad))
			margin.add_theme_constant_override("margin_right",  int(pad))
			margin.add_theme_constant_override("margin_top",    int(pad * 0.5))
			margin.add_theme_constant_override("margin_bottom", int(pad * 0.5))
			margin.add_child(row)
			grid_root.add_child(margin)

		var card := _make_skin_card(i, card_w, card_h)
		row.add_child(card)

	# Custom skin edit panel (hidden by default)
	_edit_panel = _build_edit_panel(vp)
	_edit_panel.visible = false
	root.add_child(_edit_panel)

func _make_skin_card(idx: int, w: float, h: float) -> Control:
	var skin := SkinManager.skins[idx]
	var is_selected := (idx == GameData.selected_skin)

	var card := Panel.new()
	card.custom_minimum_size = Vector2(w, h)
	card.name = "Card_%d" % idx

	var style := StyleBoxFlat.new()
	style.bg_color = skin["bg_tint"].lightened(0.05)
	style.border_color = skin["body_end"] if is_selected else Color(1,1,1,0.15)
	style.border_width_left = style.border_width_right = \
	style.border_width_top  = style.border_width_bottom = 3 if is_selected else 1
	style.corner_radius_top_left = style.corner_radius_top_right = \
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 12
	card.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)

	# Emoji
	var em := Label.new()
	em.text = skin["emoji"]
	em.add_theme_font_size_override("font_size", int(w * 0.32))
	em.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(em)

	# Name
	var nm := Label.new()
	nm.text = skin["name"]
	nm.add_theme_font_size_override("font_size", int(w * 0.15))
	nm.add_theme_color_override("font_color", skin["body_end"])
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(nm)

	# Selected checkmark
	if is_selected:
		var chk := Label.new()
		chk.text = "✓"
		chk.add_theme_font_size_override("font_size", int(w * 0.2))
		chk.add_theme_color_override("font_color", Color(0.2, 1.0, 0.5))
		chk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(chk)

	# Click area
	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_style_flat_btn(btn, Color(0,0,0,0))
	btn.pressed.connect(func(): _on_skin_selected(idx))
	card.add_child(btn)

	return card

func _on_skin_selected(idx: int) -> void:
	AudioManager.play_click()
	GameData.selected_skin = idx
	GameData.save_data()

	if idx == 15:
		# Custom slot → open editor
		_edit_panel.visible = true
		return

	# Rebuild grid to show new selection
	get_tree().reload_current_scene()

func _build_edit_panel(vp: Vector2) -> Control:
	var panel := Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.88)
	panel.add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(20, 20)
	scroll.size     = Vector2(vp.x - 40, vp.y - 40)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "🎨  Custom Skin Editor"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Color pickers
	_add_color_row(vbox, "Body Start (tail)",  "body_start")
	_add_color_row(vbox, "Body End (head)",    "body_end")
	_add_color_row(vbox, "Head Color",         "head")
	_add_color_row(vbox, "Eye Color",          "eye")
	_add_color_row(vbox, "Glow Color",         "glow")

	# Pattern selector
	var pat_lbl := Label.new()
	pat_lbl.text = "Pattern"
	pat_lbl.add_theme_font_size_override("font_size", 20)
	pat_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	vbox.add_child(pat_lbl)

	var pat_opts := OptionButton.new()
	for p in ["gradient", "solid", "rainbow", "checker", "pulse"]:
		pat_opts.add_item(p.capitalize())
	var patterns := ["gradient","solid","rainbow","checker","pulse"]
	pat_opts.selected = patterns.find(GameData.custom_skin["pattern"])
	pat_opts.add_theme_font_size_override("font_size", 20)
	pat_opts.item_selected.connect(func(i: int):
		GameData.custom_skin["pattern"] = patterns[i])
	vbox.add_child(pat_opts)

	# Shape selector
	var shp_lbl := Label.new()
	shp_lbl.text = "Segment Shape"
	shp_lbl.add_theme_font_size_override("font_size", 20)
	shp_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	vbox.add_child(shp_lbl)

	var shp_opts := OptionButton.new()
	for s in ["Rounded", "Circle", "Diamond", "Sharp"]:
		shp_opts.add_item(s)
	var shapes := ["rounded","circle","diamond","sharp"]
	shp_opts.selected = shapes.find(GameData.custom_skin["shape"])
	shp_opts.add_theme_font_size_override("font_size", 20)
	shp_opts.item_selected.connect(func(i: int):
		GameData.custom_skin["shape"] = shapes[i])
	vbox.add_child(shp_opts)

	# Glow toggle
	var glow_chk := CheckButton.new()
	glow_chk.text = "Enable Glow"
	glow_chk.button_pressed = GameData.custom_skin["glow_on"]
	glow_chk.add_theme_font_size_override("font_size", 20)
	glow_chk.add_theme_color_override("font_color", Color.WHITE)
	glow_chk.toggled.connect(func(on: bool):
		GameData.custom_skin["glow_on"] = on)
	vbox.add_child(glow_chk)

	# Buttons
	var btn_box := HBoxContainer.new()
	btn_box.add_theme_constant_override("separation", 12)
	btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_box)

	var save_btn := _make_styled_btn("💾  Save", Color(0.15, 0.7, 0.35))
	save_btn.pressed.connect(func():
		SkinManager.sync_custom_skin()
		GameData.save_data()
		AudioManager.play_click()
		get_tree().reload_current_scene()
	)
	btn_box.add_child(save_btn)

	var cancel_btn := _make_styled_btn("✕  Cancel", Color(0.7, 0.2, 0.2))
	cancel_btn.pressed.connect(func():
		AudioManager.play_click()
		panel.visible = false
	)
	btn_box.add_child(cancel_btn)

	return panel

func _add_color_row(parent: Control, label_text: String, key: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	lbl.custom_minimum_size = Vector2(220, 0)
	lbl.vertical_alignment  = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl)

	# Color preview + picker button
	var preview := ColorRect.new()
	preview.name = "Preview_" + key
	preview.custom_minimum_size = Vector2(50, 44)
	preview.color = GameData.custom_skin[key]
	var prev_style := StyleBoxFlat.new()
	prev_style.corner_radius_top_left    = prev_style.corner_radius_top_right    = 6
	prev_style.corner_radius_bottom_left = prev_style.corner_radius_bottom_right = 6
	preview.add_theme_stylebox_override("panel", prev_style)
	row.add_child(preview)

	var pick_btn := Button.new()
	pick_btn.text = "Pick"
	pick_btn.add_theme_font_size_override("font_size", 18)
	pick_btn.custom_minimum_size = Vector2(90, 44)
	_style_flat_btn(pick_btn, Color(0.2, 0.4, 0.7))
	pick_btn.pressed.connect(func(): _open_color_picker(key, preview))
	row.add_child(pick_btn)

func _open_color_picker(key: String, preview: ColorRect) -> void:
	# Create a popup-like panel with a ColorPicker
	var popup := Panel.new()
	popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	popup.size = Vector2(380, 480)
	popup.position = Vector2(
		get_viewport_rect().size.x * 0.5 - 190,
		get_viewport_rect().size.y * 0.5 - 240)
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.12, 0.12, 0.20)
	ps.border_color = Color(0.4, 0.6, 1.0)
	ps.border_width_left = ps.border_width_right = \
	ps.border_width_top  = ps.border_width_bottom = 2
	ps.corner_radius_top_left = ps.corner_radius_top_right = \
	ps.corner_radius_bottom_left = ps.corner_radius_bottom_right = 12
	popup.add_theme_stylebox_override("panel", ps)
	add_child(popup)

	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.add_theme_constant_override("separation", 10)
	popup.add_child(vb)

	var cp := ColorPicker.new()
	cp.color = GameData.custom_skin[key]
	cp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cp.color_changed.connect(func(c: Color):
		GameData.custom_skin[key] = c
		preview.color = c
	)
	vb.add_child(cp)

	var done := Button.new()
	done.text = "✓  Done"
	done.custom_minimum_size = Vector2(0, 48)
	done.add_theme_font_size_override("font_size", 22)
	_style_flat_btn(done, Color(0.15, 0.65, 0.3))
	done.pressed.connect(func():
		AudioManager.play_click()
		popup.queue_free()
	)
	vb.add_child(done)

func _make_styled_btn(txt: String, col: Color) -> Button:
	var btn := Button.new()
	btn.text = txt
	btn.custom_minimum_size = Vector2(160, 56)
	btn.add_theme_font_size_override("font_size", 22)
	_style_flat_btn(btn, col)
	return btn

func _style_flat_btn(btn: Button, col: Color) -> void:
	var ns := StyleBoxFlat.new()
	ns.bg_color     = col.darkened(0.4) if col.a > 0 else Color(0,0,0,0)
	ns.border_color = col
	ns.border_width_left = ns.border_width_right = \
	ns.border_width_top  = ns.border_width_bottom = 1
	ns.corner_radius_top_left = ns.corner_radius_top_right = \
	ns.corner_radius_bottom_left = ns.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal",  ns)
	var hs := ns.duplicate() as StyleBoxFlat
	hs.bg_color = col.darkened(0.2) if col.a > 0 else Color(1,1,1,0.08)
	btn.add_theme_stylebox_override("hover",   hs)
	btn.add_theme_stylebox_override("pressed", hs)
	btn.add_theme_color_override("font_color", Color.WHITE)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	# Animated top accent line
	var vp  := get_viewport_rect().size
	var t   := _time * 0.6
	for i in 3:
		var alpha  := sin(t + i * 1.2) * 0.3 + 0.4
		var offset := fmod(t * 100 + i * 200, vp.x)
		draw_rect(Rect2(offset - 40, 0, 80, 2),
		          Color(0.2, 1.0, 0.5, alpha * 0.5))

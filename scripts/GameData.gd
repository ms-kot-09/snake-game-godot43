extends Node
# ─── GameData Autoload ────────────────────────────────────────────────────────
# Handles all persistent data: scores, settings, selected skin, custom skin

const SAVE_PATH := "user://save.cfg"

# ── Settings ──────────────────────────────────────────────────────────────────
var sfx_volume    : float = 1.0
var music_volume  : float = 0.5
var grid_size     : int   = 20      # cells per row/col
var speed_level   : int   = 1       # 0=slow 1=normal 2=fast 3=insane
var show_grid     : bool  = false
var vibration     : bool  = true

# ── Progress ──────────────────────────────────────────────────────────────────
var high_score    : int   = 0
var total_eaten   : int   = 0
var selected_skin : int   = 0       # index into SkinManager.skins

# ── Custom skin (slot 15) ─────────────────────────────────────────────────────
var custom_skin : Dictionary = {
	"name":        "Custom",
	"body_start":  Color(0.2, 0.8, 0.3),
	"body_end":    Color(0.0, 0.5, 0.9),
	"head":        Color(1.0, 1.0, 0.3),
	"eye":         Color(1.0, 1.0, 1.0),
	"glow":        Color(0.2, 0.8, 0.3),
	"glow_on":     true,
	"pattern":     "gradient",
	"shape":       "rounded",
}

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	load_data()

func get_speed_interval() -> float:
	match speed_level:
		0: return 0.22   # Slow
		1: return 0.14   # Normal
		2: return 0.09   # Fast
		3: return 0.055  # Insane
		_: return 0.14

func update_high_score(score: int) -> bool:
	if score > high_score:
		high_score = score
		save_data()
		return true
	return false

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "sfx_volume",   sfx_volume)
	cfg.set_value("settings", "music_volume", music_volume)
	cfg.set_value("settings", "grid_size",    grid_size)
	cfg.set_value("settings", "speed_level",  speed_level)
	cfg.set_value("settings", "show_grid",    show_grid)
	cfg.set_value("settings", "vibration",    vibration)
	cfg.set_value("progress", "high_score",   high_score)
	cfg.set_value("progress", "total_eaten",  total_eaten)
	cfg.set_value("progress", "selected_skin",selected_skin)
	# Custom skin
	cfg.set_value("custom", "body_start", custom_skin["body_start"])
	cfg.set_value("custom", "body_end",   custom_skin["body_end"])
	cfg.set_value("custom", "head",       custom_skin["head"])
	cfg.set_value("custom", "eye",        custom_skin["eye"])
	cfg.set_value("custom", "glow",       custom_skin["glow"])
	cfg.set_value("custom", "glow_on",    custom_skin["glow_on"])
	cfg.set_value("custom", "pattern",    custom_skin["pattern"])
	cfg.set_value("custom", "shape",      custom_skin["shape"])
	cfg.save(SAVE_PATH)

func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	sfx_volume    = cfg.get_value("settings", "sfx_volume",   1.0)
	music_volume  = cfg.get_value("settings", "music_volume", 0.5)
	grid_size     = cfg.get_value("settings", "grid_size",    20)
	speed_level   = cfg.get_value("settings", "speed_level",  1)
	show_grid     = cfg.get_value("settings", "show_grid",    false)
	vibration     = cfg.get_value("settings", "vibration",    true)
	high_score    = cfg.get_value("progress", "high_score",   0)
	total_eaten   = cfg.get_value("progress", "total_eaten",  0)
	selected_skin = cfg.get_value("progress", "selected_skin",0)

	if cfg.has_section("custom"):
		custom_skin["body_start"] = cfg.get_value("custom", "body_start", custom_skin["body_start"])
		custom_skin["body_end"]   = cfg.get_value("custom", "body_end",   custom_skin["body_end"])
		custom_skin["head"]       = cfg.get_value("custom", "head",       custom_skin["head"])
		custom_skin["eye"]        = cfg.get_value("custom", "eye",        custom_skin["eye"])
		custom_skin["glow"]       = cfg.get_value("custom", "glow",       custom_skin["glow"])
		custom_skin["glow_on"]    = cfg.get_value("custom", "glow_on",    true)
		custom_skin["pattern"]    = cfg.get_value("custom", "pattern",    "gradient")
		custom_skin["shape"]      = cfg.get_value("custom", "shape",      "rounded")

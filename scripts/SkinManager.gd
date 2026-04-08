extends Node
# ─── SkinManager Autoload ─────────────────────────────────────────────────────
# Defines all 15 preset skins + 1 custom slot.
# Each skin dict keys:
#   name        : String
#   body_start  : Color  (tail end of gradient)
#   body_end    : Color  (head end of gradient)
#   head        : Color
#   eye         : Color
#   glow        : Color
#   glow_on     : bool
#   pattern     : "solid" | "gradient" | "rainbow" | "checker" | "pulse"
#   shape       : "rounded" | "circle" | "diamond" | "sharp"
#   food_color  : Color  (food orb color for this skin)
#   bg_tint     : Color  (subtle board tint)

var skins : Array[Dictionary] = []

func _ready() -> void:
	_define_skins()

func _define_skins() -> void:
	skins.clear()

	# 0 — Classic
	skins.append({
		"name": "Classic", "emoji": "🐍",
		"body_start": Color(0.13, 0.55, 0.13),
		"body_end":   Color(0.20, 0.80, 0.20),
		"head":       Color(0.10, 0.45, 0.10),
		"eye":        Color(1.00, 1.00, 1.00),
		"glow":       Color(0.20, 0.80, 0.20),
		"glow_on": true, "pattern": "gradient",
		"shape": "rounded",
		"food_color": Color(1.0, 0.25, 0.25),
		"bg_tint": Color(0.05, 0.10, 0.05),
	})

	# 1 — Neon Cyan
	skins.append({
		"name": "Neon", "emoji": "⚡",
		"body_start": Color(0.0, 0.5, 0.8),
		"body_end":   Color(0.0, 1.0, 1.0),
		"head":       Color(0.0, 0.8, 1.0),
		"eye":        Color(1.0, 1.0, 0.0),
		"glow":       Color(0.0, 1.0, 1.0),
		"glow_on": true, "pattern": "gradient",
		"shape": "rounded",
		"food_color": Color(1.0, 0.0, 0.8),
		"bg_tint": Color(0.0, 0.05, 0.10),
	})

	# 2 — Fire
	skins.append({
		"name": "Fire", "emoji": "🔥",
		"body_start": Color(0.6, 0.05, 0.0),
		"body_end":   Color(1.0, 0.55, 0.0),
		"head":       Color(1.0, 0.8, 0.0),
		"eye":        Color(1.0, 1.0, 1.0),
		"glow":       Color(1.0, 0.4, 0.0),
		"glow_on": true, "pattern": "gradient",
		"shape": "rounded",
		"food_color": Color(0.0, 0.8, 1.0),
		"bg_tint": Color(0.10, 0.02, 0.0),
	})

	# 3 — Ocean
	skins.append({
		"name": "Ocean", "emoji": "🌊",
		"body_start": Color(0.0, 0.15, 0.55),
		"body_end":   Color(0.0, 0.65, 0.90),
		"head":       Color(0.15, 0.85, 1.0),
		"eye":        Color(1.0, 1.0, 1.0),
		"glow":       Color(0.0, 0.7, 1.0),
		"glow_on": true, "pattern": "gradient",
		"shape": "rounded",
		"food_color": Color(1.0, 0.7, 0.0),
		"bg_tint": Color(0.0, 0.03, 0.10),
	})

	# 4 — Galaxy
	skins.append({
		"name": "Galaxy", "emoji": "🌌",
		"body_start": Color(0.20, 0.0,  0.40),
		"body_end":   Color(0.55, 0.0,  0.90),
		"head":       Color(0.80, 0.20, 1.0),
		"eye":        Color(0.0,  1.0,  1.0),
		"glow":       Color(0.70, 0.0,  1.0),
		"glow_on": true, "pattern": "gradient",
		"shape": "circle",
		"food_color": Color(0.0, 1.0, 0.5),
		"bg_tint": Color(0.05, 0.0, 0.10),
	})

	# 5 — Rainbow
	skins.append({
		"name": "Rainbow", "emoji": "🌈",
		"body_start": Color(1.0, 0.0, 0.0),
		"body_end":   Color(0.5, 0.0, 1.0),
		"head":       Color(1.0, 1.0, 0.0),
		"eye":        Color(1.0, 1.0, 1.0),
		"glow":       Color(1.0, 1.0, 1.0),
		"glow_on": true, "pattern": "rainbow",
		"shape": "rounded",
		"food_color": Color(1.0, 1.0, 1.0),
		"bg_tint": Color(0.05, 0.0, 0.08),
	})

	# 6 — Gold
	skins.append({
		"name": "Gold", "emoji": "👑",
		"body_start": Color(0.55, 0.35, 0.0),
		"body_end":   Color(1.0,  0.85, 0.0),
		"head":       Color(1.0,  1.0,  0.3),
		"eye":        Color(0.0,  0.0,  0.0),
		"glow":       Color(1.0,  0.8,  0.0),
		"glow_on": true, "pattern": "gradient",
		"shape": "diamond",
		"food_color": Color(0.8, 0.0, 1.0),
		"bg_tint": Color(0.08, 0.06, 0.0),
	})

	# 7 — Ice
	skins.append({
		"name": "Ice", "emoji": "❄️",
		"body_start": Color(0.50, 0.80, 1.0),
		"body_end":   Color(0.90, 0.96, 1.0),
		"head":       Color(1.0,  1.0,  1.0),
		"eye":        Color(0.0,  0.4,  0.8),
		"glow":       Color(0.70, 0.92, 1.0),
		"glow_on": true, "pattern": "gradient",
		"shape": "sharp",
		"food_color": Color(1.0, 0.3, 0.1),
		"bg_tint": Color(0.04, 0.06, 0.12),
	})

	# 8 — Toxic
	skins.append({
		"name": "Toxic", "emoji": "☢️",
		"body_start": Color(0.15, 0.50, 0.0),
		"body_end":   Color(0.65, 1.0,  0.0),
		"head":       Color(0.85, 1.0,  0.0),
		"eye":        Color(0.0,  0.0,  0.0),
		"glow":       Color(0.55, 1.0,  0.0),
		"glow_on": true, "pattern": "pulse",
		"shape": "circle",
		"food_color": Color(1.0, 0.0, 0.5),
		"bg_tint": Color(0.03, 0.08, 0.0),
	})

	# 9 — Candy
	skins.append({
		"name": "Candy", "emoji": "🍭",
		"body_start": Color(0.8, 0.0,  0.5),
		"body_end":   Color(1.0, 0.5,  0.8),
		"head":       Color(1.0, 0.8,  0.95),
		"eye":        Color(0.4, 0.0,  0.3),
		"glow":       Color(1.0, 0.3,  0.7),
		"glow_on": true, "pattern": "checker",
		"shape": "rounded",
		"food_color": Color(0.3, 1.0, 0.5),
		"bg_tint": Color(0.10, 0.02, 0.07),
	})

	# 10 — Midnight
	skins.append({
		"name": "Midnight", "emoji": "🌙",
		"body_start": Color(0.04, 0.04, 0.18),
		"body_end":   Color(0.12, 0.12, 0.55),
		"head":       Color(0.20, 0.20, 0.80),
		"eye":        Color(0.5,  0.8,  1.0),
		"glow":       Color(0.15, 0.15, 0.70),
		"glow_on": true, "pattern": "gradient",
		"shape": "rounded",
		"food_color": Color(0.9, 0.9, 0.2),
		"bg_tint": Color(0.02, 0.02, 0.08),
	})

	# 11 — Sunset
	skins.append({
		"name": "Sunset", "emoji": "🌅",
		"body_start": Color(0.7, 0.1,  0.3),
		"body_end":   Color(1.0, 0.5,  0.1),
		"head":       Color(1.0, 0.75, 0.0),
		"eye":        Color(0.2, 0.0,  0.1),
		"glow":       Color(1.0, 0.35, 0.0),
		"glow_on": true, "pattern": "gradient",
		"shape": "rounded",
		"food_color": Color(0.1, 0.5, 1.0),
		"bg_tint": Color(0.10, 0.03, 0.04),
	})

	# 12 — Venom
	skins.append({
		"name": "Venom", "emoji": "🕷️",
		"body_start": Color(0.05, 0.05, 0.05),
		"body_end":   Color(0.20, 0.20, 0.20),
		"head":       Color(0.10, 0.10, 0.10),
		"eye":        Color(1.0,  0.0,  0.0),
		"glow":       Color(0.5,  0.0,  0.0),
		"glow_on": true, "pattern": "solid",
		"shape": "diamond",
		"food_color": Color(1.0, 0.0, 0.0),
		"bg_tint": Color(0.04, 0.0, 0.0),
	})

	# 13 — Electric
	skins.append({
		"name": "Electric", "emoji": "🌩️",
		"body_start": Color(0.4,  0.4,  0.0),
		"body_end":   Color(1.0,  1.0,  0.3),
		"head":       Color(1.0,  1.0,  1.0),
		"eye":        Color(0.0,  0.3,  1.0),
		"glow":       Color(1.0,  1.0,  0.0),
		"glow_on": true, "pattern": "pulse",
		"shape": "sharp",
		"food_color": Color(0.0, 0.3, 1.0),
		"bg_tint": Color(0.06, 0.06, 0.0),
	})

	# 14 — Lava
	skins.append({
		"name": "Lava", "emoji": "🌋",
		"body_start": Color(0.25, 0.0, 0.0),
		"body_end":   Color(0.8,  0.1, 0.0),
		"head":       Color(1.0,  0.4, 0.0),
		"eye":        Color(1.0,  0.9, 0.0),
		"glow":       Color(0.9,  0.2, 0.0),
		"glow_on": true, "pattern": "pulse",
		"shape": "rounded",
		"food_color": Color(0.0, 0.9, 0.5),
		"bg_tint": Color(0.08, 0.01, 0.0),
	})

	# 15 — Custom (loaded from GameData at runtime)
	skins.append({
		"name": "Custom", "emoji": "🎨",
		"body_start": Color(0.2, 0.8, 0.3),
		"body_end":   Color(0.0, 0.5, 0.9),
		"head":       Color(1.0, 1.0, 0.3),
		"eye":        Color(1.0, 1.0, 1.0),
		"glow":       Color(0.2, 0.8, 0.3),
		"glow_on": true, "pattern": "gradient",
		"shape": "rounded",
		"food_color": Color(1.0, 0.3, 0.3),
		"bg_tint": Color(0.03, 0.05, 0.03),
	})

func sync_custom_skin() -> void:
	var cs := GameData.custom_skin
	skins[15]["body_start"] = cs["body_start"]
	skins[15]["body_end"]   = cs["body_end"]
	skins[15]["head"]       = cs["head"]
	skins[15]["eye"]        = cs["eye"]
	skins[15]["glow"]       = cs["glow"]
	skins[15]["glow_on"]    = cs["glow_on"]
	skins[15]["pattern"]    = cs["pattern"]
	skins[15]["shape"]      = cs["shape"]

func get_active_skin() -> Dictionary:
	sync_custom_skin()
	return skins[GameData.selected_skin]

func get_segment_color(skin: Dictionary, index: int, total: int, time: float) -> Color:
	var t := float(index) / max(float(total - 1), 1.0)
	match skin["pattern"]:
		"solid":
			return skin["body_end"]
		"gradient":
			return skin["body_start"].lerp(skin["body_end"], 1.0 - t)
		"rainbow":
			var hue := fmod(t + time * 0.3, 1.0)
			return Color.from_hsv(hue, 1.0, 1.0)
		"checker":
			return skin["body_start"] if (index % 2 == 0) else skin["body_end"]
		"pulse":
			var pulse := (sin(time * 4.0 + t * PI) * 0.5 + 0.5)
			return skin["body_start"].lerp(skin["body_end"], pulse)
		_:
			return skin["body_end"]

# 🐍 Snake Game — Godot 4.3

A polished Snake game for Android with 15 skins, RGB custom editor, particles, and smooth graphics.

## Features
- **15 preset skins** — Classic, Neon, Fire, Ocean, Galaxy, Rainbow, Gold, Ice, Toxic, Candy, Midnight, Sunset, Venom, Electric, Lava
- **Custom skin slot** — Full RGB ColorPicker for body, head, eyes, glow, pattern & shape
- **5 patterns** — Gradient, Solid, Rainbow (animated), Checker, Pulse
- **4 shapes** — Rounded, Circle, Diamond, Sharp
- **Particle explosions** on food eat and death
- **Swipe controls** optimised for mobile
- **Settings** — SFX/music volume, speed (4 levels), grid size (4 options), grid lines, vibration
- **Procedural audio** — all sounds generated in GDScript, no files needed
- **Persistent saves** — high score, skins, settings saved to disk

## Build

### GitHub Actions (automatic)
Push to `main` → APK built automatically → download from **Actions → Artifacts**

For a GitHub Release with the APK attached:
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Local Build
1. Install [Godot 4.3](https://godotengine.org/download/)
2. Clone repo, open `project.godot`
3. Install Android export templates: **Editor → Manage Export Templates**
4. **Project → Export → Android → Export Project**

## Project Layout
```
snake-game/
├── .github/workflows/build.yml   # CI/CD → APK
├── project.godot                 # Godot 4.3 config
├── export_presets.cfg            # Android export
├── icon.svg
├── scenes/
│   ├── Main.tscn                 # Menu
│   ├── Game.tscn                 # Gameplay
│   ├── SkinSelect.tscn           # Skin picker + RGB editor
│   └── Settings.tscn             # Settings
└── scripts/
    ├── GameData.gd               # Autoload: save/load
    ├── SkinManager.gd            # Autoload: 16 skins
    ├── AudioManager.gd           # Autoload: PCM sounds
    ├── Main.gd                   # Menu logic
    ├── Game.gd                   # Snake gameplay
    ├── SkinSelect.gd             # Skin selection + editor
    └── Settings.gd               # Settings UI
```

## Controls
| | PC | Android |
|---|---|---|
| Move | WASD / Arrows | Swipe |
| Pause | Esc | ⏸ button |
| Navigate | Mouse | Touch |

<div align="center">
  <img src="./assets/nix-logo.png" alt="Nix logo" width="96" />

  # hylix

  Hyprland configuration framework.

  [![Nix](https://img.shields.io/badge/Nix-flakes-689d6a?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://nixos.wiki/wiki/Flakes)
  [![Hyprland](https://img.shields.io/badge/Hyprland-Lua%20config-458588?style=flat-square&labelColor=504945&color=458588)](https://hyprland.org)

  [Overview](#overview) — [Modules](#modules) — [Usage](#usage) — [Development](#development) — [Notes](#notes)
</div>

## Overview

Define your Hyprland configuration in Nix. Each domain — settings, keybinds, monitors, animations, rules, environment — gets its own Nix option, and the framework serialises everything into the Lua format consumed by Hyprland's `hyprland.lua`.

This is a refactored fork of [`karol-broda/nixhypr`](https://github.com/karol-broda/nixhypr)

## Modules

All options live under `programs.hylix.*`.

| Nix option | Lua function | What it configures |
|---|---|---|
| `settings` | `hl.config(...)` | Freeform Hyprland settings table |
| `env` | `hl.env(...)` | Environment variables |
| `monitors` | `hl.monitor(...)` | Monitor outputs, resolution, position, scale |
| `animations.curves` | `hl.curve(...)` | Named bezier and spring curves |
| `animations.animations` | `hl.animation(...)` | Animation definitions |
| `devices` | `hl.device(...)` | Input device configuration |
| `permissions` | `hl.permission(...)` | Permission rules (binary, mode, type) |
| `gestures` | `hl.gesture(...)` | Touch gesture bindings |
| `binds` / `bindGroups` | `hl.bind(...)` | Keybindings with optional grouping |
| `rules.window` | `hl.window_rule(...)` | Window matching rules |
| `rules.workspace` | `hl.workspace_rule(...)` | Workspace rules |
| `rules.layer` | `hl.layer_rule(...)` | Layer surface rules |
| `autostart` | `hl.exec_cmd(...)` | Startup commands |
| `extraLua` / `extraLuaSnippets` | *(raw append)* | Arbitrary Lua code |

The generated output respects a deterministic ordering: settings first, then env, monitors, curves, animations, devices, permissions, gestures, binds, window/workspace/layer rules, autostart, and finally extra Lua snippets.

## Usage

Add the flake as an input and import either the generic module set or the Home Manager wrapper.

### Via Home Manager

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hylix.url = "github:adam01110/hylix";
  };
}
```

```nix
{
  imports = [ hylix.homeManagerModules.default ];

  programs.hylix = {
    enable = true;

    settings = {
      decoration = {
        blur = {
          enabled = true;
          size = 5;
        };
      };
    };

    monitors = [
      { name = "DP-1"; width = 2560; height = 1440; }
      { name = "HDMI-A-1"; width = 1920; height = 1080; }
    ];

    binds = [
      { keys = [ "SUPER" "q" ]; action = "window.close"; }
      { keys = [ "SUPER" "Return" ]; exec = "foot"; }
    ];

    autostart = [
      "waybar"
      "mako"
    ];
  };
}
```

If Hyprland's own Home Manager module is enabled, the generated Lua is injected into `extraConfig`. Otherwise it is written to `xdg.configFile."hypr/hyprland.lua"`.

### Without Home Manager

Use the generic module set directly:

```nix
{
  flake.modules.generic.hylix = {
    programs.hylix.settings = {
      general = {
        gaps_in = 2;
        gaps_out = 4;
      };
    };
  };
}
```

## Development

From the repository root:

```bash
# Inspect flake outputs
nix flake show

# Run CI-equivalent checks
nix flake check

# Format the repository
nix fmt
```

Formatting is wired through `treefmt-nix` using `alejandra`, `deadnix`, `statix`, and `keep-sorted`.

## Notes

- This is a framework, not a standalone configuration. It provides the Nix options and serialisation logic; you provide the values.
- The Lua output targets Hyprland's Lua config API (`hl.*` functions). Make sure your Hyprland build supports it.
- `binds` and `bindGroups` both produce the same `hl.bind(...)` output — groups are a convenience for organising related keybinds by category.

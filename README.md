<div align="center">
  <img src="./assets/nix-logo.png" alt="Nix logo" width="112" />

  # hylix

  Hyprland configuration framework.

  [![Repo Size](https://img.shields.io/github/repo-size/adam01110/hylix?style=flat-square&label=repo%20size&labelColor=504945&color=3c3836)](https://github.com/adam01110/hylix)
  <br />
  [![Nix](https://img.shields.io/badge/Nix-flakes-689d6a?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://nixos.wiki/wiki/Flakes)
  [![Hyprland](https://img.shields.io/badge/Hyprland-Lua%20config-458588?style=flat-square&labelColor=504945&color=458588)](https://hyprland.org)

  [Overview](#overview) - [Usage](#usage) - [Modules](#modules)
</div>

## Overview

Define your Hyprland configuration in Nix. Each domain — settings, keybinds, monitors, animations, rules, environment — gets its own Nix option, and the framework serialises everything into the Lua format consumed by Hyprland's `hyprland.lua`.

This is a refactored fork of [`karol-broda/nixhypr`](https://github.com/karol-broda/nixhypr)

## Usage

Add the flake as an input:

```nix
{
  inputs.hylix.url = "github:adam01110/hylix";
}
```

Then import the Home Manager module and set the pieces you care about:

```nix
{
  hylix,
  ...
}: {
  imports = [hylix.homeManagerModules.default];

  programs.hylix = {
    enable = true;

    settings.general = {
      gaps_in = 2;
      gaps_out = 6;
    };

    binds = [
      {
        keys = ["SUPER" "Return"];
        exec = "foot";
      }
    ];
  };
}
```

If `wayland.windowManager.hyprland.enable` is already enabled in Home Manager, hylix puts the generated Lua in `wayland.windowManager.hyprland.extraConfig`. Otherwise it writes `~/.config/hypr/hyprland.lua` through `xdg.configFile`.

For lower-level use, the generic module is exported as `hylix.modules.generic.hylix` and the generated text is exposed at `config.programs.hylix._generatedConfig`.

## Modules

All options live under `programs.hylix.*`.

| Option | Lua output | What it configures |
| --- | --- | --- |
| `settings` | `hl.config(...)` | Freeform Hyprland settings |
| `env` | `hl.env(...)` | Environment variables |
| `monitors` | `hl.monitor(...)` | Outputs, modes, positions, and scale |
| `devices` | `hl.device(...)` | Input device tables |
| `animations.curves` | `hl.curve(...)` | Named bezier and spring curves |
| `animations.animations` | `hl.animation(...)` | Animation rules |
| `rules.window` | `hl.window_rule(...)` | Window matching rules |
| `rules.workspace` | `hl.workspace_rule(...)` | Workspace rules |
| `rules.layer` | `hl.layer_rule(...)` | Layer surface rules |
| `permissions` | `hl.permission(...)` | Permission prompts and allow/deny rules |
| `gestures` | `hl.gesture(...)` | Touch gesture bindings |
| `binds` / `bindGroups` | `hl.bind(...)` | Keybinds, with optional categories |
| `autostart` | `hl.exec_cmd(...)` | Startup commands |
| `notifications` | `hl.notification.create(...)` | Startup notifications |
| `events` | `hl.on(...)` | Hyprland event hooks |
| `extraLua` / `extraLuaSnippets` | raw append | Anything the module options do not cover |

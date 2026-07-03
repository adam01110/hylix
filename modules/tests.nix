{
  config,
  inputs,
  ...
}: {
  perSystem = {system, ...}: let
    inherit (inputs.nixpkgs) lib;
    inherit (lib) mkOrder;

    pkgs = inputs.nixpkgs.legacyPackages.${system};
    hylixLib = config.flake.lib;

    generatedConfig =
      (lib.evalModules {
        modules = [
          config.flake.modules.generic.hylix
          {
            programs.hylix = {
              _generatedConfig = mkOrder 899 ''
                local MAX_ZOOM = 3
                local MIN_ZOOM = 1

                local function zoom_reset()
                    hl.config({ cursor = { zoom_factor = MIN_ZOOM } })
                end
              '';

              animations = {
                animations = [
                  {
                    leaf = "fade";
                    enabled = true;
                    speed = 3.03;
                    bezier = "fadeGeneric";
                  }

                  {
                    leaf = "windows";
                    enabled = true;
                    speed = 4;
                    spring = "springWindow";
                    style = "popin";
                  }
                ];

                curves = {
                  fadeGeneric = {
                    type = "bezier";
                    points = [0.00 0.00 0.20 1.00];
                  };

                  springWindow = {
                    type = "spring";
                    mass = 1;
                    stiffness = 45;
                    dampening = 12;
                  };
                };
              };

              bindGroups = [
                (hylixLib.mkHylixBindGroup "Applications" [
                  {
                    description = "Terminal";
                    keys = ["SUPER" "Return"];
                    exec = "runapp ghostty --initial-window=false +new-window";
                  }
                ])

                (hylixLib.mkHylixBindGroup "Window Management" [
                  {
                    description = "Reset zoom";
                    keys = ["SUPER" "SHIFT" "minus"];
                    lua = "zoom_reset";
                  }

                  {
                    description = "Toggle floating";
                    keys = ["SUPER" "V"];
                    action = "window.float";
                    args.action = "toggle";
                  }
                ])
              ];

              gestures = [
                {
                  direction = "horizontal";
                  fingers = 3;
                  action = "workspace";
                }

                {
                  direction = "pinchout";
                  fingers = 3;
                  action = "exec";
                  exec = "overzicht ipc call overview close";
                }
              ];

              monitors = [
                {
                  output = "DP-1";
                  mode = "1920x1080@144";
                  position = "-1920x96";
                  scale = "1";
                  extra.vrr = 0;
                }

                {
                  output = "eDP-1";
                  mode = "1920x1080@60";
                  position = "0x0";
                  scale = "1";
                }
              ];

              permissions = [
                {
                  binary = ".*/libhyprfocus\\.so$";
                  mode = "allow";
                  type = "plugin";
                }

                {
                  binary = "/nix/store/example-grim/bin/grim";
                  mode = "allow";
                  type = "screencopy";
                }
              ];

              rules = {
                layer = [
                  {
                    match.namespace = "overzicht";
                    blur = true;
                    blur_popups = true;
                    ignore_alpha = 0.94;
                  }
                ];

                window = [
                  {
                    match = {
                      class = "steam";
                      title = "Friends List";
                    };

                    float = true;
                    size = [380 540];
                  }

                  {
                    match.class = "me.iepure.devtoolbox";
                    center = true;
                    float = true;
                    size = [1130 750];
                  }
                ];
              };

              settings = {
                debug = {
                  suppress_errors = true;
                  watchdog_timeout = 0;
                };

                decoration = {
                  active_opacity = 0.95;
                  inactive_opacity = 0.95;
                  rounding = 0;

                  blur = {
                    input_methods = true;
                    popups = true;
                    passes = 2;
                    size = 16;
                  };
                };

                dwindle = {
                  preserve_split = true;
                  special_scale_factor = 0.8;
                };

                ecosystem = {
                  enforce_permissions = true;
                  no_donation_nag = true;
                  no_update_news = true;
                };

                general = {
                  gaps_in = 4;
                  gaps_out = 4;
                  hover_icon_on_border = false;
                };

                input = {
                  accel_profile = "flat";
                  kb_options = "caps:swapescape";
                  mouse_refocus = false;
                  touchdevice.enable = false;
                };

                misc = {
                  disable_hyprland_logo = true;
                  disable_splash_rendering = true;
                  enable_swallow = true;
                  force_default_wallpaper = 0;
                  initial_workspace_tracking = 2;
                  render_unfocused_fps = 1;
                  swallow_regex = "^com\\.mitchellh\\.ghostty$";
                  vrr = 1;
                };

                plugin.hyprfocus = {
                  keyboard_focus_animation = "shrink";
                  mouse_focus_animation = "shrink";
                  shrink_percentage = 0.995;
                };

                xwayland.force_zero_scaling = true;
              };
            };
          }
        ];
      })
      .config
      .programs
      .hylix
      ._generatedConfig;

    expectedConfig = ../assets/hylix-infra-sample.lua;
  in {
    checks.hylix-infra-sample-config =
      pkgs.runCommand "hylix-infra-sample-config" {
        inherit expectedConfig generatedConfig;
        nativeBuildInputs = [pkgs.diffutils];
        passAsFile = ["generatedConfig"];
      } ''
        diff -u "$expectedConfig" "$generatedConfigPath"

        cp "$generatedConfigPath" "$out"
      '';
  };
}

# Zed for .NET work. Imported from profiles/work.nix only, so the gaming entry
# does not get it. Noctalia ships no Zed template, so Home Manager may own
# these files; they stay mutable and the values below are merged over
# whatever Zed saved on every switch.
{ lib, pkgs, ... }:

let
  # `dotnet run`/`watch` need a project, not the solution at the worktree
  # root: walk up from the current file to the nearest *.csproj.
  dotnetNearest = pkgs.writeShellScript "dotnet-nearest" ''
    shopt -s nullglob
    dir=$1
    shift
    while [ "$dir" != / ]; do
      projects=("$dir"/*.csproj)
      [ ''${#projects[@]} -gt 0 ] && break
      dir=$(dirname "$dir")
    done
    if [ "$dir" = / ]; then
      echo "no .csproj found above the current file" >&2
      exit 1
    fi
    cd "$dir" && exec dotnet "$@"
  '';
  nearestTask = label: args: {
    inherit label;
    command = "${dotnetNearest}";
    args = [ "$ZED_DIRNAME" ] ++ args;
    tags = [ "dotnet" ];
  };
in
{
  programs.zed-editor = {
    enable = true;
    # Provides C#, .csproj, MSBuild and .slnx support.
    extensions = [ "csharp" ];

    userSettings = {
      # Zed cannot replace itself inside the Nix store.
      auto_update = false;
      buffer_font_family = "CaskaydiaCove Nerd Font Mono";
      terminal.font_family = "CaskaydiaCove Nerd Font Mono";
      inlay_hints.enabled = true;

      languages.CSharp.language_servers = [
        "roslyn"
        "!omnisharp"
        "!csharp-ls"
      ];

      lsp.roslyn = {
        # The extension would otherwise download an unpatched build from
        # NuGet. With a custom path it drops its default arguments, so they
        # are repeated here. The wrapper uses the SDK found on PATH
        # (dotnet-sdk_10, or a mise-pinned one) for MSBuild.
        binary = {
          path = lib.getExe' pkgs.roslyn-ls "Microsoft.CodeAnalysis.LanguageServer";
          arguments = [
            "--stdio"
            "--autoLoadProjects"
          ];
        };
        settings = {
          # Go-to-definition into referenced assemblies (decompiled sources).
          "csharp|symbol_search".dotnet_search_reference_assemblies = true;
          "csharp|completion" = {
            dotnet_show_completion_items_from_unimported_namespaces = true;
            dotnet_provide_regex_completions = true;
          };
          # Compiler errors for the whole solution in the diagnostics panel;
          # analyzers stay on open files because they are the expensive part.
          "csharp|background_analysis" = {
            dotnet_compiler_diagnostics_scope = "fullSolution";
            dotnet_analyzer_diagnostics_scope = "openFiles";
          };
        };
      };
    };

    userTasks = [
      {
        label = "dotnet: build";
        command = "dotnet";
        args = [ "build" ];
        cwd = "$ZED_WORKTREE_ROOT";
        tags = [ "dotnet" ];
      }
      {
        label = "dotnet: test";
        command = "dotnet";
        args = [ "test" ];
        cwd = "$ZED_WORKTREE_ROOT";
        tags = [ "dotnet" ];
      }
      (nearestTask "dotnet: test current project" [ "test" ])
      (nearestTask "dotnet: run current project" [ "run" ])
      (nearestTask "dotnet: watch current project" [ "watch" ])
    ];
  };
}

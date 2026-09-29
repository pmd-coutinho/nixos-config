{ config, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Keep a large, shared history database outside the home-directory root.
    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.stateHome}/zsh/history";
      extended = true;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;
    };
    setOptions = [ "HIST_REDUCE_BLANKS" ];
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      command_timeout = 1000;
      scan_timeout = 30;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      right_format = "$status$time";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch.symbol = "git ";
      git_status = {
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
      };
      cmd_duration.min_time = 1000;
      status.disabled = false;
      time = {
        disabled = false;
        format = "[$time](dimmed)";
        time_format = "%H:%M";
      };
    };
  };

  programs.atuin = {
    enable = true;
    daemon.enable = true;
    settings.search_mode = "fuzzy";
  };

  programs.zoxide = {
    enable = true;
    options = [
      "--cmd"
      "cd"
    ];
  };
}

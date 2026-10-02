{ lib, pkgs, ... }:

let
  # "@Github" ed25519 key, served by KeePassXC via the ssh-agent user unit.
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8YxI4GHkNBE0ZLNzZC3rFU/1s6GxRjcsXoau5WjoPN";
  email = "pmd.coutinho@gmail.com";
in
{
  programs.git = {
    enable = true;

    signing = {
      format = "ssh";
      key = "key::${signingKey}";
      signByDefault = true;
      # Lets `git log --show-signature` verify locally.
      allowedSigners = "${email} namespaces=\"git\" ${signingKey}";
    };

    settings = {
      user = {
        name = "Pedro Coutinho";
        inherit email;
      };

      core = {
        editor = "nvim";
        # Big working trees: let git use the fs monitor + cache.
        fsmonitor = true;
        untrackedCache = true;
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      fetch.prune = true;
      push = {
        autoSetupRemote = true;
        default = "current";
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };
      # The mergiraf module suggests diff3; zdiff3 keeps the base section too.
      merge.conflictStyle = lib.mkForce "zdiff3";
      rerere.enabled = true;
      branch.sort = "-committerdate";
      column.ui = "auto";

      alias = {
        st = "status";
        co = "checkout";
        sw = "switch";
        br = "branch";
        ci = "commit";
        cm = "commit -m";
        amend = "commit --amend --no-edit";
        unstage = "restore --staged";
        last = "log -1 HEAD --stat";
        df = "diff";
        dc = "diff --cached";
        lg = "log --graph --abbrev-commit --decorate --all --format=format:'%C(bold blue)%h%C(reset) %C(dim white)%an%C(reset)%C(auto)%d%C(reset) %C(white)%s%C(reset) %C(dim white)(%ar)%C(reset)'";
        pf = "push --force-with-lease";
        # Structural (syntax-aware) diff on demand; plain `git diff` stays delta.
        dft = "-c diff.external=difft diff";
      };
    };
  };

  # Pager and interactive diff filter.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "Catppuccin Mocha";
      features = "catppuccin-mocha";

      catppuccin-mocha = {
        # The four diff-background blends are deliberate non-palette mixes
        # (palette red/green blended toward base): keep them literal even if
        # the palette changes.
        minus-style = "syntax #443244";
        minus-emph-style = "syntax #56344a";
        plus-style = "syntax #2c3b3a";
        plus-emph-style = "syntax #3a4f44";
        line-numbers-minus-style = "#f38ba8";
        line-numbers-plus-style = "#a6e3a1";
        line-numbers-zero-style = "#6c7086";
        line-numbers-left-style = "#313244";
        line-numbers-right-style = "#313244";
        file-style = "#cba6f7 bold";
        file-decoration-style = "#cba6f7 ul";
        hunk-header-style = "#89b4fa bold";
        hunk-header-decoration-style = "#45475a box";
        blame-palette = "#1e1e2e #181825 #313244 #45475a";
      };
    };
  };

  # Syntax-aware merge driver that auto-resolves structural conflicts.
  programs.mergiraf = {
    enable = true;
    enableGitIntegration = true;
  };

  home.packages = [
    pkgs.difftastic
    # Secret scanner used by this repo's .githooks/pre-commit.
    pkgs.gitleaks
  ];
}

{
  config,
  pkgs,
  lib,
  utils,
  ...
}:
let
  #servarr = import ./settings-options.nix { inherit lib pkgs; };
  cfg = config.services.lazylibrarian;
in
{
  options = {

    # TODO
    # port
    # listenurl?
    # datadir
    # Dir ebook, audiobook, comic, downloads,manual_import, logs
    # User and group
    # settings:
    # API keys
    # downloaders
    # TODO for calibre
    # calibre server
    # config calibre dir needed

    services.lazylibrarian = {
      enable = lib.mkEnableOption "LazyLibrarian";

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/lazylibrarian";
        description = "The directory where Lazylibrarian stores its data files.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Open ports in the firewall for the Lazylibrarian web interface
        '';
      };

      #environmentFiles = servarr.mkServarrEnvironmentFiles "lazylibrarian";

      #settings = servarr.mkServarrSettingsOptions "lazylibrarian" 8989;

      user = lib.mkOption {
        type = lib.types.str;
        default = "lazylibrarian";
        description = "User account under which LazyLibrarian runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "lazylibrarian";
        description = "Group under which LazyLibrarian runs.";
      };

      package = lib.mkPackageOption pkgs "lazylibrarian" { };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.lazylibrarian = {
      description = "LazyLibrarian";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      #environment = servarr.mkServarrSettingsEnvVars "LAZYLIBRARIAN" cfg.settings;
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        # EnvironmentFile = cfg.environmentFiles;
        ExecStart = utils.escapeSystemdExecArgs [
          (lib.getExe cfg.package)
          #  "-nobrowser"
          # "-data=${cfg.dataDir}"
        ];
        Restart = "on-failure";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.server.port ];
    };

    users.users = lib.mkIf (cfg.user == "lazylibrarian") {
      lazylibrarian = {
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.lazylibrarian;
      };
    };

    users.groups = lib.mkIf (cfg.group == "lazylibrarian") {
      lazylibrarian.gid = config.ids.gids.lazylibrarian;
    };
  };
}

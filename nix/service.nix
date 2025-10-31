{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.pod-service;

  # Build the config file
  configFile = pkgs.writeText "pod-service-config.yaml" (builtins.toJSON {
    server = {
      port = cfg.port;
      host = cfg.host;
      base_url = cfg.baseUrl;
    };
    podcast = {
      title = cfg.podcast.title;
      description = cfg.podcast.description;
      author = cfg.podcast.author;
      language = cfg.podcast.language;
      category = cfg.podcast.category;
      image_url = cfg.podcast.imageUrl;
    };
    storage = {
      data_dir = cfg.dataDir;
      audio_dir = cfg.audioDir;
    };
    watch = {
      enabled = cfg.watch.enabled;
      file = cfg.watch.file;
    };
    log_level = cfg.logLevel;
  });

  # Python environment with pod-service
  pythonEnv = pkgs.python312.withPackages (ps: with ps; [
    flask
    watchdog
    yt-dlp
    pyyaml
    requests
    click
  ]);

in
{
  options.services.pod-service = {
    enable = mkEnableOption "Pod Service - YouTube to Podcast Feed Service";

    port = mkOption {
      type = types.int;
      default = 8083;
      description = "Port to listen on";
    };

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Host to bind to";
    };

    baseUrl = mkOption {
      type = types.str;
      default = "http://localhost:8083";
      description = "Base URL for the service (used in podcast feed)";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/pod-service";
      description = "Base data directory";
    };

    audioDir = mkOption {
      type = types.str;
      default = "/var/lib/pod-service/audio";
      description = "Audio files directory";
    };

    podcast = {
      title = mkOption {
        type = types.str;
        default = "My YouTube Podcast";
        description = "Podcast title";
      };

      description = mkOption {
        type = types.str;
        default = "Converted YouTube videos as podcast episodes";
        description = "Podcast description";
      };

      author = mkOption {
        type = types.str;
        default = "Pod Service";
        description = "Podcast author";
      };

      language = mkOption {
        type = types.str;
        default = "en-us";
        description = "Podcast language";
      };

      category = mkOption {
        type = types.str;
        default = "Technology";
        description = "Podcast category";
      };

      imageUrl = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "URL to podcast cover image";
      };
    };

    watch = {
      enabled = mkOption {
        type = types.bool;
        default = true;
        description = "Enable file watching";
      };

      file = mkOption {
        type = types.str;
        default = "/var/lib/pod-service/urls.txt";
        description = "File to watch for YouTube URLs";
      };
    };

    logLevel = mkOption {
      type = types.str;
      default = "INFO";
      description = "Logging level (DEBUG, INFO, WARNING, ERROR)";
    };

    user = mkOption {
      type = types.str;
      default = "pod-service";
      description = "User to run the service as";
    };

    group = mkOption {
      type = types.str;
      default = "pod-service";
      description = "Group to run the service as";
    };
  };

  config = mkIf cfg.enable {
    # Create user and group
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
      description = "Pod Service user";
    };

    users.groups.${cfg.group} = { };

    # Systemd service (for NixOS)
    systemd.services.pod-service = mkIf pkgs.stdenv.isLinux {
      description = "Pod Service - YouTube to Podcast Feed";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${pythonEnv}/bin/python -m pod_service serve --config ${configFile}";
        Restart = "on-failure";
        RestartSec = "10s";

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir cfg.audioDir ];
      };

      preStart = ''
        # Ensure directories exist
        mkdir -p ${cfg.dataDir}
        mkdir -p ${cfg.audioDir}
        mkdir -p ${cfg.dataDir}/Metadata

        # Create watch file if it doesn't exist
        if [ ! -f ${cfg.watch.file} ]; then
          touch ${cfg.watch.file}
        fi

        # Set permissions
        chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}
      '';
    };

    # Launchd service (for macOS/nix-darwin)
    launchd.daemons.pod-service = mkIf pkgs.stdenv.isDarwin {
      serviceConfig = {
        ProgramArguments = [
          "${pythonEnv}/bin/python"
          "-m"
          "pod_service"
          "serve"
          "--config"
          "${configFile}"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardErrorPath = "${cfg.dataDir}/pod-service.error.log";
        StandardOutPath = "${cfg.dataDir}/pod-service.out.log";
        WorkingDirectory = cfg.dataDir;
      };
    };
  };
}

# Example configuration for pod-service
# Add this to your NixOS or nix-darwin configuration

{ config, pkgs, ... }:

{
  # Import the service module
  imports = [
    /path/to/pod-service/nix/service.nix
  ];

  # Or if using flakes:
  # imports = [
  #   inputs.pod-service.nixosModules.default
  # ];

  services.pod-service = {
    enable = true;

    # Server configuration
    port = 8083;
    host = "0.0.0.0";
    baseUrl = "http://192.168.50.4:8083"; # Update to your server's IP/domain

    # Storage paths
    dataDir = "/Volumes/Storage/Data/Tmp/Pod-Service"; # macOS
    # dataDir = "/var/lib/pod-service"; # Linux

    audioDir = "/Volumes/Storage/Data/Tmp/Pod-Service/Audio"; # macOS
    # audioDir = "/var/lib/pod-service/Audio"; # Linux

    # Podcast metadata
    podcast = {
      title = "My YouTube Podcast";
      description = "Converted YouTube videos as podcast episodes";
      author = "Your Name";
      language = "en-us";
      category = "Technology";
      # imageUrl = "https://example.com/cover.jpg"; # Optional
    };

    # File watching
    watch = {
      enabled = true;
      file = "/Volumes/Storage/Data/Tmp/Pod-Service/Urls.txt"; # macOS
      # file = "/var/lib/pod-service/Urls.txt"; # Linux
    };

    # Logging
    logLevel = "INFO";
  };

  # Optional: Open firewall port (NixOS only)
  # networking.firewall.allowedTCPPorts = [ 8083 ];
}

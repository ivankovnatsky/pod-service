# Pod Service

YouTube to Podcast Feed Service - Convert YouTube URLs to podcast episodes.

A lightweight Python service that watches a file for YouTube URLs, downloads
them as audio using yt-dlp, and serves them as a podcast feed compatible with
Apple Podcasts and other podcast players.

## Features

- 🎙️ **HTTP server** serving a podcast RSS feed with iTunes extensions
- 👀 **File watching** for automatic YouTube URL processing
- 📥 **Automatic download** using yt-dlp (high-quality audio)
- 🔄 **Real-time updates** - new episodes appear immediately
- 📱 **Apple Podcast compatible** feed
- 🚀 **NixOS/nix-darwin** service module for easy deployment
- 🔒 **Lightweight** - simple Python service with minimal dependencies

## Installation

```bash
# Clone the repo
git clone https://github.com/ivankovnatsky/pod-service
cd pod-service

# Using Nix (recommended)
make dev

# Or with poetry
poetry install
```

## Quick Start (Local Development)

The fastest way to try it out:

```bash
# Start the service (automatically sets up /tmp/pod-service)
make serve

# In another terminal, add a YouTube URL
echo "https://www.youtube.com/watch?v=dQw4w9WgXcQ" >> /Volumes/Storage/Data/Tmp/Pod-Service/Urls.txt

# Open in your browser
open http://localhost:8083/feed.xml
```

That's it! The service will download the video as audio and add it to the feed.

## Production Setup

1. **Initialize configuration:**
   ```bash
   pod-service init
   ```

2. **Edit the config file:**
   - macOS: `~/Library/Application Support/pod-service/config.yaml`
   - Linux: `~/.config/pod-service/config.yaml`

3. **Start the service:**
   ```bash
   pod-service serve
   ```

4. **Subscribe in Apple Podcasts:**
   - File → Add a Show by URL
   - Enter: `http://your-server:8083/feed.xml`

## Development Commands

```bash
# Quick commands (using Makefile)
make serve         # Start dev service
make clean         # Clean temp files
make info          # Show config
make test          # Run tests
make help          # Show all commands

# Or use CLI directly
pod-service serve  # Start service
pod-service init   # Initialize config
pod-service info   # Show info

# With tmuxinator (full dev environment)
tmuxinator start pod-service
```

## Configuration

Configuration file is located at:
- macOS: `~/Library/Application Support/pod-service/config.yaml`
- Linux: `~/.config/pod-service/config.yaml`

Example configuration:

```yaml
server:
  port: 8083
  host: "0.0.0.0"

podcast:
  title: "My YouTube Podcast"
  description: "Converted YouTube videos"
  author: "Pod Service"

storage:
  data_dir: "/path/to/storage"
  audio_dir: "/path/to/storage/audio"

watch:
  file: "/path/to/urls.txt"
```

## Deployment

For production deployment on NixOS or nix-darwin, see [DEPLOYMENT.md](DEPLOYMENT.md).

## How It Works

1. Service watches a text file for YouTube URLs
2. When URLs are detected, yt-dlp downloads the audio as MP3
3. Episode metadata is extracted and saved
4. The podcast feed XML is updated automatically
5. Audio files are served via HTTP
6. Successfully processed URLs are removed from the watch file

## Project Structure

```
pod_service/
├── __init__.py       # Package initialization
├── __main__.py       # Module entry point
├── cli.py            # CLI interface
├── config.py         # Configuration management
├── daemon.py         # Main service daemon
├── downloader.py     # YouTube downloader (yt-dlp)
├── feed.py           # Podcast RSS feed generator
├── server.py         # HTTP server (Flask)
└── watcher.py        # File watching (watchdog)
```

## Similar Projects

This service is inspired by:
- [podsync](https://github.com/mxpv/podsync) - Full-featured YouTube/Vimeo to podcast converter (Go)
- [textcast](https://github.com/ivankovnatsky/textcast) - Text-to-speech podcast service (Python)

Pod-service is simpler and more focused: just YouTube URLs to podcast episodes.

## Requirements

- Python 3.8+
- ffmpeg (for audio conversion)
- yt-dlp

## License

MIT

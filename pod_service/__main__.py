"""Allow running pod_service as a module: python -m pod_service."""

from .cli import main

if __name__ == "__main__":
    main()

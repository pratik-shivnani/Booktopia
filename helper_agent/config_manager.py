"""Configuration management for the Booktopia Helper Agent."""

import os
import yaml
from pathlib import Path

CONFIG_FILE = Path(__file__).parent / "config.yaml"
STATE_FILE = Path(__file__).parent / "state.json"

DEFAULT_CONFIG = {
    "github": {
        "pat": "",
        "owner": "",
        "data_repo": "booktopia-data",
        "source_repo": "booktopia",
    },
    "ollama": {
        "model": "llama3.1",
        "host": "http://localhost:11434",
    },
}


def load_config() -> dict:
    """Load config from config.yaml, creating from defaults if missing."""
    if not CONFIG_FILE.exists():
        save_config(DEFAULT_CONFIG)
        return DEFAULT_CONFIG.copy()

    with open(CONFIG_FILE, "r") as f:
        data = yaml.safe_load(f) or {}

    # Merge with defaults for any missing keys
    merged = DEFAULT_CONFIG.copy()
    for section, values in merged.items():
        if section in data and isinstance(data[section], dict):
            values.update(data[section])
        merged[section] = values

    return merged


def save_config(config: dict):
    """Save config to config.yaml."""
    CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(CONFIG_FILE, "w") as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)


def get_github_config(config: dict) -> dict:
    return config.get("github", DEFAULT_CONFIG["github"])


def get_ollama_config(config: dict) -> dict:
    return config.get("ollama", DEFAULT_CONFIG["ollama"])


def load_state() -> dict:
    """Load agent state (last analyzed chapters, etc.)."""
    import json

    if not STATE_FILE.exists():
        return {"books": {}}

    with open(STATE_FILE, "r") as f:
        return json.load(f)


def save_state(state: dict):
    """Save agent state."""
    import json

    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(STATE_FILE, "w") as f:
        json.dump(state, f, indent=2)

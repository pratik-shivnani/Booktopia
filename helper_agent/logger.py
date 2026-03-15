"""Centralized logging for the Booktopia Helper Agent.

Writes to booktopia_helper.log next to the executable / script.
Rotates at 2 MB, keeps 3 backups.
"""

import logging
import sys
import platform
from logging.handlers import RotatingFileHandler
from pathlib import Path

LOG_FILE = Path(__file__).parent / "booktopia_helper.log"

_initialized = False


def setup_logging(level: int = logging.DEBUG) -> logging.Logger:
    """Configure and return the root 'booktopia' logger."""
    global _initialized

    logger = logging.getLogger("booktopia")

    if _initialized:
        return logger

    logger.setLevel(level)

    # File handler — detailed
    fh = RotatingFileHandler(
        LOG_FILE, maxBytes=2 * 1024 * 1024, backupCount=3, encoding="utf-8"
    )
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(logging.Formatter(
        "%(asctime)s | %(levelname)-7s | %(name)s.%(funcName)s:%(lineno)d | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    ))
    logger.addHandler(fh)

    # Console handler — errors only (don't pollute TUI)
    ch = logging.StreamHandler(sys.stderr)
    ch.setLevel(logging.ERROR)
    ch.setFormatter(logging.Formatter("%(levelname)s: %(message)s"))
    logger.addHandler(ch)

    _initialized = True

    # Log startup diagnostics
    logger.info("=" * 60)
    logger.info("Booktopia Helper Agent starting")
    logger.info("Python %s", sys.version)
    logger.info("Platform: %s %s", platform.system(), platform.release())
    logger.info("Machine: %s", platform.machine())
    logger.info("Executable: %s", sys.executable)
    logger.info("Frozen: %s", getattr(sys, 'frozen', False))
    logger.info("Script dir: %s", Path(__file__).parent.resolve())
    logger.info("Log file: %s", LOG_FILE.resolve())

    # Log available modules for debugging import issues
    _log_module_check(logger)

    logger.info("=" * 60)
    return logger


def _log_module_check(logger: logging.Logger):
    """Try importing critical modules and log success/failure."""
    modules = [
        "textual",
        "textual.app",
        "textual.widgets",
        "textual.widgets._tab_pane",
        "rich",
        "ollama",
        "ebooklib",
        "ebooklib.epub",
        "bs4",
        "github",
        "yaml",
    ]
    for mod in modules:
        try:
            __import__(mod)
            logger.debug("  import %-40s OK", mod)
        except ImportError as e:
            logger.warning("  import %-40s FAILED: %s", mod, e)


def get_logger(name: str = "booktopia") -> logging.Logger:
    """Get a child logger. Call setup_logging() first."""
    return logging.getLogger(name)

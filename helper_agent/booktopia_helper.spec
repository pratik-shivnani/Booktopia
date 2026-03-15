# -*- mode: python ; coding: utf-8 -*-
"""PyInstaller spec for Booktopia Helper Agent.

Produces a single booktopia-helper.exe that launches the TUI on double-click.
"""

from PyInstaller.utils.hooks import collect_submodules

a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('config.yaml.example', '.'),
    ],
    hiddenimports=[
        'tui',
        'logger',
        'analyzer',
        'epub_reader',
        'github_sync',
        'config_manager',
        'ollama',
        'ebooklib',
        'ebooklib.epub',
        'bs4',
        'github',
        'yaml',
    ] + collect_submodules('textual') + collect_submodules('rich'),
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='booktopia-helper',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    icon=None,
)

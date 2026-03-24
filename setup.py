"""
py2app build config for ClipStash.
Usage: python setup.py py2app
"""

from setuptools import setup

APP = ["clipboard_manager.py"]
DATA_FILES = []

OPTIONS = {
    "argv_emulation": False,
    "plist": {
        "CFBundleName": "ClipStash",
        "CFBundleDisplayName": "ClipStash",
        "CFBundleIdentifier": "com.clipstash.app",
        "CFBundleVersion": "1.0.0",
        "CFBundleShortVersionString": "1.0.0",
        "LSUIElement": True,  # Hide from Dock
        "NSAppTransportSecurity": {"NSAllowsArbitraryLoads": True},
    },
    "packages": ["rumps"],
}

setup(
    app=APP,
    data_files=DATA_FILES,
    options={"py2app": OPTIONS},
    setup_requires=["py2app"],
)

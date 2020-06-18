#!/bin/bash

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------

jazzy \
	--clean \
	--author 'Patrick Bodet' \
    --author_url 'https://github.com/iDevelopper' \
    --github_url 'https://github.com/iDevelopper/PBPopupController' \
    --sdk iphonesimulator \
    --xcodebuild-arguments -scheme,'PBPopupController' \
    --module 'PBPopupController' \
    --framework-root . \
    --readme README.md \
    --output docs/

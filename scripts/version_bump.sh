#!/usr/bin/env bash

NEW_TAG="v1.3.$(date +%s)"

git tag "$NEW_TAG"
git push origin "$NEW_TAG"

echo "Tagged new version: $NEW_TAG"
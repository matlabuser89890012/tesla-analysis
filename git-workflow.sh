#!/bin/bash

# Unified Git workflow script for tesla-stock-analysis

set -e

echo "🔄 Staging all changes..."
git add .

echo "📝 Enter commit message:"
read -r COMMIT_MSG

git commit -m "$COMMIT_MSG"

# Check if remote 'origin' exists and points to the correct URL
REMOTE_URL="https://github.com/matlabuser89890012/tesla-analysis.git"
if git remote | grep -q "^origin$"; then
    CURRENT_URL=$(git remote get-url origin)
    if [ "$CURRENT_URL" != "$REMOTE_URL" ]; then
        echo "🔁 Updating remote 'origin' to $REMOTE_URL"
        git remote remove origin
        git remote add origin "$REMOTE_URL"
    fi
else
    echo "🔗 Adding remote 'origin' as $REMOTE_URL"
    git remote add origin "$REMOTE_URL"
fi

echo "🔍 Verifying remote:"
git remote -v

echo "⬇️ Pulling remote changes with rebase..."
git pull --rebase origin main

echo "⬆️ Pushing commits to main and setting upstream..."
git push -u origin main

echo "✅ Git workflow complete."

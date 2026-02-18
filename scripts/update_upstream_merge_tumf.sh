#!/usr/bin/env bash
set -euo pipefail

# Update from upstream/main and merge into tumf branch, then push.
# Assumes remotes: upstream (getclawe/clawe), origin (tumf/clawe)

UPSTREAM_BRANCH=${UPSTREAM_BRANCH:-upstream-main}
TUMF_BRANCH=${TUMF_BRANCH:-tumf}

# Ensure we have the latest refs

echo "==> Fetching remotes..."
git fetch upstream

git fetch origin

# Ensure tracking branch exists
if ! git show-ref --verify --quiet "refs/heads/${UPSTREAM_BRANCH}"; then
  echo "==> Creating local ${UPSTREAM_BRANCH} tracking upstream/main"
  git branch --track "${UPSTREAM_BRANCH}" upstream/main
fi

# Fast-forward upstream-main

echo "==> Updating ${UPSTREAM_BRANCH}..."
current=$(git rev-parse --abbrev-ref HEAD)
git checkout "${UPSTREAM_BRANCH}" >/dev/null

git pull --ff-only upstream main

# Merge into tumf

echo "==> Merging ${UPSTREAM_BRANCH} -> ${TUMF_BRANCH}..."
git checkout "${TUMF_BRANCH}" >/dev/null

git merge --no-edit "${UPSTREAM_BRANCH}"

# Push

echo "==> Pushing ${TUMF_BRANCH} to origin..."
git push origin "${TUMF_BRANCH}"

# Return to previous branch (best effort)
if [ "${current}" != "${TUMF_BRANCH}" ]; then
  git checkout "${current}" >/dev/null || true
fi

echo "==> Done."

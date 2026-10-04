#!/usr/bin/env bash
#
# Keep this fork (Clackz/Luma-Framework) in step with upstream (Filoppi/Luma-Framework).
#
#   ./sync-upstream.sh              fetch and report what would change (no writes)
#   ./sync-upstream.sh rebase       ...then replay the fork-only commits onto upstream/main
#   ./sync-upstream.sh merge        ...then merge upstream/main into main instead
#   ./sync-upstream.sh cherry <sha> cherry-pick upstream commits onto the current branch
#   ./sync-upstream.sh drift        how far the Snowbreak mod has drifted from the UE template
#
# Full procedure, and which paths belong to whom: UPSTREAM-SYNC.md
#
# Requires git on PATH (Git Bash / PortableGit).

# MSYS turns "ref:path" into "ref\path" (drive-letter heuristic), which breaks
# every git show/diff of a single file below.
export MSYS_NO_PATHCONV=1

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FORK_REF="${FORK_REF:-main}"
UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-main}"
UPSTREAM_REF="$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"

UE_TEMPLATE='Source/Games/Unreal Engine/main.cpp'
SNOWBREAK='Source/Games/Snowbreak Containment Zone/main.cpp'

# The generic surface: upstream-owned paths a sync may move under us.
# Keep in sync with UPSTREAM-SYNC.md.
GENERIC_PATHS=(
   'Source/Core/'
   'Source/External/'
   'Source/Games/Unreal Engine/'
   'Source/Games/_Template/'
   'Source/Games/_Generic Mod/'
   'Shaders/Unreal Engine/'
   'Luma.sln'
   '.github/workflows/build_and_release.yml'
   '.github/workflows/lint.yml'
)

MODE="${1:-report}"

if [ "$MODE" = drift ]; then
   echo "UE template      $UE_TEMPLATE"
   echo "Snowbreak        $SNOWBREAK"
   echo
   printf '%-22s %6s lines\n' "UE template @$UPSTREAM_REF" "$(git show "$UPSTREAM_REF:$UE_TEMPLATE" | wc -l)"
   printf '%-22s %6s lines\n' "Snowbreak @$UPSTREAM_REF" "$(git show "$UPSTREAM_REF:$SNOWBREAK" | wc -l)"
   printf '%-22s %6s lines\n' "Snowbreak @$FORK_REF" "$(git show "$FORK_REF:$SNOWBREAK" | wc -l)"
   echo
   echo "=== template -> Snowbreak, as it stands upstream (+added / -removed) ==="
   git diff --numstat "$UPSTREAM_REF:$UE_TEMPLATE" "$UPSTREAM_REF:$SNOWBREAK" || true
   echo
   echo "=== fork-only delta on Snowbreak (+added / -removed) ==="
   git diff --numstat "$UPSTREAM_REF:$SNOWBREAK" "$FORK_REF:$SNOWBREAK" || true
   echo
   echo "Full diff: git diff \"$UPSTREAM_REF:$UE_TEMPLATE\" \"$FORK_REF:$SNOWBREAK\""
   exit 0
fi

echo "fetching $UPSTREAM_REMOTE ..."
git fetch --prune "$UPSTREAM_REMOTE"

MERGE_BASE="$(git merge-base "$FORK_REF" "$UPSTREAM_REF")"

echo
echo "fork     $FORK_REF       $(git rev-parse --short "$FORK_REF")"
echo "upstream $UPSTREAM_REF   $(git rev-parse --short "$UPSTREAM_REF")"
echo "base     (merge-base)    $(git rev-parse --short "$MERGE_BASE")"

INCOMING="$(git rev-list --count "$MERGE_BASE..$UPSTREAM_REF")"
FORKED="$(git rev-list --count "$MERGE_BASE..$FORK_REF")"
echo
echo "upstream commits not in fork : $INCOMING"
echo "fork commits not in upstream  : $FORKED"

if [ "$INCOMING" -gt 0 ]; then
   echo
   echo "=== new upstream commits ==="
   git log --oneline "$MERGE_BASE..$UPSTREAM_REF"
fi

if [ "$FORKED" -gt 0 ]; then
   echo
   echo "=== fork-only commits (these get replayed by 'rebase') ==="
   git log --oneline "$MERGE_BASE..$FORK_REF"
fi

if [ "$INCOMING" -gt 0 ]; then
   TMP="$(mktemp -d)"
   git diff --name-only "$MERGE_BASE" "$UPSTREAM_REF" | sort > "$TMP/up"
   git diff --name-only "$MERGE_BASE" "$FORK_REF" | sort > "$TMP/fork"

   echo
   echo "=== upstream touched the generic surface ==="
   while IFS= read -r p; do
      grep -F -q "$p" "$TMP/up" && echo "  $p"
   done < <(printf '%s\n' "${GENERIC_PATHS[@]}") || true

   echo
   echo "=== conflict candidates (changed on both sides) ==="
   comm -12 "$TMP/up" "$TMP/fork" || true
   echo "  (empty = upstream moved nothing this fork also moved)"
   rm -rf "$TMP"
fi

case "$MODE" in
   report)
      echo
      echo "report only, nothing was changed. Re-run with 'rebase', 'merge', 'cherry' or 'drift'."
      ;;
   rebase)
      echo
      echo "git rebase --onto $UPSTREAM_REF $MERGE_BASE $FORK_REF"
      git rebase --onto "$UPSTREAM_REF" "$MERGE_BASE" "$FORK_REF"
      ;;
   merge)
      git checkout "$FORK_REF"
      git merge --no-ff "$UPSTREAM_REF" -m "Merge $UPSTREAM_REF into $FORK_REF"
      ;;
   cherry)
      shift
      git cherry-pick "$@"
      ;;
   *)
      echo "unknown mode: $MODE" >&2
      exit 2
      ;;
esac

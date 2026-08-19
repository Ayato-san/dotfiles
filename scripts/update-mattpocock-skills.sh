#!/bin/sh

set -eu

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CONFIG_FILE="${CONFIG_FILE:-$DOTFILES_DIR/conf.toml}"

# shellcheck source=scripts/utils.sh
. "$DOTFILES_DIR/scripts/utils.sh"

REPOSITORY="mattpocock/skills"
API_URL="https://api.github.com/repos/$REPOSITORY/commits?per_page=1"
SKILLS_DIR="$DOTFILES_DIR/.agents/skills"

SKILL_PATHS="
skills/engineering/code-review
skills/engineering/codebase-design
skills/engineering/domain-modeling
skills/engineering/grill-with-docs
skills/engineering/implement
skills/engineering/prototype
skills/engineering/research
skills/engineering/resolving-merge-conflicts
skills/engineering/setup-matt-pocock-skills
skills/engineering/tdd
skills/engineering/to-spec
skills/engineering/to-tickets
skills/engineering/wayfinder
skills/productivity/grill-me
skills/productivity/grilling
skills/productivity/handoff
skills/productivity/writing-for-agents
"

skills_are_present() {
  for _skill_path in $SKILL_PATHS; do
    _skill_name=${_skill_path##*/}
    if [ ! -f "$SKILLS_DIR/$_skill_name/SKILL.md" ]; then
      return 1
    fi
  done
}

command -v tar >/dev/null 2>&1 || {
  echo "Error: tar is required to update skills." >&2
  exit 1
}

REMOTE_SHA=$(fetch_github_sha "$API_URL")
LOCAL_SHA=$(get_toml_val "external" "mattpocock-skills")

if [ "$LOCAL_SHA" = "$REMOTE_SHA" ] && skills_are_present; then
  echo "$REPOSITORY skills are up to date"
  exit 0
fi

echo "Updating $REPOSITORY skills..."

TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mattpocock-skills.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM
ARCHIVE_URL="https://github.com/$REPOSITORY/archive/$REMOTE_SHA.tar.gz"
SOURCE_DIR="$TMP_DIR/source"
mkdir -p "$SOURCE_DIR"

if ! curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$SOURCE_DIR" --strip-components=1; then
  echo "Error: Failed to download $REPOSITORY at $REMOTE_SHA." >&2
  exit 1
fi

# Validate the complete batch before replacing any installed skill.
for _skill_path in $SKILL_PATHS; do
  if [ ! -f "$SOURCE_DIR/$_skill_path/SKILL.md" ]; then
    echo "Error: Upstream skill '$_skill_path' is missing a SKILL.md." >&2
    exit 1
  fi
done

mkdir -p "$SKILLS_DIR"
for _skill_path in $SKILL_PATHS; do
  _skill_name=${_skill_path##*/}
  rm -rf "$SKILLS_DIR/$_skill_name"
  cp -R "$SOURCE_DIR/$_skill_path" "$SKILLS_DIR/$_skill_name"
done

set_toml_val "external" "mattpocock-skills" "$REMOTE_SHA" "$CONFIG_FILE"
echo "Updated $REPOSITORY skills to $REMOTE_SHA"

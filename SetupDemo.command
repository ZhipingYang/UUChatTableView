#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEMO_DIR="$ROOT_DIR/Demo"
PROJECT_FILE="$DEMO_DIR/UUChatTableViewDemo.xcodeproj"
WORKSPACE_FILE="$DEMO_DIR/UUChatTableViewDemo.xcworkspace"
PBXPROJ_FILE="$PROJECT_FILE/project.pbxproj"
PODS_DIR="$DEMO_DIR/Pods"
LOCK_FILE="$DEMO_DIR/Podfile.lock"
COCOAPODS_COMPATIBLE_OBJECT_VERSION="63"

print_step() {
  printf "\n==> %s\n" "$1"
}

show_alert() {
  local title="$1"
  local message="$2"
  local severity="${3:-warning}"

  if command -v osascript >/dev/null 2>&1; then
    osascript -e "display alert \"$title\" message \"$message\" as $severity"
  fi
}

abort_setup() {
  local title="$1"
  local message="$2"
  trap - ERR
  echo "$title: $message" >&2
  show_alert "$title" "$message" critical
  exit 1
}

handle_error() {
  local exit_code="$?"
  trap - ERR
  show_alert "Initialization Failed" "SetupDemo.command failed. Check the Terminal output for details." critical
  exit "$exit_code"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    abort_setup "Missing Tool" "Please install '$1' first, then run SetupDemo.command again."
  fi
}

clean_generated_files() {
  rm -rf "$PROJECT_FILE" "$WORKSPACE_FILE" "$PODS_DIR" "$LOCK_FILE"
}

normalize_project_format() {
  if [[ ! -f "$PBXPROJ_FILE" ]]; then
    abort_setup "Project Missing" "Generated project file was not found at $PBXPROJ_FILE."
  fi

  /usr/bin/perl -0pi -e "s/objectVersion = \\d+;/objectVersion = $COCOAPODS_COMPATIBLE_OBJECT_VERSION;/g; s/\\n\\s*preferredProjectObjectVersion = \\d+;//g" "$PBXPROJ_FILE"
}

trap handle_error ERR

print_step "Checking required tools"
require_command xcodegen
require_command pod
require_command open

print_step "Switching to Demo directory"
cd "$DEMO_DIR"

print_step "Cleaning generated files"
clean_generated_files

print_step "Generating Xcode project"
xcodegen generate

print_step "Normalizing project format for CocoaPods"
normalize_project_format

print_step "Installing CocoaPods dependencies"
pod install

if [[ ! -d "$WORKSPACE_FILE" ]]; then
  abort_setup "Workspace Missing" "Workspace was not generated successfully."
fi

print_step "Opening workspace in Xcode"
/usr/bin/open -a Xcode "$WORKSPACE_FILE"

print_step "Done"
echo "Project initialized successfully."

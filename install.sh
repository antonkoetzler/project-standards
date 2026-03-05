#!/usr/bin/env bash
# Project Standards Installer
#
# Unix / macOS / Git Bash:
#   bash <(curl -fsSL https://raw.githubusercontent.com/antonkoetzler/myoro-project-standards/main/install.sh)
#
# Options:
#   --dry-run   Show what would be created without writing any files
#   --sync      Re-fetch previously installed standards (reads docs/myoro-project-standards/.manifest)

set -euo pipefail

REPO="https://raw.githubusercontent.com/antonkoetzler/myoro-project-standards/main"
DRY_RUN=0
SYNC=0
for _a in "$@"; do
  [[ "$_a" == "--dry-run" || "$_a" == "-n" ]] && DRY_RUN=1
  [[ "$_a" == "--sync" ]] && SYNC=1
done

# ── Colors ────────────────────────────────────────────────────────────────────
_has_color() { command -v tput &>/dev/null && tput colors &>/dev/null 2>&1 && [[ $(tput colors) -ge 8 ]]; }
if _has_color; then
  RST='\033[0m' BOLD='\033[1m' DIM='\033[2m'
  GRN='\033[32m' CYN='\033[36m' YLW='\033[33m' RED='\033[31m' WHT='\033[97m'
else
  RST='' BOLD='' DIM='' GRN='' CYN='' YLW='' RED='' WHT=''
fi

# ── Fetch helper ──────────────────────────────────────────────────────────────
_fetch() {
  if command -v curl &>/dev/null; then
    curl -fsSL "$1"
  elif command -v wget &>/dev/null; then
    wget -qO- "$1"
  else
    printf "${RED}Error: curl or wget required.${RST}\n" >&2; exit 1
  fi
}

# ── Write file (respects --dry-run) ──────────────────────────────────────────
_write() {
  local path="$1"
  local content="$2"
  if [[ $DRY_RUN -eq 1 ]]; then
    printf "  ${DIM}[dry-run] %s${RST}\n" "$path"
    return
  fi
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
}

# ── Write once (only if file does not already exist) ─────────────────────────
_write_once() {
  local path="$1"
  local content="$2"
  if [[ $DRY_RUN -eq 1 ]]; then
    if [[ -f "$path" ]]; then
      printf "  ${DIM}[dry-run] %s (already exists — skipped)${RST}\n" "$path"
    else
      printf "  ${DIM}[dry-run] %s (would create)${RST}\n" "$path"
    fi
    return
  fi
  [[ -f "$path" ]] && return
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
}

# ── Safe name: strip languages/ or practices/ prefix, replace / with _ ────────
_safe() {
  local p="$1"
  p="${p#languages/}"
  p="${p#practices/}"
  printf '%s' "${p//\//_}"
}

MANIFEST_PATH="docs/myoro-project-standards/.manifest"

# ── Sync mode ────────────────────────────────────────────────────────────────
if [[ $SYNC -eq 1 ]]; then
  if [[ ! -f "$MANIFEST_PATH" ]]; then
    printf "${RED}Error: No manifest found at %s${RST}\n" "$MANIFEST_PATH"
    printf "Run the installer without --sync first to set up your project.\n"
    exit 1
  fi

  printf "${BOLD}${CYN}  ┌─────────────────────────────────────────┐${RST}\n"
  printf "${BOLD}${CYN}  │   Project Standards Sync                │${RST}\n"
  printf "${BOLD}${CYN}  └─────────────────────────────────────────┘${RST}\n\n"

  [[ $DRY_RUN -eq 1 ]] && printf "  ${YLW}${BOLD}DRY RUN — no files will be written${RST}\n\n"

  printf "  Syncing standards in: ${CYN}%s${RST}\n\n" "$(pwd)"

  # Read manifest: each line is "path|label|glob|always|tool1,tool2,..."
  # First lines are standards, last line starting with "tools:" lists tools
  local sync_tools=""
  local sync_paths=() sync_labels=() sync_globs=() sync_always=()

  while IFS='|' read -r s_path s_label s_glob s_always; do
    if [[ "$s_path" == "tools:"* ]]; then
      sync_tools="${s_path#tools:}"
      continue
    fi
    sync_paths+=("$s_path")
    sync_labels+=("$s_label")
    sync_globs+=("$s_glob")
    sync_always+=("$s_always")
  done < "$MANIFEST_PATH"

  # Re-fetch standards
  local ok_paths=() ok_labels=() ok_globs=() ok_always=()
  local i
  for (( i=0; i<${#sync_paths[@]}; i++ )); do
    local path="${sync_paths[$i]}"
    local label="${sync_labels[$i]}"
    local glob="${sync_globs[$i]}"
    local always="${sync_always[$i]}"
    local safe
    safe=$(_safe "$path")

    printf "  Fetching ${BOLD}%s${RST}... " "$label"
    local content=""
    if content=$(_fetch "${REPO}/${path}/RULES.md" 2>/dev/null); then
      _write "docs/myoro-project-standards/${safe}.md" "$content"
      ok_paths+=("$path")
      ok_labels+=("$label")
      ok_globs+=("$glob")
      ok_always+=("$always")
      printf "${GRN}✓${RST}\n"
    else
      printf "${RED}✗ failed (skipped)${RST}\n"
    fi
  done

  # Regenerate tool configs
  IFS=',' read -ra tool_list <<< "$sync_tools"
  for tool in "${tool_list[@]}"; do
    [[ -z "$tool" ]] && continue
    printf "  Regenerating ${BOLD}%s${RST} config... " "$tool"

    case "$tool" in
      claude)
        rm -f CLAUDE.md
        local md="# Project Rules"$'\n\n'
        md+="Standards are stored in \`docs/myoro-project-standards/\`. Files below are auto-loaded into context."$'\n\n'
        for (( i=0; i<${#ok_paths[@]}; i++ )); do
          local safe
          safe=$(_safe "${ok_paths[$i]}")
          md+="@docs/myoro-project-standards/${safe}.md"$'\n'
          md+="# @docs/custom/${safe}.md (create to extend)"$'\n'
        done
        _write "CLAUDE.md" "$md"
        ;;
      cursor)
        rm -rf .cursor/rules
        for (( i=0; i<${#ok_paths[@]}; i++ )); do
          local safe always_str
          safe=$(_safe "${ok_paths[$i]}")
          always_str="false"
          [[ "${ok_always[$i]}" -eq 1 ]] && always_str="true"
          local mdc="---"$'\n'"description: ${ok_labels[$i]} standards"$'\n'"globs: ${ok_globs[$i]}"$'\n'"alwaysApply: ${always_str}"$'\n'"---"$'\n\n'"@docs/myoro-project-standards/${safe}.md"$'\n'"# Custom additions: create docs/custom/${safe}.md to extend"
          _write ".cursor/rules/${safe}.mdc" "$mdc"
        done
        ;;
      windsurf)
        rm -rf .windsurf/rules
        for (( i=0; i<${#ok_paths[@]}; i++ )); do
          local safe
          safe=$(_safe "${ok_paths[$i]}")
          local ws
          if [[ "${ok_always[$i]}" -eq 1 ]]; then
            ws="---"$'\n'"trigger: always_on"$'\n'"---"
          else
            ws="---"$'\n'"trigger: glob"$'\n'"globs: ${ok_globs[$i]}"$'\n'"---"
          fi
          ws+=$'\n\n'"@docs/myoro-project-standards/${safe}.md"$'\n'"# Custom additions: create docs/custom/${safe}.md to extend"
          _write ".windsurf/rules/${safe}.md" "$ws"
        done
        ;;
      copilot)
        rm -rf .github/instructions; rm -f .github/copilot-instructions.md
        local idx="# Copilot Instructions"$'\n\n'"Per-language and practice rules are in \`.github/instructions/\` — each references \`docs/myoro-project-standards/\`."$'\n'
        for (( i=0; i<${#ok_paths[@]}; i++ )); do
          local safe
          safe=$(_safe "${ok_paths[$i]}")
          local inst="---"$'\n'"applyTo: \"${ok_globs[$i]}\""$'\n'"---"$'\n\n'"@docs/myoro-project-standards/${safe}.md"$'\n'"# Custom additions: create docs/custom/${safe}.md to extend"
          _write ".github/instructions/${safe}.instructions.md" "$inst"
          idx+=$'\n'"- \`${safe}\` → \`.github/instructions/${safe}.instructions.md\`"
        done
        _write ".github/copilot-instructions.md" "$idx"
        ;;
    esac
    printf "${GRN}✓${RST}\n"
  done

  printf "\n  ${GRN}${BOLD}Sync complete!${RST}\n\n"
  exit 0
fi

# ── stdin → tty (needed for bash <(curl ...) pattern) ────────────────────────
exec </dev/tty

# ── Language data ─────────────────────────────────────────────────────────────
# Parallel arrays: label | repo-path | glob
LANG_LABELS=()
LANG_PATHS=()
LANG_GLOBS=()
LANG_SEL=()

_lang() { LANG_LABELS+=("$1"); LANG_PATHS+=("$2"); LANG_GLOBS+=("$3"); LANG_SEL+=(0); }
_lang "CSS / Tailwind"         "languages/css/tailwind"   "**/*.css,**/*.html,**/*.tsx"
_lang "Dart (general)"         "languages/dart"           "**/*.dart"
_lang "Dart / Flutter"         "languages/dart/flutter"   "**/*.dart"
_lang "TypeScript (general)"   "languages/typescript"     "**/*.ts,**/*.tsx"
_lang "TypeScript / React"     "languages/typescript/react" "**/*.tsx"
_lang "TypeScript / Node.js"   "languages/typescript/node"  "**/*.ts"
_lang "JavaScript"             "languages/javascript"     "**/*.js,**/*.mjs"
_lang "Python"                 "languages/python"         "**/*.py"
_lang "Go"                     "languages/go"             "**/*.go"
_lang "Rust"                   "languages/rust"           "**/*.rs"
_lang "Java"                   "languages/java"           "**/*.java"
_lang "C"                      "languages/c"              "**/*.c,**/*.h"
_lang "C++"                    "languages/cpp"            "**/*.cpp,**/*.hpp"
_lang "C#"                     "languages/csharp"         "**/*.cs"

# ── Practice data ─────────────────────────────────────────────────────────────
# Parallel arrays: label | repo-path | glob | alwaysApply (1=true, 0=false)
PRACTICE_LABELS=()
PRACTICE_PATHS=()
PRACTICE_GLOBS=()
PRACTICE_ALWAYS=()
PRACTICE_SEL=()

_practice() {
  PRACTICE_LABELS+=("$1"); PRACTICE_PATHS+=("$2")
  PRACTICE_GLOBS+=("$3"); PRACTICE_ALWAYS+=("$4"); PRACTICE_SEL+=(0)
}
_practice "AI code ownership"                     "practices/ai"            "**/*"                               1
_practice "Engineering (SOLID, clean code, DRY)"   "practices/engineering"   "**/*"                               1
_practice "Workflow (Makefile, DAP, no IDE)"        "practices/workflow"      "**/*"                               1
_practice "Git & version control"                  "practices/git"           "**/*"                               1
_practice "API design"                             "practices/api"           "**/*"                               1
_practice "Security"                               "practices/security"      "**/*"                               1
_practice "SQL / Database"                         "practices/sql"           "**/*.sql,**/*.prisma,**/*.graphql"  0
_practice "Design (UI/UX)"                         "practices/design"        "**/*.css,**/*.html,**/*.tsx,**/*.vue" 0
_practice "Observability"                          "practices/observability" "**/*"                               1
_practice "Testing strategy"                       "practices/testing"       "**/*.test.*,**/*.spec.*"            0

# ── Tool data ─────────────────────────────────────────────────────────────────
TOOL_LABELS=()
TOOL_IDS=()
TOOL_SEL=()

_tool() { TOOL_LABELS+=("$1"); TOOL_IDS+=("$2"); TOOL_SEL+=(0); }
_tool "Claude Code / Antigravity"  "claude"
_tool "Cursor"                     "cursor"
_tool "Windsurf"                   "windsurf"
_tool "GitHub Copilot"             "copilot"

# ── Shared menu state (global to avoid nameref / bash 3 issues) ───────────────
_M_LABELS=()
_M_SEL=()
_M_CUR=0

# ── Key reading ───────────────────────────────────────────────────────────────
_read_key() {
  local k seq
  IFS= read -r -s -n1 k
  if [[ "$k" == $'\x1b' ]]; then
    IFS= read -r -s -n2 -t 0.1 seq || seq=""
    k="${k}${seq}"
  fi
  printf '%s' "$k"
}

# ── TUI drawing ───────────────────────────────────────────────────────────────
_draw_menu() {
  local title="$1"
  local n=${#_M_LABELS[@]}
  clear

  printf "${BOLD}${CYN}  ┌─────────────────────────────────────────┐${RST}\n"
  printf "${BOLD}${CYN}  │     Project Standards Installer         │${RST}\n"
  printf "${BOLD}${CYN}  └─────────────────────────────────────────┘${RST}\n\n"
  printf "  ${BOLD}%s${RST}\n" "$title"
  printf "  ${DIM}↑ ↓  navigate    Space  toggle    Enter  confirm    Ctrl+C  abort${RST}\n\n"

  local i
  for (( i=0; i<n; i++ )); do
    local label="${_M_LABELS[$i]}"
    local sel="${_M_SEL[$i]}"

    if [[ $i -eq $_M_CUR ]]; then
      if [[ "$sel" -eq 1 ]]; then
        printf "  ${YLW}▶ ${GRN}[✓]${RST}${YLW} %s${RST}\n" "$label"
      else
        printf "  ${YLW}▶ ${DIM}[ ]${RST}${YLW} %s${RST}\n" "$label"
      fi
    else
      if [[ "$sel" -eq 1 ]]; then
        printf "    ${GRN}[✓]${RST} %s\n" "$label"
      else
        printf "    ${DIM}[ ] %s${RST}\n" "$label"
      fi
    fi
  done
  printf "\n"
}

_run_menu() {
  local title="$1"
  local n=${#_M_LABELS[@]}
  _M_CUR=0

  while true; do
    _draw_menu "$title"
    local key
    key=$(_read_key)
    case "$key" in
      $'\x1b[A'|$'\x1bOA')   (( _M_CUR = (_M_CUR - 1 + n) % n )) || true ;;
      $'\x1b[B'|$'\x1bOB')   (( _M_CUR = (_M_CUR + 1) % n )) || true ;;
      ' ')                    (( _M_SEL[_M_CUR] = 1 - _M_SEL[_M_CUR] )) || true ;;
      ''|$'\r'|$'\n')         return 0 ;;
      $'\x03')                clear; printf "Aborted.\n"; exit 1 ;;
    esac
  done
}

# ── Main installer ────────────────────────────────────────────────────────────
_install() {
  # Collect selections
  local sel_paths=() sel_labels=() sel_globs=() sel_always=()
  local sel_tools=()
  local i

  for (( i=0; i<${#LANG_SEL[@]}; i++ )); do
    if [[ "${LANG_SEL[$i]}" -eq 1 ]]; then
      sel_paths+=("${LANG_PATHS[$i]}")
      sel_labels+=("${LANG_LABELS[$i]}")
      sel_globs+=("${LANG_GLOBS[$i]}")
      sel_always+=(0)
    fi
  done
  for (( i=0; i<${#PRACTICE_SEL[@]}; i++ )); do
    if [[ "${PRACTICE_SEL[$i]}" -eq 1 ]]; then
      sel_paths+=("${PRACTICE_PATHS[$i]}")
      sel_labels+=("${PRACTICE_LABELS[$i]}")
      sel_globs+=("${PRACTICE_GLOBS[$i]}")
      sel_always+=("${PRACTICE_ALWAYS[$i]}")
    fi
  done
  for (( i=0; i<${#TOOL_SEL[@]}; i++ )); do
    [[ "${TOOL_SEL[$i]}" -eq 1 ]] && sel_tools+=("${TOOL_IDS[$i]}")
  done

  if [[ ${#sel_paths[@]} -eq 0 && ${#sel_tools[@]} -eq 0 ]]; then
    clear; printf "  ${YLW}Nothing selected.${RST}\n\n"; exit 0
  fi

  # ── Confirmation screen ───────────────────────────────────────────────────
  clear
  printf "${BOLD}${CYN}  ┌─────────────────────────────────────────┐${RST}\n"
  printf "${BOLD}${CYN}  │     Project Standards Installer         │${RST}\n"
  printf "${BOLD}${CYN}  └─────────────────────────────────────────┘${RST}\n\n"

  [[ $DRY_RUN -eq 1 ]] && printf "  ${YLW}${BOLD}DRY RUN — no files will be written${RST}\n\n"

  printf "  ${BOLD}Install into:${RST}\n"
  printf "  ${CYN}%s${RST}\n\n" "$(pwd)"

  if [[ ${#sel_labels[@]} -gt 0 ]]; then
    printf "  ${BOLD}Standards:${RST}\n"
    for lbl in "${sel_labels[@]}"; do printf "    ${GRN}✓${RST}  %s\n" "$lbl"; done
    printf "\n"
  fi

  if [[ ${#sel_tools[@]} -gt 0 ]]; then
    printf "  ${BOLD}AI tools:${RST}\n"
    for t in "${sel_tools[@]}"; do
      case "$t" in
        claude)   printf "    ${GRN}✓${RST}  Claude Code   →  CLAUDE.md\n" ;;
        cursor)   printf "    ${GRN}✓${RST}  Cursor        →  .cursor/rules/\n" ;;
        windsurf) printf "    ${GRN}✓${RST}  Windsurf      →  .windsurf/rules/\n" ;;
        copilot)  printf "    ${GRN}✓${RST}  Copilot       →  .github/instructions/\n" ;;
      esac
    done
    printf "\n"
  fi

  # Overwrite warning
  printf "  ${YLW}${BOLD}⚠ WARNING: The following will be completely replaced if they exist:${RST}\n"
  printf "  ${YLW}  CLAUDE.md${RST}\n"
  printf "  ${YLW}  .cursor/rules/                (entire directory)${RST}\n"
  printf "  ${YLW}  .windsurf/rules/              (entire directory)${RST}\n"
  printf "  ${YLW}  .github/instructions/         (entire directory)${RST}\n"
  printf "  ${YLW}  .github/copilot-instructions.md${RST}\n"
  printf "  ${YLW}  docs/myoro-project-standards/ (managed files — docs/custom/ is never touched)${RST}\n"
  printf "\n"

  printf "  ${BOLD}Is this correct? [y/N]${RST} "
  local confirm
  IFS= read -r confirm
  printf "\n"
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    clear; printf "Aborted.\n"; exit 0
  fi

  # ── Clear AI tool config directories ──────────────────────────────────────
  if [[ $DRY_RUN -eq 0 ]] && [[ ${#sel_tools[@]} -gt 0 ]]; then
    for t in "${sel_tools[@]}"; do
      case "$t" in
        cursor)   rm -rf .cursor/rules ;;
        windsurf) rm -rf .windsurf/rules ;;
        copilot)  rm -rf .github/instructions; rm -f .github/copilot-instructions.md ;;
        claude)   rm -f CLAUDE.md ;;
      esac
    done
  fi

  # ── Fetch into docs/myoro-project-standards/ ────────────────────────────────
  local ok_paths=() ok_labels=() ok_globs=() ok_always=()

  for (( i=0; i<${#sel_paths[@]}; i++ )); do
    local path="${sel_paths[$i]}"
    local label="${sel_labels[$i]}"
    local glob="${sel_globs[$i]}"
    local always="${sel_always[$i]}"
    local safe
    safe=$(_safe "$path")

    printf "  Fetching ${BOLD}%s${RST}... " "$label"

    local content=""
    if content=$(_fetch "${REPO}/${path}/RULES.md" 2>/dev/null); then
      _write "docs/myoro-project-standards/${safe}.md" "$content"
      ok_paths+=("$path")
      ok_labels+=("$label")
      ok_globs+=("$glob")
      ok_always+=("$always")
      printf "${GRN}✓${RST}\n"
    else
      printf "${RED}✗ failed (skipped)${RST}\n"
    fi
  done

  if [[ ${#ok_paths[@]} -eq 0 && ${#sel_tools[@]} -gt 0 ]]; then
    printf "\n  ${RED}No standards fetched — nothing to write to tool configs.${RST}\n\n"
    exit 1
  fi

  # ── Write manifest ─────────────────────────────────────────────────────────
  local manifest=""
  for (( i=0; i<${#ok_paths[@]}; i++ )); do
    manifest+="${ok_paths[$i]}|${ok_labels[$i]}|${ok_globs[$i]}|${ok_always[$i]}"$'\n'
  done
  local tools_joined=""
  for t in "${sel_tools[@]+"${sel_tools[@]}"}"; do
    [[ -n "$tools_joined" ]] && tools_joined+=","
    tools_joined+="$t"
  done
  manifest+="tools:${tools_joined}"
  _write "$MANIFEST_PATH" "$manifest"

  # ── docs/custom/ ──────────────────────────────────────────────────────────
  local custom_readme="# docs/custom/

This folder is yours. The installer never touches it.

Create \`<safe_name>.md\` files here to add project-specific rules on top of the
upstream standards. File names must match the safe names used in docs/myoro-project-standards/:

  dart.md, dart_flutter.md, typescript.md, engineering.md, git.md, etc.

All AI tool configs include a comment pointing here so you know where to extend.
"
  _write_once "docs/custom/README.md" "$custom_readme"

  printf "\n"

  # ── Generate AI tool configs ───────────────────────────────────────────────
  for tool in "${sel_tools[@]+"${sel_tools[@]}"}"; do
    printf "  Generating ${BOLD}%s${RST} config... " "$tool"

    case "$tool" in

      claude)
        local md="# Project Rules"$'\n\n'
        md+="Standards are stored in \`docs/myoro-project-standards/\`. Files below are auto-loaded into context."$'\n\n'
        for (( i=0; i<${#ok_paths[@]}; i++ )); do
          local safe
          safe=$(_safe "${ok_paths[$i]}")
          md+="@docs/myoro-project-standards/${safe}.md"$'\n'
          md+="# @docs/custom/${safe}.md (create to extend)"$'\n'
        done
        _write "CLAUDE.md" "$md"
        ;;

      cursor)
        for (( i=0; i<${#ok_paths[@]}; i++ )); do
          local path="${ok_paths[$i]}"
          local label="${ok_labels[$i]}"
          local glob="${ok_globs[$i]}"
          local always="${ok_always[$i]}"
          local safe
          safe=$(_safe "$path")
          local always_str="false"
          [[ "$always" -eq 1 ]] && always_str="true"
          local mdc
          mdc="---"$'\n'
          mdc+="description: ${label} standards"$'\n'
          mdc+="globs: ${glob}"$'\n'
          mdc+="alwaysApply: ${always_str}"$'\n'
          mdc+="---"$'\n\n'
          mdc+="@docs/myoro-project-standards/${safe}.md"$'\n'
          mdc+="# Custom additions: create docs/custom/${safe}.md to extend"
          _write ".cursor/rules/${safe}.mdc" "$mdc"
        done
        ;;

      windsurf)
        for (( i=0; i<${#ok_paths[@]}; i++ )); do
          local path="${ok_paths[$i]}"
          local label="${ok_labels[$i]}"
          local glob="${ok_globs[$i]}"
          local always="${ok_always[$i]}"
          local safe
          safe=$(_safe "$path")
          local ws
          if [[ "$always" -eq 1 ]]; then
            ws="---"$'\n'"trigger: always_on"$'\n'"---"
          else
            ws="---"$'\n'"trigger: glob"$'\n'"globs: ${glob}"$'\n'"---"
          fi
          ws+=$'\n\n'"@docs/myoro-project-standards/${safe}.md"$'\n'
          ws+="# Custom additions: create docs/custom/${safe}.md to extend"
          _write ".windsurf/rules/${safe}.md" "$ws"
        done
        ;;

      copilot)
        local idx="# Copilot Instructions"$'\n\n'
        idx+="Per-language and practice rules are in \`.github/instructions/\` — each references \`docs/myoro-project-standards/\`."$'\n'
        for (( i=0; i<${#ok_paths[@]}; i++ )); do
          local path="${ok_paths[$i]}"
          local label="${ok_labels[$i]}"
          local glob="${ok_globs[$i]}"
          local safe
          safe=$(_safe "$path")
          local inst
          inst="---"$'\n'"applyTo: \"${glob}\""$'\n'"---"$'\n\n'
          inst+="@docs/myoro-project-standards/${safe}.md"$'\n'
          inst+="# Custom additions: create docs/custom/${safe}.md to extend"
          _write ".github/instructions/${safe}.instructions.md" "$inst"
          idx+=$'\n'"- \`${safe}\` → \`.github/instructions/${safe}.instructions.md\`"
        done
        _write ".github/copilot-instructions.md" "$idx"
        ;;

    esac

    printf "${GRN}✓${RST}\n"
  done

  # ── Done ─────────────────────────────────────────────────────────────────
  printf "\n"
  if [[ $DRY_RUN -eq 1 ]]; then
    printf "  ${YLW}Dry run complete — no files written.${RST}\n\n"
  else
    printf "  ${GRN}${BOLD}Done!${RST}\n\n"
    printf "  ${BOLD}docs/myoro-project-standards/${RST}  — standards (overwritten on re-run or --sync)\n"
    printf "  ${BOLD}docs/custom/${RST}                   — your permanent zone (never touched)\n"
    printf "  ${DIM}Re-sync: run with --sync to re-fetch standards without repeating setup.${RST}\n\n"
  fi
}

# ── Entry point ───────────────────────────────────────────────────────────────
clear
printf "${BOLD}${CYN}  ┌─────────────────────────────────────────┐${RST}\n"
printf "${BOLD}${CYN}  │     Project Standards Installer         │${RST}\n"
printf "${BOLD}${CYN}  └─────────────────────────────────────────┘${RST}\n\n"
printf "  Installing into: ${CYN}%s${RST}\n" "$(pwd)"
[[ $DRY_RUN -eq 1 ]] && printf "  ${YLW}Mode: dry run${RST}\n"
printf "\n  ${DIM}Press any key to start...${RST}\n"
_read_key >/dev/null

# Step 1 — Languages
_M_LABELS=("${LANG_LABELS[@]}")
_M_SEL=("${LANG_SEL[@]}")
_run_menu "Step 1 of 3 — Languages / frameworks"
for (( i=0; i<${#_M_SEL[@]}; i++ )); do LANG_SEL[$i]=${_M_SEL[$i]}; done

# Step 2 — Practices
_M_LABELS=("${PRACTICE_LABELS[@]}")
_M_SEL=("${PRACTICE_SEL[@]}")
_run_menu "Step 2 of 3 — Practices"
for (( i=0; i<${#_M_SEL[@]}; i++ )); do PRACTICE_SEL[$i]=${_M_SEL[$i]}; done

# Step 3 — Tools
_M_LABELS=("${TOOL_LABELS[@]}")
_M_SEL=("${TOOL_SEL[@]}")
_run_menu "Step 3 of 3 — AI tools to configure"
for (( i=0; i<${#_M_SEL[@]}; i++ )); do TOOL_SEL[$i]=${_M_SEL[$i]}; done

_install

#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# ai-agent-session.sh
# AGENTS.md 기반 에이전트 세션 런처
#
# 프로젝트 내 AGENTS.md 파일들을 스캔하여 에이전트 목록을 표시하고,
# 선택한 에이전트의 컨텍스트로 AI 도구 세션을 시작한다.
#
# Usage:
#   ./ai-agency.sh                    # 대화형 선택
#   ./ai-agency.sh --tool claude      # 도구 지정
#   ./ai-agency.sh --agent infra      # 에이전트 검색어로 선택
#   ./ai-agency.sh --multi            # tmux 멀티 세션
#   ./ai-agency.sh --list             # 에이전트 목록만 출력
#
# Tip: Use iTerm2 (or kitty/WezTerm) for per-agent background colors.
#      IDE built-in terminals (IntelliJ, VS Code) do not support background
#      color changes. A colored banner is shown instead.
# =============================================================================

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# --- Agent Color Palette ---
# Text colors (bright, for agent list display)
AGENT_COLORS=(
  '\033[38;5;214m'  # orange
  '\033[38;5;39m'   # blue
  '\033[38;5;154m'  # lime green
  '\033[38;5;205m'  # pink
  '\033[38;5;51m'   # cyan
  '\033[38;5;220m'  # gold
  '\033[38;5;141m'  # purple
  '\033[38;5;203m'  # coral
  '\033[38;5;49m'   # teal
  '\033[38;5;183m'  # lavender
  '\033[38;5;208m'  # dark orange
  '\033[38;5;117m'  # sky blue
  '\033[38;5;156m'  # light green
  '\033[38;5;175m'  # mauve
  '\033[38;5;81m'   # steel blue
)

# Terminal background colors (subtle dark tints — readable with light text)
# OSC 11 format: rgb:RR/GG/BB (hex pairs)
TERM_BG_COLORS=(
  '1a/14/0a'  # dark warm brown (PM)
  '0a/14/1a'  # dark navy
  '0a/1a/0f'  # dark forest
  '1a/0a/14'  # dark plum
  '0a/1a/1a'  # dark teal
  '1a/16/0a'  # dark amber
  '12/0a/1a'  # dark violet
  '1a/0e/0a'  # dark rust
  '0a/1a/15'  # dark mint
  '14/0f/1a'  # dark lavender
  '1a/10/0a'  # dark orange-brown
  '0a/12/1a'  # dark steel
  '0f/1a/0a'  # dark lime
  '1a/0a/0f'  # dark rose
  '0a/16/1a'  # dark aqua
)

# Human-readable background color names (matches TERM_BG_COLORS order)
BG_COLOR_NAMES=(
  'Warm Brown'
  'Navy'
  'Forest'
  'Plum'
  'Teal'
  'Amber'
  'Violet'
  'Rust'
  'Mint'
  'Lavender'
  'Orange-Brown'
  'Steel'
  'Lime'
  'Rose'
  'Aqua'
)

get_bg_color_name() {
  local idx=$1
  local palette_size=${#BG_COLOR_NAMES[@]}
  echo "${BG_COLOR_NAMES[$((idx % palette_size))]}"
}

# tmux pane background colors (256-color approximation of above)
TMUX_PANE_BG=(
  '#1a140a'
  '#0a141a'
  '#0a1a0f'
  '#1a0a14'
  '#0a1a1a'
  '#1a160a'
  '#120a1a'
  '#1a0e0a'
  '#0a1a15'
  '#140f1a'
)

# tmux status-bar foreground colors per window
TMUX_FG_COLORS=(
  'colour214'  # orange
  'colour39'   # blue
  'colour154'  # lime
  'colour205'  # pink
  'colour51'   # cyan
  'colour220'  # gold
  'colour141'  # purple
  'colour203'  # coral
  'colour49'   # teal
  'colour183'  # lavender
)

get_agent_color() {
  local idx=$1
  local palette_size=${#AGENT_COLORS[@]}
  echo "${AGENT_COLORS[$((idx % palette_size))]}"
}

# ANSI background colors for banner (bright enough to be visible, works EVERYWHERE)
BANNER_BG_COLORS=(
  '\033[48;5;94m'   # brown
  '\033[48;5;24m'   # navy
  '\033[48;5;22m'   # forest
  '\033[48;5;53m'   # plum
  '\033[48;5;30m'   # teal
  '\033[48;5;136m'  # amber
  '\033[48;5;54m'   # violet
  '\033[48;5;130m'  # rust
  '\033[48;5;29m'   # mint
  '\033[48;5;60m'   # lavender
  '\033[48;5;166m'  # orange-brown
  '\033[48;5;66m'   # steel
  '\033[48;5;64m'   # lime
  '\033[48;5;125m'  # rose
  '\033[48;5;37m'   # aqua
)

# Change terminal background via OSC 11 (works in iTerm2, kitty, WezTerm; ignored elsewhere)
set_term_bg() {
  local idx=$1
  local palette_size=${#TERM_BG_COLORS[@]}
  local bg="${TERM_BG_COLORS[$((idx % palette_size))]}"
  printf '\033]11;rgb:%s\033\\' "$bg"
}

# Reset terminal background to default
reset_term_bg() {
  printf '\033]111;\033\\'
}

# Set terminal tab/window title via OSC 0 (works in almost all terminals)
set_term_title() {
  local title="$1"
  printf '\033]0;%s\007' "$title"
}

# Print a full-width colored banner (works in ALL terminals including IntelliJ, VS Code)
print_agent_banner() {
  local idx=$1
  local name="$2"
  local bg_name="$3"
  local palette_size=${#BANNER_BG_COLORS[@]}
  local banner_bg="${BANNER_BG_COLORS[$((idx % palette_size))]}"
  local color
  color=$(get_agent_color "$idx")

  # Get terminal width, default 80
  local cols
  cols=$(tput cols 2>/dev/null || echo 80)

  local label=" Agent: ${name} "
  local pad_len=$(( cols - ${#label} ))
  [[ $pad_len -lt 0 ]] && pad_len=0
  local padding
  padding=$(printf '%*s' "$pad_len" '')

  echo ""
  echo -e "${banner_bg}\033[1;37m${label}${padding}${NC}"
  echo ""
}

# --- Defaults ---
# PROJECT_ROOT: 1) env var, 2) git root if in a repo, 3) script's parent dir
if [[ -n "${PROJECT_ROOT:-}" ]]; then
  PROJECT_ROOT="$PROJECT_ROOT"
elif git rev-parse --show-toplevel &>/dev/null; then
  PROJECT_ROOT="$(git rev-parse --show-toplevel)"
else
  PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi
TOOL=""
AGENT_FILTER=""
MULTI_MODE=false
LIST_ONLY=false
TMUX_SESSION="ai-agents"

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool|-t)    TOOL="$2"; shift 2 ;;
    --agent|-a)   AGENT_FILTER="$2"; shift 2 ;;
    --multi|-m)   MULTI_MODE=true; shift ;;
    --list|-l)    LIST_ONLY=true; shift ;;
    --help|-h)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -t, --tool <claude|codex|cursor>   AI 도구 선택"
      echo "  -a, --agent <keyword>              에이전트 검색어로 직접 선택"
      echo "  -m, --multi                        tmux 멀티 에이전트 세션"
      echo "  -l, --list                         에이전트 목록만 출력"
      echo "  -h, --help                         도움말"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Scan AGENTS.md files ---
declare -a AGENT_PATHS=()
declare -a AGENT_NAMES=()
declare -a AGENT_ROLES=()
declare -a AGENT_DIRS=()

scan_agents() {
  local root="$1"

  while IFS= read -r agents_file; do
    local dir
    dir="$(dirname "$agents_file")"
    local rel_dir="${dir#"$root"}"
    rel_dir="${rel_dir#/}"
    [[ -z "$rel_dir" ]] && rel_dir="."

    # Extract role from AGENTS.md (first ## Role section content)
    local role=""
    role=$(awk '/^## Role/{found=1; next} found && /^##/{exit} found && NF{print; exit}' "$agents_file" 2>/dev/null)
    [[ -z "$role" ]] && role=$(head -1 "$agents_file" | sed 's/^# //')

    # Extract name from first heading
    local name=""
    name=$(head -1 "$agents_file" | sed 's/^# //')
    [[ -z "$name" ]] && name="$rel_dir"

    AGENT_PATHS+=("$agents_file")
    AGENT_NAMES+=("$name")
    AGENT_ROLES+=("$role")
    AGENT_DIRS+=("$rel_dir")
  done <<< "$(find "$root" -name "AGENTS.md" -not -path "*/.git/*" -not -path "*/.omc/*" -not -path "*/node_modules/*" -not -path "*/__pycache__/*" | sort)"
}

scan_agents "$PROJECT_ROOT"

if [[ ${#AGENT_PATHS[@]} -eq 0 ]]; then
  echo -e "${RED}AGENTS.md 파일을 찾을 수 없습니다.${NC}"
  echo ""
  echo "먼저 AGENTS.md 파일들을 생성하세요:"
  echo "  1. ./setup.sh 실행 (대화형 자동 세팅)"
  echo "  2. 또는 수동: claude --dangerously-skip-permissions \"Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project\""
  exit 1
fi

# --- Display agent list ---
display_agents() {
  echo ""
  echo -e "${BOLD}=== AI Agent Sessions ===${NC}"
  echo -e "${DIM}Project: ${PROJECT_ROOT}${NC}"
  echo -e "${DIM}Found: ${#AGENT_PATHS[@]} agent(s)${NC}"
  echo ""

  local i=0
  for idx in "${!AGENT_PATHS[@]}"; do
    i=$((idx + 1))
    local dir="${AGENT_DIRS[$idx]}"
    local name="${AGENT_NAMES[$idx]}"
    local role="${AGENT_ROLES[$idx]}"
    local color
    color=$(get_agent_color "$idx")

    local bg_name
    bg_name=$(get_bg_color_name "$idx")

    # Each agent gets its own color + background color label
    if [[ "$dir" == "." ]]; then
      echo -e "  ${color}${BOLD}${i})${NC} ${color}${BOLD}[PM] ${name}${NC} ${DIM}(bg: ${bg_name})${NC}"
      echo -e "     ${DIM}Path: ./AGENTS.md${NC}"
      echo -e "     ${color}${role}${NC}"
    else
      echo -e "  ${color}${BOLD}${i})${NC} ${color}${BOLD}${name}${NC} ${DIM}(bg: ${bg_name})${NC}"
      echo -e "     ${DIM}Path: ${dir}/AGENTS.md${NC}"
      echo -e "     ${color}${role}${NC}"
    fi
    echo ""
  done
}

# --- List-only mode ---
if $LIST_ONLY; then
  display_agents
  exit 0
fi

# --- Select agent ---
select_agent() {
  # If --agent filter provided, find matching agent
  if [[ -n "$AGENT_FILTER" ]]; then
    for idx in "${!AGENT_DIRS[@]}"; do
      local lc_filter lc_name lc_role
      lc_filter=$(echo "$AGENT_FILTER" | tr '[:upper:]' '[:lower:]')
      lc_name=$(echo "${AGENT_NAMES[$idx]}" | tr '[:upper:]' '[:lower:]')
      lc_role=$(echo "${AGENT_ROLES[$idx]}" | tr '[:upper:]' '[:lower:]')
      if [[ "${AGENT_DIRS[$idx]}" == *"$AGENT_FILTER"* ]] || \
         [[ "$lc_name" == *"$lc_filter"* ]] || \
         [[ "$lc_role" == *"$lc_filter"* ]]; then
        SELECTED_IDX=$idx
        return 0
      fi
    done
    echo -e "${RED}\"${AGENT_FILTER}\"와 일치하는 에이전트를 찾을 수 없습니다.${NC}"
    exit 1
  fi

  # Interactive selection
  display_agents

  echo -e "${BOLD}Select agent (number, or 'q' to quit):${NC} "
  read -r choice

  [[ "$choice" == "q" || "$choice" == "Q" ]] && exit 0

  if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#AGENT_PATHS[@]} )); then
    SELECTED_IDX=$((choice - 1))
  else
    echo -e "${RED}Invalid selection.${NC}"
    exit 1
  fi
}

# --- Select AI tool ---
select_tool() {
  if [[ -n "$TOOL" ]]; then
    return
  fi

  echo ""
  echo -e "${BOLD}=== AI Tool ===${NC}"
  echo -e "  ${GREEN}1)${NC} claude  ${DIM}(Claude Code CLI)${NC}"
  echo -e "  ${GREEN}2)${NC} codex   ${DIM}(OpenAI Codex CLI)${NC}"
  echo -e "  ${GREEN}3)${NC} print   ${DIM}(프롬프트만 출력 — 수동 복사용)${NC}"
  echo ""
  echo -e "${BOLD}Select tool (1-3):${NC} "
  read -r tool_choice

  case "$tool_choice" in
    1|claude)  TOOL="claude" ;;
    2|codex)   TOOL="codex" ;;
    3|print)   TOOL="print" ;;
    *)         TOOL="print" ;;
  esac
}

# --- Build context prompt ---
build_prompt() {
  local idx=$1
  local agents_file="${AGENT_PATHS[$idx]}"
  local dir="${AGENT_DIRS[$idx]}"
  local name="${AGENT_NAMES[$idx]}"

  local prompt=""

  # Always include root AGENTS.md context if selecting a sub-agent
  if [[ "$dir" != "." ]]; then
    local root_agents="${PROJECT_ROOT}/AGENTS.md"
    if [[ -f "$root_agents" ]]; then
      prompt+="먼저 프로젝트 루트의 AGENTS.md(${root_agents})를 읽어 전체 프로젝트 컨텍스트를 파악하라. "
    fi
  fi

  # Include the selected agent's AGENTS.md
  prompt+="${agents_file}를 읽고, 해당 에이전트의 역할과 권한에 따라 작업하라. "

  # Add working directory context
  if [[ "$dir" != "." ]]; then
    prompt+="작업 범위는 ${PROJECT_ROOT}/${dir}/ 디렉토리이다. "
    prompt+="이 범위를 벗어나는 변경은 PM 에이전트에게 위임하라."
  else
    prompt+="전체 프로젝트를 관리하는 PM 에이전트로서 작업하라. "
    prompt+="하위 에이전트가 있는 디렉토리의 작업은 해당 에이전트에 위임하라."
  fi

  echo "$prompt"
}

# --- Launch session ---
launch_session() {
  local idx=$1
  local prompt
  prompt=$(build_prompt "$idx")
  local name="${AGENT_NAMES[$idx]}"
  local dir="${AGENT_DIRS[$idx]}"
  local work_dir="$PROJECT_ROOT"
  [[ "$dir" != "." ]] && work_dir="${PROJECT_ROOT}/${dir}"

  local color
  color=$(get_agent_color "$idx")

  local bg_name
  bg_name=$(get_bg_color_name "$idx")

  # 1. Print colored banner (works in ALL terminals)
  print_agent_banner "$idx" "$name" "$bg_name"
  echo -e "${DIM}Directory: ${work_dir}${NC}"
  echo -e "${DIM}Tool: ${TOOL}${NC}"
  echo ""

  # 2. Set terminal tab/window title (works in most terminals)
  set_term_title "Agent: ${name}"

  # 3. Change terminal background (iTerm2, kitty, WezTerm — ignored elsewhere)
  set_term_bg "$idx"

  # Ensure background + title reset when the session exits
  trap 'reset_term_bg; set_term_title "Terminal"' EXIT

  # Launch AI tool (no exec — so trap EXIT fires and restores background)
  case "$TOOL" in
    claude)
      cd "$work_dir"
      claude --dangerously-skip-permissions "$prompt"
      ;;
    codex)
      cd "$work_dir"
      codex "$prompt"
      ;;
    print)
      echo -e "${YELLOW}=== Copy this prompt ===${NC}"
      echo ""
      echo "$prompt"
      echo ""
      echo -e "${YELLOW}========================${NC}"
      ;;
    *)
      echo -e "${RED}Unknown tool: ${TOOL}${NC}"
      exit 1
      ;;
  esac
  # trap EXIT will reset background + title automatically
}

# --- Multi-agent tmux session ---
launch_multi() {
  if ! command -v tmux &>/dev/null; then
    echo -e "${RED}tmux가 설치되어 있지 않습니다. brew install tmux${NC}"
    exit 1
  fi

  display_agents

  echo -e "${BOLD}Select agents for multi-session (comma-separated numbers, or 'all'):${NC} "
  read -r multi_choice

  local indices=()
  if [[ "$multi_choice" == "all" ]]; then
    for idx in "${!AGENT_PATHS[@]}"; do
      indices+=("$idx")
    done
  else
    IFS=',' read -ra nums <<< "$multi_choice"
    for num in "${nums[@]}"; do
      num=$(echo "$num" | tr -d ' ')
      if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#AGENT_PATHS[@]} )); then
        indices+=($((num - 1)))
      fi
    done
  fi

  if [[ ${#indices[@]} -eq 0 ]]; then
    echo -e "${RED}No valid agents selected.${NC}"
    exit 1
  fi

  select_tool

  # Kill existing session if any
  tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true

  # Create tmux session with first agent
  local first_idx="${indices[0]}"
  local first_name="${AGENT_NAMES[$first_idx]}"
  local first_prompt
  first_prompt=$(build_prompt "$first_idx")
  local first_dir="$PROJECT_ROOT"
  [[ "${AGENT_DIRS[$first_idx]}" != "." ]] && first_dir="${PROJECT_ROOT}/${AGENT_DIRS[$first_idx]}"

  tmux new-session -d -s "$TMUX_SESSION" -n "$first_name" -c "$first_dir"

  # Apply color to first window — status bar + pane background
  local fg_size=${#TMUX_FG_COLORS[@]}
  local bg_size=${#TMUX_PANE_BG[@]}
  tmux set-window-option -t "${TMUX_SESSION}:0" window-status-style "fg=${TMUX_FG_COLORS[0]}"
  tmux set-window-option -t "${TMUX_SESSION}:0" window-status-current-style "fg=${TMUX_FG_COLORS[0]},bold,underscore"
  tmux select-pane -t "${TMUX_SESSION}:0" -P "bg=${TMUX_PANE_BG[0]}"

  case "$TOOL" in
    claude) tmux send-keys -t "${TMUX_SESSION}:0" "claude --dangerously-skip-permissions '$first_prompt'" C-m ;;
    codex)  tmux send-keys -t "${TMUX_SESSION}:0" "codex '$first_prompt'" C-m ;;
    print)  tmux send-keys -t "${TMUX_SESSION}:0" "echo '$first_prompt'" C-m ;;
  esac

  # Create additional windows for remaining agents
  for i in "${!indices[@]}"; do
    [[ "$i" -eq 0 ]] && continue
    local idx="${indices[$i]}"
    local name="${AGENT_NAMES[$idx]}"
    local prompt
    prompt=$(build_prompt "$idx")
    local work_dir="$PROJECT_ROOT"
    [[ "${AGENT_DIRS[$idx]}" != "." ]] && work_dir="${PROJECT_ROOT}/${AGENT_DIRS[$idx]}"

    tmux new-window -t "$TMUX_SESSION" -n "$name" -c "$work_dir"

    # Apply unique color per window — status bar + pane background
    local color_idx=$((i % fg_size))
    local bg_idx=$((i % bg_size))
    tmux set-window-option -t "${TMUX_SESSION}:${i}" window-status-style "fg=${TMUX_FG_COLORS[$color_idx]}"
    tmux set-window-option -t "${TMUX_SESSION}:${i}" window-status-current-style "fg=${TMUX_FG_COLORS[$color_idx]},bold,underscore"
    tmux select-pane -t "${TMUX_SESSION}:${i}" -P "bg=${TMUX_PANE_BG[$bg_idx]}"

    case "$TOOL" in
      claude) tmux send-keys -t "${TMUX_SESSION}:${i}" "claude --dangerously-skip-permissions '$prompt'" C-m ;;
      codex)  tmux send-keys -t "${TMUX_SESSION}:${i}" "codex '$prompt'" C-m ;;
      print)  tmux send-keys -t "${TMUX_SESSION}:${i}" "echo '$prompt'" C-m ;;
    esac
  done

  echo ""
  echo -e "${GREEN}${BOLD}Multi-agent session created!${NC}"
  echo -e "${DIM}Agents: ${#indices[@]}${NC}"
  echo -e ""
  echo -e "  ${BOLD}tmux attach -t ${TMUX_SESSION}${NC}"
  echo ""
  echo -e "${DIM}Tips:${NC}"
  echo -e "${DIM}  Ctrl+B N  = next window${NC}"
  echo -e "${DIM}  Ctrl+B P  = previous window${NC}"
  echo -e "${DIM}  Ctrl+B W  = window list${NC}"
  echo -e "${DIM}  Ctrl+B D  = detach${NC}"
}

# --- Main ---
if $MULTI_MODE; then
  launch_multi
else
  select_agent
  select_tool
  launch_session "$SELECTED_IDX"
fi

#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# setup.sh — One-command interactive setup for ai-initializer
#
# Replaces the manual flow:
#   clone → open AI tool → read HOW_TO_AGENTS.md → run → launch ai-agency.sh
#
# With:
#   ./setup.sh → select tool → select language → auto-setup → done
#
# Usage:
#   ./setup.sh              # Interactive setup
#   ./setup.sh --help       # Show help
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

# --- Project Root ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# --- Help ---
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo ""
  echo -e "${BOLD}setup.sh${NC} — One-command interactive setup for ai-initializer"
  echo ""
  echo -e "${BOLD}Usage:${NC}"
  echo "  ./setup.sh          Interactive setup"
  echo "  ./setup.sh --help   Show this help"
  echo ""
  echo -e "${BOLD}What it does:${NC}"
  echo "  1. Select AI agent tool (Claude Code, Codex, Gemini CLI)"
  echo "  2. Select language for generated context"
  echo "  3. Auto-run HOW_TO_AGENTS.md to generate AGENTS.md + context"
  echo "  4. Show how to launch agent sessions with ai-agency.sh"
  echo ""
  exit 0
fi

# =============================================================================
# Banner
# =============================================================================
clear
echo ""
echo -e "${CYAN}${BOLD}"
echo "  ┌─────────────────────────────────────────────────────────┐"
echo "  │                                                         │"
echo "  │              ai-initializer  Setup                      │"
echo "  │                                                         │"
echo "  │    Automatic AGENTS.md + Context Generator              │"
echo "  │                                                         │"
echo "  └─────────────────────────────────────────────────────────┘"
echo -e "${NC}"
echo -e "  ${DIM}This script sets up AI agent context for your project.${NC}"
echo -e "  ${DIM}It will generate AGENTS.md, knowledge, skills, and roles.${NC}"
echo ""

# =============================================================================
# Step 1: Check prerequisites
# =============================================================================
echo -e "${BOLD}[1/4] Checking prerequisites...${NC}"
echo ""

# Check HOW_TO_AGENTS.md exists
if [[ ! -f "$PROJECT_ROOT/HOW_TO_AGENTS.md" ]]; then
  echo -e "${RED}  ✗ HOW_TO_AGENTS.md not found in $PROJECT_ROOT${NC}"
  echo -e "  ${DIM}Make sure you're running this from the ai-initializer directory,${NC}"
  echo -e "  ${DIM}or from a project that has HOW_TO_AGENTS.md copied into it.${NC}"
  exit 1
fi
echo -e "${GREEN}  ✓${NC} HOW_TO_AGENTS.md found"

# Detect available tools
HAS_CLAUDE=false
HAS_CODEX=false
HAS_GEMINI=false

if command -v claude &>/dev/null; then
  HAS_CLAUDE=true
  echo -e "${GREEN}  ✓${NC} Claude Code CLI detected"
fi
if command -v codex &>/dev/null; then
  HAS_CODEX=true
  echo -e "${GREEN}  ✓${NC} OpenAI Codex CLI detected"
fi
if command -v gemini &>/dev/null; then
  HAS_GEMINI=true
  echo -e "${GREEN}  ✓${NC} Gemini CLI detected"
fi

if ! $HAS_CLAUDE && ! $HAS_CODEX && ! $HAS_GEMINI; then
  echo ""
  echo -e "${RED}  ✗ No AI CLI tool found.${NC}"
  echo ""
  echo -e "  ${BOLD}Install one of the following:${NC}"
  echo -e "    Claude Code:  ${DIM}npm install -g @anthropic-ai/claude-code${NC}"
  echo -e "    Codex CLI:    ${DIM}npm install -g @openai/codex${NC}"
  echo -e "    Gemini CLI:   ${DIM}npm install -g @anthropic-ai/gemini-cli  (or see Google docs)${NC}"
  echo ""
  exit 1
fi

# --- Check for existing setup ---
EXISTING_AGENTS=0
HAS_AI_AGENTS_DIR=false
SETUP_MODE="full"

if command -v find &>/dev/null; then
  EXISTING_AGENTS=$(find "$PROJECT_ROOT" -name "AGENTS.md" -not -path "*/.git/*" -not -path "*/.omc/*" -not -path "*/node_modules/*" 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ -d "$PROJECT_ROOT/.ai-agents" ]]; then
  HAS_AI_AGENTS_DIR=true
fi

if [[ "$EXISTING_AGENTS" -gt 0 ]] || $HAS_AI_AGENTS_DIR; then
  echo ""
  echo -e "  ${YELLOW}⚠  Existing setup detected:${NC}"
  if [[ "$EXISTING_AGENTS" -gt 0 ]]; then
    echo -e "     ${DIM}${EXISTING_AGENTS} AGENTS.md file(s) found${NC}"
  fi
  if $HAS_AI_AGENTS_DIR; then
    echo -e "     ${DIM}.ai-agents/ directory exists${NC}"
  fi
  echo ""
  echo -e "  ${BOLD}How would you like to proceed?${NC}"
  echo -e "  ${GREEN}1)${NC} ${BOLD}Full regeneration${NC}     ${DIM}(overwrites everything)${NC}"
  echo -e "  ${GREEN}2)${NC} ${BOLD}Incremental update${NC}    ${DIM}(new directories only, preserves existing)${NC}"
  echo -e "  ${GREEN}3)${NC} Cancel"
  echo ""
  echo -ne "  ${BOLD}Select mode (1-3):${NC} "
  read -r mode_choice

  case "$mode_choice" in
    1) SETUP_MODE="full" ;;
    2) SETUP_MODE="incremental" ;;
    3|q|Q)
      echo -e "  ${YELLOW}Setup cancelled.${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}  Invalid selection. Exiting.${NC}"
      exit 1
      ;;
  esac
  echo -e "  ${DIM}→ Mode: ${SETUP_MODE}${NC}"
fi

echo ""

# =============================================================================
# Step 2: Select AI tool
# =============================================================================
echo -e "${BOLD}[2/4] Select AI agent tool${NC}"
echo ""

TOOL_OPTIONS=()
TOOL_COMMANDS=()
TOOL_IDX=1

if $HAS_CLAUDE; then
  echo -e "  ${GREEN}${TOOL_IDX})${NC} ${BOLD}Claude Code${NC}  ${DIM}(claude --dangerously-skip-permissions)${NC}"
  TOOL_OPTIONS+=("claude")
  TOOL_COMMANDS+=("claude")
  TOOL_IDX=$((TOOL_IDX + 1))
fi
if $HAS_CODEX; then
  echo -e "  ${GREEN}${TOOL_IDX})${NC} ${BOLD}Codex CLI${NC}    ${DIM}(codex --full-auto)${NC}"
  TOOL_OPTIONS+=("codex")
  TOOL_COMMANDS+=("codex")
  TOOL_IDX=$((TOOL_IDX + 1))
fi
if $HAS_GEMINI; then
  echo -e "  ${GREEN}${TOOL_IDX})${NC} ${BOLD}Gemini CLI${NC}   ${DIM}(gemini)${NC}"
  TOOL_OPTIONS+=("gemini")
  TOOL_COMMANDS+=("gemini")
  TOOL_IDX=$((TOOL_IDX + 1))
fi

echo ""
echo -ne "  ${BOLD}Select tool (1-$((TOOL_IDX - 1))):${NC} "
read -r tool_choice

# Validate selection
if [[ ! "$tool_choice" =~ ^[0-9]+$ ]] || (( tool_choice < 1 || tool_choice >= TOOL_IDX )); then
  echo -e "${RED}  Invalid selection. Exiting.${NC}"
  exit 1
fi

SELECTED_TOOL="${TOOL_OPTIONS[$((tool_choice - 1))]}"
SELECTED_CMD="${TOOL_COMMANDS[$((tool_choice - 1))]}"
echo -e "  ${DIM}→ Selected: ${SELECTED_TOOL}${NC}"
echo ""

# =============================================================================
# Step 3: Select language
# =============================================================================
echo -e "${BOLD}[3/4] Select language for generated context${NC}"
echo ""
echo -e "  ${DIM}The generated AGENTS.md and context files will be written in this language.${NC}"
echo -e "  ${DIM}English is recommended for lower token cost and optimal AI performance.${NC}"
echo ""

# Language options with HOW_TO_AGENTS file mapping
declare -a LANG_NAMES=("English" "한국어 (Korean)" "日本語 (Japanese)" "中文 (Chinese)" "Español (Spanish)" "Français (French)" "Deutsch (German)" "Русский (Russian)" "हिन्दी (Hindi)" "العربية (Arabic)")
declare -a LANG_CODES=("en" "ko" "ja" "zh" "es" "fr" "de" "ru" "hi" "ar")
declare -a LANG_FILES=("HOW_TO_AGENTS.md" "" "" "" "" "" "" "" "" "")
declare -a LANG_PROMPTS_EN=(
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project."
  "HOW_TO_AGENTS.md를 읽고 지시에 맞게 AGENTS.md를 생성."
  "HOW_TO_AGENTS.mdを読み、このプロジェクトに合わせてAGENTS.mdを生成せよ。"
  "阅读 HOW_TO_AGENTS.md，为本项目生成定制的 AGENTS.md。"
  "Lee HOW_TO_AGENTS.md y genera AGENTS.md adaptado a este proyecto."
  "Lis HOW_TO_AGENTS.md et génère un AGENTS.md adapté à ce projet."
  "Lies HOW_TO_AGENTS.md und generiere eine auf dieses Projekt zugeschnittene AGENTS.md."
  "Прочитай HOW_TO_AGENTS.md и сгенерируй AGENTS.md, адаптированный для этого проекта."
  "HOW_TO_AGENTS.md पढ़ें और इस प्रोजेक्ट के लिए अनुकूलित AGENTS.md बनाएं।"
  "اقرأ HOW_TO_AGENTS.md وأنشئ AGENTS.md مخصصًا لهذا المشروع."
)

for i in "${!LANG_NAMES[@]}"; do
  local_num=$((i + 1))
  if [[ $i -eq 0 ]]; then
    echo -e "  ${GREEN}${local_num})${NC} ${BOLD}${LANG_NAMES[$i]}${NC}  ${DIM}(recommended — lower token cost)${NC}"
  else
    echo -e "  ${GREEN}${local_num})${NC} ${LANG_NAMES[$i]}"
  fi
done

echo ""
echo -ne "  ${BOLD}Select language (1-${#LANG_NAMES[@]}):${NC} "
read -r lang_choice

if [[ ! "$lang_choice" =~ ^[0-9]+$ ]] || (( lang_choice < 1 || lang_choice > ${#LANG_NAMES[@]} )); then
  echo -e "${RED}  Invalid selection. Exiting.${NC}"
  exit 1
fi

LANG_IDX=$((lang_choice - 1))
SELECTED_LANG="${LANG_NAMES[$LANG_IDX]}"
SELECTED_LANG_CODE="${LANG_CODES[$LANG_IDX]}"
SELECTED_PROMPT="${LANG_PROMPTS_EN[$LANG_IDX]}"

# Determine which HOW_TO_AGENTS file to use
HOW_TO_FILE="${LANG_FILES[$LANG_IDX]}"
if [[ -z "$HOW_TO_FILE" || ! -f "$PROJECT_ROOT/$HOW_TO_FILE" ]]; then
  # Fall back to English version (always available)
  HOW_TO_FILE="HOW_TO_AGENTS.md"
fi

# For non-English languages without a native HOW_TO_AGENTS, add language instruction
LANG_SUFFIX=""
if [[ "$SELECTED_LANG_CODE" != "en" && "$HOW_TO_FILE" == "HOW_TO_AGENTS.md" && -z "${LANG_FILES[$LANG_IDX]}" ]]; then
  LANG_SUFFIX=" Write all generated files (AGENTS.md, context, skills, roles) in ${SELECTED_LANG}."
fi

echo -e "  ${DIM}→ Selected: ${SELECTED_LANG}${NC}"
echo ""

# =============================================================================
# Step 4: Execute setup
# =============================================================================
echo -e "${BOLD}[4/4] Running setup...${NC}"
echo ""

# Build the full prompt — replace HOW_TO_AGENTS.md reference with actual file path
FULL_PROMPT="${SELECTED_PROMPT//HOW_TO_AGENTS.md/$HOW_TO_FILE}${LANG_SUFFIX}"

# Append incremental mode instructions if applicable
if [[ "$SETUP_MODE" == "incremental" ]]; then
  FULL_PROMPT="${FULL_PROMPT} IMPORTANT: This is an incremental update. Do NOT overwrite existing AGENTS.md files or .ai-agents/context/ files that already have content. Only generate AGENTS.md for directories that do not already have one. Only create new .ai-agents/context/ files that do not yet exist. Preserve all existing files and their content."
fi

# Show what will be executed
echo -e "  ${DIM}Tool:     ${SELECTED_TOOL}${NC}"
echo -e "  ${DIM}Language: ${SELECTED_LANG}${NC}"
echo -e "  ${DIM}Guide:    ${HOW_TO_FILE}${NC}"
echo -e "  ${DIM}Mode:     ${SETUP_MODE}${NC}"
echo -e "  ${DIM}Prompt:   ${FULL_PROMPT}${NC}"
echo ""

# Confirm before execution
echo -ne "  ${BOLD}Proceed? (Y/n):${NC} "
read -r confirm
confirm="${confirm:-Y}"

if [[ "$confirm" != "Y" && "$confirm" != "y" && "$confirm" != "yes" ]]; then
  echo -e "  ${YELLOW}Setup cancelled.${NC}"
  exit 0
fi

echo ""
echo -e "  ${CYAN}${BOLD}Starting AI agent...${NC}"
echo -e "  ${DIM}This may take a few minutes depending on project size.${NC}"
echo -e "  ${DIM}The AI will analyze your project and generate all context files.${NC}"
echo ""

# Execute the selected tool
cd "$PROJECT_ROOT"

case "$SELECTED_TOOL" in
  claude)
    claude --dangerously-skip-permissions --model claude-opus-4-6 "$FULL_PROMPT"
    ;;
  codex)
    codex --full-auto "$FULL_PROMPT"
    ;;
  gemini)
    gemini "$FULL_PROMPT"
    ;;
esac

EXIT_CODE=$?

echo ""

if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "${RED}${BOLD}  ✗ Setup encountered an error (exit code: $EXIT_CODE)${NC}"
  echo ""
  echo -e "  ${DIM}You can try running it again, or run manually:${NC}"
  case "$SELECTED_TOOL" in
    claude)
      echo -e "  ${DIM}  claude --dangerously-skip-permissions --model claude-opus-4-6 \"${FULL_PROMPT}\"${NC}"
      ;;
    codex)
      echo -e "  ${DIM}  codex --full-auto \"${FULL_PROMPT}\"${NC}"
      ;;
    gemini)
      echo -e "  ${DIM}  gemini \"${FULL_PROMPT}\"${NC}"
      ;;
  esac
  exit 1
fi

# =============================================================================
# Done — show next steps
# =============================================================================
echo ""
echo -e "${GREEN}${BOLD}"
echo "  ┌─────────────────────────────────────────────────────────┐"
echo "  │                                                         │"
echo "  │              ✓  Setup Complete!                          │"
echo "  │                                                         │"
echo "  └─────────────────────────────────────────────────────────┘"
echo -e "${NC}"

# Check what was generated
AGENT_COUNT=0
if command -v find &>/dev/null; then
  AGENT_COUNT=$(find "$PROJECT_ROOT" -name "AGENTS.md" -not -path "*/.git/*" -not -path "*/.omc/*" -not -path "*/node_modules/*" 2>/dev/null | wc -l | tr -d ' ')
fi

if [[ "$AGENT_COUNT" -gt 0 ]]; then
  echo -e "  ${GREEN}✓${NC} ${AGENT_COUNT} AGENTS.md file(s) generated"
fi

if [[ -d "$PROJECT_ROOT/.ai-agents" ]]; then
  echo -e "  ${GREEN}✓${NC} .ai-agents/ context directory created"
fi

echo ""
echo -e "  ${BOLD}Next steps — launch an agent session:${NC}"
echo ""
echo -e "    ${CYAN}# Interactive mode (select agent + tool)${NC}"
echo -e "    ${BOLD}./ai-agency.sh${NC}"
echo ""
echo -e "    ${CYAN}# Direct launch with Claude${NC}"
echo -e "    ${BOLD}./ai-agency.sh --tool claude${NC}"
echo ""
echo -e "    ${CYAN}# Multi-agent parallel sessions (tmux)${NC}"
echo -e "    ${BOLD}./ai-agency.sh --multi${NC}"
echo ""
echo -e "    ${CYAN}# List all available agents${NC}"
echo -e "    ${BOLD}./ai-agency.sh --list${NC}"
echo ""
echo -e "  ${DIM}See README.md for full documentation.${NC}"
echo ""

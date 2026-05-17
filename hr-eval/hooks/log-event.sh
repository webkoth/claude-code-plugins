#!/usr/bin/env bash
# hr-eval — core logger
# Called by log-prompt.sh / log-pre-tool.sh / log-post-tool.sh wrappers.
# Reads JSON event from stdin, appends a normalized line to the session log.
#
# Always exits 0 — must NEVER block Claude Code execution.
# Required env: HR_EVAL_SESSION (session id), HR_EVAL_CWD (absolute cwd of session)
# Arg 1: event type — one of: user_prompt | tool_pre | tool_post

set -uo pipefail

EVENT_TYPE="${1:-unknown}"
SESSION_ID="${HR_EVAL_SESSION:-}"
SESSION_CWD="${HR_EVAL_CWD:-$PWD}"

if [[ -z "$SESSION_ID" ]]; then
  exit 0
fi

LOG_DIR="$SESSION_CWD/.hr-eval/sessions/$SESSION_ID"
LOG_FILE="$LOG_DIR/log.jsonl"

mkdir -p "$LOG_DIR" 2>/dev/null || exit 0

INPUT=$(cat)
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if command -v jq >/dev/null 2>&1; then
  echo "$INPUT" | jq -c \
    --arg ts "$TS" \
    --arg type "$EVENT_TYPE" \
    --arg session "$SESSION_ID" \
    '{ts: $ts, type: $type, hr_eval_session: $session, raw: .}' \
    >> "$LOG_FILE" 2>/dev/null
else
  ESCAPED=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || printf '"%s"' "${INPUT//\"/\\\"}")
  printf '{"ts":"%s","type":"%s","hr_eval_session":"%s","raw_text":%s}\n' \
    "$TS" "$EVENT_TYPE" "$SESSION_ID" "$ESCAPED" >> "$LOG_FILE"
fi

exit 0

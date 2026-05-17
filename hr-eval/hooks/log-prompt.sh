#!/usr/bin/env bash
# hr-eval — UserPromptSubmit logger
# Thin wrapper around log-event.sh
exec "$(dirname "$0")/log-event.sh" user_prompt

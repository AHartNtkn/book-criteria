#!/bin/bash
# Config parsing for the fiction pipeline.
# Requires: yq
#
# Supports two config files:
#   1. criteria-settings.yaml — per-criterion and per-sentinel on/off toggles + iteration_cap
#   2. auditor-settings.yaml — which auditors exist and what level they operate at
#
# The criteria-settings file is generated from the style questionnaire.
# The auditor-settings file maps auditors to their criteria/sentinel groups.

CONFIG_FILE=""
CRITERIA_FILE=""
MODEL_SETTINGS_FILE=""

load_config() {
    local config_file="$1"
    if [[ ! -f "$config_file" ]]; then
        echo "FATAL: Config file not found: $config_file" >&2
        return 1
    fi
    CONFIG_FILE="$config_file"
}

load_criteria_settings() {
    local criteria_file="$1"
    if [[ ! -f "$criteria_file" ]]; then
        echo "FATAL: Criteria settings file not found: $criteria_file" >&2
        return 1
    fi
    CRITERIA_FILE="$criteria_file"
}

get_iteration_cap() {
    local level="${1:-}"
    local cap=""

    # Check for per-level cap first (iteration_caps.scene, iteration_caps.chapter_plan, etc.)
    if [[ -n "$level" && -n "$CRITERIA_FILE" ]]; then
        cap=$(yq ".iteration_caps.${level} // \"\"" "$CRITERIA_FILE" 2>/dev/null)
    fi

    # Fall back to global cap
    if [[ -z "$cap" || "$cap" == "null" ]]; then
        if [[ -n "$CRITERIA_FILE" ]]; then
            cap=$(yq '.iteration_cap' "$CRITERIA_FILE")
        else
            cap=$(yq '.iteration_cap' "$CONFIG_FILE")
        fi
    fi

    echo "${cap:-0}"
}

# Get list of auditors for a given pipeline level
get_active_auditors() {
    local level="$1"
    yq -r ".${level}[] | .auditor" "$CONFIG_FILE"
}

# Check if a specific criterion is enabled
is_criterion_enabled() {
    local criterion_id="$1"
    if [[ -z "$CRITERIA_FILE" ]]; then
        # No criteria file loaded — default to enabled
        echo "true"
        return
    fi
    local result
    result=$(yq ".criteria.\"${criterion_id}\"" "$CRITERIA_FILE")
    if [[ "$result" == "false" ]]; then
        echo "false"
    else
        # Default to true if not explicitly set to false
        echo "true"
    fi
}

# Check if a specific sentinel is enabled
is_sentinel_enabled() {
    local sentinel_id="$1"
    if [[ -z "$CRITERIA_FILE" ]]; then
        echo "true"
        return
    fi
    local result
    result=$(yq ".sentinels.\"${sentinel_id}\"" "$CRITERIA_FILE")
    if [[ "$result" == "false" ]]; then
        echo "false"
    else
        echo "true"
    fi
}

load_model_settings() {
    local model_file="$1"
    if [[ ! -f "$model_file" ]]; then
        echo "WARNING: Model settings not found: $model_file — using CLI defaults" >&2
        return
    fi
    MODEL_SETTINGS_FILE="$model_file"
}

# Get the model for a pipeline role.
# Args: $1 = role (synthesis|planning|enhancement|fixing|auditor|consolidation|context_collection|backtracking|ideation)
# Returns: model flag string (e.g., "--model sonnet") or empty string for CLI default
get_model_flag() {
    local role="$1"
    if [[ -z "$MODEL_SETTINGS_FILE" ]]; then
        return
    fi
    local model
    model=$(yq -r ".$role // \"\"" "$MODEL_SETTINGS_FILE")
    if [[ -n "$model" && "$model" != "null" ]]; then
        echo "--model $model"
    fi
}

# Get all enabled criteria as a list
get_enabled_criteria() {
    if [[ -z "$CRITERIA_FILE" ]]; then
        echo "WARNING: No criteria settings loaded — all criteria enabled by default" >&2
        return
    fi
    yq -r '.criteria | to_entries[] | select(.value == true) | .key' "$CRITERIA_FILE"
}

# Get all enabled sentinels as a list
get_enabled_sentinels() {
    if [[ -z "$CRITERIA_FILE" ]]; then
        echo "WARNING: No criteria settings loaded — all sentinels enabled by default" >&2
        return
    fi
    yq -r '.sentinels | to_entries[] | select(.value == true) | .key' "$CRITERIA_FILE"
}

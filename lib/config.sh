#!/bin/bash
# Config parsing for the fiction pipeline.
# Requires: yq

CONFIG_FILE=""

load_config() {
    local config_file="$1"
    if [[ ! -f "$config_file" ]]; then
        echo "FATAL: Config file not found: $config_file" >&2
        return 1
    fi
    CONFIG_FILE="$config_file"
}

get_iteration_cap() {
    yq '.iteration_cap' "$CONFIG_FILE"
}

get_active_auditors() {
    local level="$1"
    yq -r ".${level}[] | select(.enabled == true) | .auditor" "$CONFIG_FILE"
}

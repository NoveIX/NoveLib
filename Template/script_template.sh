#!/usr/bin/env bash

# Script Name:    script.sh
# Description:    Short description of what this script does.
#
# Usage:          script.sh [options] [arguments]
#
# Options:
#   -h, --help        Show this help message and exit.
#   -v, --verbose     Enable verbose output.
#   -f, --file FILE   Specify input file.
#
# Examples:
#   ./script.sh -f input.txt
#   ./script.sh --verbose
#
# Notes:
#   - Requires Bash 4.4+ for associative arrays
#   - Tested on Ubuntu 22.04 and Debian 13
#   - Make sure you have write permission in the output directory
#
# More info:
#   GitHub:  https://github.com/tuonome/script
#   Docs:    https://example.com/docs/script
#
# TODO:
#   - Add support for multiple input files
#   - Add logging to a file
#
# License: MIT
# Author:  Your Name
# Version: 1.0.0
# ---

set -euo pipefail

show_help() {
    sed -n '2,/# ---/p' "$0" | sed '/# ---/d; s/^# \{0,1\}//'
}

if [[ $# -lt 1 ]]; then
    show_help
    exit 0
fi
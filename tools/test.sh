#!/bin/bash
echo "Test"; echo
set -e
set -o pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_DIR="$(realpath "${SCRIPT_DIR}/..")"

parse_args(){
    SOURCES=( )
    QA=( )
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -d|--debug) set -x ;;
            *)
                if [[ -e "$1" ]]; then
                    TEST="$(realpath --relative-to="${PROJECT_DIR}/tests" "$1")"
                    case "${TEST}" in
                        src*) SOURCES+=( "$1" ) ;;
                        qa*) QA+=( "$1" ) ;;
                        .) ;;
                        *)
                            echo "[ERROR]: Not a test: $1" >&2
                            exit 1
                            ;;
                    esac
                else
                    echo "Unsupported argument: $1" >&2
                    exit 1
                fi
                ;;
        esac
        shift
    done
    [[ -n "${SOURCES[@]}" || -n "${QA}" ]] || { SOURCES="${PROJECT_DIR}/tests/src"; QA="${PROJECT_DIR}/tests/qa"; }
}

run_pytest(){
    echo "=> pyltest ${PROJECT_DIR}/tests"
    find ${PROJECT_DIR} -name .coverage\* | xargs --no-run-if-empty rm -f
    [[ -z "${SOURCES[@]}" ]] || { \
        pytest --cov="${PROJECT_DIR}/src" -n 4 "${SOURCES}"; \
        coverage report > "${PROJECT_DIR}/tools/qa/coverage/report.txt"; \
        coverage html --directory tools/qa/coverage/html
    }
    [[ -z "${QA[@]}" ]] || pytest -n 4 "${QA}"
    echo
}

parse_args "$@"
run_pytest
echo [OK]

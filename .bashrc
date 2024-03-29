#!/usr/bin/env bash
# ==================================================
# BASH
# ==================================================
# make git bash save history - from https://stackoverflow.com/a/10901227/2135504
PROMPT_COMMAND='history -a'

# throw erros upon undefined variables
set -u

# Function wrapper to debug functions
# https://unix.stackexchange.com/a/699265/309309
# -x = print command to be eXecuted
# -u = raise error for Unset variables
# alias _trace='trap "set +xu" RETURN; set -xu'
# alias _ensure_variables_exist='trap "set +u" RETURN; set -u'

# see https://stackoverflow.com/a/10408906/2135504
_start_in_background() {
    # & opens command in background and doesn't block terminal.
    # nohup keeps program open when exiting terminal.
    # >/dev/null is used to avoid creating nohup.out
    nohup $1 >/dev/null 2>&1 &!
}

# see https://stackoverflow.com/a/16957078/2135504
_find_text() {
    grep -rnw $1 --include=\*.py -e $2
}

# How to split any commit:
# https://emmanuelbernard.com/blog/2014/04/14/split-a-commit-in-two-with-git/

# ==================================================
# GIT
# ==================================================
alias glog='git log --decorate --oneline --graph --abbrev=8'
alias grebase='git fetch --all; git rebase origin/master -i --autosquash'
alias gsquash='git rebase -i --autosquash $(git merge-base HEAD origin/master)'
alias gamend="git commit --amend --no-edit"
alias gwip="git add . && git commit -m 'WIP from $(date +%Y%m%d_%H%M%S)'"

# show 10 most recently used branches
alias gbranch="git branch --sort=-committerdate | head -10"

gdiff() {
    git diff --color-moved=dimmed-zebra $1
    # possible further options
    # --color-words=" "
    # --color-moved-ws=allow-indentation-change \
}

gsync() {
    set -x
    cd $1
    gwip
    git pull
    git push
    set +x
}

# config
git config --global color.diff.meta "black yellow italic"

# search withing git log
# git log
# --walk-reflogs    # show all commits (including dangling ones) from most recent to oldest
# -S <string>       # show commits which change the number of occurences of <string>

# ==================================================
# PYTHON
# ==================================================

vact() {
    deactivate

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        source ./venv/bin/activate
    elif [[ "$OSTYPE" == "msys" ]]; then
        # happpens with git bash under windows
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
        source ./venv/Scripts/activate
    else
        # see https://stackoverflow.com/a/8597411/2135504
        echo "Error, unknown OS!" 1>&2
        exit 1
    fi
}

# run pytest easily in pycharm with git bash
# https://stackoverflow.com/q/32597209/2135504
alias ptest="winpty pytest -vv --instafail"

# see https://superuser.com/a/304489/1010479
alias _watch_pytest="when-changed -rsv tests/ -c pytest tests/ -vv --instafail -k XXX"

_create_venv() {
    deactivate
    python -m venv venv
    vact
    python -m pip install --upgrade pip setuptools wheel pip-tools
}

_pip_install() {
    vact
    # see https://github.com/jazzband/pip-tools
    pip-compile requirements.in
    pip-sync requirements.txt
}

# ==================================================
#
# ==================================================

# ==================================================
# QUICK OPEN
# ==================================================

# get (absolute) parent path of this script
# https://stackoverflow.com/a/246128/2135504
_UTILS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
_SHARED_DIR=$(dirname ${_UTILS_DIR})

# source the .env file in the parent directory
source ${_SHARED_DIR}/utils/.env

# Assert that the following variables are defined in .env
# see https://unix.stackexchange.com/a/228333/309309
set -u
: "$_IDE_PATH"
: "$_MARKDOWN_PATH"
: "$_START_COMMANDS"
: "$_SANDBOX_DIR"
set +u

_ide() {
    # opens IDE at current location
    _start_in_background "$_IDE_PATH $1"
}

_run_python_script() {
    local script_path="${_SHARED_DIR}/utils/python_scripts"
    select script_name in $(ls ${script_path}); do
        local path=${script_path}/${script_name}
        python $path "$@"
        break
    done
}

_create_sandbox() {
    set -x
    local dst_dir=${_SANDBOX_DIR}/"$(date '+%Y%m%d')_$1"

    echo "Which project template do you want?"
    select dirname in "project_template_pycharm" "project_template_vscode"; do
        local src_dir="${_SHARED_DIR}/utils/${dirname}"

        cp -r $src_dir $dst_dir
        cd $dst_dir
        _ide .
        _create_venv

        break
    done
    set +x
}

_create_shared_note() {
    set -x
    cd $_SHARED_DIR
    cd "shared_notes"
    local filename="$(date +%Y%m%d)_$1.md"
    touch $filename
    _start_in_background "$_MARKDOWN_PATH $filename"
    set +x
}

_sync_shared_directories() {
    set -x
    gsync $_SHARED_DIR/utils
    gsync $_SHARED_DIR/shared_notes
    set +x
}

_startday() {
    # & opens in background (otherwise could not trigger next command)
    # nohup keeps programs open when exiting
    for cmd in $_START_COMMANDS; do
        echo $cmd
        _start_in_background "$cmd"
    done
    _sync_shared_directories
    exit
}

# ==================================================
# BASH
# ==================================================
# make git bash save history - from https://stackoverflow.com/a/10901227/2135504
PROMPT_COMMAND='history -a'

# ==================================================
# GIT
# ==================================================
alias glog='git log --decorate --oneline --graph --abbrev=8'
alias grebase='git fetch --all; git rebase origin/master -i --autosquash'
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

gsync () {
    # -x = prints command to be e(X)ecuted
    # -u = raises error if a variable is (U)nset
    set -xu
    cd $1
    gwip
    git pull
    git push
    set +xu
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
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias vact="source ./venv/bin/activate"
elif [[ "$OSTYPE" == "msys" ]]; then
    # happpens with git bash under windows
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    alias vact='source ./venv/Scripts/activate'
else
    # see https://stackoverflow.com/a/8597411/2135504
    echo "Error, unknown OS!" 1>&2
    exit 1
fi

# run pytest easily in pycharm with git bash
# https://stackoverflow.com/q/32597209/2135504
alias ptest="winpty pytest -vv --instafail"

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
# QUICK OPEN
# ==================================================
# source the .env file in the parent directory
_SHARED_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )";
source ${_SHARED_DIR}/utils/.env

# ASSERT THAT THE FOLLOWING VARIABLES ARE DEFINED
# see https://unix.stackexchange.com/a/228333/309309
set -xu
: "$_IDE_PATH"
: "$_TYPORA_PATH"
: "$_START_COMMANDS"
: "$_SANDBOX_DIR"
set +xu

_ide () {
    # opens IDE at current location
    # & opens command in background (otherwise could not trigger next commands).
    # nohup keeps program open when exiting.
    # >/dev/null is used to ???
    nohup $_IDE_PATH . >/dev/null 2>&1 &
}

_startday() {
    set -xu
    # & opens in background (otherwise could not trigger next command)
    # nohup keeps programs open when exiting 
    for cmd in $START_COMMANDS; do
        nohup $cmd &
    done
    _sync_shared_directories
    set +xu
    exit
}

_create_sandbox() {
    set -xu
    cd ${_SANDBOX_DIR}
    dirname="$(date '+%Y%m%d')_$1"
    echo $dirname
    mkdir ${dirname}
    cd ${dirname}

    cp ${_PROJECT_TEMPLATE_DIR}/* .
    _ide
    _create_venv
    set +xu
}

_create_shared_note() {
    set -xu
    cd $_SHARED_DIR
    cd "shared_notes"
    filename="$(date +%Y%m%d_%H%M%S)_$1.md"
    touch $filename
    $_TYPORA_PATH $filename
    set +xu
}

_sync_shared_directories() {
    set -xu
    _gsync $_SHARED_DIR/utils
    _gsync $_SHARED_DIR/shared_notes
    set +xu
}

_startday() {
    _sync_shared_directories
    set -xu
    # & opens in background (otherwise could not trigger next command)
    # nohup keeps programs open when exiting 
    for cmd in $START_COMMANDS; do
        nohup $cmd &
    done
    set +xu
    exit
}
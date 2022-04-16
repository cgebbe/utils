# ======================================= Bash
# make git bash save history - from https://stackoverflow.com/a/10901227/2135504
PROMPT_COMMAND='history -a'

# ======================================= Git
alias glog='git log --decorate --oneline --graph --abbrev=8'
alias grebase='git fetch --all; git rebase origin/master -i --autosquash'
alias gamend="git commit --amend --no-edit"
alias gwip="git add . && git commit -m wip"

# show 10 most recently used branches
alias gbranch="git branch --sort=-committerdate | head -10"

git config --global color.diff.meta "black yellow italic"
gdiff() {
    git diff --color-moved=dimmed-zebra $1
    # possible further options
    # --color-words=" "
    # --color-moved-ws=allow-indentation-change \
}

# search withing git log
# git log
# --walk-reflogs    # show all commits (including dangling ones) from most recent to oldest
# -S <string>       # show commits which change the number of occurences of <string>

# ======================================= python
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


# ======================================= QUICK OPEN

# Define the following variables in .env:
# _IDE_PATH
# _SANDBOX_DIR
# _PROJECT_TEMPLATE_DIR
_PARENT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source ${_PARENT_DIR}/.env

# TODO: Not working at the moment :/
# _assert_variable_set() {
#     if [ -z $1 ]; then
#         echo "Variable $1 is not set" 1>&2
#         # exit 1
#     else
#         echo "Variable $1 is set"
#     fi
# }

# & is used to open in background (otherwise could not trigger next commands).
# nohup is used to keep programs open when exiting.
# >/dev/null is used to t
alias _ide="nohup $_IDE_PATH . >/dev/null 2>&1 &"

_setup_sandbox() {
    [ -z "$1" ] && echo "Please supply a directory name for the sandbox!" && return 1

    set -x # activate debugging from here
    cd ${_SANDBOX_DIR}
    dirname="$(date '+%Y%m%d')_$1"
    echo $dirname
    mkdir ${dirname}
    cd ${dirname}

    cp ${_PROJECT_TEMPLATE_DIR}/* .
    _ide
    _create_venv
    set +x # stop debugging from here
}

_commit_notes() {
    cd /c/data/notes
    git add .
    COMMIT_MESSAGE="commit from $(date '+%Y%m%d_%H%M%S_%N')"
    git commit -m "$COMMIT_MESSAGE"
}

_startday() {
    _commit_notes
    nohup "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE" &
    nohup "C:\apps\doublecmd\doublecmd.exe" &
    nohup pycharm64 &
    nohup code "C:\data\notes" &
    exit
}

# _startday() {
#     nohup code /mnt/sda1/files/notes &
#     nohup /home/cgebbe/pycharm_professional_2020.2/bin/pycharm.sh &
#     nohup /usr/bin/google-chrome-stable %U &
#     exit
# }

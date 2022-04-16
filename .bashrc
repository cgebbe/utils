# GIT
alias glog="git log --all --decorate --oneline --graph --abbrev=8"
alias gwip="git add . && git commit -m 'WIP from $(date +%Y%m%d_%H%M%S)'"

alias pcharm="nohup /home/cgebbe/pycharm_professional_2020.2/bin/pycharm.sh & ."
alias vact="source ./venv/bin/activate"
alias _create_venv="
deactivate
python -m venv venv
source venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
"

# QUICK OPEN
# TODO: get parent folder
source .env

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

_sync_shared_directories() {
    for dir in $SYNC_DIRECTORIES; do
        _gsync $dir
    done
}

_create_shared_note() {
    set -xu
    cd $SHARED_NOTES_PATH
    filename="$(date +%Y%m%d_%H%M%S)_$1.md"
    touch $filename
    $TYPORA $filename
    set +xu
}

_gsync () {
    # -x = prints command to be e(X)ecuted
    # -u = raises error if a variable is (U)nset
    set -xu
    cd $1
    gwip
    git pull
    git push
    set +xu
}
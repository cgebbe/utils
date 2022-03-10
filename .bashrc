# GIT
alias glog="git log --all --decorate --oneline --graph --abbrev=8"
alias pcharm="nohup /home/cgebbe/pycharm_professional_2020.2/bin/pycharm.sh & ."
alias vact="source ./venv/bin/activate"
alias _create_venv="
deactivate
python -m venv venv
source venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
"

# QUICK OPEN
# & is used to open in background (otherwise could not trigger next commands).
# nohup is used to keep programs open when exiting.
alias _startday="
nohup code /mnt/sda1/files/notes &
nohup /home/cgebbe/pycharm_professional_2020.2/bin/pycharm.sh &
nohup /usr/bin/google-chrome-stable %U &
exit
"
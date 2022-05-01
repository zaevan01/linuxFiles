#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export EDITOR='nano'

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias off="sudo systemctl poweroff"
alias roff="sudo systemctl reboot"
alias backup="sudo timeshift --create"
alias sleep="sudo systemctl suspend"
alias wisdom="fortune | cowsay -f tux | lolcat"
alias e="exit"
alias c="clear"
alias tc="trizen -Qdtq"
alias switchon="pactl load-module module-loopback latency_msec=1"
alias switchoff="pactl unload-module module-loopback"
alias damocles="ssh -p 4444 192.168.1.50 -l zac"
alias server="ssh -p 4446 192.168.1.43 -l mrzix"
alias wife="ssh -p 4447 192.168.1.48 -l andy"
alias daedalus="ssh -p 4448 192.168.1.47 -l pi"
alias kronos="ssh -p 4449 192.168.1.45 -l pi"
alias sword="ssh -p 4450 192.168.1.51 -l pi"
alias stick="ssh -p 22 192.168.1.60 -l root"
alias edit="sudo nano ~/.bashrc"

function u() { yay -Syyu --noconfirm; yay -Rsn $(yay -Qdtq) --noconfirm; }
function y() { yay -S $1; }
function yr() { yay -Rsn $1; }
function cache() { sudo pacman -Sc; }
function usd() { u; off; }
function uroff() { u; roff; }
function offt() { backup; u; off; }
function enable() { sudo systemctl enable $1.service; }
function start() { sudo systemctl start $1.service; }

function gpush() { git add $1; git commit -m "Update"; git push origin master; }

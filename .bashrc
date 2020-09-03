#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias off="sudo shutdown now"
alias roff="sudo reboot now"
alias sleep="sudo pm-suspend"
alias wisdom="fortune | cowsay -f tux | lolcat"
alias e="exit"
alias c="clear"
alias tc="trizen -Qdtq"
alias switchon="pactl load-module module-loopback latency_msec=1"
alias switchoff="pactl unload-module module-loopback"
alias start="ssh -p 4446 192.168.1.97 -l mrzix"
alias edit="sudo nano ~/.bashrc"

function u() { trizen -Syu --noconfirm; trizen -Rsn $(trizen -Qdtq) --noconfirm; }
function t() { trizen -S $1; }
function tr() { trizen -Rs $1; }
function usd() { u; off; }
function enable() { sudo systemctl enable $1.service; }

command1()
{
	if [ "$BASH_COMMAND" != command2 ]
	then
		command_flag=1
	fi
	return 0
}
trap command1 debug
command2()
{
	if [ ! "$command_flag" ]
	then
		loginctl lock-session
	fi
	command_flag=
}
PROMPT_COMMAND=command2

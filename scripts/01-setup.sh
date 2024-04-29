#!/bin/bash

# set common env vars / etc
source scripts/00-env.sh

# install mkdocs and plugins/themes/etc
# NOTE: should not be needed now devcontainer call pip install correctly,
#       leaving it here for now (just in cases)
# pip install --no-cache-dir --upgrade pip
# pip install --no-cache-dir -r requirements.txt

# setup git (be sure to set them in 00-env.sh)
git config --global user.name $MAIN_USER
git config --global user.email $MAIN_EMAIL
git config --global --add safe.directory "/workspace"

# setup ~/.bash_aliases
cat << EOF > ~/.bash_aliases
#!/bin/bash

# safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# directory listing aliases
alias ls='ls --color=auto'

alias la='ls -a'
alias ll='ls -l'
alias lla='ls -al'

alias cls='clear; pwd; ls'
alias cla='cls -a'
alias cll='cls -l'
alias clla='cls -al'

alias clt='clear; pwd; tree'
alias clt2='clear; pwd; tree -L 2'

# git aliases
alias cgb='clear; pwd; git branch'
alias cgs='clear; pwd; git status'

# grep aliases
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
EOF
source ~/.bash_aliases

cat << EOF > ~/.bashrc
#!/bin/bash

# setup prompt
# - red prompt for root
# - green prompt for users
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
    PS1="$RED\u@\h [ $NORMAL\w$RED ]# $NORMAL"
else
    PS1="$GREEN\u@\h [ $NORMAL\w$GREEN ]\$ $NORMAL"
fi
unset script RED GREEN NORMAL

# the default umask, not use in ssh sessions
umask 0077

# set PATH so it includes user's private bin directories
if [ -d ~/bin ]; then
    PATH=$PATH:~/bin
    export PATH
fi

EOF
source ~/.bashrc

cat << EOF > ~/.bash_profile
#!/bin/bash

export BASH_SILENCE_DEPRECATION_WARNING=1

# check for .profile
if [ -f ~/.profile ]; then
    . ~/.profile
fi

# check for .bashrc
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# check for .bash_aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# check for bash completions
if [ -f /usr/local/etc/bash_completion ]; then
    . /usr/local/etc/bash_completion;
fi

# vim:set ft=sh syntax=sh ts=4 sw=4 et tw=78:
EOF
source ~/.bash_profile

cat << EOF > ~/.tmux.conf
# 0 is too far from ` ;)
set -g base-index 1

# Automatically set window title
set-window-option -g automatic-rename on
set-option -g set-titles on

#set -g default-terminal screen-256color
set -g status-keys vi
set -g history-limit 10000

setw -g mode-keys vi
setw -g monitor-activity on

# Sane-er split commands
bind-key v split-window -h
bind-key s split-window -v

bind-key | split-window -h -c "#{pane_current_path}"
bind-key - split-window -v -c "#{pane_current_path}"

# Resize pane with Vim movement keys
bind-key J resize-pane -D 5
bind-key K resize-pane -U 5
bind-key H resize-pane -L 5
bind-key L resize-pane -R 5

bind-key M-j resize-pane -D
bind-key M-k resize-pane -U
bind-key M-h resize-pane -L
bind-key M-l resize-pane -R

# Vim style pane selection
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Use Alt-vim keys without prefix key to switch panes
bind -n M-h select-pane -L
bind -n M-j select-pane -D
bind -n M-k select-pane -U
bind -n M-l select-pane -R

# Use Alt-arrow keys without prefix key to switch panes
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Shift arrow to switch windows
bind -n S-Left  previous-window
bind -n S-Right next-window

# No delay for escape key press
set -sg escape-time 0

# Open ~/.tmux.conf in vim and reload settings on quit
unbind e
bind e new-window -n '~/.tmux.conf' "sh -c 'vim ~/.tmux.conf && tmux source ~/.tmux.conf'"

# Reload tmux config
bind r source-file ~/.tmux.conf

# Set mouse mode (tmux v2.1 and later)
set -g mouse on

# THEME
set -g status-justify centre
set -g status-bg black
set -g status-fg white
set -g status-interval 60
set -g status-left-length 30
set -g status-left '#[fg=green][ #(whoami)@#(hostname -f) ]#[default][ '
set -g status-right '#[fg=green] ][ %Y/%m/%d %H:%M:%S ]#[default]'

######################
### DESIGN CHANGES ###
######################

# loud or quiet?
set -g visual-activity off
set -g visual-bell off
set -g visual-silence off
setw -g monitor-activity off
set -g bell-action none

# modes
#setw -g clock-mode-colour colour5
#setw -g mode-style 'fg=green bg=black'

# panes
set -g pane-border-status top
set -g pane-border-format "[ #{pane_index}: #{pane_current_command} ]"

#set -g pane-border-style 'fg=green bg=black'
set -g pane-border-style fg=green      
set -ga pane-border-style bg=black

#set -g pane-active-border-style 'bg=green fg=black'
set -g pane-active-border-style fg=green
set -ga pane-active-border-style bg=black

# windows
set -g window-style 'fg=green bg=black'
set -g window-active-style 'fg=green bg=black'

# window status
setw -g window-status-style fg=green    
setw -ga window-status-style bg=black
setw -ga window-status-style dim

# default window title colors
set-window-option -g window-status-style fg=green
set-window-option -g window-status-style bg=default
set-window-option -g window-status-style dim

# active window title colors
set-window-option -g window-status-current-style fg=white
set-window-option -g window-status-current-style bg=default
set-window-option -g window-status-current-style dim

# default statusbar colors
set -g status-fg green
set -g status-bg black
set -g status-style dim

# messages
set -g message-style fg=white          
set -ga message-style bg=black
set -ga message-style bright

###############################################################################
# Original .tmux.conf
###############################################################################

## Create a new session on server start
#new-session
#
################################################################################
## Key bindings
################################################################################
#
## Default is Ctrl-B
##set -g prefix C-a
#
## Move windows
#bind-key < swap-window -t -1
#bind-key > swap-window -t +1
#
################################################################################
## Set status bar
################################################################################

################################################################################
## Options
################################################################################

################################################################################
## Mouse mode
################################################################################
## On Linux, holding the alt key is terminal selection
#setw -g mode-mouse on
#setw -g mouse-resize-pane on
#setw -g mouse-select-pane on
#setw -g mouse-select-window on

################################################################################
## Tmux Vars
################################################################################

# $(echo $USER) - shows the current username
# %a --> Day of week (Mon)
# %A --> Day of week Expanded (Monday)

# %b --> Month (Jan)
# %d --> Day (31)
# %Y --> Year (2017)

# %D --> Month/Day/Year (12/31/2017)
# %v --> Day-Month-Year (31-Dec-2017)

# %r --> Hour:Min:Sec AM/PM (12:30:27 PM)
# %T --> 24 Hour:Min:Sec (16:30:27)
# %X --> Hour:Min:Sec (12:30:27)
# %R --> 24 Hour:Min (16:30)
# %H --> 24 Hour (16)
# %l --> Hour (12)
# %M --> Mins (30)
# %S --> Seconds (09)
# %p --> AM/PM (AM)

# For a more complete list view: https://linux.die.net/man/3/strftime

#colour0 (black)
#colour1 (red)
#colour2 (green)
#colour3 (yellow)
#colour4 (blue)
#colour7 (white)
#colour5 colour6 colour7 colour8 colour9 colour10 colour11 colour12 colour13 colour14 colour15 colour16 colour17

#D ()
#F ()
#H (hostname)
#I (window index)
#P ()
#S (session index)
#T (pane title)
#W (currnet task like vim if editing a file in vim or zsh if running zsh)

################################################################################
# End of file
################################################################################

EOF

# set file/dir permissions
find . -type d -exec chmod 0700 {} \;
find . -type f -exec chmod 0600 {} \;
chmod 0700 scripts/*.sh

# setup bash aliases
echo; echo;
echo "Don't forget to run: source ~/.bash_aliases"
echo; echo;

# vim: set syn=sh ft=unix ts=4 sw=4 et tw=78:

# Created by newuser for 5.9
#

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
bindkey -v
setopt histignorealldups sharehistory

COLOR_DEF='%f'
COLOR_USR='%F{143}'
COLOR_DIR='%F{29}'
COLOR_GIT='%F{39}'
NEWLINE=$'\n'
#RETVAL="%?"
RETVAL="%(?.%F{green}/.%F{red}X)%f"
setopt PROMPT_SUBST

autoload -Uz vcs_info
zstyle ':vcs_info:*' stagedstr 'S' 
zstyle ':vcs_info:*' unstagedstr 'U' 
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' actionformats '%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats '%F{5}[%F{2}%b%F{5}] %F{2}%c%F{3}%u%f'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
zstyle ':vcs_info:*' enable git 
+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
  [[ $(git ls-files --other --directory --exclude-standard | sed q | wc -l | tr -d ' ') == 1 ]] ; then
  hook_com[unstaged]+='%F{1}?%f'
fi
}


precmd () { vcs_info }
PROMPT='%F{5}[%F{2}%n%F{5}] %F{3}%3~ ${vcs_info_msg_0_}[${RETVAL}]${NEWLINE}%f$ '


RPROMPT='%*'

alias ls="ls --color=auto"
alias ll="ls -a --color=auto"
alias tf="terraform"
alias ot="opentofu"
alias nv="nvim"

export EDITOR=nvim
export VISUAL=nvim
export LANG=en_US.UTF-8
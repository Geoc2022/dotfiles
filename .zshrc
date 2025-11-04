source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
# test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

autoload -U compinit; compinit -i

source ~/my_zsh/zsh-defer/zsh-defer.plugin.zsh
# zsh-defer source ~/my_zsh/fzf/fzf-tab.plugin.zsh

setup_autosuggestions() {
  source ~/my_zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

  autosuggest_accept_partial() {
    if (( $CURSOR == $#BUFFER )); then
      zle forward-word
    else
      zle forward-char
    fi
  }
  zle -N autosuggest_accept_partial

  ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(autosuggest_accept_partial)

  bindkey '^Y' autosuggest-execute        # Accept + execute
  bindkey '^N' autosuggest-clear          # Clear suggestion
  bindkey '^F' autosuggest_accept_partial # Accept one word at a time

  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(buffer-empty bracketed-paste accept-line push-line-or-edit)
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
}
zsh-defer setup_autosuggestions
zsh-defer source ~/my_zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(zoxide init zsh)"
# z() {
#   local dir=$(
#     zoxide query --list --score |
#     fzf --height 40% --layout reverse --info inline \
#         --nth 2.. --tac --no-sort --query "$*" \
#         --bind 'enter:become:echo {2..}'
#   ) && cd "$dir"
# }

alias python='python3'
alias py='python3'
alias ipy='ipython'
alias jl='jupyter-lab'
alias jn='jupyter notebook'
finder() { open -a "finder" "$@"; }
alias firefox='/Applications/Firefox.app/Contents/MacOS/firefox'
alias idea='open -na "IntelliJ IDEA.app"'
alias sshbrown='ssh -A gchemmal@ssh.cs.brown.edu'
# alias sshoscar='ssh -AtX gchemmal@ssh.ccv.brown.edu'
alias sshoscar='ssh -AtX gchemmal@sshcampus.ccv.brown.edu'
scposcar() {
  scp -A gchemmal@sshcampus.ccv.brown.edu:$1 $2
}
alias bored='python ~/Documents/prgm/python/pgm47.py && exit'
alias leet='cd ~/Documents/prgm/leetcode/ && python ~/Documents/prgm/leetcode/leetcode_anki.py'
alias cs300='cd ~/Documents/courses/CS_300 && ./cs300-run-docker'
alias cs1515='cd ~/Documents/courses/CS_1515 && ./cs1515-run-docker'
alias bell='afplay /System/Library/Sounds/Bottle.aiff -v 3'
alias ls='eza --icons --sort oldest --hyperlink --git'
alias tree='eza --icons -T -L'
alias haskell='ghci'
alias notes= 'wezterm --config-file ~/.config/wezterm/notes.lua'

alias \
    grep="grep --color=always" \
    diff="diff --color=always"

explain() {
  local cmd

  if [[ "$1" == "--last" ]]; then
    # Get the last command (excluding 'explain --last')
    cmd=$(fc -ln -1 | head -n 1)
  else
    cmd="$*"
  fi

  local url
  url=$(python3 -c "import urllib.parse, sys; print('https://explainshell.com/explain?cmd=' + urllib.parse.quote(sys.argv[1]))" "$cmd")

  /Applications/Firefox.app/Contents/MacOS/firefox -new-tab "$url"
}


pbfilter() {
  if [ $# -gt 0 ]; then
      pbpaste | "$@" | pbcopy
  else
      pbpaste | pbcopy
  fi
}

touch_r() { mkdir -p "$(dirname "$1")" && touch "$1" ; }

function setup_nvm() {
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}
zsh-defer setup_nvm

function conda_startup() {
  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$('/Users/geo/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "/Users/geo/anaconda3/etc/profile.d/conda.sh" ]; then
          . "/Users/geo/anaconda3/etc/profile.d/conda.sh"
      else
          export PATH="/Users/geo/anaconda3/bin:$PATH"
      fi
  fi
  unset __conda_setup
  # <<< conda initialize <<<
}

function ocamel() {
  [[ ! -r '/Users/geo/.opam/opam-init/init.zsh' ]] || source '/Users/geo/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
}
zsh-defer ocamel

function ghcup() {
  [ -f "/Users/geo/.ghcup/env" ] && source "/Users/geo/.ghcup/env" # ghcup-env
}
zsh-defer ghcup

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

. "$HOME/.local/bin/env"

source <(fzf --zsh)

# also make the preview bat the file
#   --preview 'bat -n --color=always {}'
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'eza --icons -T -L 1 {} && bat -n  --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

export MANPAGER="nvim +Man!"
export VISUAL="nvim"
export EDITOR="vi"

bindkey -v
setopt autocd
set rtp+=/usr/local/opt/fzf
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
export PATH="$PATH:/Applications/Isabelle2025.app/bin"

alias config='/usr/bin/git --git-dir=/Users/geo/.cfg/ --work-tree=/Users/geo'

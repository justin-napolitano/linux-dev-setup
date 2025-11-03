export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git z fzf asdf colored-man-pages docker kubectl zsh-autosuggestions zsh-syntax-highlighting zsh-completions history-substring-search)
source $ZSH/oh-my-zsh.sh

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS SHARE_HISTORY INC_APPEND_HISTORY
export EDITOR="nvim"

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f "$HOME/.asdf/asdf.sh" ] && . "$HOME/.asdf/asdf.sh"
[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh

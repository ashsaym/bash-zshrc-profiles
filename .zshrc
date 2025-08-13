#######################################
# MACOS ZSHRC CONFIGURATION
#######################################
# Optimized for macOS with modern zsh features
# Based on SUSE-style configuration patterns adapted for macOS
#
# INSTALLATION INSTRUCTIONS:
# 1. Copy this file to ~/.zshrc
# 2. Reload: source ~/.zshrc or restart terminal
# 3. Enjoy enhanced macOS zsh experience!
#

#######################################
# SYSTEM DETECTION & MACOS SETUP
#######################################
# Ensure we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Warning: This .zshrc is optimized for macOS only!"
    return 1
fi

export IS_MACOS=true
export MACOS_VERSION="$(sw_vers -productVersion)"
export MACOS_BUILD="$(sw_vers -buildVersion)"

# Architecture detection for Apple Silicon vs Intel
if [[ "$(uname -m)" == "arm64" ]]; then
    export MACOS_ARCH="arm64"
    export IS_APPLE_SILICON=true
else
    export MACOS_ARCH="x86_64"
    export IS_APPLE_SILICON=false
fi

#######################################
# PATH CLEANUP AND SETUP
#######################################
# Robust PATH deduplication function (SUSE-style)
dedup_path() {
    # Handle empty PATH
    [[ -z "$PATH" ]] && return 0
    
    local OLD_PATH="$PATH"
    local NEW_PATH=""
    local ENTRY
    
    # Use proper IFS and array handling for zsh
    local IFS=':'
    local -a ENTRIES
    ENTRIES=(${(s/:/)OLD_PATH})
    
    for ENTRY in "${ENTRIES[@]}"; do
        # Skip empty entries and duplicates
        [[ -z "$ENTRY" ]] && continue
        [[ ":$NEW_PATH:" != *":$ENTRY:"* ]] && NEW_PATH="${NEW_PATH:+$NEW_PATH:}$ENTRY"
    done
    
    export PATH="$NEW_PATH"
    return 0
}

# macOS Homebrew paths (prioritize based on architecture)
if [[ "$IS_APPLE_SILICON" == "true" ]]; then
    # Apple Silicon - prioritize /opt/homebrew
    if [[ -d /opt/homebrew/bin ]]; then
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    fi
    # Fallback to Intel Homebrew if exists
    if [[ -d /usr/local/bin ]]; then
        export PATH="$PATH:/usr/local/bin:/usr/local/sbin"
    fi
else
    # Intel Mac - prioritize /usr/local
    if [[ -d /usr/local/bin ]]; then
        export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
    fi
    # Check for Apple Silicon Homebrew if exists
    if [[ -d /opt/homebrew/bin ]]; then
        export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
    fi
fi

# macOS system paths
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Add user bin directory
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Add MacPorts if installed
if [[ -d /opt/local/bin ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
fi

# Add Xcode Command Line Tools if available
if [[ -d /usr/bin ]]; then
  export PATH="/usr/bin:$PATH"
fi

dedup_path

#######################################
# ENABLE ZSH COMPLETION SYSTEM EARLY
#######################################
autoload -Uz compinit

# macOS optimization: check if completions need refresh daily
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

#######################################
# GENERAL SETTINGS
#######################################
export EDITOR="nano"
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

# macOS-specific environment variables
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Enable better completion matching
setopt AUTO_LIST
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# Directory navigation improvements
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

#######################################
# MACOS-SPECIFIC FEATURES
#######################################
# Quick access to common macOS directories
export CDPATH=".:~:~/Desktop:~/Documents:~/Downloads"

# macOS clipboard integration
alias pbcopy='pbcopy'
alias pbpaste='pbpaste'
alias copy='pbcopy'
alias paste='pbpaste'

# macOS system aliases
alias finder='open -a Finder'
alias preview='open -a Preview'
alias safari='open -a Safari'
alias chrome='open -a "Google Chrome"'
alias vscode='open -a "Visual Studio Code"'

# Show/hide hidden files in Finder
alias showhidden='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidehidden='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'

# macOS system information
alias sysinfo='system_profiler SPSoftwareDataType'
alias machw='system_profiler SPHardwareDataType'

# macOS network utilities
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias localip='ipconfig getifaddr en0'
alias publicip='curl -s http://checkip.amazonaws.com/'

#######################################
# ALIASES HELPER
#######################################
alias aliases='alias | sort'

#######################################
# GIT ALIASES
#######################################
alias gst='git status'
alias gco='git checkout'
alias gcm='git commit -m'
alias gacp='git add . && git commit -m'
alias gpl='git pull'
alias gps='git push'
alias gundo='git reset --soft HEAD~1'
alias gfixup='git commit --fixup'
alias gpr='gh pr create --fill'
alias gco-pr='gh pr checkout'

#######################################
# KUBERNETES (with safe autocompletion)
#######################################
if command -v kubectl &>/dev/null; then
  # Load kubectl's completion first
  source <(kubectl completion zsh)

  # Alias k -> kubectl with same completion
  alias k=kubectl
  compdef __start_kubectl k

  # Namespace autocompletion
  _kubectl_ns_complete() {
    local ns_list
    ns_list=$(kubectl get ns --no-headers -o custom-columns=:metadata.name 2>/dev/null)
    compadd $ns_list
  }
  zstyle ':completion:*:*:kubectl:*' option-stacking yes
  zstyle ':completion:*:*:kubectl:*' matcher-list 'm:{a-z}={A-Za-z}'
  zstyle ':completion:*:*:kubectl:*:options' \
      -n _kubectl_ns_complete \
      --namespace _kubectl_ns_complete

  # Resource-aware completion (describe/logs/etc.)
  _kubectl_resource_complete() {
    __start_kubectl
  }
  compdef _kubectl_resource_complete kubectl k

  # Common kubectl shortcuts
  alias kgp='kubectl get pods'
  alias kgs='kubectl get svc'
  alias kgd='kubectl get deployments'
  alias kga='kubectl get all'
  alias kd='kubectl describe'
  alias kl='kubectl logs'
  alias ke='kubectl exec -it'
  alias kpf='kubectl port-forward'
  alias kns='kubectl config set-context --current --namespace'
fi

#######################################
# FLUXCD
#######################################
if command -v flux &>/dev/null; then
  source <(flux completion zsh)
  alias fxks='flux get kustomizations'
  alias fxhr='flux get helmreleases'
  alias fxre='flux reconcile kustomization'
  alias fxsus='flux suspend kustomization'
  alias fxres='flux resume kustomization'
  alias fxtrace='flux trace'
fi

#######################################
# HELM
#######################################
if command -v helm &>/dev/null; then
  source <(helm completion zsh)
  alias hi='helm install'
  alias hu='helm upgrade'
  alias hr='helm repo'
fi

#######################################
# PYTHON HELPERS
#######################################
if command -v python3 &>/dev/null; then
  alias python='python3'
  alias pip='pip3'
fi
alias mkvenv='python -m venv .venv && source .venv/bin/activate'
alias pysetup='pip install --upgrade pip setuptools wheel'
alias pyclean='find . -type d -name "__pycache__" -exec rm -r {} +'

#######################################
# MODERN CLI TOOLS (macOS optimized)
#######################################
# Enhanced ls with eza (or fallback to native ls with colors)
if command -v eza &>/dev/null; then
    alias ls='eza --icons --color=always'
    alias ll='eza -l --icons --color=always'
    alias la='eza -la --icons --color=always'
    alias lt='eza --tree --icons --color=always'
elif command -v gls &>/dev/null; then
    # GNU ls from coreutils (brew install coreutils)
    alias ls='gls --color=auto'
    alias ll='gls -l --color=auto'
    alias la='gls -la --color=auto'
else
    # Native macOS ls
    alias ls='ls -G'
    alias ll='ls -lG'
    alias la='ls -laG'
fi

# Enhanced cat with bat
command -v bat &>/dev/null && alias cat='bat --style=plain --paging=never'

# Enhanced grep with ripgrep
command -v rg &>/dev/null && alias grep='rg'

# Enhanced top with btop
command -v btop &>/dev/null && alias top='btop'

# Enhanced find with fd
command -v fd &>/dev/null && alias find='fd'

# Enhanced du with dust
command -v dust &>/dev/null && alias du='dust'

# macOS-specific brew aliases
if command -v brew &>/dev/null; then
    alias brewup='brew update && brew upgrade && brew cleanup'
    alias brewinfo='brew info'
    alias brewsearch='brew search'
    alias brewlist='brew list'
    alias brewdeps='brew deps --tree'
fi

#######################################
# DOCKER & CONTAINER TOOLS (macOS optimized)
#######################################
if command -v docker &>/dev/null; then
    alias d='docker'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias drmi='docker rmi'
    alias drm='docker rm'
    alias dstop='docker stop'
    alias dstart='docker start'
    alias drestart='docker restart'
    alias dlogs='docker logs'
    alias dexec='docker exec -it'
    alias dbuild='docker build'
    alias dpull='docker pull'
    alias dpush='docker push'
    
    # Docker cleanup aliases
    alias dclean='docker system prune -f'
    alias dcleanall='docker system prune -a -f'
    alias dvclean='docker volume prune -f'
    alias dnclean='docker network prune -f'
fi

if command -v docker-compose &>/dev/null; then
    alias dc='docker-compose'
    alias dcup='docker-compose up'
    alias dcdown='docker-compose down'
    alias dcbuild='docker-compose build'
    alias dcrestart='docker-compose restart'
    alias dclogs='docker-compose logs'
fi

#######################################
# MACOS DEVELOPMENT TOOLS
#######################################
# Xcode and iOS development
if command -v xcrun &>/dev/null; then
    alias ios-sim='xcrun simctl'
    alias xcode-select='xcode-select'
fi

# Node.js version management with nvm (if installed)
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    source "$HOME/.nvm/nvm.sh"
    alias nodeversions='nvm list'
    alias nodeuse='nvm use'
    alias nodeinstall='nvm install'
fi

# Python version management with pyenv (if installed)
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
    alias pyversions='pyenv versions'
    alias pyuse='pyenv global'
    alias pyinstall='pyenv install'
fi

# Ruby version management with rbenv (if installed)
if command -v rbenv &>/dev/null; then
    eval "$(rbenv init -)"
    alias rubyversions='rbenv versions'
    alias rubyuse='rbenv global'
    alias rubyinstall='rbenv install'
fi

# Kubectl completion (avoid duplicate)
if command -v kubectl &>/dev/null; then
    source <(kubectl completion zsh)
    compdef kubectl k
fi

#######################################
# MACOS TERMINAL ENHANCEMENTS
#######################################
# iTerm2 shell integration (if available)
if [[ -f "$HOME/.iterm2_shell_integration.zsh" ]]; then
    source "$HOME/.iterm2_shell_integration.zsh"
fi

# Auto-suggestions (if installed via brew)
if [[ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Syntax highlighting (if installed via brew)
if [[ -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -f "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

#######################################
# CUSTOM FUNCTIONS
#######################################
# Quick directory creation and navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Weather function using curl
weather() {
    curl -s "wttr.in/${1:-}"
}

# Quick web search
google() {
    open "https://www.google.com/search?q=$*"
}

#######################################
# LOAD LOCAL CUSTOMIZATIONS
#######################################
# Load local customizations if they exist
if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

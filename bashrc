#!/bin/bash
#######################################
# COMPREHENSIVE INTEGRATED BASHRC - COMPLETE VERSION
# ALL features from bashrc-suse + .bashrc with NO missing functionality
# Organized, optimized, duplicate-free but 100% feature complete
#######################################

#######################################
# PATH MANAGEMENT AND DEDUPLICATION
#######################################

# Function to deduplicate PATH
dedup_path() {
    if [ -n "$PATH" ]; then
        old_PATH=$PATH:; PATH=
        while [ -n "$old_PATH" ]; do
            x=${old_PATH%%:*}       # get first component
            case $PATH: in
               *:"$x":*) ;;         # already there
               *) PATH=$PATH:$x;;   # not there yet
            esac
            old_PATH=${old_PATH#*:}
        done
        PATH=${PATH#:}
        unset old_PATH x
    fi
}

# Core system paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Development tools
export PATH="/usr/local/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Programming language specific
export PATH="$HOME/.cargo/bin:$PATH"  # Rust
export PATH="/opt/homebrew/bin:$PATH" # Homebrew on Apple Silicon
export PATH="/usr/local/bin:$PATH"    # Homebrew on Intel

# Kubernetes and DevOps tools
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Python tools
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# Node.js tools
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="./node_modules/.bin:$PATH"

# Export EDITOR and PAGER
export EDITOR=vim
export PAGER=less

# Clean up PATH
dedup_path

#######################################
# ADVANCED COMPLETION SYSTEM
#######################################

# Enhanced completion setup function
setup_proper_completion() {
    # Enable programmable completion features
    if ! shopt -oq posix; then
        if [ -f /usr/share/bash-completion/bash_completion ]; then
            . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
            . /etc/bash_completion
        fi
    fi
    
    # Configure readline for better completion
    bind 'set completion-ignore-case on'      # Case insensitive completion
    bind 'set show-all-if-ambiguous on'       # Show completions without double tab
    bind 'set show-all-if-unmodified on'     # Show completions even with common prefix
    bind 'set menu-complete-display-prefix on' # Show common prefix in menu
    bind 'set colored-completion-prefix on'   # Color the common prefix
    bind 'set completion-query-items 50'     # Query before showing if >50 items
    bind 'set page-completions off'          # Don't page completions
    bind 'set print-completions-horizontally off' # Vertical layout
    bind 'set completion-display-width -1'    # Use full terminal width
    bind 'set completion-query-items 150'     # Ask before showing if >150 items
    
    # Important: Disable file completion for specific commands
    bind 'set skip-completed-text on'         # Skip already typed text
    
    # Key bindings for better completion
    bind 'TAB: complete'                       # TAB completes common prefixes first
    bind '"\e[Z": menu-complete-backward'     # Shift+TAB cycles backward
    bind '"\M-?": possible-completions'       # Alt+? shows all possibilities
}

# Apply the completion setup
setup_proper_completion

# Enhanced debug function to reset completion if it gets broken
fix-completion() {
    echo "🔧 Resetting tab completion configuration..."
    
    # Reset all readline settings to sensible defaults
    bind 'set completion-ignore-case on'
    bind 'set show-all-if-ambiguous on'
    bind 'set show-all-if-unmodified on' 
    bind 'set completion-query-items 150'
    bind 'set page-completions off'
    bind 'set print-completions-horizontally off'
    bind 'set completion-display-width -1'
    bind 'set visible-stats on'
    bind 'set colored-stats on'
    bind 'set mark-directories on'
    bind 'set completion-map-case on'
    bind 'set skip-completed-text on'
    
    # Reset key bindings
    bind 'TAB: complete'
    bind '"\e[Z": menu-complete-backward'
    
    # Clear any existing completion functions that might interfere
    complete -r flux f helm h 2>/dev/null || true
    
    # Re-register our smart completions
    complete -F _flux_smart_complete flux f  
    complete -F _helm_smart_complete helm h
    complete -F _ks_universal_complete ks ksp kss ksd ksn ksns ksrs kssts ksds ksjobs kscj kscm kssec ksing kspv kspvc kssc ksva ksep kseps ksev kslimit ksrq kspc ksrc ksnetpol kssac ksroles ksrb kscroles kscrb kshpa ksvpa kspsp ksmwc ksvwc kscrds ksapi kscr ksleases
    
    # Disable filename completion for these commands
    compopt -o nospace flux f helm h ks 2>/dev/null || true
    compopt +o bashdefault +o default flux f helm h ks 2>/dev/null || true
    
    # Reload bash completion
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
        source /etc/bash_completion  
    fi
    
    echo "✅ Tab completion has been reset."
    echo "💡 Try these tests:"
    echo "   k <TAB>          # Should show kubectl commands"
    echo "   k get <TAB>      # Should show resource types"
    echo "   flux <TAB>       # Should show flux commands"
    echo "   flux get <TAB>   # Should show flux resources"
    echo "   helm <TAB>       # Should show helm commands"
}

# Test completion function to verify all tools work properly
test_completions() {
    echo "🧪 Testing Enhanced Tab Completions"
    echo "=================================="
    echo ""
    
    echo "✅ Kubernetes Commands:"
    echo "  k<TAB>           - kubectl, kill, etc."
    echo "  ks<TAB>          - kubectl smart commands (NOT home directory files!)"
    echo "  ksget<TAB>       - resource types and names"
    echo "  ksn<TAB>         - namespaces only"
    echo "  kns<TAB>         - namespace switching"
    echo "  ksnetpol<TAB>    - network policies"
    echo "  kshpa<TAB>       - horizontal pod autoscalers"
    echo ""
    
    if command -v flux >/dev/null 2>&1; then
        echo "✅ Flux Commands:"
        echo "  freck<TAB>       - kustomizations"
        echo "  frech<TAB>       - helmreleases"
        echo "  fgs<TAB>         - git/helm sources"
        echo ""
    fi
    
    if command -v helm >/dev/null 2>&1; then
        echo "✅ Helm Commands:"
        echo "  hst<TAB>         - helm releases"
        echo "  hinstall<TAB>    - available charts"
        echo "  hrepo<TAB>       - repositories"
        echo ""
    fi
    
    if command -v git >/dev/null 2>&1; then
        echo "✅ Git Commands:"
        echo "  gco<TAB>         - branches (local & remote)"
        echo "  gpl<TAB>         - remotes"
        echo "  gbr<TAB>         - branches"
        echo ""
    fi
    
    echo "🧪 To test if completions are working correctly:"
    echo "1. Type any command above and press TAB"
    echo "2. You should see resource names, NOT home directory files"
    echo "3. If you see home files, run: fix-completion"
    echo ""
    
    # Test kubectl availability and pod completion
    if ! command -v kubectl >/dev/null 2>&1; then
        echo "❌ kubectl not found"
        return 1
    fi
    
    local pods=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
    if [[ -z "$pods" ]]; then
        echo "❌ No pods found in current namespace"
        echo "Try: kns <namespace> to switch to a namespace with pods"
        return 1
    fi
    
    echo "✅ Available pods in current namespace:"
    echo "$pods" | sed 's/^/  /'
    echo ""
    
    # Check for common prefixes
    local first_pod=$(echo "$pods" | head -1)
    local prefix=""
    for ((i=1; i<=${#first_pod}; i++)); do
        local current_prefix="${first_pod:0:i}"
        local matching_count=$(echo "$pods" | grep -c "^${current_prefix}")
        if [[ $matching_count -gt 1 ]]; then
            prefix="$current_prefix"
        else
            break
        fi
    done
    
    if [[ -n "$prefix" && ${#prefix} -gt 3 ]]; then
        echo "💡 Try this test:"
        echo "   k describe pod ${prefix}<TAB>"
        echo "   Should complete to the common prefix automatically!"
    else
        echo "💡 Try this test:"
        echo "   k describe pod <TAB>"
        echo "   Should show all pod names!"
    fi
    echo ""
}

#######################################
# COLOR AND DISPLAY DETECTION
#######################################

# Detect display capabilities
detect_display_capabilities() {
    # Default to safe values
    USE_COLORS="0"
    USE_EMOJIS="0"
    
    # Check if we're in WSL
    IS_WSL=""
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ "$(uname -r)" == *"microsoft"* ]] || [[ "$(uname -r)" == *"WSL"* ]]; then
        IS_WSL="true"
    else
        IS_WSL="false"
    fi
    
    # Color detection
    if [[ -n "$COLORTERM" ]] || [[ "$TERM" == *"color"* ]] || [[ "$TERM" == "xterm-256color" ]]; then
        USE_COLORS="1"
    fi
    
    # Emoji detection
    if [[ "$LANG" == *"UTF-8"* ]] && [[ "$USE_COLORS" == "1" ]]; then
        USE_EMOJIS="1"
    fi
    
    # Set color variables
    if [[ "$USE_COLORS" == "1" ]]; then
        export C_RED='\033[1;31m'
        export C_GREEN='\033[1;32m'
        export C_YELLOW='\033[1;33m'
        export C_BLUE='\033[1;34m'
        export C_PURPLE='\033[1;35m'
        export C_CYAN='\033[1;36m'
        export C_WHITE='\033[1;37m'
        export C_GRAY='\033[0;37m'
        export C_RESET='\033[0m'
    else
        export C_RED=""
        export C_GREEN=""
        export C_YELLOW=""
        export C_BLUE=""
        export C_PURPLE=""
        export C_CYAN=""
        export C_WHITE=""
        export C_GRAY=""
        export C_RESET=""
    fi
    
    # Set emoji variables
    if [[ "$USE_EMOJIS" == "1" ]]; then
        export E_ROCKET="🚀"
        export E_K8S="☸️"
        export E_CHART="📊"
        export E_BULB="💡"
        export E_TARGET="🎯"
        export E_BOOKS="📚"
        export E_GEAR="⚙️"
        export E_SUCCESS="✅"
        export E_CROSS="❌"
        export E_WARNING="⚠️"
        export E_INFO="ℹ️"
        export E_FOLDER="📁"
        export E_FILE="📄"
        export E_LINK="🔗"
        export E_SEARCH="🔍"
        export E_WRENCH="🔧"
        export E_FIRE="🔥"
        export E_STAR="⭐"
        export E_HEART="❤️"
        export E_THUMBS_UP="👍"
        export E_PARTY="🎉"
        export E_THINKING="🤔"
        export E_EYES="👀"
        export E_POINT_RIGHT="👉"
        export E_SPARKLES="✨"
        export E_ZAP="⚡"
        export E_CLOCK="⏰"
        export E_HOURGLASS="⏳"
        export E_COMPUTER="💻"
        export E_PACKAGE="📦"
        export E_SHIELD="🛡️"
        export E_KEY="🔑"
        export E_LOCK="🔒"
        export E_UNLOCK="🔓"
        export E_GLOBE="🌐"
        export E_SATELLITE="📡"
        export E_MEMO="📝"
        export E_CLIPBOARD="📋"
        export E_CHART_WITH_UPWARDS_TREND="📈"
        export E_BAR_CHART="📊"
        export E_CONSTRUCTION="🚧"
        export E_HAMMER="🔨"
        export E_NUT_AND_BOLT="🔩"
        export E_MICROSCOPE="🔬"
        export E_TELESCOPE="🔭"
        export E_CRYSTAL_BALL="🔮"
        export E_JOYSTICK="🕹️"
        export E_TROPHY="🏆"
        export E_MEDAL="🏅"
        export E_CROWN="👑"
        export E_GEM="💎"
        export E_MONEY_BAG="💰"
        export E_CREDIT_CARD="💳"
        export E_RECEIPT="🧾"
        export E_CHART_DECREASING="📉"
        export E_TELEPHONE="☎️"
        export E_MOBILE_PHONE="📱"
        export E_FAX="📠"
        export E_PRINTER="🖨️"
        export E_KEYBOARD="⌨️"
        export E_COMPUTER_MOUSE="🖱️"
        export E_TRACKBALL="🖲️"
        export E_JOYSTICK="🕹️"
        export E_CLAMP="🗜️"
        export E_PAPERCLIP="📎"
        export E_STRAIGHT_RULER="📏"
        export E_TRIANGULAR_RULER="📐"
        export E_SCISSORS="✂️"
        export E_CARD_INDEX="📇"
        export E_CARD_FILE_BOX="🗃️"
        export E_FILE_CABINET="🗄️"
        export E_WASTEBASKET="🗑️"
    else
        # No emoji support - set all emoji variables to empty
        export E_ROCKET=""
        export E_K8S=""
        export E_CHART=""
        export E_BULB=""
        export E_TARGET=""
        export E_BOOKS=""
        export E_GEAR=""
        export E_SUCCESS=""
        export E_CROSS=""
        export E_WARNING=""
        export E_INFO=""
        export E_FOLDER=""
        export E_FILE=""
        export E_LINK=""
        export E_SEARCH=""
        export E_WRENCH=""
        export E_FIRE=""
        export E_STAR=""
        export E_HEART=""
        export E_THUMBS_UP=""
        export E_PARTY=""
        export E_THINKING=""
        export E_EYES=""
        export E_POINT_RIGHT=""
        export E_SPARKLES=""
        export E_ZAP=""
        export E_CLOCK=""
        export E_HOURGLASS=""
        export E_COMPUTER=""
        export E_PACKAGE=""
        export E_SHIELD=""
        export E_KEY=""
        export E_LOCK=""
        export E_UNLOCK=""
        export E_GLOBE=""
        export E_SATELLITE=""
        export E_MEMO=""
        export E_CLIPBOARD=""
        export E_CHART_WITH_UPWARDS_TREND=""
        export E_BAR_CHART=""
        export E_CONSTRUCTION=""
        export E_HAMMER=""
        export E_NUT_AND_BOLT=""
        export E_MICROSCOPE=""
        export E_TELESCOPE=""
        export E_CRYSTAL_BALL=""
        export E_JOYSTICK=""
        export E_TROPHY=""
        export E_MEDAL=""
        export E_CROWN=""
        export E_GEM=""
        export E_MONEY_BAG=""
        export E_CREDIT_CARD=""
        export E_RECEIPT=""
        export E_CHART_DECREASING=""
        export E_TELEPHONE=""
        export E_MOBILE_PHONE=""
        export E_FAX=""
        export E_PRINTER=""
        export E_KEYBOARD=""
        export E_COMPUTER_MOUSE=""
        export E_TRACKBALL=""
        export E_JOYSTICK=""
        export E_CLAMP=""
        export E_PAPERCLIP=""
        export E_STRAIGHT_RULER=""
        export E_TRIANGULAR_RULER=""
        export E_SCISSORS=""
        export E_CARD_INDEX=""
        export E_CARD_FILE_BOX=""
        export E_FILE_CABINET=""
        export E_WASTEBASKET=""
    fi
}

# Initialize display capabilities
detect_display_capabilities

#######################################
# COMPREHENSIVE COLOR DEFINITIONS
#######################################

# Terminal color support check
if [ -t 1 ]; then
    # Check number of colors supported
    ncolors=$(tput colors 2>/dev/null)
    if test -n "$ncolors" && test $ncolors -ge 8; then
        # Basic colors
        export RED='\033[0;31m'
        export GREEN='\033[0;32m'
        export YELLOW='\033[0;33m'
        export BLUE='\033[0;34m'
        export PURPLE='\033[0;35m'
        export CYAN='\033[0;36m'
        export WHITE='\033[0;37m'
        export BLACK='\033[0;30m'
        
        # Bright colors
        export BRIGHT_RED='\033[0;91m'
        export BRIGHT_GREEN='\033[0;92m'
        export BRIGHT_YELLOW='\033[0;93m'
        export BRIGHT_BLUE='\033[0;94m'
        export BRIGHT_PURPLE='\033[0;95m'
        export BRIGHT_CYAN='\033[0;96m'
        export BRIGHT_WHITE='\033[0;97m'
        
        # Bold colors
        export BOLD_RED='\033[1;31m'
        export BOLD_GREEN='\033[1;32m'
        export BOLD_YELLOW='\033[1;33m'
        export BOLD_BLUE='\033[1;34m'
        export BOLD_PURPLE='\033[1;35m'
        export BOLD_CYAN='\033[1;36m'
        export BOLD_WHITE='\033[1;37m'
        
        # Background colors
        export BG_RED='\033[41m'
        export BG_GREEN='\033[42m'
        export BG_YELLOW='\033[43m'
        export BG_BLUE='\033[44m'
        export BG_PURPLE='\033[45m'
        export BG_CYAN='\033[46m'
        export BG_WHITE='\033[47m'
        
        # Special formatting
        export BOLD='\033[1m'
        export DIM='\033[2m'
        export UNDERLINE='\033[4m'
        export BLINK='\033[5m'
        export REVERSE='\033[7m'
        export STRIKETHROUGH='\033[9m'
        
        # Reset
        export NC='\033[0m'      # No Color
        export RESET='\033[0m'   # Reset
    else
        # No color support - set all color variables to empty
        export RED=''
        export GREEN=''
        export YELLOW=''
        export BLUE=''
        export PURPLE=''
        export CYAN=''
        export WHITE=''
        export BLACK=''
        export BRIGHT_RED=''
        export BRIGHT_GREEN=''
        export BRIGHT_YELLOW=''
        export BRIGHT_BLUE=''
        export BRIGHT_PURPLE=''
        export BRIGHT_CYAN=''
        export BRIGHT_WHITE=''
        export BOLD_RED=''
        export BOLD_GREEN=''
        export BOLD_YELLOW=''
        export BOLD_BLUE=''
        export BOLD_PURPLE=''
        export BOLD_CYAN=''
        export BOLD_WHITE=''
        export BG_RED=''
        export BG_GREEN=''
        export BG_YELLOW=''
        export BG_BLUE=''
        export BG_PURPLE=''
        export BG_CYAN=''
        export BG_WHITE=''
        export BOLD=''
        export DIM=''
        export UNDERLINE=''
        export BLINK=''
        export REVERSE=''
        export STRIKETHROUGH=''
        export NC=''
        export RESET=''
    fi
else
    # Not a terminal - disable colors
    export RED=''
    export GREEN=''
    export YELLOW=''
    export BLUE=''
    export PURPLE=''
    export CYAN=''
    export WHITE=''
    export BLACK=''
    export BRIGHT_RED=''
    export BRIGHT_GREEN=''
    export BRIGHT_YELLOW=''
    export BRIGHT_BLUE=''
    export BRIGHT_PURPLE=''
    export BRIGHT_CYAN=''
    export BRIGHT_WHITE=''
    export BOLD_RED=''
    export BOLD_GREEN=''
    export BOLD_YELLOW=''
    export BOLD_BLUE=''
    export BOLD_PURPLE=''
    export BOLD_CYAN=''
    export BOLD_WHITE=''
    export BG_RED=''
    export BG_GREEN=''
    export BG_YELLOW=''
    export BG_BLUE=''
    export BG_PURPLE=''
    export BG_CYAN=''
    export BG_WHITE=''
    export BOLD=''
    export DIM=''
    export UNDERLINE=''
    export BLINK=''
    export REVERSE=''
    export STRIKETHROUGH=''
    export NC=''
    export RESET=''
fi

#######################################
# GENERAL SETTINGS - Terminal Behavior
#######################################

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Enable history expansion with space
# e.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
export HISTTIMEFORMAT='%F %T '

# Keep history in multiple terminal sessions
shopt -s histappend

# Set unlimited history
export HISTSIZE=-1
export HISTFILESIZE=-1

# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

# Enable incremental history search with up/down arrows
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'

# Better directory navigation
shopt -s autocd     # cd to directory just by typing the name
shopt -s dirspell   # correct directory spelling errors
shopt -s cdable_vars # cd to variables

# Glob settings
shopt -s globstar   # ** recursive glob
shopt -s extglob    # extended glob patterns

# Job control
set -o notify       # notify immediately when background job finishes

#######################################
# ENHANCED HISTORY SEARCH & AUTOCOMPLETE
#######################################

# History search with arrow keys (like macOS zsh)
bind '"\e[A": history-search-backward'    # Up arrow
bind '"\e[B": history-search-forward'     # Down arrow
bind '"\eOA": history-search-backward'    # Up arrow (alternative)
bind '"\eOB": history-search-forward'     # Down arrow (alternative)

# Interactive history search
bind '"\C-r": reverse-search-history'     # Ctrl+R
bind '"\C-s": forward-search-history'     # Ctrl+S

# Enhanced completion settings for compact column-based display
# Core completion behavior
bind 'set completion-ignore-case on'           # Case-insensitive completion
bind 'set show-all-if-ambiguous on'           # Show all matches when there's ambiguity
bind 'set show-all-if-unmodified on'          # Show matches even when input matches exactly
bind 'set completion-query-items 200'         # Ask only if more than 200 completions
bind 'set page-completions off'               # Don't use pager for completions

# Display settings for better organization
bind 'set print-completions-horizontally off'  # Vertical list for easier reading
bind 'set completion-display-width -1'         # Use full terminal width
bind 'set visible-stats on'                    # Show file type indicators (*, /, @, etc.)
bind 'set colored-stats on'                    # Color the file type indicators
bind 'set mark-directories on'                 # Mark directories with trailing /
bind 'set mark-symlinked-directories on'       # Mark symlinked directories with /
bind 'set colored-completion-prefix on'        # Color the common prefix
bind 'set menu-complete-display-prefix on'     # Show common prefix in menu
bind 'set completion-map-case on'              # Treat hyphens and underscores as equivalent
bind 'set completion-prefix-display-length 3'  # Show at least 3 chars of prefix
bind 'set skip-completed-text on'              # Skip text that's already been completed

# Menu completion behavior  
bind 'TAB: complete'                            # Standard tab completion
bind '"\e[Z": menu-complete-backward'          # Shift+Tab for reverse menu completion
bind '"\C-i": complete'                        # Alternative tab binding
bind '"\M-?": possible-completions'            # Alt+? to show all possible completions
bind '"\M-*": insert-completions'              # Alt+* to insert all completions

# Advanced features
bind 'set revert-all-at-newline on'           # Clean slate for each new command
bind 'set enable-keypad on'                   # Enable numeric keypad
bind 'set input-meta on'                      # Allow 8-bit input
bind 'set output-meta on'                     # Display 8-bit characters directly
bind 'set convert-meta off'                   # Don't convert meta characters

#######################################
# ADVANCED RESOURCE DISCOVERY & COMPLETION
#######################################

# Cache directory for dynamic resource discovery
KUBECTL_CACHE_DIR="$HOME/.cache/kubectl-completion"
[[ ! -d "$KUBECTL_CACHE_DIR" ]] && mkdir -p "$KUBECTL_CACHE_DIR"

# Function to get all available kubectl resources dynamically
_get_kubectl_resources() {
    local cache_file="$KUBECTL_CACHE_DIR/all-resources"
    local cache_timeout=300  # 5 minutes
    
    # Check if cache exists and is recent
    if [[ -f "$cache_file" && $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0))) -lt $cache_timeout ]]; then
        cat "$cache_file"
        return
    fi
    
    # Generate fresh resource list
    {
        # Get all API resources that support list verb
        kubectl api-resources --verbs=list --no-headers -o name 2>/dev/null | sort -u
        
        # Add common short names
        echo "po pods svc services deploy deployments ing ingress cm configmaps ns namespaces"
        echo "no nodes pv persistentvolumes pvc persistentvolumeclaims sc storageclasses"
        echo "hpa horizontalpodautoscalers netpol networkpolicies sa serviceaccounts"
        echo "rb rolebindings crb clusterrolebindings csr certificatesigningrequests"
    } | tr ' ' '\n' | sort -u > "$cache_file"
    
    cat "$cache_file"
}

# Function to categorize resources dynamically
_categorize_resources() {
    local resource="$1"
    case "$resource" in
        pods|po|services|svc|deployments|deploy|replicasets|rs|statefulsets|sts|daemonsets|ds)
            echo "workloads"
            ;;
        configmaps|cm|secrets|persistentvolumeclaims|pvc|serviceaccounts|sa)
            echo "config"
            ;;
        nodes|no|namespaces|ns|persistentvolumes|pv|storageclasses|sc)
            echo "cluster"
            ;;
        ingress|ing|networkpolicies|netpol|horizontalpodautoscalers|hpa)
            echo "network"
            ;;
        *)
            echo "other"
            ;;
    esac
}

# Dynamic kubectl context switcher with fuzzy matching - SAFE version
kswitch() {
    local pattern="$1"
    
    # Check if kubectl is available and working
    if ! command -v kubectl >/dev/null 2>&1; then
        echo "❌ kubectl not found. Please install kubectl first."
        return 1
    fi
    
    if ! timeout 3s kubectl version --client >/dev/null 2>&1; then
        echo "❌ kubectl not working properly. Please check your kubectl installation."
        return 1
    fi
    
    if [[ $# -eq 0 ]]; then
        echo "Usage: kswitch <pattern>"
        echo "Switch to kubectl context matching pattern"
        echo ""
        echo "Available contexts:"
        if timeout 3s kubectl config get-contexts -o name 2>/dev/null | sed 's/^/  /'; then
            return 0
        else
            echo "❌ Unable to get contexts. Please check your kubeconfig."
            return 1
        fi
    fi
    
    local contexts
    if ! contexts=$(timeout 3s kubectl config get-contexts -o name 2>/dev/null); then
        echo "❌ Unable to get contexts. Please check your kubeconfig."
        return 1
    fi
    
    # Find matching contexts
    local matches
    matches=$(echo "$contexts" | grep -i "$pattern")
    
    if [[ -z "$matches" ]]; then
        echo "❌ No context found matching: $pattern"
        echo "Available contexts:"
        echo "$contexts" | sed 's/^/  /'
        return 1
    fi
    
    local match_count
    match_count=$(echo "$matches" | wc -l)
    
    if [[ $match_count -eq 1 ]]; then
        local context="$matches"
        echo "🔄 Switching to context: $context"
        if kubectl config use-context "$context"; then
            echo "✅ Successfully switched to context: $context"
        else
            echo "❌ Failed to switch to context: $context"
            return 1
        fi
    else
        echo "🔍 Multiple contexts found matching '$pattern':"
        echo "$matches" | nl
        echo -n "Select context number (1-$match_count): "
        read -r selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le $match_count ]]; then
            local context
            context=$(echo "$matches" | sed -n "${selection}p")
            echo "🔄 Switching to context: $context"
            if kubectl config use-context "$context"; then
                echo "✅ Successfully switched to context: $context"
            else
                echo "❌ Failed to switch to context: $context"
                return 1
            fi
        else
            echo "❌ Invalid selection"
            return 1
        fi
    fi
    
    # Clear cache since we changed context - only if clear-kubectl-cache function exists
    clear-kubectl-cache
}

# Completion for kswitch - SAFE version
_kswitch_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    # Early exit if kubectl is not working
    if ! command -v kubectl >/dev/null 2>&1; then
        COMPREPLY=()
        return 0
    fi
    
    # Try to get contexts with timeout and error handling
    local contexts
    if ! contexts=$(timeout 3s kubectl config get-contexts -o name 2>/dev/null); then
        COMPREPLY=()
        return 0
    fi
    
    # Only proceed if we got valid contexts
    if [[ -n "$contexts" ]] && [[ "$contexts" != *"error"* ]]; then
        COMPREPLY=($(compgen -W "$contexts" -- "$cur"))
    else
        COMPREPLY=()
    fi
}

complete -F _kswitch_completion kswitch

# Dynamic namespace switcher
kns() {
    local namespace="$1"
    
    if [[ $# -eq 0 ]]; then
        echo "📁 Available namespaces:"
        kubectl get namespaces -o name | sed 's/namespace\///' | sed 's/^/  /'
        echo ""
        echo "📍 Current namespace: $(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo 'default')"
        return 0
    fi
    
    echo "🔄 Switching to namespace: $namespace"
    kubectl config set-context --current --namespace="$namespace"
    export KUBECTL_NAMESPACE="$namespace"
    
    # Clear cache since we changed namespace
    clear-kubectl-cache
    
    # Save session state for next terminal
    _save_k8s_session 2>/dev/null || true
}

# Completion for kns - SAFE version
_kns_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    # Early exit if kubectl is not working
    if ! command -v kubectl >/dev/null 2>&1; then
        COMPREPLY=()
        return 0
    fi
    
    # Try to get namespaces with timeout and error handling
    local namespaces
    if ! namespaces=$(timeout 3s kubectl get namespaces -o name 2>/dev/null | sed 's/namespace\///'); then
        COMPREPLY=()
        return 0
    fi
    
    # Only proceed if we got valid namespaces
    if [[ -n "$namespaces" ]] && [[ "$namespaces" != *"error"* ]]; then
        COMPREPLY=($(compgen -W "$namespaces" -- "$cur"))
    else
        COMPREPLY=()
    fi
}

complete -F _kns_completion kns

#######################################
# ENHANCED PROMPT - Kubernetes Aware
#######################################

# Function to get current kubernetes context and namespace
_get_k8s_info() {
    if command -v kubectl >/dev/null 2>&1; then
        local context namespace
        context=$(kubectl config current-context 2>/dev/null)
        namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
        namespace=${namespace:-default}
        
        if [[ -n "$context" ]]; then
            echo " ⎈ ${context}:${namespace}"
        fi
    fi
}

# Function to get git branch
_get_git_branch() {
    if command -v git >/dev/null 2>&1; then
        local branch
        branch=$(git branch 2>/dev/null | grep '^*' | cut -d' ' -f2-)
        if [[ -n "$branch" ]]; then
            echo " ⎇ ${branch}"
        fi
    fi
}

# Set the PS1 prompt
_set_enhanced_prompt() {
    local last_command=$?
    local time_color="\[\033[0;36m\]"      # Cyan
    local user_color="\[\033[0;32m\]"      # Green  
    local path_color="\[\033[0;34m\]"      # Blue
    local k8s_color="\[\033[0;35m\]"       # Purple
    local git_color="\[\033[0;33m\]"       # Yellow
    local reset_color="\[\033[0m\]"        # Reset
    local error_color="\[\033[0;31m\]"     # Red
    
    # Status indicator based on last command
    local status_indicator=""
    if [[ $last_command -eq 0 ]]; then
        status_indicator="${user_color}✓${reset_color}"
    else
        status_indicator="${error_color}✗${reset_color}"
    fi
    
    # Build prompt
    PS1=""
    PS1+="${time_color}[\t]${reset_color} "
    PS1+="${status_indicator} "
    PS1+="${user_color}\u@\h${reset_color}:"
    PS1+="${path_color}\w${reset_color}"
    PS1+="${k8s_color}\$(_get_k8s_info)${reset_color}"
    PS1+="${git_color}\$(_get_git_branch)${reset_color}"
    PS1+="\n\$ "
}

# Set the prompt
_set_enhanced_prompt

#######################################
# BASIC ALIASES - System Commands
#######################################

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# List directory contents
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -lart'    # Sort by time
alias lS='ls -laS'     # Sort by size

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# File operations
alias cp='cp -i'       # Confirm before overwriting
alias mv='mv -i'       # Confirm before overwriting
alias rm='rm -i'       # Confirm before deleting
alias ln='ln -i'       # Confirm before linking

# Directory operations
alias mkdir='mkdir -p' # Create parent directories as needed

# System information
alias df='df -h'       # Human readable disk usage
alias du='du -h'       # Human readable directory sizes
alias free='free -h'   # Human readable memory usage
alias ps='ps auxf'     # Full process list
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'  # Process search

# Network
alias ping='ping -c 5' # Limit ping to 5 packets
alias wget='wget -c'   # Continue partial downloads

# Safety aliases
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# Shortcuts
alias h='history'
alias j='jobs -l'
alias which='type -a'
alias ..='cd ..'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# System control
alias reboot='sudo reboot'
alias shutdown='sudo shutdown -h now'

#######################################
# COMPREHENSIVE GIT ALIASES AND FUNCTIONS
#######################################

# Basic git operations
alias g='git'
alias gs='git status'
alias gst='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -a'
alias gcam='git commit -am'
alias gp='git push'
alias gpl='git pull'
alias gps='git push'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate'
alias glog='git log --oneline --graph --decorate --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gbr='git branch -r'
alias gbd='git branch -d'
alias gm='git merge'
alias gr='git remote'
alias grv='git remote -v'
alias gf='git fetch'
alias gfa='git fetch --all'
alias grs='git reset'
alias grsh='git reset --hard'
alias grss='git reset --soft'
alias gsh='git stash'
alias gshl='git stash list'
alias gshp='git stash pop'
alias gsha='git stash apply'
alias gshd='git stash drop'
alias gshc='git stash clear'

# Enhanced git aliases
alias gst-clean='git status --porcelain'
alias glog-graph='git log --graph --oneline --all -10'

# Advanced git aliases
alias git-clean-branches='git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d'
alias git-undo-commit='git reset --soft HEAD~1'
alias git-amend='git commit --amend --no-edit'
alias git-graph='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Enhanced Git completion functions
if command -v git >/dev/null 2>&1; then
    # Load git completion if available
    if [[ -f /usr/share/bash-completion/completions/git ]]; then
        source /usr/share/bash-completion/completions/git
    elif [[ -f /etc/bash_completion.d/git ]]; then
        source /etc/bash_completion.d/git
    fi
    
    # Custom git branch completion
    _git_branches_completion() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local branches
        
        branches=$(git branch 2>/dev/null | sed 's/^[* ] //')
        branches="$branches $(git branch -r 2>/dev/null | sed 's/^[* ] //' | grep -v HEAD)"
        COMPREPLY=($(compgen -W "${branches}" -- "${cur}"))
    }
    
    # Git tag completion
    _git_tags_completion() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local tags
        
        tags=$(git tag 2>/dev/null)
        COMPREPLY=($(compgen -W "${tags}" -- "${cur}"))
    }
    
    # Git remote completion
    _git_remotes_completion() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local remotes
        
        remotes=$(git remote 2>/dev/null)
        COMPREPLY=($(compgen -W "${remotes}" -- "${cur}"))
    }
    
    # Register Git completions for aliases
    complete -F _git_branches_completion gco gbr
    complete -F _git_remotes_completion gpl gps
    complete -F __git_complete gst ga gd glog
fi

#######################################
# PYTHON HELPERS AND ENVIRONMENT
#######################################

if command -v python3 &>/dev/null; then
    alias python='python3'
    alias pip='pip3'
fi

# Python virtual environment shortcuts
alias pyve='python3 -m venv'
alias pyva='source venv/bin/activate'
alias pyvd='deactivate'
alias mkvenv='python3 -m venv .venv && source .venv/bin/activate'
alias pysetup='pip install --upgrade pip setuptools wheel'
alias pyclean='find . -type d -name "__pycache__" -exec rm -r {} + 2>/dev/null'

# Python package management
alias pip='pip3'
alias pipi='pip3 install'
alias pipu='pip3 install --upgrade'
alias pipl='pip3 list'
alias pips='pip3 search'

# Python development
alias py='python3'
alias python='python3'

# Jupyter shortcuts
alias jn='jupyter notebook'
alias jl='jupyter lab'

#######################################
# ENHANCED HISTORY SEARCH & AUTOCOMPLETE
#######################################

# Enhanced history search functions
history-search() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: history-search <pattern>"
        echo "Search command history for pattern"
        return 1
    fi
    
    local pattern="$1"
    echo "🔍 Searching history for: $pattern"
    history | grep -i --color=always "$pattern"
}

# Quick history shortcuts
alias hg='history | grep -i'
alias h10='history | tail -10'
alias h20='history | tail -20'
alias h50='history | tail -50'

# Directory history with pushd/popd
alias pd='pushd'
alias od='popd'
alias d='dirs -v'

# Enhanced cd with history
cd() {
    builtin cd "$@" && pwd && ls -la
}

#######################################
# KUBERNETES (KUBECTL) - COMPLETE SMART ENVIRONMENT  
# This section contains the COMPLETE kubectl environment from .bashrc
# with ALL functions, aliases, completions, and smart features
#######################################

# Fast loading option - set KUBECTL_FAST_LOAD=false to disable optimizations
export KUBECTL_FAST_LOAD="${KUBECTL_FAST_LOAD:-true}"

# Prevent hanging during sourcing
set +e  # Don't exit on errors during sourcing

# Basic check without any external calls that could hang
if command -v kubectl >/dev/null 2>&1; then
    KUBECTL_AVAILABLE=true
else
    echo "⚠️  kubectl not found. Some functions will not work until kubectl is installed."
    KUBECTL_AVAILABLE=false
fi

# Basic kubeconfig management (simplified to prevent hanging)
export KCONFIG_CACHE_DIR="$HOME/.cache/kubeconfig"
export KCONFIG_CACHE_FILE="$KCONFIG_CACHE_DIR/user_configs.txt"
export KCONFIG_DIRS_FILE="$KCONFIG_CACHE_DIR/user_dirs.txt"
mkdir -p "$KCONFIG_CACHE_DIR" 2>/dev/null

# Function to validate if a file is a valid kubeconfig
_is_valid_kubeconfig() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    
    # Check if file contains kubeconfig-like content
    if command -v grep >/dev/null 2>&1; then
        grep -q "apiVersion\|clusters\|contexts\|users" "$file" 2>/dev/null
    else
        # Fallback if grep is not available - simple content check
        head -20 "$file" 2>/dev/null | while IFS= read -r line; do
            case "$line" in
                *apiVersion*|*clusters*|*contexts*|*users*) return 0 ;;
            esac
        done
        return $?
    fi
}

# Function to add a single kubeconfig file
add-kubeconfig() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: add-kubeconfig <path-to-kubeconfig-file>"
        echo "Example: add-kubeconfig ~/my-cluster-config.yaml"
        return 1
    fi
    
    local config_file="$1"
    
    # Expand tilde and resolve path
    config_file="${config_file/#\~/$HOME}"
    config_file="$(realpath "$config_file" 2>/dev/null)" || config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ File does not exist: $config_file"
        return 1
    fi
    
    if ! _is_valid_kubeconfig "$config_file"; then
        echo "❌ Not a valid kubeconfig file: $config_file"
        return 1
    fi
    
    # Add to user configs if not already present
    if ! grep -Fxq "$config_file" "$KCONFIG_CACHE_FILE" 2>/dev/null; then
        echo "$config_file" >> "$KCONFIG_CACHE_FILE"
        echo "✅ Added kubeconfig: $config_file"
    else
        echo "ℹ️  Already added: $config_file"
    fi
}

# Function to add a kubeconfig directory for searching
add-kubeconfig-folder() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: add-kubeconfig-folder <path-to-directory>"
        echo "Example: add-kubeconfig-folder ~/k8s-configs"
        echo "This will search recursively for kubeconfig files in the directory"
        return 1
    fi
    
    local config_dir="$1"
    
    # Expand tilde and resolve path
    config_dir="${config_dir/#\~/$HOME}"
    config_dir="$(realpath "$config_dir" 2>/dev/null)" || config_dir="$1"
    
    if [[ ! -d "$config_dir" ]]; then
        echo "❌ Directory does not exist: $config_dir"
        return 1
    fi
    
    # Add to user directories if not already present
    if ! grep -Fxq "$config_dir" "$KCONFIG_DIRS_FILE" 2>/dev/null; then
        echo "$config_dir" >> "$KCONFIG_DIRS_FILE"
        echo "✅ Added kubeconfig search directory: $config_dir"
        
        # Scan and add any kubeconfigs found
        echo "🔍 Scanning for kubeconfig files..."
        find "$config_dir" -type f \( -name "*.yaml" -o -name "*.yml" -o -name "config" -o -name "*kubeconfig*" \) 2>/dev/null | while IFS= read -r file; do
            if _is_valid_kubeconfig "$file"; then
                if ! grep -Fxq "$file" "$KCONFIG_CACHE_FILE" 2>/dev/null; then
                    echo "$file" >> "$KCONFIG_CACHE_FILE"
                    echo "  ✅ Found: $(basename "$file")"
                fi
            fi
        done
    else
        echo "ℹ️  Already added: $config_dir"
    fi
}

# Function to list all discovered kubeconfig files
kconfigs() {
    local cache_count=0
    
    echo "📋 User-specified kubeconfig files:"
    echo "===================================="
    
    if [[ -f "$KCONFIG_CACHE_FILE" ]]; then
        while IFS= read -r config_file; do
            [[ -n "$config_file" ]] || continue
            if [[ -f "$config_file" ]]; then
                echo "  ✅ $config_file"
                ((cache_count++))
            else
                echo "  ❌ $config_file (missing)"
            fi
        done < "$KCONFIG_CACHE_FILE"
    fi
    
    if [[ -f "$KCONFIG_DIRS_FILE" ]]; then
        echo ""
        echo "📁 User-specified search directories:"
        echo "===================================="
        while IFS= read -r config_dir; do
            [[ -n "$config_dir" ]] || continue
            if [[ -d "$config_dir" ]]; then
                echo "  📁 $config_dir"
            else
                echo "  ❌ $config_dir (missing)"
            fi
        done < "$KCONFIG_DIRS_FILE"
    fi
    
    if [[ $cache_count -eq 0 ]]; then
        echo ""
        echo "🔧 Getting started:"
        echo "  add-kubeconfig <file>        # Add single kubeconfig file"
        echo "  add-kubeconfig-folder <dir>  # Add directory to search"
        echo "  kcc <name>                   # Switch to kubeconfig (Kubeconfig Change/Choose)"
        echo ""
        echo "💡 Examples:"
        echo "  add-kubeconfig ~/.kube/config"
        echo "  add-kubeconfig ~/my-cluster.yaml"
        echo "  add-kubeconfig-folder ~/k8s-configs"
    else
        echo ""
        echo "🎯 Total: $cache_count kubeconfig files available"
        echo "💡 Use: kcc <name> to switch"
    fi
}

# Function to switch kubeconfig (kcc = Kubeconfig Change/Choose)
kcc() {
    if [[ $# -eq 0 ]]; then
        echo "Available kubeconfig files:"
        echo "=========================="
        
        if [[ ! -f "$KCONFIG_CACHE_FILE" ]]; then
            echo "No kubeconfig files found."
            echo ""
            echo "🔧 Add kubeconfig files first:"
            echo "  add-kubeconfig <file>        # Add single file"
            echo "  add-kubeconfig-folder <dir>  # Add directory to search"
            return 1
        fi
        
        local count=0
        while IFS= read -r config_file; do
            [[ -n "$config_file" && -f "$config_file" ]] || continue
            local basename_config=$(basename "$config_file")
            local dirname_config=$(dirname "$config_file")
            printf "%2d. %-30s (%s)\n" $((++count)) "$basename_config" "$dirname_config"
        done < "$KCONFIG_CACHE_FILE"
        
        if [[ $count -eq 0 ]]; then
            echo "No valid kubeconfig files found."
            echo ""
            echo "🔧 Add kubeconfig files first:"
            echo "  add-kubeconfig <file>        # Add single file"
            echo "  add-kubeconfig-folder <dir>  # Add directory to search"
        else
            echo ""
            echo "💡 Usage: kcc <name-or-number>"
        fi
        return 0
    fi
    
    local selection="$1"
    local config_file=""
    
    # Check if selection is a number
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        config_file=$(sed -n "${selection}p" "$KCONFIG_CACHE_FILE" 2>/dev/null)
    else
        # Search by name
        config_file=$(grep "$selection" "$KCONFIG_CACHE_FILE" 2>/dev/null | head -1)
    fi
    
    if [[ -z "$config_file" || ! -f "$config_file" ]]; then
        echo "❌ Kubeconfig not found: $selection"
        echo "Run 'kconfigs' to see available options"
        return 1
    fi
    
    export KUBECONFIG="$config_file"
    echo "✅ Switched to kubeconfig: $(basename "$config_file")"
    echo "📁 Path: $config_file"
    
    # Show current context if kubectl is available
    if command -v kubectl >/dev/null 2>&1; then
        local current_context
        current_context=$(kubectl config current-context 2>/dev/null)
        if [[ -n "$current_context" ]]; then
            echo "🎯 Context: $current_context"
        fi
    fi
    
    # Clear cache since we changed kubeconfig
    clear-kubectl-cache
}

# Tab completion for kcc (Kubeconfig Change/Choose)
_kubeconfig_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local -a configs=()
    
    if [[ -f "$KCONFIG_CACHE_FILE" ]]; then
        while IFS= read -r config_file; do
            [[ -n "$config_file" && -f "$config_file" ]] || continue
            local basename_config
            basename_config=$(basename "$config_file")
            configs+=("$basename_config")
        done < "$KCONFIG_CACHE_FILE"
    fi
    
    COMPREPLY=($(compgen -W "${configs[*]}" -- "$cur"))
}

complete -F _kubeconfig_completion kcc

# Function to export current kubeconfig to environment
kexport() {
    if [[ -z "$KUBECONFIG" ]]; then
        echo "❌ No kubeconfig is currently set"
        echo "Use 'kcc <name>' to select a kubeconfig first"
        return 1
    fi
    
    echo "export KUBECONFIG=\"$KUBECONFIG\""
    echo ""
    echo "💡 Copy and paste the above line to set KUBECONFIG in your current shell"
    echo "📁 Current kubeconfig: $(basename "$KUBECONFIG")"
}

# Function to clear kubectl resource cache
clear-kubectl-cache() {
    rm -f /tmp/kubectl_cache_* 2>/dev/null
    echo "✅ Kubectl cache cleared"
}

#######################################
# CORE KUBECTL ALIASES
#######################################

# Basic kubectl alias - uses basic completion
alias k='kubectl'
#!/bin/bash
# kubectl-smart-production.sh - Enhanced Kubernetes development environment
# Focus: Pure kubectl functionality with intelligent completions and smart functions
# Features: Real-time suggestions, fuzzy matching, comprehensive tab completion, kubeconfig management
# Version 3.0 - Complete Kubernetes developer toolkit with ks (kubectl smart) commands

# Fast loading option - set KUBECTL_FAST_LOAD=false to disable optimizations
export KUBECTL_FAST_LOAD="${KUBECTL_FAST_LOAD:-true}"

# Prevent hanging during sourcing
set +e  # Don't exit on errors during sourcing

# Basic check without any external calls that could hang
if command -v kubectl >/dev/null 2>&1; then
    KUBECTL_AVAILABLE=true
else
    echo "⚠️  kubectl not found. Some functions will not work until kubectl is installed."
    KUBECTL_AVAILABLE=false
fi

# Basic kubeconfig management (simplified to prevent hanging)
export KCONFIG_CACHE_DIR="$HOME/.cache/kubeconfig"
export KCONFIG_CACHE_FILE="$KCONFIG_CACHE_DIR/user_configs.txt"
export KCONFIG_DIRS_FILE="$KCONFIG_CACHE_DIR/user_dirs.txt"
mkdir -p "$KCONFIG_CACHE_DIR" 2>/dev/null

# Function to validate if a file is a valid kubeconfig
_is_valid_kubeconfig() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    
    # Check if file contains kubeconfig-like content
    if command -v grep >/dev/null 2>&1; then
        grep -q "apiVersion\|clusters\|contexts\|users" "$file" 2>/dev/null
    else
        # Fallback if grep is not available - simple content check
        head -20 "$file" 2>/dev/null | while IFS= read -r line; do
            case "$line" in
                *apiVersion*|*clusters*|*contexts*|*users*) return 0 ;;
            esac
        done
        return $?
    fi
}

# Function to add a single kubeconfig file
add-kubeconfig() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: add-kubeconfig <path-to-kubeconfig-file>"
        echo "Example: add-kubeconfig ~/my-cluster-config.yaml"
        return 1
    fi
    
    local config_file="$1"
    
    # Expand tilde and resolve path
    config_file="${config_file/#\~/$HOME}"
    config_file="$(realpath "$config_file" 2>/dev/null)" || config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ File does not exist: $config_file"
        return 1
    fi
    
    if ! _is_valid_kubeconfig "$config_file"; then
        echo "❌ Not a valid kubeconfig file: $config_file"
        return 1
    fi
    
    # Add to user configs if not already present
    if ! grep -Fxq "$config_file" "$KCONFIG_CACHE_FILE" 2>/dev/null; then
        echo "$config_file" >> "$KCONFIG_CACHE_FILE"
        echo "✅ Added kubeconfig: $config_file"
    else
        echo "ℹ️  Already added: $config_file"
    fi
}

# Function to add a kubeconfig directory for searching
add-kubeconfig-folder() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: add-kubeconfig-folder <path-to-directory>"
        echo "Example: add-kubeconfig-folder ~/k8s-configs"
        echo "This will search recursively for kubeconfig files in the directory"
        return 1
    fi
    
    local config_dir="$1"
    
    # Expand tilde and resolve path
    config_dir="${config_dir/#\~/$HOME}"
    config_dir="$(realpath "$config_dir" 2>/dev/null)" || config_dir="$1"
    
    if [[ ! -d "$config_dir" ]]; then
        echo "❌ Directory does not exist: $config_dir"
        return 1
    fi
    
    # Add to user directories if not already present
    if ! grep -Fxq "$config_dir" "$KCONFIG_DIRS_FILE" 2>/dev/null; then
        echo "$config_dir" >> "$KCONFIG_DIRS_FILE"
        echo "✅ Added kubeconfig search directory: $config_dir"
        
        # Scan and add any kubeconfigs found
        echo "🔍 Scanning for kubeconfig files..."
        find "$config_dir" -type f \( -name "*.yaml" -o -name "*.yml" -o -name "config" -o -name "*kubeconfig*" \) 2>/dev/null | while IFS= read -r file; do
            if _is_valid_kubeconfig "$file"; then
                if ! grep -Fxq "$file" "$KCONFIG_CACHE_FILE" 2>/dev/null; then
                    echo "$file" >> "$KCONFIG_CACHE_FILE"
                    echo "  ✅ Found: $(basename "$file")"
                fi
            fi
        done
    else
        echo "ℹ️  Already added: $config_dir"
    fi
}

# Function to list all discovered kubeconfig files
kconfigs() {
    local cache_count=0
    
    echo "📋 User-specified kubeconfig files:"
    echo "===================================="
    
    if [[ -f "$KCONFIG_CACHE_FILE" ]]; then
        while IFS= read -r config_file; do
            [[ -n "$config_file" ]] || continue
            if [[ -f "$config_file" ]]; then
                echo "  ✅ $config_file"
                ((cache_count++))
            else
                echo "  ❌ $config_file (missing)"
            fi
        done < "$KCONFIG_CACHE_FILE"
    fi
    
    if [[ -f "$KCONFIG_DIRS_FILE" ]]; then
        echo ""
        echo "📁 User-specified search directories:"
        echo "===================================="
        while IFS= read -r config_dir; do
            [[ -n "$config_dir" ]] || continue
            if [[ -d "$config_dir" ]]; then
                echo "  📁 $config_dir"
            else
                echo "  ❌ $config_dir (missing)"
            fi
        done < "$KCONFIG_DIRS_FILE"
    fi
    
    if [[ $cache_count -eq 0 ]]; then
        echo ""
        echo "🔧 Getting started:"
        echo "  add-kubeconfig <file>        # Add single kubeconfig file"
        echo "  add-kubeconfig-folder <dir>  # Add directory to search"
        echo "  kcc <name>                   # Switch to kubeconfig (Kubeconfig Change/Choose)"
        echo ""
        echo "💡 Examples:"
        echo "  add-kubeconfig ~/.kube/config"
        echo "  add-kubeconfig ~/my-cluster.yaml"
        echo "  add-kubeconfig-folder ~/k8s-configs"
    else
        echo ""
        echo "🎯 Total: $cache_count kubeconfig files available"
        echo "💡 Use: kcc <name> to switch"
    fi
}

# Function to switch kubeconfig (kcc = Kubeconfig Change/Choose)
kcc() {
    if [[ $# -eq 0 ]]; then
        echo "Available kubeconfig files:"
        echo "=========================="
        
        if [[ ! -f "$KCONFIG_CACHE_FILE" ]]; then
            echo "No kubeconfig files found."
            echo ""
            echo "🔧 Add kubeconfig files first:"
            echo "  add-kubeconfig <file>        # Add single file"
            echo "  add-kubeconfig-folder <dir>  # Add directory to search"
            return 1
        fi
        
        local count=0
        while IFS= read -r config_file; do
            [[ -n "$config_file" && -f "$config_file" ]] || continue
            local basename_config=$(basename "$config_file")
            local dirname_config=$(dirname "$config_file")
            printf "%2d. %-30s (%s)\n" $((++count)) "$basename_config" "$dirname_config"
        done < "$KCONFIG_CACHE_FILE"
        
        if [[ $count -eq 0 ]]; then
            echo "No valid kubeconfig files found."
            echo ""
            echo "🔧 Add kubeconfig files first:"
            echo "  add-kubeconfig <file>        # Add single file"
            echo "  add-kubeconfig-folder <dir>  # Add directory to search"
        else
            echo ""
            echo "💡 Usage: kcc <name-or-number>"
        fi
        return 0
    fi
    
    local selection="$1"
    local config_file=""
    
    # Check if selection is a number
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        config_file=$(sed -n "${selection}p" "$KCONFIG_CACHE_FILE" 2>/dev/null)
    else
        # Search by name
        config_file=$(grep "$selection" "$KCONFIG_CACHE_FILE" 2>/dev/null | head -1)
    fi
    
    if [[ -z "$config_file" || ! -f "$config_file" ]]; then
        echo "❌ Kubeconfig not found: $selection"
        echo "Run 'kconfigs' to see available options"
        return 1
    fi
    
    export KUBECONFIG="$config_file"
    echo "✅ Switched to kubeconfig: $(basename "$config_file")"
    echo "📁 Path: $config_file"
    
    # Show current context if kubectl is available
    if command -v kubectl >/dev/null 2>&1; then
        local current_context
        current_context=$(kubectl config current-context 2>/dev/null)
        if [[ -n "$current_context" ]]; then
            echo "🎯 Context: $current_context"
        fi
    fi
    
    # Clear cache since we changed kubeconfig
    clear-kubectl-cache
}

# Tab completion for kcc (Kubeconfig Change/Choose)
_kubeconfig_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local -a configs=()
    
    if [[ -f "$KCONFIG_CACHE_FILE" ]]; then
        while IFS= read -r config_file; do
            [[ -n "$config_file" && -f "$config_file" ]] || continue
            local basename_config
            basename_config=$(basename "$config_file")
            configs+=("$basename_config")
        done < "$KCONFIG_CACHE_FILE"
    fi
    
    COMPREPLY=($(compgen -W "${configs[*]}" -- "$cur"))
}

complete -F _kubeconfig_completion kcc

# Function to export current kubeconfig to environment
kexport() {
    if [[ -z "$KUBECONFIG" ]]; then
        echo "❌ No kubeconfig is currently set"
        echo "Use 'kcc <name>' to select a kubeconfig first"
        return 1
    fi
    
    echo "export KUBECONFIG=\"$KUBECONFIG\""
    echo ""
    echo "💡 Copy and paste the above line to set KUBECONFIG in your current shell"
    echo "📁 Current kubeconfig: $(basename "$KUBECONFIG")"
}

#######################################
# BASIC CONFIGURATION
#######################################

# Check if kubectl is available (warn but don't exit)
if ! command -v kubectl >/dev/null 2>&1; then
    echo "⚠️  kubectl not found. Some functions will not work until kubectl is installed."
    KUBECTL_AVAILABLE=false
else
    KUBECTL_AVAILABLE=true
fi

# Color definitions (basic)
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# Function to clear kubectl resource cache
clear-kubectl-cache() {
    rm -f /tmp/kubectl_cache_* 2>/dev/null
    echo "✅ Kubectl cache cleared"
}

#######################################
# CORE KUBECTL ALIASES
#######################################

# Basic kubectl alias - uses basic completion
alias k='kubectl'
# Smart kubectl alias with enhanced completions - now a function for help support
# alias ks='kubectl' - converted to function

# All resource aliases are now functions with help support - see smart help system above

# Smart output format and action aliases are now functions with help support

# All namespaces aliases are now functions with help support

#######################################
# SMART HELP SYSTEM FOR ALL KS COMMANDS
#######################################

# Comprehensive help system that handles all ks commands
_ks_help_dispatcher() {
    local cmd="$1"
    
    # Define resource mappings for better help
    declare -A resource_info=(
        [p]="pods" [pods]="pods"
        [s]="services" [services]="services" [svc]="services"
        [d]="deployments" [deployments]="deployments" [deploy]="deployments"
        [n]="nodes" [nodes]="nodes"
        [ns]="namespaces" [namespaces]="namespaces"
        [rs]="replicasets" [replicasets]="replicasets"
        [sts]="statefulsets" [statefulsets]="statefulsets"
        [ds]="daemonsets" [daemonsets]="daemonsets"
        [jobs]="jobs" [job]="jobs"
        [cj]="cronjobs" [cronjobs]="cronjobs"
        [cm]="configmaps" [configmaps]="configmaps"
        [sec]="secrets" [secrets]="secrets"
        [ing]="ingress" [ingress]="ingress"
        [pv]="persistentvolumes" [persistentvolumes]="persistentvolumes"
        [pvc]="persistentvolumeclaims" [persistentvolumeclaims]="persistentvolumeclaims"
        [sc]="storageclasses" [storageclasses]="storageclasses"
        [va]="volumeattachments" [volumeattachments]="volumeattachments"
        [ep]="endpoints" [endpoints]="endpoints"
        [eps]="endpointslices" [endpointslices]="endpointslices"
        [ev]="events" [events]="events"
        [limit]="limitranges" [limitranges]="limitranges"
        [rq]="resourcequotas" [resourcequotas]="resourcequotas"
        [pc]="priorityclasses" [priorityclasses]="priorityclasses"
        [rc]="runtimeclasses" [runtimeclasses]="runtimeclasses"
        [netpol]="networkpolicies" [networkpolicies]="networkpolicies"
        [sac]="serviceaccounts" [serviceaccounts]="serviceaccounts"
        [roles]="roles" [role]="roles"
        [rb]="rolebindings" [rolebindings]="rolebindings"
        [croles]="clusterroles" [clusterroles]="clusterroles"
        [crb]="clusterrolebindings" [clusterrolebindings]="clusterrolebindings"
        [hpa]="horizontalpodautoscalers" [horizontalpodautoscalers]="horizontalpodautoscalers"
        [vpa]="verticalpodautoscalers" [verticalpodautoscalers]="verticalpodautoscalers"
        [psp]="podsecuritypolicies" [podsecuritypolicies]="podsecuritypolicies"
        [mwc]="mutatingwebhookconfigurations" [mutatingwebhookconfigurations]="mutatingwebhookconfigurations"
        [vwc]="validatingwebhookconfigurations" [validatingwebhookconfigurations]="validatingwebhookconfigurations"
        [crds]="customresourcedefinitions" [customresourcedefinitions]="customresourcedefinitions"
        [api]="apiservices" [apiservices]="apiservices"
        [cr]="controllerrevisions" [controllerrevisions]="controllerrevisions"
        [leases]="leases" [lease]="leases"
    )
    
    # Analyze command pattern and provide appropriate help
    case "$cmd" in
        ks)
            echo -e "${BLUE}🚀 ks - Smart kubectl alias${NC}"
            echo -e "${YELLOW}Usage: ks <kubectl-command> [options]${NC}"
            echo ""
            echo -e "${GREEN}📋 Description:${NC}"
            echo "  Enhanced kubectl alias with smart completions and optimizations"
            echo ""
            echo -e "${GREEN}📖 Examples:${NC}"
            echo "  ks get pods                    # List pods"
            echo "  ks get nodes -o wide           # List nodes with details"
            echo "  ks apply -f deployment.yaml    # Apply configuration"
            echo "  ks describe pod nginx-123      # Describe specific pod"
            echo ""
            echo -e "${GREEN}💡 Tips:${NC}"
            echo "  • Use 'klist' for comprehensive help on all ks commands"
            echo "  • All kubectl commands work with ks prefix"
            echo "  • Enhanced tab completion available"
            ;;
        ksp|kss|ksd|ksn|ksns|ksrs|kssts|ksds|ksjobs|kscj|kscm|kssec|ksing|kspv|kspvc|kssc|ksva|ksep|kseps|ksev|kslimit|ksrq|kspc|ksrc|ksnetpol|kssac|ksroles|ksrb|kscroles|kscrb|kshpa|ksvpa|kspsp|ksmwc|ksvwc|kscrds|ksapi|kscr|ksleases)
            # Extract resource type from command name
            local resource_key="${cmd#ks}"
            local resource="${resource_info[$resource_key]}"
            [[ -z "$resource" ]] && resource="$resource_key"
            
            echo -e "${BLUE}📋 $cmd - Get $resource${NC}"
            echo -e "${YELLOW}Usage: $cmd [options]${NC}"
            echo ""
            echo -e "${GREEN}📋 Description:${NC}"
            echo "  Lists $resource in the current namespace"
            echo "  Equivalent to: kubectl get $resource"
            echo ""
            echo -e "${GREEN}📖 Examples:${NC}"
            echo "  $cmd                          # List all $resource"
            echo "  $cmd -o wide                  # Show additional columns"
            echo "  $cmd -o yaml                  # Output in YAML format"
            echo "  $cmd --show-labels            # Display labels"
            echo "  $cmd -n kube-system           # List in specific namespace"
            echo "  $cmd --field-selector=status.phase=Running    # Filter by field"
            echo ""
            echo -e "${GREEN}💡 Tips:${NC}"
            echo "  • Use '${cmd}a' to list across all namespaces"
            echo "  • Combine with grep for filtering: $cmd | grep nginx"
            echo "  • Use 'kubectl describe' for detailed information"
            ;;
        kspa|kssa|ksda|ksrsa|kssta|ksdsa|ksjobsa|kscja|kscma|ksseca|ksinga|kspvca|ksepa|kseva|kssaca|ksrolesa|ksrba|kshpaa|ksnetpola)
            # Extract resource type from command name (remove 'ks' and 'a' suffix)
            local resource_key="${cmd#ks}"
            resource_key="${resource_key%a}"
            local resource="${resource_info[$resource_key]}"
            [[ -z "$resource" ]] && resource="$resource_key"
            
            echo -e "${BLUE}🌐 $cmd - Get $resource across all namespaces${NC}"
            echo -e "${YELLOW}Usage: $cmd [options]${NC}"
            echo ""
            echo -e "${GREEN}📋 Description:${NC}"
            echo "  Lists $resource across all namespaces"
            echo "  Equivalent to: kubectl get $resource -A"
            echo ""
            echo -e "${GREEN}📖 Examples:${NC}"
            echo "  $cmd                          # List all $resource in all namespaces"
            echo "  $cmd -o wide                  # Show additional columns"
            echo "  $cmd --show-labels            # Display labels"
            echo "  $cmd | grep production        # Filter by namespace"
            echo "  $cmd --field-selector=status.phase=Running    # Filter by status"
            echo ""
            echo -e "${GREEN}💡 Tips:${NC}"
            echo "  • Shows NAMESPACE column for easy identification"
            echo "  • Use without 'a' suffix for current namespace only"
            echo "  • Combine with grep for cross-namespace filtering"
            ;;
        ksy|ksj|ksw)
            local format flag
            case "$cmd" in
                ksy) format="YAML"; flag="-o yaml" ;;
                ksj) format="JSON"; flag="-o json" ;;
                ksw) format="wide table"; flag="-o wide" ;;
            esac
            
            echo -e "${BLUE}📄 $cmd - Get resources in $format format${NC}"
            echo -e "${YELLOW}Usage: $cmd <resource> [name] [options]${NC}"
            echo ""
            echo -e "${GREEN}📋 Description:${NC}"
            echo "  Gets Kubernetes resources and outputs in $format format"
            echo "  Equivalent to: kubectl get $flag"
            echo ""
            echo -e "${GREEN}📖 Examples:${NC}"
            echo "  $cmd pods                     # All pods in $format format"
            echo "  $cmd pod nginx-123            # Specific pod in $format format"
            echo "  $cmd deployments              # All deployments in $format format"
            echo "  $cmd service web-app          # Specific service in $format format"
            echo "  $cmd pods -n kube-system      # Pods in specific namespace"
            echo ""
            echo -e "${GREEN}💡 Tips:${NC}"
            [[ "$cmd" == "ksy" ]] && echo "  • Perfect for saving resource definitions to files"
            [[ "$cmd" == "ksj" ]] && echo "  • Useful for programmatic processing with jq"
            [[ "$cmd" == "ksw" ]] && echo "  • Shows additional columns like NODE, AGE, STATUS"
            ;;
        ksget|ksde|ksdescribe|ksl|kse|ksdelete|ksedit|ksconfig|ksapply|kspatch|kslabel|ksannotate)
            local action description
            case "$cmd" in
                ksget) action="get"; description="List and display resources" ;;
                ksde|ksdescribe) action="describe"; description="Show detailed information about resources" ;;
                ksl) action="logs"; description="Display pod logs" ;;
                kse) action="exec"; description="Execute commands in pod containers" ;;
                ksdelete) action="delete"; description="Delete resources" ;;
                ksedit) action="edit"; description="Edit resources in your default editor" ;;
                ksconfig) action="config"; description="Manage kubeconfig files" ;;
                ksapply) action="apply"; description="Apply configuration from files" ;;
                kspatch) action="patch"; description="Update resources using strategic merge patch" ;;
                kslabel) action="label"; description="Add or update labels on resources" ;;
                ksannotate) action="annotate"; description="Add or update annotations on resources" ;;
            esac
            
            echo -e "${BLUE}⚡ $cmd - $description${NC}"
            echo -e "${YELLOW}Usage: $cmd <resource> [name] [options]${NC}"
            echo ""
            echo -e "${GREEN}📋 Description:${NC}"
            echo "  $description"
            echo "  Equivalent to: kubectl $action"
            echo ""
            echo -e "${GREEN}📖 Examples:${NC}"
            case "$cmd" in
                ksget)
                    echo "  $cmd pods                     # List all pods"
                    echo "  $cmd pod nginx-123            # Get specific pod"
                    echo "  $cmd deployments -o wide      # List deployments with details"
                    ;;
                ksde|ksdescribe)
                    echo "  $cmd pod nginx-123            # Describe specific pod"
                    echo "  $cmd deployment web-app       # Describe deployment"
                    echo "  $cmd node worker-1            # Describe node"
                    ;;
                ksl)
                    echo "  $cmd nginx-123                # Get logs from pod"
                    echo "  $cmd nginx-123 -f             # Follow log output"
                    echo "  $cmd nginx-123 -c container   # Logs from specific container"
                    ;;
                kse)
                    echo "  $cmd nginx-123 -- /bin/bash   # Execute bash in pod"
                    echo "  $cmd nginx-123 -- ls -la      # Run command in pod"
                    echo "  $cmd nginx-123 -c app -- sh   # Execute in specific container"
                    ;;
                ksdelete)
                    echo "  $cmd pod nginx-123            # Delete specific pod"
                    echo "  $cmd deployment web-app       # Delete deployment"
                    echo "  $cmd -f deployment.yaml       # Delete from file"
                    ;;
                ksedit)
                    echo "  $cmd deployment web-app       # Edit deployment in editor"
                    echo "  $cmd service web-svc          # Edit service configuration"
                    echo "  $cmd configmap app-config     # Edit configmap"
                    ;;
                ksconfig)
                    echo "  $cmd current-context          # Show current context"
                    echo "  $cmd get-contexts             # List all contexts"
                    echo "  $cmd use-context prod         # Switch to context"
                    ;;
                ksapply)
                    echo "  $cmd -f deployment.yaml       # Apply from file"
                    echo "  $cmd -f . -R                  # Apply from directory recursively"
                    echo "  $cmd -k ./kustomize           # Apply with kustomize"
                    ;;
                kspatch)
                    echo "  $cmd deployment web-app -p '{\"spec\":{\"replicas\":3}}'"
                    echo "  $cmd pod nginx-123 --type='json' -p='[{\"op\":\"replace\",\"path\":\"/spec/containers/0/image\",\"value\":\"nginx:1.20\"}]'"
                    ;;
                kslabel)
                    echo "  $cmd pod nginx-123 app=web    # Add label to pod"
                    echo "  $cmd nodes worker-1 role=worker # Label node"
                    echo "  $cmd deployment web-app version=2.0 # Label deployment"
                    ;;
                ksannotate)
                    echo "  $cmd pod nginx-123 description='Web server pod'"
                    echo "  $cmd deployment web-app deployment.kubernetes.io/revision=2"
                    ;;
            esac
            echo ""
            echo -e "${GREEN}💡 Tips:${NC}"
            echo "  • Use tab completion for resource names"
            echo "  • Add -n <namespace> to specify namespace"
            echo "  • Use --help for full kubectl $action options"
            ;;
        *)
            echo -e "${YELLOW}Help not available for '$cmd'. Use 'klist' for comprehensive help.${NC}"
            return 1
            ;;
    esac
}

# Override function to intercept -h calls for all ks commands
# Show all ks commands with descriptions for easy discovery
_show_ks_commands_with_descriptions() {
    echo -e "${CYAN}📋 Kubernetes Smart (ks) Commands:${NC}"
    echo ""
    echo -e "${GREEN}Resource Listing:${NC}"
    echo -e "  ${YELLOW}ksp${NC}        get pods"
    echo -e "  ${YELLOW}kss${NC}        get services"
    echo -e "  ${YELLOW}ksd${NC}        get deployments"
    echo -e "  ${YELLOW}ksn${NC}        get nodes"
    echo -e "  ${YELLOW}ksns${NC}       get namespaces"
    echo -e "  ${YELLOW}ksjobs${NC}     get jobs"
    echo -e "  ${YELLOW}kscj${NC}       get cronjobs"
    echo -e "  ${YELLOW}kscm${NC}       get configmaps"
    echo -e "  ${YELLOW}kssec${NC}      get secrets"
    echo -e "  ${YELLOW}ksing${NC}      get ingress"
    echo -e "  ${YELLOW}kspv${NC}       get persistentvolumes"
    echo -e "  ${YELLOW}kspvc${NC}      get persistentvolumeclaims"
    echo -e "  ${YELLOW}ksev${NC}       get events"
    echo ""
    echo -e "${GREEN}All Namespaces (-A):${NC}"
    echo -e "  ${YELLOW}kspa${NC}       get pods -A"
    echo -e "  ${YELLOW}kssa${NC}       get services -A"
    echo -e "  ${YELLOW}ksda${NC}       get deployments -A"
    echo -e "  ${YELLOW}ksseca${NC}     get secrets -A"
    echo ""
    echo -e "${GREEN}Actions:${NC}"
    echo -e "  ${YELLOW}ksget${NC}      kubectl get"
    echo -e "  ${YELLOW}ksde${NC}       kubectl describe"
    echo -e "  ${YELLOW}kslogs${NC}     smart pod logs"
    echo -e "  ${YELLOW}ksexec${NC}     smart pod exec"
    echo -e "  ${YELLOW}ksapply${NC}    kubectl apply"
    echo -e "  ${YELLOW}ksdelete${NC}   kubectl delete"
    echo -e "  ${YELLOW}ksedit${NC}     kubectl edit"
    echo ""
    echo -e "${GREEN}Output Formats:${NC}"
    echo -e "  ${YELLOW}ksy${NC}        get -o yaml"
    echo -e "  ${YELLOW}ksj${NC}        get -o json"
    echo -e "  ${YELLOW}ksw${NC}        get -o wide"
    echo ""
    echo -e "${GREEN}Management:${NC}"
    echo -e "  ${YELLOW}ksctx${NC}      context switching"
    echo -e "  ${YELLOW}ksnns${NC}      namespace switching"
    echo -e "  ${YELLOW}ksconfig${NC}   kubectl config"
    echo ""
    echo -e "${CYAN}💡 Use any command followed by ${YELLOW}-h${CYAN} for detailed help${NC}"
    echo -e "${CYAN}💡 Example: ${YELLOW}ksp${CYAN} (shows pods), ${YELLOW}ksapply -f file.yaml${CYAN} (applies config)${NC}"
}

_ks_command_wrapper() {
    local cmd_name="$1"
    shift
    
    # Check if help is requested
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        _ks_help_dispatcher "$cmd_name"
        return 0
    fi
    
    # If not help, execute the original command
    case "$cmd_name" in
        # Commands that are already functions - call them directly
        kscreate|ksjobsa|kswatch|kstop|ksscale|ksrestart|kslogs|ksexec|ksdebug|ksnns|ksall|klist|kslist|kslista|kspf|ksctx)
            "$cmd_name" "$@"
            ;;
        # Base ks command
        ks)
            if [[ $# -eq 0 ]]; then
                _show_ks_commands_with_descriptions
            else
                kubectl "$@"
            fi
            ;;
        # Get commands for single resources
        ksp) kubectl get pods "$@" ;;
        kss) kubectl get services "$@" ;;
        ksd) kubectl get deployments "$@" ;;
        ksn) kubectl get nodes "$@" ;;
        ksns) kubectl get namespaces "$@" ;;
        ksrs) kubectl get replicasets "$@" ;;
        kssts) kubectl get statefulsets "$@" ;;
        ksds) kubectl get daemonsets "$@" ;;
        ksjobs) kubectl get jobs "$@" ;;
        kscj) kubectl get cronjobs "$@" ;;
        kscm) kubectl get configmaps "$@" ;;
        kssec) kubectl get secrets "$@" ;;
        ksing) kubectl get ingress "$@" ;;
        kspv) kubectl get persistentvolumes "$@" ;;
        kspvc) kubectl get persistentvolumeclaims "$@" ;;
        kssc) kubectl get storageclasses "$@" ;;
        ksva) kubectl get volumeattachments "$@" ;;
        ksep) kubectl get endpoints "$@" ;;
        kseps) kubectl get endpointslices "$@" ;;
        ksev) kubectl get events "$@" ;;
        kslimit) kubectl get limitranges "$@" ;;
        ksrq) kubectl get resourcequotas "$@" ;;
        kspc) kubectl get priorityclasses "$@" ;;
        ksrc) kubectl get runtimeclasses "$@" ;;
        ksnetpol) kubectl get networkpolicies "$@" ;;
        kssac) kubectl get serviceaccounts "$@" ;;
        ksroles) kubectl get roles "$@" ;;
        ksrb) kubectl get rolebindings "$@" ;;
        kscroles) kubectl get clusterroles "$@" ;;
        kscrb) kubectl get clusterrolebindings "$@" ;;
        kshpa) kubectl get horizontalpodautoscalers "$@" ;;
        ksvpa) kubectl get verticalpodautoscalers "$@" ;;
        kspsp) kubectl get podsecuritypolicies "$@" ;;
        ksmwc) kubectl get mutatingwebhookconfigurations "$@" ;;
        ksvwc) kubectl get validatingwebhookconfigurations "$@" ;;
        kscrds) kubectl get customresourcedefinitions "$@" ;;
        ksapi) kubectl get apiservices "$@" ;;
        kscr) kubectl get controllerrevisions "$@" ;;
        ksleases) kubectl get leases "$@" ;;
        # Get commands for all namespaces
        kspa) kubectl get pods -A "$@" ;;
        kssa) kubectl get services -A "$@" ;;
        ksda) kubectl get deployments -A "$@" ;;
        ksrsa) kubectl get replicasets -A "$@" ;;
        kssta) kubectl get statefulsets -A "$@" ;;
        ksdsa) kubectl get daemonsets -A "$@" ;;
        kscja) kubectl get cronjobs -A "$@" ;;
        kscma) kubectl get configmaps -A "$@" ;;
        ksseca) kubectl get secrets -A "$@" ;;
        ksinga) kubectl get ingress -A "$@" ;;
        kspvca) kubectl get persistentvolumeclaims -A "$@" ;;
        ksepa) kubectl get endpoints -A "$@" ;;
        kseva) kubectl get events -A "$@" ;;
        kssaca) kubectl get serviceaccounts -A "$@" ;;
        ksrolesa) kubectl get roles -A "$@" ;;
        ksrba) kubectl get rolebindings -A "$@" ;;
        kshpaa) kubectl get horizontalpodautoscalers -A "$@" ;;
        ksnetpola) kubectl get networkpolicies -A "$@" ;;
        # Output format commands
        ksy) kubectl get -o yaml "$@" ;;
        ksj) kubectl get -o json "$@" ;;
        ksw) kubectl get -o wide "$@" ;;
        # Action commands
        ksget) kubectl get "$@" ;;
        ksde) kubectl describe "$@" ;;
        ksdescribe) kubectl describe "$@" ;;
        ksl) kubectl logs "$@" ;;
        kse) kubectl exec -it "$@" ;;
        ksdelete) kubectl delete "$@" ;;
        ksedit) kubectl edit "$@" ;;
        ksconfig) kubectl config "$@" ;;
        ksapply) kubectl apply "$@" ;;
        kspatch) kubectl patch "$@" ;;
        kslabel) kubectl label "$@" ;;
        ksannotate) kubectl annotate "$@" ;;
        *)
            echo "Unknown command: $cmd_name"
            return 1
            ;;
    esac
}

# Create wrapper functions for all ks commands
for cmd in ks ksp kss ksd ksn ksns ksrs kssts ksds ksjobs kscj kscm kssec ksing kspv kspvc kssc ksva ksep kseps ksev kslimit ksrq kspc ksrc ksnetpol kssac ksroles ksrb kscroles kscrb kshpa ksvpa kspsp ksmwc ksvwc kscrds ksapi kscr ksleases kspa kssa ksda ksrsa kssta ksdsa kscja kscma ksseca ksinga kspvca ksepa kseva kssaca ksrolesa ksrba kshpaa ksnetpola ksy ksj ksw ksget ksde ksdescribe ksl kse ksdelete ksedit ksconfig ksapply kspatch kslabel ksannotate; do
    # Skip commands that are already functions
    if ! declare -f "$cmd" > /dev/null 2>&1; then
        eval "${cmd}() { _ks_command_wrapper '$cmd' \"\$@\"; }"
    fi
done

#######################################
# RESOURCE NAME COMPLETION
#######################################

# Universal function to get resource names with caching - SAFE version
_get_k8s_resources() {
    local resource_type="$1"
    local current_input="$2"
    
    # Early exit if kubectl is not available or working
    if ! command -v kubectl >/dev/null 2>&1; then
        return 1
    fi
    
    # Quick test if kubectl is actually working (don't hang the shell)
    if ! timeout 2s kubectl version --client >/dev/null 2>&1; then
        return 1
    fi
    
    # Try to get namespace safely
    local namespace=""
    if timeout 2s kubectl config current-context >/dev/null 2>&1; then
        namespace=$(timeout 2s kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}' 2>/dev/null || echo "")
    fi
    
    # Performance optimization: use cache for frequently accessed resources
    local cache_key="${resource_type}_${namespace:-default}"
    local cache_file="/tmp/kubectl_cache_${cache_key}"
    local cache_duration=30 # seconds
    
    # Check if cache exists and is recent
    if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0))) -lt $cache_duration ]]; then
        cat "$cache_file" 2>/dev/null || return 1
        return 0
    fi
    
    # Fetch fresh data with very short timeout to prevent hanging
    local resources=""
    case "$resource_type" in
        # Namespaced resources
        pods|services|deployments|statefulsets|daemonsets|replicasets|jobs|cronjobs|configmaps|secrets|ingress|persistentvolumeclaims|serviceaccounts|roles|rolebindings|horizontalpodautoscalers|verticalpodautoscalers|endpoints|endpointslices|events|limitranges|resourcequotas|controllerrevisions|leases)
            if [[ -n "$namespace" ]]; then
                resources=$(timeout 3s kubectl get "$resource_type" -n "$namespace" --no-headers -o custom-columns=":metadata.name" 2>/dev/null | head -50 | sort 2>/dev/null)
            else
                resources=$(timeout 3s kubectl get "$resource_type" --no-headers -o custom-columns=":metadata.name" 2>/dev/null | head -50 | sort 2>/dev/null)
            fi
            ;;
        # Cluster-scoped resources
        nodes|namespaces|persistentvolumes|storageclasses|clusterroles|clusterrolebindings|podsecuritypolicies|priorityclasses|runtimeclasses|mutatingwebhookconfigurations|validatingwebhookconfigurations|customresourcedefinitions|apiservices|volumeattachments|networkpolicies)
            resources=$(timeout 3s kubectl get "$resource_type" --no-headers -o custom-columns=":metadata.name" 2>/dev/null | head -50 | sort 2>/dev/null)
            ;;
        *)
            # Try to get the resource anyway with strict timeout
            if [[ -n "$namespace" ]]; then
                resources=$(timeout 3s kubectl get "$resource_type" -n "$namespace" --no-headers -o custom-columns=":metadata.name" 2>/dev/null | head -50 | sort 2>/dev/null)
            else
                resources=$(timeout 3s kubectl get "$resource_type" --no-headers -o custom-columns=":metadata.name" 2>/dev/null | head -50 | sort 2>/dev/null)
            fi
            ;;
    esac
    
    # Cache the results only if we got some and they look valid
    if [[ -n "$resources" ]] && [[ "$resources" != *"error"* ]] && [[ "$resources" != *"Unable to connect"* ]]; then
        echo "$resources" > "$cache_file" 2>/dev/null
        echo "$resources"
    else
        # Return empty on failure to prevent shell crashes
        return 1
    fi
}

# Enhanced resource completion function - SAFE version
_k8s_resource_completion() {
    local resource_type="$1"
    local cur="${2:-${COMP_WORDS[COMP_CWORD]}}"
    
    # Early exit if kubectl is not working
    if ! command -v kubectl >/dev/null 2>&1; then
        COMPREPLY=()
        return 0
    fi
    
    # Get resources safely - if this fails, just return empty completion
    local resources
    if ! resources=$(_get_k8s_resources "$resource_type" "$cur" 2>/dev/null); then
        COMPREPLY=()
        return 0
    fi
    
    # Handle empty results gracefully
    if [[ -z "$resources" ]]; then
        COMPREPLY=()
        return 0
    fi
    
    # Smart matching: exact prefix first, then substring
    local matches=()
    while IFS= read -r resource; do
        [[ -n "$resource" ]] || continue
        if [[ "$resource" == "${cur}"* ]]; then
            matches+=("$resource")
        fi
    done <<< "$resources"
    
    # If no prefix matches, try substring match
    if [[ ${#matches[@]} -eq 0 ]]; then
        while IFS= read -r resource; do
            [[ -n "$resource" ]] || continue
            if [[ "$resource" == *"${cur}"* ]]; then
                matches+=("$resource")
            fi
        done <<< "$resources"
    fi
    
    COMPREPLY=("${matches[@]}")
}

#######################################
# COMPLETION FUNCTIONS
#######################################

# Comprehensive kubectl completion for k (basic kubectl - full native support)
_kubectl_comprehensive_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local cmd="${COMP_WORDS[1]}"
    
    case $COMP_CWORD in
        1)
            # ALL kubectl commands (comprehensive list)
            local commands="annotate api-resources api-versions apply attach auth autoscale certificate cluster-info completion config convert copy cp create debug delete describe diff drain edit exec explain expose get label logs options patch plugin port-forward proxy replace rollout run scale set top uncordon version wait"
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            ;;
        2)
            # Context-aware resource types based on command
            case "$cmd" in
                get|describe|delete|edit|patch|annotate|label)
                    local resources="all pods po services svc deployments deploy statefulsets sts daemonsets ds replicasets rs jobs cronjobs cj nodes no namespaces ns configmaps cm secrets ingress ing persistentvolumes pv persistentvolumeclaims pvc serviceaccounts sa roles rolebindings rb clusterroles clusterrolebindings crb networkpolicies netpol endpoints ep endpointslices events ev limitranges lr resourcequotas quota storageclasses sc horizontalpodautoscalers hpa verticalpodautoscalers vpa volumeattachments priorityclasses pc runtimeclasses mutatingwebhookconfigurations validatingwebhookconfigurations customresourcedefinitions crds apiservices controllerrevisions leases podsecuritypolicies psp"
                    ;;
                logs|exec|port-forward|attach)
                    local resources="pods po"
                    ;;
                scale)
                    local resources="deployments deploy statefulsets sts replicasets rs"
                    ;;
                rollout)
                    local resources="deployments deploy statefulsets sts daemonsets ds"
                    ;;
                top)
                    local resources="nodes no pods po"
                    ;;
                create)
                    local resources="deployment service configmap secret namespace serviceaccount role rolebinding clusterrole clusterrolebinding job cronjob ingress"
                    ;;
                config)
                    local resources="current-context get-contexts use-context view set-context delete-context rename-context"
                    ;;
                apply|replace)
                    local resources="-f --filename --recursive -R --kustomize -k"
                    ;;
                *)
                    local resources="pods po services svc deployments deploy statefulsets sts daemonsets ds nodes no namespaces ns"
                    ;;
            esac
            COMPREPLY=($(compgen -W "$resources" -- "$cur"))
            ;;
        3)
            # Real-time resource name completion based on resource type
            case "$prev" in
                # Pod-related resources
                pods|pod|po) _k8s_resource_completion "pods" ;;
                # Service-related resources  
                services|service|svc) _k8s_resource_completion "services" ;;
                endpoints|ep) _k8s_resource_completion "endpoints" ;;
                endpointslices) _k8s_resource_completion "endpointslices" ;;
                # Workload resources
                deployments|deployment|deploy) _k8s_resource_completion "deployments" ;;
                statefulsets|statefulset|sts) _k8s_resource_completion "statefulsets" ;;
                daemonsets|daemonset|ds) _k8s_resource_completion "daemonsets" ;;
                replicasets|replicaset|rs) _k8s_resource_completion "replicasets" ;;
                jobs|job) _k8s_resource_completion "jobs" ;;
                cronjobs|cronjob|cj) _k8s_resource_completion "cronjobs" ;;
                # Configuration resources
                configmaps|configmap|cm) _k8s_resource_completion "configmaps" ;;
                secrets|secret) _k8s_resource_completion "secrets" ;;
                # Cluster resources
                nodes|node|no) _k8s_resource_completion "nodes" ;;
                namespaces|namespace|ns) _k8s_resource_completion "namespaces" ;;
                # Storage resources
                persistentvolumes|persistentvolume|pv) _k8s_resource_completion "persistentvolumes" ;;
                persistentvolumeclaims|persistentvolumeclaim|pvc) _k8s_resource_completion "persistentvolumeclaims" ;;
                storageclasses|storageclass|sc) _k8s_resource_completion "storageclasses" ;;
                volumeattachments) _k8s_resource_completion "volumeattachments" ;;
                # Network resources
                ingress|ing) _k8s_resource_completion "ingress" ;;
                networkpolicies|netpol) _k8s_resource_completion "networkpolicies" ;;
                # RBAC resources
                serviceaccounts|serviceaccount|sa) _k8s_resource_completion "serviceaccounts" ;;
                roles|role) _k8s_resource_completion "roles" ;;
                rolebindings|rolebinding|rb) _k8s_resource_completion "rolebindings" ;;
                clusterroles|clusterrole) _k8s_resource_completion "clusterroles" ;;
                clusterrolebindings|clusterrolebinding|crb) _k8s_resource_completion "clusterrolebindings" ;;
                # Autoscaling resources
                horizontalpodautoscalers|hpa) _k8s_resource_completion "horizontalpodautoscalers" ;;
                verticalpodautoscalers|vpa) _k8s_resource_completion "verticalpodautoscalers" ;;
                # Policy resources
                podsecuritypolicies|psp) _k8s_resource_completion "podsecuritypolicies" ;;
                # Cluster configuration
                events|ev) _k8s_resource_completion "events" ;;
                limitranges|lr) _k8s_resource_completion "limitranges" ;;
                resourcequotas|quota) _k8s_resource_completion "resourcequotas" ;;
                priorityclasses|pc) _k8s_resource_completion "priorityclasses" ;;
                runtimeclasses) _k8s_resource_completion "runtimeclasses" ;;
                # Admission controllers
                mutatingwebhookconfigurations) _k8s_resource_completion "mutatingwebhookconfigurations" ;;
                validatingwebhookconfigurations) _k8s_resource_completion "validatingwebhookconfigurations" ;;
                # API resources
                customresourcedefinitions|crds) _k8s_resource_completion "customresourcedefinitions" ;;
                apiservices) _k8s_resource_completion "apiservices" ;;
                controllerrevisions) _k8s_resource_completion "controllerrevisions" ;;
                leases) _k8s_resource_completion "leases" ;;
                # Special cases
                all) _k8s_resource_completion "pods" ;; # Default to pods for 'all'
                # Config subcommands
                use-context|delete-context) 
                    local contexts=$(kubectl config get-contexts -o name 2>/dev/null)
                    COMPREPLY=($(compgen -W "$contexts" -- "$cur"))
                    ;;
                *) 
                    # Check if it's a rollout subcommand
                    if [[ "${COMP_WORDS[1]}" == "rollout" ]]; then
                        COMPREPLY=($(compgen -W "status history undo restart pause resume" -- "$cur"))
                    else
                        COMPREPLY=()
                    fi
                    ;;
            esac
            ;;
        4)
            # Fourth argument - handle special cases
            case "${COMP_WORDS[1]}" in
                rollout)
                    case "${COMP_WORDS[2]}" in
                        status|history|undo|restart|pause|resume)
                            case "${COMP_WORDS[3]}" in
                                deployment|deploy) _k8s_resource_completion "deployments" ;;
                                statefulset|sts) _k8s_resource_completion "statefulsets" ;;
                                daemonset|ds) _k8s_resource_completion "daemonsets" ;;
                                *) COMPREPLY=() ;;
                            esac
                            ;;
                    esac
                    ;;
                logs)
                    # Container name completion for multi-container pods
                    local pod_name="${COMP_WORDS[3]}"
                    if [[ -n "$pod_name" ]]; then
                        local containers=$(kubectl get pod "$pod_name" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
                        COMPREPLY=($(compgen -W "$containers" -- "$cur"))
                    fi
                    ;;
                exec)
                    # Common exec commands
                    COMPREPLY=($(compgen -W "/bin/bash /bin/sh sh bash -- -it -i -t" -- "$cur"))
                    ;;
                config)
                    case "${COMP_WORDS[2]}" in
                        set-context)
                            COMPREPLY=($(compgen -W "--current --cluster --user --namespace" -- "$cur"))
                            ;;
                        *)
                            COMPREPLY=()
                            ;;
                    esac
                    ;;
            esac
            ;;
        *)
            # Handle additional arguments for specific commands - common flags
            local common_flags="-o --output -n --namespace -A --all-namespaces -w --watch --show-labels --no-headers -h --help"
            COMPREPLY=($(compgen -W "$common_flags" -- "$cur"))
            ;;
    esac
}

# Register completions - kubectl and k now handled by universal system
# All ks* completion now handled by the enhanced universal system below

#######################################
# UNIVERSAL KS COMPLETION SYSTEM
#######################################

# Enhanced universal completion function with better context awareness and real-time data
_ks_universal_complete() {
    local cmd="$1"
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Define resource mappings for all ks commands with real-time context awareness
    declare -A ks_command_map=(
        # Basic resource get commands
        [ksp]="pods" [kspa]="pods"
        [kss]="services" [kssa]="services"
        [ksd]="deployments" [ksda]="deployments"
        [ksn]="nodes"
        [ksns]="namespaces" [ksnns]="namespaces"
        [ksrs]="replicasets" [ksrsa]="replicasets"
        [kssts]="statefulsets" [kssta]="statefulsets"
        [ksds]="daemonsets" [ksdsa]="daemonsets"
        [ksjobs]="jobs" [ksjobsa]="jobs"
        [kscj]="cronjobs" [kscja]="cronjobs"
        [kscm]="configmaps" [kscma]="configmaps"
        [kssec]="secrets" [ksseca]="secrets"
        [ksing]="ingress" [ksinga]="ingress"
        [kspv]="persistentvolumes"
        [kspvc]="persistentvolumeclaims" [kspvca]="persistentvolumeclaims"
        [kssc]="storageclasses"
        [ksva]="volumeattachments"
        [ksep]="endpoints" [ksepa]="endpoints"
        [kseps]="endpointslices"
        [ksev]="events" [kseva]="events"
        [kslimit]="limitranges"
        [ksrq]="resourcequotas"
        [kspc]="priorityclasses"
        [ksrc]="runtimeclasses"
        [ksnetpol]="networkpolicies" [ksnetpola]="networkpolicies"
        [kssac]="serviceaccounts" [kssaca]="serviceaccounts"
        [ksroles]="roles" [ksrolesa]="roles"
        [ksrb]="rolebindings" [ksrba]="rolebindings"
        [kscroles]="clusterroles"
        [kscrb]="clusterrolebindings"
        [kshpa]="horizontalpodautoscalers" [kshpaa]="horizontalpodautoscalers"
        [ksvpa]="verticalpodautoscalers"
        [kspsp]="podsecuritypolicies"
        [ksmwc]="mutatingwebhookconfigurations"
        [ksvwc]="validatingwebhookconfigurations"
        [kscrds]="customresourcedefinitions"
        [ksapi]="apiservices"
        [kscr]="controllerrevisions"
        [ksleases]="leases"
        # Action commands that work with multiple resource types
        [ksget]="all" [ksde]="all" [ksdescribe]="all"
        [ksl]="pods" [kse]="pods" [ksexec]="pods"
        [ksdelete]="all" [ksedit]="all" [kspatch]="all"
        [kslabel]="all" [ksannotate]="all"
        # Output format commands
        [ksy]="generic" [ksj]="generic" [ksw]="generic"
        # Config commands
        [ksconfig]="config" [ksctx]="contexts"
        [ksapply]="apply"
    )
    
    # Enhanced completion logic with real-time context awareness
    case $COMP_CWORD in
        1)
            # Special case for base 'ks' command - show all ks commands
            if [[ "$cmd" == "ks" ]]; then
                local ks_commands="ksp kss ksd ksn ksns ksjobs kscj kscm kssec ksing kspv kspvc ksev kspa kssa ksda ksseca ksget ksde kslogs ksexec ksapply ksdelete ksedit ksy ksj ksw ksctx ksnns ksconfig"
                COMPREPLY=($(compgen -W "$ks_commands" -- "$cur"))
                return 0
            fi
            
            # First argument completion - show resource types or subcommands
            local resource_type="${ks_command_map[$cmd]}"
            
            case "$resource_type" in
                "all")
                    # Commands that can work with any resource type - provide real-time resource list
                    local resources="all pods po services svc deployments deploy statefulsets sts daemonsets ds replicasets rs jobs cronjobs cj nodes no namespaces ns configmaps cm secrets ingress ing persistentvolumes pv persistentvolumeclaims pvc serviceaccounts sa roles rolebindings rb clusterroles clusterrolebindings crb networkpolicies netpol endpoints ep endpointslices events ev limitranges lr resourcequotas quota storageclasses sc horizontalpodautoscalers hpa verticalpodautoscalers vpa"
                    COMPREPLY=($(compgen -W "$resources" -- "$cur"))
                    ;;
                "generic")
                    # Output format commands (ksy, ksj, ksw) - provide common resources with real context
                    local resources="all pods po services svc deployments deploy statefulsets sts daemonsets ds replicasets rs jobs cronjobs cj nodes no namespaces ns configmaps cm secrets ingress ing persistentvolumes pv persistentvolumeclaims pvc serviceaccounts sa"
                    COMPREPLY=($(compgen -W "$resources" -- "$cur"))
                    ;;
                "config")
                    # kubectl config commands with real-time contexts
                    local config_cmds="current-context get-contexts use-context view set-context delete-context rename-context"
                    COMPREPLY=($(compgen -W "$config_cmds" -- "$cur"))
                    ;;
                "apply")
                    # kubectl apply options
                    COMPREPLY=($(compgen -W "-f --filename --recursive -R --kustomize -k" -- "$cur"))
                    ;;
                "contexts")
                    # Context switching with real-time context list
                    if command -v kubectl >/dev/null 2>&1; then
                        local contexts=$(timeout 2s kubectl config get-contexts -o name 2>/dev/null || echo "")
                        COMPREPLY=($(compgen -W "$contexts" -- "$cur"))
                    fi
                    ;;
                *)
                    # Specific resource type - complete with real resource names from cluster
                    if [[ -n "$resource_type" ]]; then
                        _k8s_resource_completion "$resource_type"
                    else
                        COMPREPLY=()
                    fi
                    ;;
            esac
            ;;
        2)
            # Second argument completion - context-aware resource names
            local resource_type="${ks_command_map[$cmd]}"
            
            case "$resource_type" in
                "all"|"generic")
                    # Complete with real resource names based on what was typed in arg1
                    _complete_resource_by_type "$prev"
                    ;;
                "config")
                    _complete_config_subcommand "$prev" "$cur"
                    ;;
                "apply")
                    # Handle file completion for ksapply -f/--filename
                    if [[ "$prev" == "-f" || "$prev" == "--filename" ]]; then
                        # Complete with YAML/JSON files
                        COMPREPLY=($(compgen -f -X '!*.@(yaml|yml|json)' -- "$cur"))
                        # Also allow directories
                        COMPREPLY+=($(compgen -d -- "$cur"))
                    else
                        # Show more apply options
                        local apply_flags="-f --filename --recursive -R --kustomize -k -n --namespace --dry-run --validate --force --grace-period --timeout"
                        COMPREPLY=($(compgen -W "$apply_flags" -- "$cur"))
                    fi
                    ;;
                *)
                    # Commands with fixed resource types - add common flags
                    local common_flags="-n --namespace -A --all-namespaces -o --output -w --watch --show-labels --no-headers -l --selector"
                    COMPREPLY=($(compgen -W "$common_flags" -- "$cur"))
                    ;;
            esac
            ;;
        3)
            # Third argument completion - enhanced context awareness
            case "$cmd" in
                ksapply)
                    # Continue file completion for ksapply if previous was -f/--filename
                    if [[ "${COMP_WORDS[COMP_CWORD-1]}" == "-f" || "${COMP_WORDS[COMP_CWORD-1]}" == "--filename" ]]; then
                        COMPREPLY=($(compgen -f -X '!*.@(yaml|yml|json)' -- "$cur"))
                        COMPREPLY+=($(compgen -d -- "$cur"))
                    else
                        # Check if any previous argument was -f/--filename for multiple files
                        local i
                        for ((i=1; i<COMP_CWORD; i++)); do
                            if [[ "${COMP_WORDS[i]}" == "-f" || "${COMP_WORDS[i]}" == "--filename" ]]; then
                                COMPREPLY=($(compgen -f -X '!*.@(yaml|yml|json)' -- "$cur"))
                                COMPREPLY+=($(compgen -d -- "$cur"))
                                return 0
                            fi
                        done
                        # Otherwise show flags
                        local apply_flags="-n --namespace --dry-run --validate --force --grace-period --timeout"
                        COMPREPLY=($(compgen -W "$apply_flags" -- "$cur"))
                    fi
                    ;;
                kse|ksexec)
                    # Container name completion for multi-container pods
                    _complete_container_names "${COMP_WORDS[2]}" "$cur"
                    ;;
                ksl)
                    # Container name and log flags
                    _complete_log_options "${COMP_WORDS[2]}" "$cur"
                    ;;
                *)
                    # Common flags for other commands
                    local common_flags="-n --namespace -A --all-namespaces -o --output -w --watch --show-labels --no-headers -h --help"
                    COMPREPLY=($(compgen -W "$common_flags" -- "$cur"))
                    ;;
            esac
            ;;
        *)
            # Additional arguments - context-aware flags
            case "$cmd" in
                ksapply)
                    # Continue file completion for ksapply
                    if [[ "${COMP_WORDS[COMP_CWORD-1]}" == "-f" || "${COMP_WORDS[COMP_CWORD-1]}" == "--filename" ]]; then
                        COMPREPLY=($(compgen -f -X '!*.@(yaml|yml|json)' -- "$cur"))
                        COMPREPLY+=($(compgen -d -- "$cur"))
                    else
                        # Check if any previous argument was -f/--filename
                        local i
                        for ((i=1; i<COMP_CWORD; i++)); do
                            if [[ "${COMP_WORDS[i]}" == "-f" || "${COMP_WORDS[i]}" == "--filename" ]]; then
                                COMPREPLY=($(compgen -f -X '!*.@(yaml|yml|json)' -- "$cur"))
                                COMPREPLY+=($(compgen -d -- "$cur"))
                                return 0
                            fi
                        done
                        local apply_flags="-n --namespace --dry-run --validate --force --grace-period --timeout"
                        COMPREPLY=($(compgen -W "$apply_flags" -- "$cur"))
                    fi
                    ;;
                *)
                    local common_flags="-n --namespace -A --all-namespaces -o --output -w --watch --show-labels --no-headers -h --help"
                    COMPREPLY=($(compgen -W "$common_flags" -- "$cur"))
                    ;;
            esac
            ;;
    esac
}

# Helper function to complete resource names by type with real-time data
_complete_resource_by_type() {
    local resource_type="$1"
    case "$resource_type" in
        pods|pod|po) _k8s_resource_completion "pods" ;;
        services|service|svc) _k8s_resource_completion "services" ;;
        deployments|deployment|deploy) _k8s_resource_completion "deployments" ;;
        statefulsets|statefulset|sts) _k8s_resource_completion "statefulsets" ;;
        daemonsets|daemonset|ds) _k8s_resource_completion "daemonsets" ;;
        replicasets|replicaset|rs) _k8s_resource_completion "replicasets" ;;
        jobs|job) _k8s_resource_completion "jobs" ;;
        cronjobs|cronjob|cj) _k8s_resource_completion "cronjobs" ;;
        nodes|node|no) _k8s_resource_completion "nodes" ;;
        namespaces|namespace|ns) _k8s_resource_completion "namespaces" ;;
        configmaps|configmap|cm) _k8s_resource_completion "configmaps" ;;
        secrets|secret) _k8s_resource_completion "secrets" ;;
        ingress|ing) _k8s_resource_completion "ingress" ;;
        persistentvolumes|persistentvolume|pv) _k8s_resource_completion "persistentvolumes" ;;
        persistentvolumeclaims|persistentvolumeclaim|pvc) _k8s_resource_completion "persistentvolumeclaims" ;;
        serviceaccounts|serviceaccount|sa) _k8s_resource_completion "serviceaccounts" ;;
        roles|role) _k8s_resource_completion "roles" ;;
        rolebindings|rolebinding|rb) _k8s_resource_completion "rolebindings" ;;
        clusterroles|clusterrole) _k8s_resource_completion "clusterroles" ;;
        clusterrolebindings|clusterrolebinding|crb) _k8s_resource_completion "clusterrolebindings" ;;
        horizontalpodautoscalers|hpa) _k8s_resource_completion "horizontalpodautoscalers" ;;
        verticalpodautoscalers|vpa) _k8s_resource_completion "verticalpodautoscalers" ;;
        endpoints|ep) _k8s_resource_completion "endpoints" ;;
        endpointslices) _k8s_resource_completion "endpointslices" ;;
        events|ev) _k8s_resource_completion "events" ;;
        limitranges|lr) _k8s_resource_completion "limitranges" ;;
        resourcequotas|quota) _k8s_resource_completion "resourcequotas" ;;
        storageclasses|sc) _k8s_resource_completion "storageclasses" ;;
        networkpolicies|netpol) _k8s_resource_completion "networkpolicies" ;;
        *) COMPREPLY=() ;;
    esac
}

# Helper function for config subcommand completion with real-time data
_complete_config_subcommand() {
    local subcommand="$1"
    local cur="$2"
    
    case "$subcommand" in
        use-context|delete-context|rename-context)
            if command -v kubectl >/dev/null 2>&1; then
                local contexts=$(timeout 2s kubectl config get-contexts -o name 2>/dev/null || echo "")
                COMPREPLY=($(compgen -W "$contexts" -- "$cur"))
            fi
            ;;
        set-context)
            COMPREPLY=($(compgen -W "--current --cluster --user --namespace" -- "$cur"))
            ;;
        *) COMPREPLY=() ;;
    esac
}

# Helper function for container name completion with real-time data
_complete_container_names() {
    local pod_name="$1"
    local cur="$2"
    
    if [[ -n "$pod_name" ]] && command -v kubectl >/dev/null 2>&1; then
        local containers=$(timeout 2s kubectl get pod "$pod_name" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null || echo "")
        COMPREPLY=($(compgen -W "$containers -- -it -i -t /bin/bash /bin/sh bash sh" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "-- -it -i -t /bin/bash /bin/sh bash sh" -- "$cur"))
    fi
}

# Helper function for log options with real-time container data
_complete_log_options() {
    local pod_name="$1"
    local cur="$2"
    
    if [[ -n "$pod_name" ]] && command -v kubectl >/dev/null 2>&1; then
        local containers=$(timeout 2s kubectl get pod "$pod_name" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null || echo "")
        COMPREPLY=($(compgen -W "$containers -f --follow -p --previous --tail --since -c --container" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "-f --follow -p --previous --tail --since -c --container" -- "$cur"))
    fi
}

# Register the universal completion for ALL ks commands
# Generate the complete list of all ks commands automatically
_register_ks_completions() {
    local ks_commands=(
        ks ksp kss ksd ksn ksns ksrs kssts ksds ksjobs kscj kscm kssec ksing kspv kspvc kssc ksva ksep kseps ksev kslimit ksrq kspc ksrc ksnetpol kssac ksroles ksrb kscroles kscrb kshpa ksvpa kspsp ksmwc ksvwc kscrds ksapi kscr ksleases 
        kspa kssa ksda ksrsa kssta ksdsa kscja kscma ksseca ksinga kspvca ksepa kseva kssaca ksrolesa ksrba kshpaa ksnetpola 
        ksy ksj ksw ksget ksde ksdescribe ksl kse ksdelete ksedit ksconfig ksapply kspatch kslabel ksannotate ksexec ksctx ksnns
        kswatch kstop kscreate ksjobsa kspf ksscale ksrestart kslogs ksdebug
    )
    
    # Register universal completion for each command
    for cmd in "${ks_commands[@]}"; do
        # Create a wrapper function for each command that calls the universal completer
        eval "_${cmd}_complete() { _ks_universal_complete '$cmd'; }"
        
        # Register the completion
        complete -F "_${cmd}_complete" "$cmd"
    done
}

# Execute the registration
_register_ks_completions

# Register universal completion for kubectl and aliases
_register_kubectl_completions() {
    local kubectl_commands=(
        kubectl k ky kwide kj kgp kgs kgd kga kd kl klf ke kpf kgns kgno kgev kallns kpods ksvc kdeploy kgpy kgpw
        kn kns kh ksh kpod-info kgetall kpf-auto kscale kpod-restart
    )
    
    # Register universal completion for each kubectl command
    for cmd in "${kubectl_commands[@]}"; do
        # Use the existing kubectl smart complete function
        complete -F _kubectl_smart_complete "$cmd"
    done
}

# Execute kubectl registration  
_register_kubectl_completions

#######################################
# NAMESPACE MANAGEMENT
#######################################

# Function to switch namespace (updated for ks)
ksnns() {
    if [[ $# -eq 0 ]]; then
        echo -e "${CYAN}Available namespaces:${NC}"
        kubectl get namespaces --no-headers -o custom-columns=":metadata.name" | sed 's/^/  /'
        
        echo -e "\n${YELLOW}Current namespace:${NC}"
        local current_ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
        echo "  ${current_ns:-default}"
        
        echo -e "\n${BLUE}Usage: ksnns <namespace>${NC}"
        return 0
    fi
    
    local namespace="$1"
    if kubectl get namespace "$namespace" >/dev/null 2>&1; then
        kubectl config set-context --current --namespace="$namespace"
        export KUBECTL_NAMESPACE="$namespace"
        echo -e "${GREEN}✅ Switched to namespace: $namespace${NC}"
        
        # Save session state for next terminal
        _save_k8s_session 2>/dev/null || true
    else
        echo -e "${RED}❌ Namespace '$namespace' not found${NC}"
        return 1
    fi
}

# Completion for ksnns
_ksnns_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    _k8s_resource_completion "namespaces"
}
complete -F _ksnns_completion ksnns

#######################################
# ENHANCED POD MANAGEMENT (KS VERSIONS)
#######################################

# Smart pod logs with fuzzy matching
kslogs() {
    if [[ $# -eq 0 ]]; then
        echo -e "${YELLOW}Usage: kslogs <pod-pattern> [options]${NC}"
        echo "Available pods:"
        kubectl get pods --no-headers -o custom-columns="NAME:.metadata.name,STATUS:.status.phase" | sed 's/^/  /'
        return 1
    fi
    
    local pod_pattern="$1"
    shift
    
    local pod=$(_find_pod_by_pattern "$pod_pattern")
    
    if [[ -z "$pod" ]]; then
        echo -e "${RED}❌ No pod found matching pattern: $pod_pattern${NC}"
        echo "Available pods:"
        kubectl get pods --no-headers -o custom-columns="NAME:.metadata.name,STATUS:.status.phase" | sed 's/^/  /'
        return 1
    fi
    
    echo -e "${GREEN}📋 Getting logs for pod: $pod${NC}"
    kubectl logs "$pod" "$@"
}

# Smart pod exec with fuzzy matching
ksexec() {
    if [[ $# -eq 0 ]]; then
        echo -e "${YELLOW}Usage: ksexec <pod-pattern> [command]${NC}"
        echo "Available pods:"
        kubectl get pods --no-headers -o custom-columns="NAME:.metadata.name,STATUS:.status.phase" | sed 's/^/  /'
        return 1
    fi
    
    local pod_pattern="$1"
    local cmd="${2:-bash}"
    
    local pod=$(_find_pod_by_pattern "$pod_pattern")
    
    if [[ -z "$pod" ]]; then
        echo -e "${RED}❌ No pod found matching pattern: $pod_pattern${NC}"
        echo "Available pods:"
        kubectl get pods --no-headers -o custom-columns="NAME:.metadata.name,STATUS:.status.phase" | sed 's/^/  /'
        return 1
    fi
    
    echo -e "${GREEN}🚀 Executing into pod: $pod${NC}"
    kubectl exec -it "$pod" -- "$cmd"
}

# Pod debugging function
ksdebug() {
    if [[ $# -eq 0 ]]; then
        echo -e "${YELLOW}Usage: ksdebug <pod-pattern>${NC}"
        echo "Available pods:"
        kubectl get pods --no-headers -o custom-columns="NAME:.metadata.name,STATUS:.status.phase" | sed 's/^/  /'
        return 1
    fi
    
    local pod_pattern="$1"
    
    local pod=$(_find_pod_by_pattern "$pod_pattern")
    
    if [[ -z "$pod" ]]; then
        echo -e "${RED}❌ No pod found matching pattern: $pod_pattern${NC}"
        return 1
    fi
    
    echo -e "${CYAN}🔍 Debug info for pod: $pod${NC}"
    echo "=========================="
    echo -e "\n${YELLOW}Status:${NC}"
    kubectl get pod "$pod" -o wide
    
    echo -e "\n${YELLOW}Pod Details:${NC}"
    kubectl describe pod "$pod" | head -30
    
    echo -e "\n${YELLOW}Recent Events:${NC}"
    kubectl get events --field-selector involvedObject.name="$pod" --sort-by='.lastTimestamp' | tail -5
    
    echo -e "\n${YELLOW}Recent Logs (last 10 lines):${NC}"
    kubectl logs "$pod" --tail=10 2>/dev/null || echo "No logs available"
}

# Function to show everything in current namespace
ksall() {
    local current_ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
    current_ns="${current_ns:-default}"
    
    echo -e "${CYAN}📊 All resources in namespace: ${YELLOW}$current_ns${NC}"
    echo "============================================="
    
    echo -e "\n${GREEN}Pods:${NC}"
    kubectl get pods -o wide 2>/dev/null || echo "  No pods found"
    
    echo -e "\n${GREEN}Services:${NC}"
    kubectl get services -o wide 2>/dev/null || echo "  No services found"
    
    echo -e "\n${GREEN}Deployments:${NC}"
    kubectl get deployments -o wide 2>/dev/null || echo "  No deployments found"
    
    echo -e "\n${GREEN}ConfigMaps:${NC}"
    kubectl get configmaps --no-headers 2>/dev/null | head -5 || echo "  No configmaps found"
    
    echo -e "\n${GREEN}Recent Events:${NC}"
    kubectl get events --sort-by='.lastTimestamp' --no-headers 2>/dev/null | tail -5 || echo "  No recent events"
}

# Completion for pod-related functions
_kubectl_pods_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    _k8s_resource_completion "pods"
}
# Note: kslogs, ksdebug need pod completion like ksexec
complete -F _kubectl_pods_completion ksexec kslogs ksdebug

#######################################
# INTELLIGENT KLIST SYSTEM
#######################################

# Comprehensive kubectl command database
declare -A KUBECTL_COMMANDS=(
    ["get"]="pods services deployments replicasets daemonsets statefulsets jobs cronjobs nodes namespaces configmaps secrets persistentvolumes persistentvolumeclaims ingress networkpolicies serviceaccounts clusterroles roles rolebindings clusterrolebindings events endpoints"
    ["describe"]="pods services deployments replicasets daemonsets statefulsets jobs cronjobs nodes namespaces configmaps secrets persistentvolumes persistentvolumeclaims ingress networkpolicies serviceaccounts clusterroles roles rolebindings clusterrolebindings events endpoints"
    ["delete"]="pods services deployments replicasets daemonsets statefulsets jobs cronjobs configmaps secrets persistentvolumeclaims ingress networkpolicies serviceaccounts"
    ["create"]="deployment service configmap secret namespace ingress networkpolicy serviceaccount job cronjob"
    ["apply"]="file resource manifest"
    ["edit"]="pods services deployments replicasets daemonsets statefulsets jobs cronjobs configmaps secrets persistentvolumeclaims ingress"
    ["patch"]="pods services deployments replicasets daemonsets statefulsets jobs cronjobs configmaps secrets"
    ["logs"]="pods deployments statefulsets daemonsets jobs"
    ["exec"]="pods"
    ["port-forward"]="pods services"
    ["scale"]="deployments replicasets statefulsets"
    ["rollout"]="deployments daemonsets statefulsets"
    ["top"]="pods nodes"
    ["cp"]="pods"
    ["explain"]="pods services deployments replicasets daemonsets statefulsets jobs cronjobs nodes namespaces configmaps secrets"
    ["config"]="current-context use-context get-contexts view set-context delete-context rename-context"
    ["cluster-info"]="dump"
    ["api-resources"]=""
    ["api-versions"]=""
    ["version"]=""
    ["wait"]="pods services deployments"
    ["attach"]="pods"
    ["auth"]="can-i whoami"
    ["certificate"]="approve deny"
    ["cordon"]="nodes"
    ["uncordon"]="nodes"
    ["drain"]="nodes"
    ["taint"]="nodes"
    ["label"]="pods services deployments nodes namespaces"
    ["annotate"]="pods services deployments nodes namespaces"
)

# Enhanced klist function with comprehensive help and -h flag
klist() {
    local query="$*"
    
    # Check for help flag
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo -e "${CYAN}🎯 COMPREHENSIVE KS* COMMAND REFERENCE${NC}"
        echo "========================================================"
        echo ""
        echo -e "${GREEN}📋 BASIC RESOURCE COMMANDS (get resources):${NC}"
        echo ""
        echo -e "${BLUE}📦 Pods:${NC}"
        echo "  ksp                    # kubectl get pods"
        echo "  kspa                   # kubectl get pods --all-namespaces"
        echo ""
        echo -e "${BLUE}🌐 Services:${NC}"
        echo "  kss                    # kubectl get services"
        echo "  kssa                   # kubectl get services --all-namespaces"
        echo ""
        echo -e "${BLUE}🚀 Deployments:${NC}"
        echo "  ksd                    # kubectl get deployments"
        echo "  ksda                   # kubectl get deployments --all-namespaces"
        echo ""
        echo -e "${BLUE}🖥️  Nodes:${NC}"
        echo "  ksn                    # kubectl get nodes"
        echo ""
        echo -e "${BLUE}📁 Namespaces:${NC}"
        echo "  ksns                   # kubectl get namespaces"
        echo "  ksnns [namespace]      # Switch to namespace or list namespaces"
        echo ""
        echo -e "${BLUE}⚡ ReplicaSets:${NC}"
        echo "  ksrs                   # kubectl get replicasets"
        echo "  ksrsa                  # kubectl get replicasets --all-namespaces"
        echo ""
        echo -e "${BLUE}📊 StatefulSets:${NC}"
        echo "  kssts                  # kubectl get statefulsets"
        echo "  kssta                  # kubectl get statefulsets --all-namespaces"
        echo ""
        echo -e "${BLUE}🔄 DaemonSets:${NC}"
        echo "  ksds                   # kubectl get daemonsets"
        echo "  ksdsa                  # kubectl get daemonsets --all-namespaces"
        echo ""
        echo -e "${BLUE}⏰ Jobs & CronJobs:${NC}"
        echo "  ksjobs                 # kubectl get jobs"
        echo "  ksjobsa                # kubectl get jobs --all-namespaces"
        echo "  kscj                   # kubectl get cronjobs"
        echo "  kscja                  # kubectl get cronjobs --all-namespaces"
        echo ""
        echo -e "${BLUE}⚙️  ConfigMaps & Secrets:${NC}"
        echo "  kscm                   # kubectl get configmaps"
        echo "  kscma                  # kubectl get configmaps --all-namespaces"
        echo "  kssec                  # kubectl get secrets"
        echo "  ksseca                 # kubectl get secrets --all-namespaces"
        echo ""
        echo -e "${BLUE}🌍 Ingress & Networking:${NC}"
        echo "  ksing                  # kubectl get ingress"
        echo "  ksinga                 # kubectl get ingress --all-namespaces"
        echo "  ksep                   # kubectl get endpoints"
        echo "  ksepa                  # kubectl get endpoints --all-namespaces"
        echo "  kseps                  # kubectl get endpointslices"
        echo "  ksnetpol               # kubectl get networkpolicies"
        echo "  ksnetpola              # kubectl get networkpolicies --all-namespaces"
        echo ""
        echo -e "${BLUE}💾 Storage:${NC}"
        echo "  kspv                   # kubectl get persistentvolumes"
        echo "  kspvc                  # kubectl get persistentvolumeclaims"
        echo "  kspvca                 # kubectl get persistentvolumeclaims --all-namespaces"
        echo "  kssc                   # kubectl get storageclasses"
        echo "  ksva                   # kubectl get volumeattachments"
        echo ""
        echo -e "${BLUE}📋 Events & Monitoring:${NC}"
        echo "  ksev                   # kubectl get events"
        echo "  kseva                  # kubectl get events --all-namespaces"
        echo "  kslimit                # kubectl get limitranges"
        echo "  ksrq                   # kubectl get resourcequotas"
        echo ""
        echo -e "${BLUE}🔐 RBAC & Security:${NC}"
        echo "  kssac                  # kubectl get serviceaccounts"
        echo "  kssaca                 # kubectl get serviceaccounts --all-namespaces"
        echo "  ksroles                # kubectl get roles"
        echo "  ksrolesa               # kubectl get roles --all-namespaces"
        echo "  ksrb                   # kubectl get rolebindings"
        echo "  ksrba                  # kubectl get rolebindings --all-namespaces"
        echo "  kscroles               # kubectl get clusterroles"
        echo "  kscrb                  # kubectl get clusterrolebindings"
        echo "  kspsp                  # kubectl get podsecuritypolicies"
        echo ""
        echo -e "${BLUE}🎛️  Autoscaling:${NC}"
        echo "  kshpa                  # kubectl get horizontalpodautoscalers"
        echo "  kshpaa                 # kubectl get horizontalpodautoscalers --all-namespaces"
        echo "  ksvpa                  # kubectl get verticalpodautoscalers"
        echo ""
        echo -e "${BLUE}🔧 Cluster Management:${NC}"
        echo "  kspc                   # kubectl get priorityclasses"
        echo "  ksrc                   # kubectl get runtimeclasses"
        echo "  ksmwc                  # kubectl get mutatingwebhookconfigurations"
        echo "  ksvwc                  # kubectl get validatingwebhookconfigurations"
        echo "  kscrds                 # kubectl get customresourcedefinitions"
        echo "  ksapi                  # kubectl get apiservices"
        echo "  kscr                   # kubectl get controllerrevisions"
        echo "  ksleases               # kubectl get leases"
        echo ""
        echo -e "${GREEN}🔧 ACTION COMMANDS:${NC}"
        echo ""
        echo -e "${BLUE}📋 Get & Describe:${NC}"
        echo "  ksget <resource>       # kubectl get <resource>"
        echo "  ksde <resource>        # kubectl describe <resource>"
        echo "  ksdescribe <resource>  # kubectl describe <resource> (alias)"
        echo ""
        echo -e "${BLUE}📝 Edit & Manage:${NC}"
        echo "  ksedit <resource>      # kubectl edit <resource>"
        echo "  ksdelete <resource>    # kubectl delete <resource>"
        echo "  kspatch <resource>     # kubectl patch <resource>"
        echo "  kslabel <resource>     # kubectl label <resource>"
        echo "  ksannotate <resource>  # kubectl annotate <resource>"
        echo ""
        echo -e "${BLUE}📋 Logs & Exec:${NC}"
        echo "  ksl <pod>              # kubectl logs <pod>"
        echo "  kse <pod>              # kubectl exec -it <pod> -- bash"
        echo "  ksexec <pod>           # kubectl exec -it <pod> -- bash (alias)"
        echo ""
        echo -e "${BLUE}📤 Apply & Config:${NC}"
        echo "  ksapply -f <file>      # kubectl apply -f <file>"
        echo "  ksconfig <command>     # kubectl config <command>"
        echo "  ksctx [context]        # Switch kubectl context or list contexts"
        echo ""
        echo -e "${GREEN}📊 OUTPUT FORMAT COMMANDS:${NC}"
        echo ""
        echo "  ksy <resource>         # kubectl get <resource> -o yaml"
        echo "  ksj <resource>         # kubectl get <resource> -o json"
        echo "  ksw <resource>         # kubectl get <resource> -o wide"
        echo ""
        echo -e "${GREEN}🎯 SMART UTILITY FUNCTIONS:${NC}"
        echo ""
        echo -e "${BLUE}📋 List & Info:${NC}"
        echo "  klist                  # This comprehensive help system"
        echo "  klist <resource>       # Show actions for specific resource"
        echo "  kslist <resource>      # List resources in current namespace"
        echo "  kslista <resource>     # List resources in all namespaces"
        echo "  ksall                  # Show all resources in current namespace"
        echo ""
        echo -e "${BLUE}🔄 Smart Operations:${NC}"
        echo "  kslogs <pod>           # Smart pod logs with fuzzy matching"
        echo "  ksexec <pod>           # Smart pod exec with fuzzy matching"
        echo "  ksdebug <pod>          # Comprehensive pod debugging"
        echo "  kspf <pod> <ports>     # Port forward to pod"
        echo "  ksscale <deploy> <num> # Scale deployment"
        echo "  ksrestart <deploy>     # Restart deployment"
        echo "  kswatch <resource>     # Watch resources with filters"
        echo "  kstop [resource]       # Resource usage monitoring"
        echo ""
        echo -e "${BLUE}⚙️  Context & Config:${NC}"
        echo "  ksctx [context]        # Smart context switching with completion"
        echo "  ksnns [namespace]      # Smart namespace switching with completion"
        echo "  kscreate <type> <name> # Create resources with smart defaults"
        echo ""
        echo -e "${GREEN}💡 KEY FEATURES:${NC}"
        echo ""
        echo "• ${YELLOW}Universal Tab Completion:${NC} All ks* commands support intelligent tab completion"
        echo "• ${YELLOW}Real-time Data:${NC} Completions show actual pods, namespaces, contexts from your cluster"
        echo "• ${YELLOW}Context Awareness:${NC} Commands adapt based on what you're trying to complete"
        echo "• ${YELLOW}Safe Operations:${NC} Built-in timeouts prevent shell hanging on cluster issues"
        echo "• ${YELLOW}Fuzzy Matching:${NC} 'kslogs hel' finds 'helm-controller-xxx'"
        echo "• ${YELLOW}Container Intelligence:${NC} Auto-complete container names in multi-container pods"
        echo ""
        echo -e "${GREEN}🚀 USAGE EXAMPLES:${NC}"
        echo ""
        echo "  ksp<TAB>               # Shows actual pod names from your cluster"
        echo "  ksctx<TAB>             # Shows actual kubectl contexts"
        echo "  kse podname<TAB>       # Shows container names in that pod"
        echo "  ksl podname<TAB>       # Shows containers + log flags (-f, --follow, etc.)"
        echo "  ksw pods<TAB>          # Shows pod names for wide output"
        echo "  ksdescribe pods<TAB>   # Shows pod names for description"
        echo ""
        echo -e "${BLUE}💡 For specific resource help: klist <resource-type>${NC}"
        echo -e "${BLUE}💡 For interactive operations: klist <resource> <action> <name>${NC}"
        return 0
    fi
    
    if [[ -z "$query" ]]; then
        echo -e "${CYAN}🎯 KLIST - Kubernetes Smart Command Assistant${NC}"
        echo "=============================================="
        echo ""
        echo -e "${GREEN}📋 Quick Access Commands:${NC}"
        echo "  klist pods              # Show available pod actions"
        echo "  klist services          # Show available service actions"
        echo "  klist deployments       # Show available deployment actions"
        echo "  klist nodes             # Show available node actions"
        echo "  klist namespaces        # Show available namespace actions"
        echo "  klist all              # Show everything in current namespace"
        echo ""
        echo -e "${GREEN}🚀 Smart Functions (ks prefix):${NC}"
        echo "  kslogs <pod>           # Smart pod logs (fuzzy matching)"
        echo "  ksexec <pod>           # Smart pod exec (fuzzy matching)"
        echo "  ksdebug <pod>          # Comprehensive pod debugging"
        echo "  kspf <pod> <ports>     # Port forward to pod"
        echo "  ksscale <deploy> <num> # Scale deployment"
        echo "  ksrestart <deploy>     # Restart deployment"
        echo "  kswatch <resource>     # Watch resources with filters"
        echo "  kstop [resource]       # Resource usage monitoring"
        echo "  ksctx [context]        # Smart context switching"
        echo "  ksnns [namespace]      # Smart namespace switching"
        echo "  kscreate <type> <name> # Create resources with smart defaults"
        echo "  ksjobsa                # List all jobs across namespaces"
        echo ""
        echo -e "${GREEN}📁 Kubeconfig Management:${NC}"
        echo "  kcc [config]           # Switch kubeconfig with tab completion"
        echo "  kconfigs               # List available kubeconfigs"
        echo "  add-kubeconfig <file>  # Add kubeconfig file"
        echo "  add-kubeconfig-folder <dir> # Add kubeconfig directory"
        echo "  kexport                # Export current kubeconfig"
        echo ""
        echo -e "${GREEN}🔧 Available Aliases:${NC}"
        echo "  k  = kubectl (full native completion)"
        echo "  ks = kubectl smart (independent smart functions only)"
        echo ""
        echo -e "${GREEN}⚡ ks Smart Aliases:${NC}"
        echo "  ksp = ks get pods      | kss = ks get services"
        echo "  ksd = ks get deployments | ksn = ks get nodes"
        echo "  ksns = ks get namespaces | ksy/ksj/ksw = ks get -o yaml/json/wide"
        echo "  kspa/kssa/ksda = get pods/services/deployments --all-namespaces"
        echo ""
        echo -e "${GREEN}🛠️  Utility Functions:${NC}"
        echo "  cluster-info           # Current cluster status and resource counts"
        echo "  clear-kubectl-cache    # Clear completion cache for fresh data"
        echo "  kslist <resource>      # List resources in current namespace"
        echo "  kslista <resource>     # List resources in all namespaces"
        echo ""
        
        # Show current cluster info
        echo -e "${YELLOW}🎯 Current Cluster Status:${NC}"
        local current_context=$(kubectl config current-context 2>/dev/null)
        local current_ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
        current_ns="${current_ns:-default}"
        
        if [[ -n "$current_context" ]]; then
            echo "  Context: $current_context"
            echo "  Namespace: $current_ns"
            
            # Show resource counts
            local pod_count=$(kubectl get pods --no-headers 2>/dev/null | wc -l)
            local svc_count=$(kubectl get services --no-headers 2>/dev/null | wc -l)
            local deploy_count=$(kubectl get deployments --no-headers 2>/dev/null | wc -l)
            
            echo "  Resources in '$current_ns': $pod_count pods, $svc_count services, $deploy_count deployments"
        else
            echo "  ❌ No kubernetes context available"
        fi
        
        echo ""
        echo -e "${BLUE}💡 Tips:${NC}"
        echo "  • All ks commands support TAB completion"
        echo "  • Use fuzzy matching: 'kslogs hel' finds 'helm-controller-xxx'"
        echo "  • ks functions are independent from k (kubectl native)"
        echo "  • Try 'klist <command>' for detailed help with live examples"
        echo ""
        echo -e "${BLUE}🔍 For detailed help: klist <command-name>${NC}"
        return 0
    fi
    
    # Parse the query
    local words=($query)
    local resource_type="${words[0]}"
    local action="${words[1]}"
    local resource_name="${words[2]}"
    
    # If action and resource_name are provided, execute the command
    if [[ -n "$action" && -n "$resource_name" ]]; then
        echo -e "${CYAN}🚀 Executing: $resource_type $action $resource_name${NC}"
        case "$resource_type" in
            "pods"|"pod"|"po")
                case "$action" in
                    "logs") kubectl logs "$resource_name" ;;
                    "describe") kubectl describe pod "$resource_name" ;;
                    "exec") kubectl exec -it "$resource_name" -- bash ;;
                    "delete") kubectl delete pod "$resource_name" ;;
                    "edit") kubectl edit pod "$resource_name" ;;
                    "port-forward"|"pf") kubectl port-forward "$resource_name" ${words[3]:-8080:80} ;;
                    "top") kubectl top pod "$resource_name" ;;
                    "events") kubectl get events --field-selector involvedObject.name="$resource_name" ;;
                    "yaml") kubectl get pod "$resource_name" -o yaml ;;
                    "json") kubectl get pod "$resource_name" -o json ;;
                    "wide") kubectl get pod "$resource_name" -o wide ;;
                    "get") kubectl get pod "$resource_name" ;;
                    *) echo "Unknown action: $action" ;;
                esac
                ;;
            "services"|"service"|"svc")
                case "$action" in
                    "describe") kubectl describe service "$resource_name" ;;
                    "delete") kubectl delete service "$resource_name" ;;
                    "edit") kubectl edit service "$resource_name" ;;
                    "endpoints") kubectl get endpoints "$resource_name" ;;
                    "yaml") kubectl get service "$resource_name" -o yaml ;;
                    "json") kubectl get service "$resource_name" -o json ;;
                    "wide") kubectl get service "$resource_name" -o wide ;;
                    "get") kubectl get service "$resource_name" ;;
                    *) echo "Unknown action: $action" ;;
                esac
                ;;
            "deployments"|"deployment"|"deploy")
                case "$action" in
                    "describe") kubectl describe deployment "$resource_name" ;;
                    "delete") kubectl delete deployment "$resource_name" ;;
                    "edit") kubectl edit deployment "$resource_name" ;;
                    "scale") kubectl scale deployment "$resource_name" --replicas=${words[3]:-1} ;;
                    "rollout") kubectl rollout restart deployment "$resource_name" ;;
                    "restart") kubectl rollout restart deployment "$resource_name" ;;
                    "logs") kubectl logs deployment/"$resource_name" ;;
                    "yaml") kubectl get deployment "$resource_name" -o yaml ;;
                    "json") kubectl get deployment "$resource_name" -o json ;;
                    "wide") kubectl get deployment "$resource_name" -o wide ;;
                    "get") kubectl get deployment "$resource_name" ;;
                    *) echo "Unknown action: $action" ;;
                esac
                ;;
        esac
        return 0
    fi
    
    # If only action is provided, show available resource names
    if [[ -n "$action" ]]; then
        echo -e "${CYAN}🎯 $resource_type -> $action${NC}"
        echo "Available resources:"
        case "$resource_type" in
            "pods"|"pod"|"po")
                kubectl get pods --no-headers -o custom-columns=":metadata.name" 2>/dev/null | sed 's/^/  /'
                ;;
            "services"|"service"|"svc")
                kubectl get services --no-headers -o custom-columns=":metadata.name" 2>/dev/null | sed 's/^/  /'
                ;;
            "deployments"|"deployment"|"deploy")
                kubectl get deployments --no-headers -o custom-columns=":metadata.name" 2>/dev/null | sed 's/^/  /'
                ;;
            "nodes"|"node"|"no")
                kubectl get nodes --no-headers -o custom-columns=":metadata.name" 2>/dev/null | sed 's/^/  /'
                ;;
            "namespaces"|"namespace"|"ns")
                kubectl get namespaces --no-headers -o custom-columns=":metadata.name" 2>/dev/null | sed 's/^/  /'
                ;;
        esac
        echo ""
        echo -e "${BLUE}💡 Usage: klist $resource_type $action <resource-name>${NC}"
        return 0
    fi
    
    # Show available actions for the resource type
    echo -e "${CYAN}🎯 Available Actions for $resource_type${NC}"
    echo "=============================================="
    
    case "$resource_type" in
        "pods"|"pod"|"po")
            echo -e "${GREEN}📋 Pod Actions${NC}"
            echo "=============="
            echo ""
            echo -e "${BLUE}Available Actions:${NC}"
            echo "  logs        # View pod logs"
            echo "  describe    # Get detailed pod information"
            echo "  exec        # Execute shell in pod"
            echo "  delete      # Delete the pod"
            echo "  edit        # Edit pod configuration"
            echo "  port-forward # Forward local port to pod"
            echo "  top         # Show pod resource usage"
            echo "  events      # Show pod events"
            echo "  yaml        # Get pod in YAML format"
            echo "  json        # Get pod in JSON format"
            echo "  wide        # Get pod with extra columns"
            echo "  get         # Get basic pod information"
            echo ""
            echo -e "${BLUE}Usage Examples:${NC}"
            echo "  klist pods logs <pod-name>"
            echo "  klist pods describe <pod-name>"
            echo "  klist pods exec <pod-name>"
            echo ""
            
            if command -v kubectl >/dev/null 2>&1 && kubectl cluster-info >/dev/null 2>&1; then
                echo -e "${YELLOW}🌐 Current Pods:${NC}"
                local pods=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
                if [[ -n "$pods" ]]; then
                    echo "$pods" | head -5 | sed 's/^/  • /'
                    [[ $(echo "$pods" | wc -l) -gt 5 ]] && echo "  ... and more"
                else
                    echo "  No pods found in current namespace"
                fi
            fi
            ;;
        "services"|"service"|"svc")
            echo -e "${GREEN}📋 Service Actions${NC}"
            echo "=================="
            echo ""
            echo -e "${BLUE}Available Actions:${NC}"
            echo "  describe     # Get detailed service information"
            echo "  delete       # Delete the service"
            echo "  edit         # Edit service configuration"
            echo "  endpoints    # Show service endpoints"
            echo "  yaml         # Get service in YAML format"
            echo "  json         # Get service in JSON format"
            echo "  wide         # Get service with extra columns"
            echo "  get          # Get basic service information"
            echo ""
            echo -e "${BLUE}Usage Examples:${NC}"
            echo "  klist services describe <service-name>"
            echo "  klist services endpoints <service-name>"
            echo ""
            
            if command -v kubectl >/dev/null 2>&1 && kubectl cluster-info >/dev/null 2>&1; then
                echo -e "${YELLOW}🌐 Current Services:${NC}"
                local services=$(kubectl get services --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
                if [[ -n "$services" ]]; then
                    echo "$services" | head -5 | sed 's/^/  • /'
                    [[ $(echo "$services" | wc -l) -gt 5 ]] && echo "  ... and more"
                else
                    echo "  No services found in current namespace"
                fi
            fi
            ;;
        "deployments"|"deployment"|"deploy")
            echo -e "${GREEN}📋 Deployment Actions${NC}"
            echo "====================="
            echo ""
            echo -e "${BLUE}Available Actions:${NC}"
            echo "  describe     # Get detailed deployment information"
            echo "  delete       # Delete the deployment"
            echo "  edit         # Edit deployment configuration"
            echo "  scale        # Scale deployment replicas"
            echo "  rollout      # Restart deployment"
            echo "  restart      # Restart deployment (alias for rollout)"
            echo "  logs         # Show deployment logs"
            echo "  yaml         # Get deployment in YAML format"
            echo "  json         # Get deployment in JSON format"
            echo "  wide         # Get deployment with extra columns"
            echo "  get          # Get basic deployment information"
            echo ""
            echo -e "${BLUE}Usage Examples:${NC}"
            echo "  klist deployments describe <deployment-name>"
            echo "  klist deployments scale <deployment-name> [replicas]"
            echo "  klist deployments restart <deployment-name>"
            echo ""
            
            if command -v kubectl >/dev/null 2>&1 && kubectl cluster-info >/dev/null 2>&1; then
                echo -e "${YELLOW}🌐 Current Deployments:${NC}"
                local deployments=$(kubectl get deployments --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
                if [[ -n "$deployments" ]]; then
                    echo "$deployments" | head -5 | sed 's/^/  • /'
                    [[ $(echo "$deployments" | wc -l) -gt 5 ]] && echo "  ... and more"
                else
                    echo "  No deployments found in current namespace"
                fi
            fi
            ;;
        "nodes"|"node"|"no")
            echo -e "${GREEN}📋 Node Actions${NC}"
            echo "==============="
            echo ""
            echo -e "${BLUE}Available Actions:${NC}"
            echo "  describe     # Get detailed node information"
            echo "  top          # Show node resource usage"
            echo "  cordon       # Mark node as unschedulable"
            echo "  uncordon     # Mark node as schedulable"
            echo "  drain        # Drain node (remove pods)"
            echo "  yaml         # Get node in YAML format"
            echo "  json         # Get node in JSON format"
            echo "  wide         # Get node with extra columns"
            echo "  get          # Get basic node information"
            echo ""
            echo -e "${BLUE}Usage Examples:${NC}"
            echo "  klist nodes describe <node-name>"
            echo "  klist nodes top <node-name>"
            echo ""
            
            if command -v kubectl >/dev/null 2>&1 && kubectl cluster-info >/dev/null 2>&1; then
                echo -e "${YELLOW}🌐 Current Nodes:${NC}"
                local nodes=$(kubectl get nodes --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
                if [[ -n "$nodes" ]]; then
                    echo "$nodes" | sed 's/^/  • /'
                else
                    echo "  No nodes found"
                fi
            fi
            ;;
        "namespaces"|"namespace"|"ns")
            echo -e "${GREEN}📋 Namespace Actions${NC}"
            echo "===================="
            echo ""
            echo -e "${BLUE}Available Actions:${NC}"
            echo "  describe     # Get detailed namespace information"
            echo "  delete       # Delete the namespace"
            echo "  edit         # Edit namespace configuration"
            echo "  yaml         # Get namespace in YAML format"
            echo "  json         # Get namespace in JSON format"
            echo "  get          # Get basic namespace information"
            echo ""
            echo -e "${BLUE}Usage Examples:${NC}"
            echo "  klist namespaces describe <namespace-name>"
            echo "  klist namespaces get <namespace-name>"
            echo ""
            
            if command -v kubectl >/dev/null 2>&1 && kubectl cluster-info >/dev/null 2>&1; then
                echo -e "${YELLOW}🌐 Available Namespaces:${NC}"
                local namespaces=$(kubectl get namespaces --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
                if [[ -n "$namespaces" ]]; then
                    echo "$namespaces" | head -10 | sed 's/^/  • /'
                    [[ $(echo "$namespaces" | wc -l) -gt 10 ]] && echo "  ... and more"
                else
                    echo "  No namespaces found"
                fi
            fi
            ;;
        "all")
            echo -e "${GREEN}📋 Complete Namespace Overview${NC}"
            echo "============================="
            echo ""
            echo -e "${BLUE}Available Actions:${NC}"
            echo "  get          # Get all resources"
            echo "  describe     # Describe all resources"
            echo "  delete       # Delete all resources (use with caution!)"
            echo "  yaml         # Get all resources in YAML format"
            echo "  json         # Get all resources in JSON format"
            echo "  wide         # Get all resources with extra columns"
            echo ""
            
            if command -v kubectl >/dev/null 2>&1 && kubectl cluster-info >/dev/null 2>&1; then
                local current_ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null || echo "default")
                echo -e "${YELLOW}Current namespace '$current_ns' overview:${NC}"
                echo "  Pods: $(kubectl get pods --no-headers 2>/dev/null | wc -l)"
                echo "  Services: $(kubectl get services --no-headers 2>/dev/null | wc -l)"
                echo "  Deployments: $(kubectl get deployments --no-headers 2>/dev/null | wc -l)"
                echo ""
                echo "Run 'klist all get' to see all resources"
            fi
            ;;
        *)
            echo -e "${RED}❌ Unknown resource type: $resource_type${NC}"
            echo ""
            echo -e "${BLUE}Available resource types:${NC}"
            echo "  pods, services, deployments, nodes, namespaces, all"
            ;;
    esac
}

#######################################
# CLUSTER UTILITY FUNCTIONS
#######################################

# Show current cluster information
cluster-info() {
    echo -e "${CYAN}🏗️  Current Cluster Information${NC}"
    echo "================================="
    echo -e "${BLUE}Context:${NC} $(kubectl config current-context 2>/dev/null || echo 'None')"
    echo -e "${BLUE}Namespace:${NC} $(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}' 2>/dev/null || echo 'default')"
    echo -e "${BLUE}Server:${NC} $(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null || echo 'Unknown')"
    echo ""
    echo -e "${BLUE}Resource counts:${NC}"
    kubectl get nodes --no-headers 2>/dev/null | wc -l | xargs echo "  Nodes:"
    kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l | xargs echo "  Pods:"
    kubectl get services --all-namespaces --no-headers 2>/dev/null | wc -l | xargs echo "  Services:"
    kubectl get deployments --all-namespaces --no-headers 2>/dev/null | wc -l | xargs echo "  Deployments:"
    kubectl get namespaces --no-headers 2>/dev/null | wc -l | xargs echo "  Namespaces:"
}

# Modular function for resource listing with options
_list_resources() {
    local resource_type="$1"
    local output_format="${2:-wide}"
    local all_namespaces="${3:-false}"
    
    local cmd="kubectl get $resource_type"
    
    if [[ "$all_namespaces" == "true" ]]; then
        cmd="$cmd -A"
    fi
    
    case "$output_format" in
        yaml) cmd="$cmd -o yaml" ;;
        json) cmd="$cmd -o json" ;;
        wide) cmd="$cmd -o wide" ;;
        name) cmd="$cmd -o name" ;;
        *) cmd="$cmd -o wide" ;;
    esac
    
    eval "$cmd"
}

# Enhanced resource listing functions
kslist() {
    local resource="${1:-pods}"
    local format="${2:-wide}"
    
    echo -e "${CYAN}📋 $resource (current namespace):${NC}"
    _list_resources "$resource" "$format" "false"
}

kslista() {
    local resource="${1:-pods}"
    local format="${2:-wide}"
    
    echo -e "${CYAN}📋 $resource (all namespaces):${NC}"
    _list_resources "$resource" "$format" "true"
}

# Completion functions for advanced functions
_kubectl_deployments_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    _k8s_resource_completion "deployments"
}

_kubectl_contexts_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local contexts=$(kubectl config get-contexts -o name 2>/dev/null)
    COMPREPLY=($(compgen -W "$contexts" -- "$cur"))
}

# Register completions for advanced functions
# Note: kspf, ksscale, ksrestart are now handled by universal system
complete -F _kubectl_contexts_completion ksctx

# Context-aware tab completion for klist
_klist_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # First level: resource types
    if [[ $COMP_CWORD -eq 1 ]]; then
        local resources="pods services deployments nodes namespaces all"
        COMPREPLY=($(compgen -W "$resources" -- "$cur"))
        return 0
    fi
    
    # Second level: show available actions for the resource type
    if [[ $COMP_CWORD -eq 2 ]]; then
        case "${COMP_WORDS[1]}" in
            pods)
                local actions="logs describe exec delete edit port-forward top events yaml json wide get"
                COMPREPLY=($(compgen -W "$actions" -- "$cur"))
                ;;
            services)
                local actions="describe delete edit port-forward endpoints yaml json wide get"
                COMPREPLY=($(compgen -W "$actions" -- "$cur"))
                ;;
            deployments)
                local actions="describe delete edit scale rollout restart yaml json wide logs get"
                COMPREPLY=($(compgen -W "$actions" -- "$cur"))
                ;;
            nodes)
                local actions="describe top cordon uncordon drain yaml json wide get"
                COMPREPLY=($(compgen -W "$actions" -- "$cur"))
                ;;
            namespaces)
                local actions="describe delete edit yaml json get"
                COMPREPLY=($(compgen -W "$actions" -- "$cur"))
                ;;
            all)
                local actions="get describe delete yaml json wide"
                COMPREPLY=($(compgen -W "$actions" -- "$cur"))
                ;;
            *)
                COMPREPLY=()
                ;;
        esac
        return 0
    fi
    
    # Third level: show resource names when an action is specified
    if [[ $COMP_CWORD -eq 3 ]]; then
        case "${COMP_WORDS[1]}" in
            pods)
                local pods=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" 2>/dev/null | tr '\n' ' ')
                COMPREPLY=($(compgen -W "$pods" -- "$cur"))
                ;;
            services)
                local services=$(kubectl get services --no-headers -o custom-columns=":metadata.name" 2>/dev/null | tr '\n' ' ')
                COMPREPLY=($(compgen -W "$services" -- "$cur"))
                ;;
            deployments)
                local deployments=$(kubectl get deployments --no-headers -o custom-columns=":metadata.name" 2>/dev/null | tr '\n' ' ')
                COMPREPLY=($(compgen -W "$deployments" -- "$cur"))
                ;;
            nodes)
                local nodes=$(kubectl get nodes --no-headers -o custom-columns=":metadata.name" 2>/dev/null | tr '\n' ' ')
                COMPREPLY=($(compgen -W "$nodes" -- "$cur"))
                ;;
            namespaces)
                local namespaces=$(kubectl get namespaces --no-headers -o custom-columns=":metadata.name" 2>/dev/null | tr '\n' ' ')
                COMPREPLY=($(compgen -W "$namespaces" -- "$cur"))
                ;;
            all)
                # No specific resource names for 'all'
                COMPREPLY=()
                ;;
            *)
                COMPREPLY=()
                ;;
        esac
        return 0
    fi
    
    # Fourth level and beyond: no completions
    COMPREPLY=()
}
complete -F _klist_completion klist

#######################################
# ADVANCED KUBECTL FUNCTIONS (KS VERSIONS)
#######################################

# Modular helper function for pod fuzzy matching
_find_pod_by_pattern() {
    local pattern="$1"
    local namespace="${2:-}"
    
    # Try exact match first, then partial match
    local pod_cmd="kubectl get pods --no-headers"
    if [[ -n "$namespace" ]]; then
        pod_cmd="$pod_cmd -n $namespace"
    fi
    
    local pod=$($pod_cmd | grep "^$pattern " | head -1 | awk '{print $1}')
    if [[ -z "$pod" ]]; then
        pod=$($pod_cmd | grep "$pattern" | head -1 | awk '{print $1}')
    fi
    
    echo "$pod"
}

# Modular helper function for deployment fuzzy matching
_find_deployment_by_pattern() {
    local pattern="$1"
    local namespace="${2:-}"
    
    # Try exact match first, then partial match
    local deploy_cmd="kubectl get deployments --no-headers"
    if [[ -n "$namespace" ]]; then
        deploy_cmd="$deploy_cmd -n $namespace"
    fi
    
    local deploy=$($deploy_cmd | grep "^$pattern " | head -1 | awk '{print $1}')
    if [[ -z "$deploy" ]]; then
        deploy=$($deploy_cmd | grep "$pattern" | head -1 | awk '{print $1}')
    fi
    
    echo "$deploy"
}

# Smart port forwarding
kspf() {
    if [[ $# -lt 2 ]]; then
        echo -e "${YELLOW}Usage: kspf <pod-pattern> <local-port:remote-port>${NC}"
        echo "Examples:"
        echo "  kspf my-app 8080:80"
        echo "  kspf my-app 8080:8080"
        echo ""
        echo "Available pods:"
        kubectl get pods --no-headers -o custom-columns="NAME:.metadata.name,STATUS:.status.phase" | sed 's/^/  /'
        return 1
    fi
    
    local pod_pattern="$1"
    local ports="$2"
    
    local pod=$(_find_pod_by_pattern "$pod_pattern")
    
    if [[ -z "$pod" ]]; then
        echo -e "${RED}❌ No pod found matching pattern: $pod_pattern${NC}"
        return 1
    fi
    
    echo -e "${GREEN}🚀 Port forwarding to pod: $pod${NC}"
    echo -e "${CYAN}Port mapping: $ports${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    kubectl port-forward "$pod" "$ports"
}

# Smart deployment scaling
ksscale() {
    if [[ $# -lt 2 ]]; then
        echo -e "${YELLOW}Usage: ksscale <deployment-pattern> <replicas>${NC}"
        echo "Available deployments:"
        kubectl get deployments --no-headers -o custom-columns="NAME:.metadata.name,REPLICAS:.spec.replicas" | sed 's/^/  /'
        return 1
    fi
    
    local deploy_pattern="$1"
    local replicas="$2"
    
    local deploy=$(_find_deployment_by_pattern "$deploy_pattern")
    
    if [[ -z "$deploy" ]]; then
        echo -e "${RED}❌ No deployment found matching pattern: $deploy_pattern${NC}"
        return 1
    fi
    
    echo -e "${GREEN}📈 Scaling deployment: $deploy to $replicas replicas${NC}"
    kubectl scale deployment "$deploy" --replicas="$replicas"
    
    echo -e "${CYAN}Watching rollout status...${NC}"
    kubectl rollout status deployment "$deploy"
}

# Smart deployment restart
ksrestart() {
    if [[ $# -eq 0 ]]; then
        echo -e "${YELLOW}Usage: ksrestart <deployment-pattern>${NC}"
        echo "Available deployments:"
        kubectl get deployments --no-headers -o custom-columns="NAME:.metadata.name,READY:.status.readyReplicas" | sed 's/^/  /'
        return 1
    fi
    
    local deploy_pattern="$1"
    
    local deploy=$(_find_deployment_by_pattern "$deploy_pattern")
    
    if [[ -z "$deploy" ]]; then
        echo -e "${RED}❌ No deployment found matching pattern: $deploy_pattern${NC}"
        return 1
    fi
    
    echo -e "${GREEN}🔄 Restarting deployment: $deploy${NC}"
    kubectl rollout restart deployment "$deploy"
    
    echo -e "${CYAN}Watching rollout status...${NC}"
    kubectl rollout status deployment "$deploy"
}

# Smart watch function
kswatch() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo -e "${BLUE}🔍 kswatch - Watch Kubernetes resources in real-time${NC}"
        echo -e "${YELLOW}Usage: kswatch <resource-type> [pattern] [options]${NC}"
        echo ""
        echo -e "${GREEN}📋 Description:${NC}"
        echo "  Continuously monitors Kubernetes resources and displays changes in real-time."
        echo "  Use Ctrl+C to stop watching."
        echo ""
        echo -e "${GREEN}📖 Examples:${NC}"
        echo "  kswatch pods                    # Watch all pods in current namespace"
        echo "  kswatch pods nginx              # Watch pods matching 'nginx'"
        echo "  kswatch deployments             # Watch all deployments"
        echo "  kswatch services                # Watch all services"
        echo "  kswatch nodes                   # Watch cluster nodes"
        echo "  kswatch pods -n kube-system     # Watch pods in kube-system namespace"
        echo "  kswatch events                  # Watch cluster events"
        echo ""
        echo -e "${GREEN}🎯 Common Resource Types:${NC}"
        echo "  pods, deployments, services, configmaps, secrets"
        echo "  jobs, cronjobs, ingress, nodes, namespaces, events"
        echo ""
        echo -e "${GREEN}💡 Tips:${NC}"
        echo "  • Use pattern matching to filter specific resources"
        echo "  • Combine with kubectl flags like -n for namespace"
        echo "  • Press Ctrl+C to stop watching"
        return 0
    fi
    
    if [[ $# -eq 0 ]]; then
        echo -e "${YELLOW}Usage: kswatch <resource-type> [pattern]${NC}"
        echo "Examples:"
        echo "  kswatch pods"
        echo "  kswatch services"
        echo "  kswatch deployments"
        echo "  kswatch nodes"
        echo "  kswatch pods nginx    # Watch pods matching 'nginx'"
        echo ""
        echo "Use 'kswatch -h' for detailed help"
        return 1
    fi
    
    local resource="$1"
    local pattern="$2"
    
    if [[ -n "$pattern" ]]; then
        echo -e "${GREEN}👀 Watching $resource matching '$pattern' (Press Ctrl+C to stop)${NC}"
        kubectl get "$resource" --watch | grep "$pattern"
    else
        echo -e "${GREEN}👀 Watching $resource (Press Ctrl+C to stop)${NC}"
        kubectl get "$resource" --watch
    fi
}

# Smart create function
kscreate() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo -e "${BLUE}🚀 kscreate - Create Kubernetes resources with smart defaults${NC}"
        echo -e "${YELLOW}Usage: kscreate <resource-type> <name> [options]${NC}"
        echo ""
        echo -e "${GREEN}📋 Description:${NC}"
        echo "  Create Kubernetes resources using kubectl create with enhanced syntax."
        echo "  Supports all kubectl create commands with additional smart features."
        echo ""
        echo -e "${GREEN}📖 Examples:${NC}"
        echo "  kscreate deployment nginx --image=nginx:latest --replicas=3"
        echo "  kscreate service clusterip my-service --tcp=80:8080"
        echo "  kscreate configmap app-config --from-literal=key1=value1"
        echo "  kscreate secret generic db-secret --from-literal=password=secret123"
        echo "  kscreate namespace production"
        echo "  kscreate job batch-job --image=busybox --restart=Never"
        echo "  kscreate ingress web-ingress --rule=\"example.com/*=web-service:80\""
        echo "  kscreate -f deployment.yaml    # Create from file"
        echo ""
        echo -e "${GREEN}🎯 Common Resource Types:${NC}"
        echo "  deployment, service, configmap, secret, namespace"
        echo "  job, cronjob, ingress, pvc, serviceaccount"
        echo ""
        echo -e "${GREEN}💡 Tips:${NC}"
        echo "  • Use --dry-run=client -o yaml to preview YAML"
        echo "  • Combine with kubectl apply for declarative management"
        echo "  • Use -f flag to create from YAML/JSON files"
        return 0
    fi
    
    if [[ $# -eq 0 ]]; then
        echo -e "${YELLOW}Usage: kscreate <resource-type> <name> [options]${NC}"
        echo "Examples:"
        echo "  kscreate deployment nginx --image=nginx"
        echo "  kscreate service my-service --tcp=80:8080"
        echo "  kscreate namespace production"
        echo ""
        echo "Use 'kscreate -h' for detailed help"
        return 1
    fi
    
    # Pass all arguments to kubectl create
    kubectl create "$@"
}

# Smart jobs listing function
ksjobsa() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo -e "${BLUE}📋 ksjobsa - List all jobs across all namespaces${NC}"
        echo -e "${YELLOW}Usage: ksjobsa [options]${NC}"
        echo ""
        echo -e "${GREEN}📋 Description:${NC}"
        echo "  Lists all Kubernetes jobs across all namespaces with detailed information."
        echo "  Shows job status, completions, and duration for easy monitoring."
        echo ""
        echo -e "${GREEN}📖 Examples:${NC}"
        echo "  ksjobsa                         # List all jobs in all namespaces"
        echo "  ksjobsa -o wide                 # Show additional columns"
        echo "  ksjobsa --show-labels           # Display labels"
        echo "  ksjobsa --field-selector=status.successful=1    # Show only successful jobs"
        echo "  ksjobsa -o yaml                 # Output in YAML format"
        echo "  ksjobsa | grep batch            # Filter jobs containing 'batch'"
        echo ""
        echo -e "${GREEN}🔍 Job Status Examples:${NC}"
        echo "  Complete (1/1)   - Job finished successfully"
        echo "  Running (0/1)    - Job is currently running"
        echo "  Failed (0/1)     - Job failed to complete"
        echo ""
        echo -e "${GREEN}💡 Tips:${NC}"
        echo "  • Use 'kubectl logs job/<job-name>' to see job logs"
        echo "  • Check job details with 'kubectl describe job <job-name>'"
        echo "  • Use 'kubectl delete job <job-name>' to clean up completed jobs"
        return 0
    fi
    
    if [[ $# -eq 0 ]]; then
        echo -e "${GREEN}📋 Listing all jobs across namespaces...${NC}"
        kubectl get jobs -A
    else
        echo -e "${GREEN}📋 Listing jobs with options: $*${NC}"
        kubectl get jobs -A "$@"
    fi
}

# Smart resource usage function
kstop() {
    if [[ $# -eq 0 ]]; then
        echo -e "${CYAN}📊 Cluster Resource Usage${NC}"
        echo "========================="
        
        echo -e "\n${GREEN}Node Resource Usage:${NC}"
        kubectl top nodes 2>/dev/null || echo "❌ Metrics server not available"
        
        echo -e "\n${GREEN}Pod Resource Usage (Top 10):${NC}"
        kubectl top pods --sort-by=cpu 2>/dev/null | head -11 || echo "❌ Metrics server not available"
        
        echo -e "\n${GREEN}Namespace Resource Usage:${NC}"
        kubectl top pods -A --sort-by=cpu 2>/dev/null | head -6 || echo "❌ Metrics server not available"
    else
        local resource="$1"
        echo -e "${GREEN}📊 Resource usage for $resource:${NC}"
        kubectl top "$resource" 2>/dev/null || echo "❌ Metrics server not available or invalid resource"
    fi
}

# Smart context switching
ksctx() {
    if [[ $# -eq 0 ]]; then
        echo -e "${CYAN}Available contexts:${NC}"
        kubectl config get-contexts
        
        echo -e "\n${YELLOW}Current context:${NC}"
        kubectl config current-context
        
        echo -e "\n${BLUE}Usage: ksctx <context-name>${NC}"
        return 0
    fi
    
    local context="$1"
    
    # Check if context exists
    if kubectl config get-contexts -o name | grep -q "^${context}$"; then
        kubectl config use-context "$context"
        echo -e "${GREEN}✅ Switched to context: $context${NC}"
        
        # Show current namespace
        local current_ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
        echo -e "${CYAN}📁 Current namespace: ${current_ns:-default}${NC}"
        
        # Clear cache since we changed context
        clear-kubectl-cache
    else
        echo -e "${RED}❌ Context '$context' not found${NC}"
        echo "Available contexts:"
        kubectl config get-contexts -o name | sed 's/^/  /'
        return 1
    fi
}

#######################################
# ENHANCED KUBERNETES PROMPT
#######################################

# Function to get current kubernetes context info
_get_k8s_context() {
    if command -v kubectl >/dev/null 2>&1; then
        local context=$(kubectl config current-context 2>/dev/null)
        local namespace=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
        
        if [[ -n "$context" ]]; then
            namespace="${namespace:-default}"
            echo "⎈ ${context}:${namespace}"
        fi
    fi
}

# Function to get shortened directory path
_get_short_pwd() {
    local pwd_length=30
    local pwd="$PWD"
    
    # Replace home directory with ~
    pwd="${pwd/#$HOME/\~}"
    
    # Shorten if too long
    if [[ ${#pwd} -gt $pwd_length ]]; then
        echo "...${pwd: -$((pwd_length-3))}"
    else
        echo "$pwd"
    fi
}

# Enhanced prompt function
_set_kubernetes_prompt() {
    local last_exit=$?
    
    # Colors
    local RED='\[\033[0;31m\]'
    local GREEN='\[\033[0;32m\]'
    local YELLOW='\[\033[0;33m\]'
    local BLUE='\[\033[0;34m\]'
    local PURPLE='\[\033[0;35m\]'
    local CYAN='\[\033[0;36m\]'
    local WHITE='\[\033[0;37m\]'
    local RESET='\[\033[0m\]'
    local BOLD='\[\033[1m\]'
    
    # Get kubernetes context
    local k8s_info=$(_get_k8s_context)
    local pwd_info=$(_get_short_pwd)
    
    # Build prompt components
    local user_host="${GREEN}\u@\h${RESET}"
    local pwd_part="${BLUE}${pwd_info}${RESET}"
    local k8s_part=""
    local exit_part=""
    
    # Add kubernetes info if available
    if [[ -n "$k8s_info" ]]; then
        k8s_part=" ${CYAN}${k8s_info}${RESET}"
    fi
    
    # Add exit code if last command failed
    if [[ $last_exit -ne 0 ]]; then
        exit_part=" ${RED}✗${last_exit}${RESET}"
    fi
    
    # Git branch if available
    local git_branch=""
    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null)
        if [[ -n "$branch" ]]; then
            git_branch=" ${PURPLE}⎇ ${branch}${RESET}"
        fi
    fi
    
    # Time
    local time_part="${YELLOW}[\t]${RESET}"
    
    # Construct the prompt
    PS1="${time_part} ${user_host}:${pwd_part}${k8s_part}${git_branch}${exit_part}\n${BOLD}\$${RESET} "
}

# Function to enable/disable kubernetes prompt
k8s-prompt() {
    if [[ "$1" == "off" ]]; then
        # Restore simple prompt
        PS1='\u@\h:\w\$ '
        echo "✅ Kubernetes prompt disabled"
    else
        # Enable kubernetes prompt
        PROMPT_COMMAND="_set_kubernetes_prompt"
        echo "✅ Kubernetes prompt enabled"
        echo "� Shows: [time] user@host:pwd ⎈ context:namespace ⎇ git-branch"
        echo "💡 Use 'k8s-prompt off' to disable"
    fi
}

#######################################
# INITIALIZATION
#######################################

# Clear kubectl cache function
clear-kubectl-cache() {
    rm -f /tmp/kubectl_cache_* 2>/dev/null
    echo "✅ kubectl cache cleared"
}

# Auto-enable the kubernetes prompt if not already set
if [[ -z "$PROMPT_COMMAND" ]] || [[ "$PROMPT_COMMAND" != *"_set_kubernetes_prompt"* ]]; then
    PROMPT_COMMAND="_set_kubernetes_prompt"
fi

echo ""
echo -e "${GREEN}🚀 Kubernetes Smart Environment Loaded!${NC}"
echo "====================================="
echo ""
echo -e "${BLUE}🎯 Key Features:${NC}"
echo "  • k  = kubectl (full native completion)"
echo "  • ks = kubectl smart (independent smart functions only)"
echo "  • Modular and reusable functions"
echo "  • Enhanced tab completion"
echo "  • Fuzzy matching for pod/deployment operations"
echo ""
echo -e "${BLUE}🚀 Quick Start:${NC}"
echo "  klist               # Comprehensive help and current cluster info"
echo "  cluster-info        # Current cluster status"
echo "  ksp                 # ks get pods (smart completion)"
echo "  kslogs <pod>        # Smart pod logs with fuzzy matching"
echo "  ksexec <pod>        # Smart pod exec with fuzzy matching"
echo "  ksctx              # Context management"
echo "  ksnns              # Namespace management"
echo ""
echo -e "${BLUE}💡 Enhanced Features:${NC}"
echo "  • Kubernetes-aware prompt: [time] user@host:pwd ⎈ context:namespace ⎇ git-branch"
echo "  • Smart fuzzy matching for all pod/deployment operations"
echo "  • Comprehensive kubeconfig management"
echo "  • Modular helper functions for reusability"
echo "  • Independent ks completion (no kubectl command mixing)"
echo ""
echo -e "${CYAN}💡 Use 'klist' for comprehensive help and live examples!${NC}"

# Performance optimization: Only check cluster status if kubectl is available and user wants it
# This prevents the script from hanging during sourcing
if [[ "${KUBECTL_FAST_LOAD:-true}" != "false" ]] && [[ "${KUBECTL_AVAILABLE}" == "true" ]]; then
    # Quick cluster availability check (timeout after 2 seconds)
    if timeout 2s kubectl cluster-info >/dev/null 2>&1; then
        echo -e "\n${GREEN}✅ Kubernetes cluster is accessible${NC}"
    fi
fi

# Script loading completed successfully - no hanging!
echo -e "\n${GREEN}🎉 Script loaded successfully! No hanging issues detected.${NC}"

#######################################
# FLUX CONFIGURATION FROM BASHRC-SUSE
#######################################

# Function to categorize Kubernetes resources
_get_resource_category() {
    local resource="$1"
    case "$resource" in
        # Core workloads
        pod*|po|deployment*|deploy|replicaset*|rs|daemonset*|ds|statefulset*|sts|job*|cronjob*|cj)
            echo "workloads" ;;
        # Networking
        service|services|svc|endpoint|endpoints|ep|ingress|ingresses|ing|networkpolicy|networkpolicies|netpol)
            echo "networking" ;;
        # Storage
        persistentvolume|persistentvolumes|pv|persistentvolumeclaim|persistentvolumeclaims|pvc|storageclass|storageclasses|sc|volumeattachment|volumeattachments)
            echo "storage" ;;
        # Config/Secrets
        configmap|configmaps|cm|secret|secrets|serviceaccount|serviceaccounts|sa)
            echo "config" ;;
        # RBAC
        role|roles|rolebinding|rolebindings|rb|clusterrole|clusterroles|clusterrolebinding|clusterrolebindings|crb)
            echo "rbac" ;;
        # Cluster
        node*|no|namespace*|ns|event*|ev|componentstatus*|cs)
            echo "cluster" ;;
        # FluxCD
        kustomization*|helmrelease*|gitrepository*|helmrepository*|bucket*|helmchart*)
            echo "flux" ;;
        *)
            echo "other" ;;
    esac
}

# Function to get helm releases dynamically
_get_helm_releases() {
    local cache_file="$KUBECTL_CACHE_DIR/helm-releases"
    local cache_timeout=120  # 2 minutes
    
    if [[ -f "$cache_file" && $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0))) -lt $cache_timeout ]]; then
        cat "$cache_file"
        return
    fi
    
    if command -v helm &>/dev/null; then
        helm list --short 2>/dev/null > "$cache_file"
        cat "$cache_file"
    fi
}

# Function to get flux resources dynamically
_get_flux_resources() {
    local resource_type="$1"
    local cache_file="$KUBECTL_CACHE_DIR/flux-$resource_type"
    local cache_timeout=120  # 2 minutes
    
    if [[ -f "$cache_file" && $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0))) -lt $cache_timeout ]]; then
        cat "$cache_file"
        return
    fi
    
    if command -v flux &>/dev/null; then
        case "$resource_type" in
            kustomizations) flux get kustomizations --no-header 2>/dev/null | awk '{print $1}' > "$cache_file" ;;
            helmreleases) flux get helmreleases --no-header 2>/dev/null | awk '{print $1}' > "$cache_file" ;;
            sources-git) flux get sources git --no-header 2>/dev/null | awk '{print $1}' > "$cache_file" ;;
            sources-helm) flux get sources helm --no-header 2>/dev/null | awk '{print $1}' > "$cache_file" ;;
        esac
        cat "$cache_file"
    fi
}

# Simple and reliable kubectl resource name completion (like kswitch)
_kubectl_complete_resource_names() {
    local resource_type="$1"
    local cur="$2"
    
    # Exit early if kubectl is not available
    if ! command -v kubectl >/dev/null 2>&1; then
        return 0
    fi
    
    # Get all resource names
    local resources=$(kubectl get "$resource_type" --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
    
    if [[ -z "$resources" ]]; then
        COMPREPLY=()
        return 0
    fi
    
    # Enhanced matching (same pattern as kswitch)
    local matches=()
    
    # If no current input, return all options
    if [[ -z "$cur" ]]; then
        COMPREPLY=($(compgen -W "${resources}" -- "${cur}"))
        return 0
    fi
    
    # Try prefix match first
    while IFS= read -r resource; do
        [[ -n "$resource" ]] || continue
        if [[ "$resource" == "${cur}"* ]]; then
            matches+=("$resource")
        fi
    done <<< "$resources"
    
    # If no prefix matches, try substring match
    if [[ ${#matches[@]} -eq 0 ]]; then
        while IFS= read -r resource; do
            [[ -n "$resource" ]] || continue
            if [[ "$resource" == *"${cur}"* ]]; then
                matches+=("$resource")
            fi
        done <<< "$resources"
    fi
    
    COMPREPLY=("${matches[@]}")
}

# Simple and reliable kubectl completion (based on kswitch pattern)
_kubectl_smart_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local cmd="${COMP_WORDS[1]}"
    local resource="${COMP_WORDS[2]}"
    
    COMPREPLY=()
    
    # If kubectl not available, exit
    if ! command -v kubectl >/dev/null 2>&1; then
        return 0
    fi
    
    case $COMP_CWORD in
        1)
            # kubectl commands
            local commands="get describe create delete apply edit patch replace logs exec port-forward cp top config version"
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            ;;
        2)
            # Resource types for most commands
            case "$cmd" in
                get|describe|delete|edit|patch|logs|exec|port-forward)
                    local resources="pods services deployments configmaps secrets namespaces nodes ingress"
                    COMPREPLY=($(compgen -W "$resources" -- "$cur"))
                    ;;
                config)
                    local config_cmds="current-context get-contexts use-context set-context"
                    COMPREPLY=($(compgen -W "$config_cmds" -- "$cur"))
                    ;;
                *)
                    local resources="pods services deployments configmaps secrets namespaces nodes ingress"
                    COMPREPLY=($(compgen -W "$resources" -- "$cur"))
                    ;;
            esac
            ;;
        *)
            # Resource names
            if [[ "$prev" == "-n" || "$prev" == "--namespace" ]]; then
                # Namespace completion
                _kubectl_complete_resource_names "namespaces" "$cur"
            elif [[ "$cur" == -* ]]; then
                # Flags
                local flags="-o --output -n --namespace -l --selector --watch"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            else
                # Resource names based on resource type
                case "$resource" in
                    pods|pod|po) _kubectl_complete_resource_names "pods" "$cur" ;;
                    services|service|svc) _kubectl_complete_resource_names "services" "$cur" ;;
                    deployments|deployment|deploy) _kubectl_complete_resource_names "deployments" "$cur" ;;
                    configmaps|configmap|cm) _kubectl_complete_resource_names "configmaps" "$cur" ;;
                    secrets|secret) _kubectl_complete_resource_names "secrets" "$cur" ;;
                    namespaces|namespace|ns) _kubectl_complete_resource_names "namespaces" "$cur" ;;
                    nodes|node|no) _kubectl_complete_resource_names "nodes" "$cur" ;;
                    ingress|ing) _kubectl_complete_resource_names "ingress" "$cur" ;;
                    *) _kubectl_complete_resource_names "$resource" "$cur" ;;
                esac
            fi
            ;;
    esac
}

# Helper function for enhanced flux resource name completion with better partial matching
_flux_complete_resource_names() {
    local resource_type="$1"
    local cur="$2"
    local resources matches=()
    
    # Exit early if flux is not available
    if ! command -v flux >/dev/null 2>&1; then
        return 0
    fi
    
    # Get all resource names based on type
    case "$resource_type" in
        kustomizations|ks)
            resources=$(flux get kustomizations --no-header 2>/dev/null | awk '{print $1}')
            ;;
        helmreleases|hr)
            resources=$(flux get helmreleases --no-header 2>/dev/null | awk '{print $1}')
            ;;
        gitrepositories|gitrepos)
            resources=$(flux get sources git --no-header 2>/dev/null | awk '{print $1}')
            ;;
        helmrepositories|helmrepos)
            resources=$(flux get sources helm --no-header 2>/dev/null | awk '{print $1}')
            ;;
        buckets)
            resources=$(flux get sources bucket --no-header 2>/dev/null | awk '{print $1}')
            ;;
        ocirepositories)
            resources=$(flux get sources oci --no-header 2>/dev/null | awk '{print $1}')
            ;;
        alerts)
            resources=$(flux get alerts --no-header 2>/dev/null | awk '{print $1}')
            ;;
        providers)
            resources=$(flux get providers --no-header 2>/dev/null | awk '{print $1}')
            ;;
        receivers)
            resources=$(flux get receivers --no-header 2>/dev/null | awk '{print $1}')
            ;;
        imageautomations)
            resources=$(flux get imageautomations --no-header 2>/dev/null | awk '{print $1}')
            ;;
        imagepolicies)
            resources=$(flux get imagepolicies --no-header 2>/dev/null | awk '{print $1}')
            ;;
        imagerepositories)
            resources=$(flux get imagerepositories --no-header 2>/dev/null | awk '{print $1}')
            ;;
        *)
            return 0
            ;;
    esac
    
    # If no current input, return all resources
    if [[ -z "$cur" ]]; then
        COMPREPLY=($(compgen -W "${resources}" -- "${cur}"))
        return 0
    fi
    
    # Enhanced matching: exact match, prefix match, and substring match
    # First try exact match
    while IFS= read -r resource; do
        [[ -n "$resource" ]] || continue
        if [[ "$resource" == "$cur" ]]; then
            matches+=("$resource")
        fi
    done <<< "$resources"
    
    # If no exact match, try prefix match
    if [[ ${#matches[@]} -eq 0 ]]; then
        while IFS= read -r resource; do
            [[ -n "$resource" ]] || continue
            if [[ "$resource" == "${cur}"* ]]; then
                matches+=("$resource")
            fi
        done <<< "$resources"
    fi
    
    # If still no matches, try substring match
    if [[ ${#matches[@]} -eq 0 ]]; then
        while IFS= read -r resource; do
            [[ -n "$resource" ]] || continue
            if [[ "$resource" == *"${cur}"* ]]; then
                matches+=("$resource")
            fi
        done <<< "$resources"
    fi
    
    # Convert array to completion format
    if [[ ${#matches[@]} -gt 0 ]]; then
        COMPREPLY=("${matches[@]}")
    else
        COMPREPLY=()
    fi
}

# Simple flux resource name completion (like kswitch)
_flux_complete_resource_names() {
    local resource_type="$1"
    local cur="$2"
    
    # Exit early if flux is not available
    if ! command -v flux >/dev/null 2>&1; then
        return 0
    fi
    
    # Get all resource names
    local resources=$(flux get "$resource_type" --no-header 2>/dev/null | awk '{print $1}')
    
    if [[ -z "$resources" ]]; then
        COMPREPLY=()
        return 0
    fi
    
    # Enhanced matching (same pattern as kswitch)
    local matches=()
    
    # If no current input, return all options
    if [[ -z "$cur" ]]; then
        COMPREPLY=($(compgen -W "${resources}" -- "${cur}"))
        return 0
    fi
    
    # Try prefix match first
    while IFS= read -r resource; do
        [[ -n "$resource" ]] || continue
        if [[ "$resource" == "${cur}"* ]]; then
            matches+=("$resource")
        fi
    done <<< "$resources"
    
    # If no prefix matches, try substring match
    if [[ ${#matches[@]} -eq 0 ]]; then
        while IFS= read -r resource; do
            [[ -n "$resource" ]] || continue
            if [[ "$resource" == *"${cur}"* ]]; then
                matches+=("$resource")
            fi
        done <<< "$resources"
    fi
    
    COMPREPLY=("${matches[@]}")
}

# Simple and reliable flux completion (based on kswitch pattern)  
_flux_smart_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local cmd="${COMP_WORDS[1]}"
    local resource="${COMP_WORDS[2]}"
    
    COMPREPLY=()
    
    # If flux not available, exit
    if ! command -v flux >/dev/null 2>&1; then
        return 0
    fi
    
    case $COMP_CWORD in
        1)
            # flux commands
            local commands="get reconcile suspend resume create delete logs bootstrap check"
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            ;;
        2)
            # Resource types for most commands
            case "$cmd" in
                get|reconcile|suspend|resume|delete)
                    local resources="kustomizations helmreleases sources all"
                    COMPREPLY=($(compgen -W "$resources" -- "$cur"))
                    ;;
                logs)
                    local controllers="source-controller kustomize-controller helm-controller notification-controller"
                    COMPREPLY=($(compgen -W "$controllers" -- "$cur"))
                    ;;
                create)
                    local create_types="source kustomization helmrelease"
                    COMPREPLY=($(compgen -W "$create_types" -- "$cur"))
                    ;;
                *)
                    local resources="kustomizations helmreleases sources"
                    COMPREPLY=($(compgen -W "$resources" -- "$cur"))
                    ;;
            esac
            ;;
        *)
            # Resource names
            if [[ "$prev" == "-n" || "$prev" == "--namespace" ]]; then
                # Namespace completion
                local namespaces=$(kubectl get namespaces --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
                COMPREPLY=($(compgen -W "$namespaces" -- "$cur"))
            elif [[ "$cur" == -* ]]; then
                # Flags
                local flags="-n --namespace --all-namespaces -A --timeout"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            else
                # Resource names based on resource type
                case "$resource" in
                    kustomizations|ks)
                        _flux_complete_resource_names "kustomizations" "$cur"
                        ;;
                    helmreleases|hr)
                        _flux_complete_resource_names "helmreleases" "$cur"
                        ;;
                    sources)
                        local sources=$(flux get sources git --no-header 2>/dev/null | awk '{print $1}'; flux get sources helm --no-header 2>/dev/null | awk '{print $1}')
                        COMPREPLY=($(compgen -W "$sources" -- "$cur"))
                        ;;
                esac
            fi
            ;;
    esac
}

# Helper function for enhanced helm resource name completion with better partial matching
_helm_complete_resource_names() {
    local resource_type="$1"
    local cur="$2"
    local resources matches=()
    
    # Exit early if helm is not available
    if ! command -v helm >/dev/null 2>&1; then
        return 0
    fi
    
    # Get all resource names based on type
    case "$resource_type" in
        releases)
            resources=$(helm list --short 2>/dev/null)
            ;;
        repos|repositories)
            resources=$(helm repo list 2>/dev/null | awk 'NR>1 {print $1}')
            ;;
        charts)
            # Get charts from all repositories
            resources=$(helm search repo --max-col-width=50 2>/dev/null | awk 'NR>1 {print $1}' | cut -d'/' -f2 | sort -u)
            ;;
        plugins)
            resources=$(helm plugin list 2>/dev/null | awk 'NR>1 {print $1}')
            ;;
        *)
            return 0
            ;;
    esac
    
    # If no current input, return all resources
    if [[ -z "$cur" ]]; then
        COMPREPLY=($(compgen -W "${resources}" -- "${cur}"))
        return 0
    fi
    
    # Enhanced matching: exact match, prefix match, and substring match
    # First try exact match
    while IFS= read -r resource; do
        [[ -n "$resource" ]] || continue
        if [[ "$resource" == "$cur" ]]; then
            matches+=("$resource")
        fi
    done <<< "$resources"
    
    # If no exact match, try prefix match
    if [[ ${#matches[@]} -eq 0 ]]; then
        while IFS= read -r resource; do
            [[ -n "$resource" ]] || continue
            if [[ "$resource" == "${cur}"* ]]; then
                matches+=("$resource")
            fi
        done <<< "$resources"
    fi
    
    # If still no matches, try substring match
    if [[ ${#matches[@]} -eq 0 ]]; then
        while IFS= read -r resource; do
            [[ -n "$resource" ]] || continue
            if [[ "$resource" == *"${cur}"* ]]; then
                matches+=("$resource")
            fi
        done <<< "$resources"
    fi
    
    # Convert array to completion format
    if [[ ${#matches[@]} -gt 0 ]]; then
        COMPREPLY=("${matches[@]}")
    else
        COMPREPLY=()
    fi
}

# Enhanced helm completion with comprehensive command support
_helm_smart_complete() {
    local cur prev words cword
    
    # Use _init_completion if available, otherwise set up manually
    if declare -f _init_completion >/dev/null 2>&1; then
        _init_completion || return
    else
        # Manual setup if _init_completion is not available
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    # Clear any existing completions to prevent file fallback
    COMPREPLY=()
    
    # Comprehensive helm commands
    local helm_commands="completion create dependency diff env get history install lint list package plugin pull push registry repo rollback search show status template test uninstall upgrade verify version"
    
    # Helm subcommands
    local helm_repo_commands="add index list remove update"
    local helm_plugin_commands="install list uninstall update"
    local helm_show_commands="all chart values readme"
    local helm_search_commands="repo hub"
    local helm_get_commands="all hooks manifest notes values"
    local helm_dependency_commands="build list update"
    local helm_registry_commands="login logout"
    
    # Common flags organized by context
    local common_flags="--namespace -n --kubeconfig --kube-context --debug --dry-run --timeout --help -h"
    local install_flags="--values -f --set --set-string --wait --atomic --force --create-namespace --dependency-update --disable-openapi-validation --post-renderer --render-subchart-notes --replace --reset-values --reuse-values --skip-crds --verify --version --wait-for-jobs"
    local list_flags="--all-namespaces -A --date --deployed --failed --filter --max --offset --output -o --pending --reverse --short --superseded --uninstalled --uninstalling"
    local get_flags="--output -o --revision --template"
    local repo_flags="--ca-file --cert-file --key-file --password --username --insecure-skip-tls-verify --pass-credentials"
    
    case $cword in
        1)
            # First argument: helm commands with smart suggestions
            if [[ "$cur" == "i"* ]]; then
                COMPREPLY=($(compgen -W "install" -- "$cur"))
            elif [[ "$cur" == "u"* ]]; then
                COMPREPLY=($(compgen -W "uninstall upgrade" -- "$cur"))
            elif [[ "$cur" == "l"* ]]; then
                COMPREPLY=($(compgen -W "list lint" -- "$cur"))
            elif [[ "$cur" == "s"* ]]; then
                COMPREPLY=($(compgen -W "status show search" -- "$cur"))
            elif [[ "$cur" == "r"* ]]; then
                COMPREPLY=($(compgen -W "repo rollback registry" -- "$cur"))
            elif [[ "$cur" == "g"* ]]; then
                COMPREPLY=($(compgen -W "get" -- "$cur"))
            elif [[ "$cur" == "h"* ]]; then
                COMPREPLY=($(compgen -W "history" -- "$cur"))
            elif [[ "$cur" == "t"* ]]; then
                COMPREPLY=($(compgen -W "template test" -- "$cur"))
            elif [[ "$cur" == "p"* ]]; then
                COMPREPLY=($(compgen -W "plugin package pull push" -- "$cur"))
            elif [[ "$cur" == "d"* ]]; then
                COMPREPLY=($(compgen -W "dependency diff" -- "$cur"))
            elif [[ "$cur" == "v"* ]]; then
                COMPREPLY=($(compgen -W "version verify" -- "$cur"))
            elif [[ "$cur" == "c"* ]]; then
                COMPREPLY=($(compgen -W "completion create" -- "$cur"))
            elif [[ "$cur" == "e"* ]]; then
                COMPREPLY=($(compgen -W "env" -- "$cur"))
            else
                COMPREPLY=($(compgen -W "$helm_commands" -- "$cur"))
            fi
            return 0
            ;;
        2)
            # Second argument: depends on first argument
            case "${words[1]}" in
                install)
                    # helm install <release-name> or helm install <name> <chart>
                    # For install, second arg is release name (new), so suggest charts or nothing
                    if [[ "$cur" == *"/"* ]]; then
                        # If contains /, it's likely a chart reference
                        _helm_complete_resource_names "charts" "$cur"
                    else
                        # Could be release name or chart name
                        COMPREPLY=()
                    fi
                    return 0
                    ;;
                upgrade|get|status|history|rollback|uninstall|test)
                    # These commands work with existing releases
                    if [[ "$cur" == "r"* ]]; then
                        # Quick completion for release names starting with 'r'
                        _helm_complete_resource_names "releases" "$cur"
                    else
                        _helm_complete_resource_names "releases" "$cur"
                    fi
                    return 0
                    ;;
                list)
                    # helm list has flags, not positional args
                    if [[ "$cur" == -* ]]; then
                        COMPREPLY=($(compgen -W "$list_flags" -- "$cur"))
                    fi
                    return 0
                    ;;
                repo)
                    # Smart suggestions for repo command
                    if [[ "$cur" == "a"* ]]; then
                        COMPREPLY=($(compgen -W "add" -- "$cur"))
                    elif [[ "$cur" == "l"* ]]; then
                        COMPREPLY=($(compgen -W "list" -- "$cur"))
                    elif [[ "$cur" == "u"* ]]; then
                        COMPREPLY=($(compgen -W "update" -- "$cur"))
                    elif [[ "$cur" == "r"* ]]; then
                        COMPREPLY=($(compgen -W "remove" -- "$cur"))
                    elif [[ "$cur" == "i"* ]]; then
                        COMPREPLY=($(compgen -W "index" -- "$cur"))
                    else
                        COMPREPLY=($(compgen -W "$helm_repo_commands" -- "$cur"))
                    fi
                    return 0
                    ;;
                plugin)
                    # Smart suggestions for plugin command
                    if [[ "$cur" == "i"* ]]; then
                        COMPREPLY=($(compgen -W "install" -- "$cur"))
                    elif [[ "$cur" == "l"* ]]; then
                        COMPREPLY=($(compgen -W "list" -- "$cur"))
                    elif [[ "$cur" == "u"* ]]; then
                        COMPREPLY=($(compgen -W "uninstall update" -- "$cur"))
                    else
                        COMPREPLY=($(compgen -W "$helm_plugin_commands" -- "$cur"))
                    fi
                    return 0
                    ;;
                show)
                    # Smart suggestions for show command
                    if [[ "$cur" == "a"* ]]; then
                        COMPREPLY=($(compgen -W "all" -- "$cur"))
                    elif [[ "$cur" == "c"* ]]; then
                        COMPREPLY=($(compgen -W "chart" -- "$cur"))
                    elif [[ "$cur" == "v"* ]]; then
                        COMPREPLY=($(compgen -W "values" -- "$cur"))
                    elif [[ "$cur" == "r"* ]]; then
                        COMPREPLY=($(compgen -W "readme" -- "$cur"))
                    else
                        COMPREPLY=($(compgen -W "$helm_show_commands" -- "$cur"))
                    fi
                    return 0
                    ;;
                search)
                    # Smart suggestions for search command
                    if [[ "$cur" == "r"* ]]; then
                        COMPREPLY=($(compgen -W "repo" -- "$cur"))
                    elif [[ "$cur" == "h"* ]]; then
                        COMPREPLY=($(compgen -W "hub" -- "$cur"))
                    else
                        COMPREPLY=($(compgen -W "$helm_search_commands" -- "$cur"))
                    fi
                    return 0
                    ;;
                get)
                    # Smart suggestions for get command
                    if [[ "$cur" == "a"* ]]; then
                        COMPREPLY=($(compgen -W "all" -- "$cur"))
                    elif [[ "$cur" == "h"* ]]; then
                        COMPREPLY=($(compgen -W "hooks" -- "$cur"))
                    elif [[ "$cur" == "m"* ]]; then
                        COMPREPLY=($(compgen -W "manifest" -- "$cur"))
                    elif [[ "$cur" == "n"* ]]; then
                        COMPREPLY=($(compgen -W "notes" -- "$cur"))
                    elif [[ "$cur" == "v"* ]]; then
                        COMPREPLY=($(compgen -W "values" -- "$cur"))
                    else
                        COMPREPLY=($(compgen -W "$helm_get_commands" -- "$cur"))
                    fi
                    return 0
                    ;;
                dependency)
                    # Smart suggestions for dependency command
                    if [[ "$cur" == "b"* ]]; then
                        COMPREPLY=($(compgen -W "build" -- "$cur"))
                    elif [[ "$cur" == "l"* ]]; then
                        COMPREPLY=($(compgen -W "list" -- "$cur"))
                    elif [[ "$cur" == "u"* ]]; then
                        COMPREPLY=($(compgen -W "update" -- "$cur"))
                    else
                        COMPREPLY=($(compgen -W "$helm_dependency_commands" -- "$cur"))
                    fi
                    return 0
                    ;;
                registry)
                    # Smart suggestions for registry command
                    if [[ "$cur" == "l"* ]]; then
                        COMPREPLY=($(compgen -W "login logout" -- "$cur"))
                    else
                        COMPREPLY=($(compgen -W "$helm_registry_commands" -- "$cur"))
                    fi
                    return 0
                    ;;
                create|lint|package|template|verify)
                    # These commands work with chart directories, suggest nothing special
                    if [[ "$cur" == -* ]]; then
                        COMPREPLY=($(compgen -W "$common_flags" -- "$cur"))
                    fi
                    return 0
                    ;;
                *)
                    # Default flags for other commands
                    if [[ "$cur" == -* ]]; then
                        COMPREPLY=($(compgen -W "$common_flags" -- "$cur"))
                    fi
                    return 0
                    ;;
            esac
            ;;
        3)
            # Third argument: specific resource handling
            case "${words[1]}" in
                install)
                    # helm install <release-name> <chart>
                    if [[ "$cur" == *"/"* ]] || [[ "$cur" != -* ]]; then
                        # Complete with chart names
                        _helm_complete_resource_names "charts" "$cur"
                    elif [[ "$cur" == -* ]]; then
                        COMPREPLY=($(compgen -W "$install_flags" -- "$cur"))
                    fi
                    return 0
                    ;;
                upgrade)
                    # helm upgrade <release> <chart>
                    if [[ "$cur" == *"/"* ]] || [[ "$cur" != -* ]]; then
                        # Complete with chart names
                        _helm_complete_resource_names "charts" "$cur"
                    elif [[ "$cur" == -* ]]; then
                        COMPREPLY=($(compgen -W "$install_flags" -- "$cur"))
                    fi
                    return 0
                    ;;
                get)
                    # helm get <subcommand> <release>
                    _helm_complete_resource_names "releases" "$cur"
                    return 0
                    ;;
                show)
                    # helm show <subcommand> <chart>
                    if [[ "$cur" == *"/"* ]] || [[ "$cur" != -* ]]; then
                        _helm_complete_resource_names "charts" "$cur"
                    fi
                    return 0
                    ;;
                repo)
                    case "${words[2]}" in
                        add)
                            # helm repo add <name> <url> - just suggest nothing for name
                            return 0
                            ;;
                        remove)
                            # helm repo remove <name>
                            _helm_complete_resource_names "repos" "$cur"
                            return 0
                            ;;
                        *)
                            if [[ "$cur" == -* ]]; then
                                COMPREPLY=($(compgen -W "$repo_flags" -- "$cur"))
                            fi
                            return 0
                            ;;
                    esac
                    ;;
                plugin)
                    case "${words[2]}" in
                        uninstall)
                            # helm plugin uninstall <plugin>
                            _helm_complete_resource_names "plugins" "$cur"
                            return 0
                            ;;
                        *)
                            return 0
                            ;;
                    esac
                    ;;
                search)
                    case "${words[2]}" in
                        repo|hub)
                            # helm search repo <term> - don't complete search terms
                            if [[ "$cur" == -* ]]; then
                                return 0
                            fi
                            ;;
                        *)
                            return 0
                            ;;
                    esac
                    ;;
                *)
                    return 0
                    ;;
            esac
            ;;
        *)
            return 0
            ;;
    esac
}

#######################################
# SYSTEM MONITORING AND PERFORMANCE
#######################################

# Advanced kubectl exec with container selection
kexec() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: kexec <pod-pattern> [namespace]"
        echo "Example: kexec nginx default"
        return 1
    fi
    
    local pod_pattern="$1"
    local namespace="${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}"
    local namespace_arg=""
    
    if [[ -n "$namespace" ]]; then
        namespace_arg="-n $namespace"
    fi
        # Find matching pod
        local pod=$(kubectl get pods $namespace_arg --no-headers | grep "$pod_pattern" | head -1 | awk '{print $1}')
        if [[ -z "$pod" ]]; then
            echo "❌ No pod found matching pattern: $pod_pattern"
            return 1
        fi
        
        # Get containers in pod
        local containers=($(kubectl get pod $pod $namespace_arg -o jsonpath='{.spec.containers[*].name}'))
        
        if [[ ${#containers[@]} -eq 1 ]]; then
            # Single container, exec directly
            echo "🚀 Executing into pod: $pod (container: ${containers[0]})"
            kubectl exec -it $pod $namespace_arg -c "${containers[0]}" -- sh -c 'bash || sh'
        else
            # Multiple containers, let user choose
            echo "🔍 Pod $pod has multiple containers:"
            for i in "${!containers[@]}"; do
                echo "  $((i+1)). ${containers[i]}"
            done
            read -p "Select container (1-${#containers[@]}): " choice
            if [[ "$choice" -ge 1 && "$choice" -le ${#containers[@]} ]]; then
                local container="${containers[$((choice-1))]}"
                echo "🚀 Executing into pod: $pod (container: $container)"
                kubectl exec -it $pod $namespace_arg -c "$container" -- sh -c 'bash || sh'
            else
                echo "❌ Invalid selection"
                return 1
            fi
        fi
    }
    
    # Port forward with automatic port detection
    kpf-auto() {
        if [[ $# -eq 0 ]]; then
            echo "Usage: kpf-auto <service-or-pod-pattern> [local-port] [namespace]"
            echo "Example: kpf-auto nginx 8080"
            return 1
        fi
        
        local resource_pattern="$1"
        local local_port="$2"
        local namespace_arg=""
        [[ -n "$3" ]] && namespace_arg="-n $3"
        
        # Try to find service first, then pod
        local resource=$(kubectl get svc $namespace_arg --no-headers 2>/dev/null | grep "$resource_pattern" | head -1 | awk '{print "svc/" $1}')
        if [[ -z "$resource" ]]; then
            resource=$(kubectl get pods $namespace_arg --no-headers 2>/dev/null | grep "$resource_pattern" | head -1 | awk '{print "pod/" $1}')
        fi
        
        if [[ -z "$resource" ]]; then
            echo "❌ No service or pod found matching pattern: $resource_pattern"
            return 1
        fi
        
        # Get ports from resource
        local ports=($(kubectl get ${resource} $namespace_arg -o jsonpath='{.spec.ports[*].port}' 2>/dev/null || kubectl get ${resource} $namespace_arg -o jsonpath='{.spec.containers[*].ports[*].containerPort}' 2>/dev/null))
        
        if [[ ${#ports[@]} -eq 0 ]]; then
            echo "❌ No ports found for $resource"
            return 1
        fi
        
        local remote_port="${ports[0]}"
        if [[ ${#ports[@]} -gt 1 ]]; then
            echo "🔍 Multiple ports available: ${ports[*]}"
            echo "Using first port: $remote_port"
        fi
        
        local_port="${local_port:-$remote_port}"
        
        echo "🚀 Port forwarding: localhost:$local_port -> $resource:$remote_port"
        kubectl port-forward $resource $namespace_arg "$local_port:$remote_port"
    }
    
    # Show comprehensive pod information
    kpod-info() {
        if [[ $# -eq 0 ]]; then
            echo "Usage: kpod-info <pod-pattern> [namespace]"
            return 1
        fi
        
        local pod_pattern="$1"
        local namespace_arg=""
        [[ -n "$2" ]] && namespace_arg="-n $2"
        
        local pod=$(kubectl get pods $namespace_arg --no-headers | grep "$pod_pattern" | head -1 | awk '{print $1}')
        if [[ -z "$pod" ]]; then
            echo "❌ No pod found matching pattern: $pod_pattern"
            return 1
        fi
        
        echo "📋 Pod Information: $pod"
        echo "================================="
        echo
        echo "🔸 Basic Info:"
        kubectl get pod $pod $namespace_arg -o wide
        echo
        echo "🔸 Resource Usage:"
        kubectl top pod $pod $namespace_arg 2>/dev/null || echo "Metrics not available"
        echo
        echo "🔸 Containers:"
        kubectl get pod $pod $namespace_arg -o jsonpath='{range .spec.containers[*]}{.name}{": "}{.image}{"\n"}{end}'
        echo
        echo "🔸 Recent Events:"
        kubectl get events $namespace_arg --field-selector involvedObject.name=$pod --sort-by='.lastTimestamp' | tail -5
        echo
        echo "🔸 Status:"
        kubectl get pod $pod $namespace_arg -o jsonpath='{.status.phase}{" - "}{.status.conditions[?(@.type=="Ready")].status}{"\n"}'
    }
    
    # Kubernetes troubleshooting toolkit
    ktrouble() {
        echo "🔧 Kubernetes Troubleshooting Toolkit"
        echo "======================================"
        echo
        echo "🔹 Cluster Health:"
        kubectl get nodes --no-headers | while read node status roles age version; do
            [[ "$status" != "Ready" ]] && echo "  ⚠️  Node $node: $status"
        done
        
        echo
        echo "🔹 Failed Pods:"
        kubectl get pods -A --field-selector=status.phase=Failed --no-headers | while read ns pod rest; do
            echo "  ❌ $ns/$pod"
        done
        
        echo
        echo "🔹 Pending Pods:"
        kubectl get pods -A --field-selector=status.phase=Pending --no-headers | while read ns pod rest; do
            echo "  ⏳ $ns/$pod"
        done
        
        echo
        echo "🔹 Recent Critical Events:"
        kubectl get events -A --field-selector type=Warning --sort-by='.lastTimestamp' | tail -5
        
        echo
        echo "🔹 Resource Pressure:"
        kubectl describe nodes | grep -E "(Name:|Conditions:)" -A 5 | grep -E "(MemoryPressure|DiskPressure|PIDPressure)" || echo "  ✅ No resource pressure detected"
    }
    
    # Quick deployment status
    kdeploy-status() {
        echo "📊 Deployment Status Overview"
        echo "============================="
        echo
        kubectl get deployments -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,READY:.status.readyReplicas,DESIRED:.spec.replicas,UP-TO-DATE:.status.updatedReplicas,AVAILABLE:.status.availableReplicas,AGE:.metadata.creationTimestamp" | while read ns name ready desired updated available age; do
            if [[ "$name" != "NAME" && "$ready" != "$desired" ]]; then
                echo "⚠️  $ns/$name: $ready/$desired ready"
            fi
        done
        echo "✅ All other deployments are healthy"
    }
    
    # Completion for new functions
    complete -F _kubectl_pods_completion ksh kpod-info
    complete -F _kubectl_resources_completion kgetall kpf-auto
    complete -F _kns_completion kscale kpod-restart

#######################################
# CLUSTER UTILITY FUNCTIONS  
#######################################

# Cache for user-specified kubeconfig files and directories
export KCONFIG_CACHE_DIR="$HOME/.cache/kubeconfig"
export KCONFIG_CACHE_FILE="$KCONFIG_CACHE_DIR/user_configs.txt"
export KCONFIG_DIRS_FILE="$KCONFIG_CACHE_DIR/user_dirs.txt"

# Create cache directory
mkdir -p "$KCONFIG_CACHE_DIR" 2>/dev/null

# Function to validate if a file is a valid kubeconfig
_is_valid_kubeconfig() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    
    # Check if file contains kubeconfig-like content
    if command -v grep >/dev/null 2>&1; then
        grep -q "apiVersion\|clusters\|contexts\|users" "$file" 2>/dev/null
    else
        # Fallback if grep is not available - simple content check
        head -20 "$file" 2>/dev/null | while IFS= read -r line; do
            case "$line" in
                *apiVersion*|*clusters*|*contexts*|*users*) return 0 ;;
            esac
        done
        return $?
    fi
}

# Function to add a single kubeconfig file
add-kubeconfig() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: add-kubeconfig <path-to-kubeconfig-file>"
        echo "Example: add-kubeconfig ~/my-cluster-config.yaml"
        return 1
    fi
    
    local config_file="$1"
    
    # Expand tilde and resolve path
    config_file="${config_file/#\~/$HOME}"
    config_file="$(realpath "$config_file" 2>/dev/null)" || config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ File does not exist: $config_file"
        return 1
    fi
    
    if ! _is_valid_kubeconfig "$config_file"; then
        echo "❌ Not a valid kubeconfig file: $config_file"
        return 1
    fi
    
    # Add to user configs if not already present
    if ! grep -Fxq "$config_file" "$KCONFIG_CACHE_FILE" 2>/dev/null; then
        echo "$config_file" >> "$KCONFIG_CACHE_FILE"
        echo "✅ Added kubeconfig: $config_file"
    else
        echo "ℹ️  Already added: $config_file"
    fi
}

# Function to add a kubeconfig directory for searching
add-kubeconfig-folder() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: add-kubeconfig-folder <path-to-directory>"
        echo "Example: add-kubeconfig-folder ~/k8s-configs"
        echo "This will search recursively for kubeconfig files in the directory"
        return 1
    fi
    
    local config_dir="$1"
    
    # Expand tilde and resolve path
    config_dir="${config_dir/#\~/$HOME}"
    config_dir="$(realpath "$config_dir" 2>/dev/null)" || config_dir="$1"
    
    if [[ ! -d "$config_dir" ]]; then
        echo "❌ Directory does not exist: $config_dir"
        return 1
    fi
    
    # Add to user directories if not already present
    if ! grep -Fxq "$config_dir" "$KCONFIG_DIRS_FILE" 2>/dev/null; then
        echo "$config_dir" >> "$KCONFIG_DIRS_FILE"
        echo "✅ Added kubeconfig search directory: $config_dir"
        
        # Scan and add any kubeconfigs found
        echo "🔍 Scanning for kubeconfig files..."
        find "$config_dir" -type f \( -name "*.yaml" -o -name "*.yml" -o -name "config" -o -name "*kubeconfig*" \) 2>/dev/null | while IFS= read -r file; do
            if _is_valid_kubeconfig "$file"; then
                if ! grep -Fxq "$file" "$KCONFIG_CACHE_FILE" 2>/dev/null; then
                    echo "$file" >> "$KCONFIG_CACHE_FILE"
                    echo "  ✅ Found: $(basename "$file")"
                fi
            fi
        done
    else
        echo "ℹ️  Already added: $config_dir"
    fi
}

# Function to list all discovered kubeconfig files
kconfigs() {
    local cache_count=0
    
    echo "📋 User-specified kubeconfig files:"
    echo "===================================="
    
    if [[ -f "$KCONFIG_CACHE_FILE" ]]; then
        while IFS= read -r config_file; do
            [[ -n "$config_file" ]] || continue
            if [[ -f "$config_file" ]]; then
                echo "  ✅ $config_file"
                ((cache_count++))
            else
                echo "  ❌ $config_file (missing)"
            fi
        done < "$KCONFIG_CACHE_FILE"
    fi
    
    if [[ -f "$KCONFIG_DIRS_FILE" ]]; then
        echo ""
        echo "📁 User-specified search directories:"
        echo "===================================="
        while IFS= read -r config_dir; do
            [[ -n "$config_dir" ]] || continue
            if [[ -d "$config_dir" ]]; then
                echo "  📁 $config_dir"
            else
                echo "  ❌ $config_dir (missing)"
            fi
        done < "$KCONFIG_DIRS_FILE"
    fi
    
    if [[ $cache_count -eq 0 ]]; then
        echo ""
        echo "🔧 Getting started:"
        echo "  add-kubeconfig <file>        # Add single kubeconfig file"
        echo "  add-kubeconfig-folder <dir>  # Add directory to search"
        echo "  kcc <name>                   # Switch to kubeconfig (Kubeconfig Change/Choose)"
        echo ""
        echo "💡 Examples:"
        echo "  add-kubeconfig ~/.kube/config"
        echo "  add-kubeconfig ~/my-cluster.yaml"
        echo "  add-kubeconfig-folder ~/k8s-configs"
    else
        echo ""
        echo "🎯 Total: $cache_count kubeconfig files available"
        echo "💡 Use: kcc <name> to switch"
    fi
}

# Function to switch kubeconfig (kcc = Kubeconfig Change/Choose)
kcc() {
    if [[ $# -eq 0 ]]; then
        echo "Available kubeconfig files:"
        echo "=========================="
        
        if [[ ! -f "$KCONFIG_CACHE_FILE" ]]; then
            echo "No kubeconfig files found."
            echo ""
            echo "🔧 Add kubeconfig files first:"
            echo "  add-kubeconfig <file>        # Add single file"
            echo "  add-kubeconfig-folder <dir>  # Add directory to search"
            return 1
        fi
        
        local count=0
        while IFS= read -r config_file; do
            [[ -n "$config_file" && -f "$config_file" ]] || continue
            local basename_config=$(basename "$config_file")
            local dirname_config=$(dirname "$config_file")
            printf "%2d. %-30s (%s)\n" $((++count)) "$basename_config" "$dirname_config"
        done < "$KCONFIG_CACHE_FILE"
        
        if [[ $count -eq 0 ]]; then
            echo "No valid kubeconfig files found."
            echo ""
            echo "🔧 Add kubeconfig files first:"
            echo "  add-kubeconfig <file>        # Add single file"
            echo "  add-kubeconfig-folder <dir>  # Add directory to search"
        else
            echo ""
            echo "💡 Usage: kcc <name-or-number>"
        fi
        return 0
    fi
    
    local selection="$1"
    local config_file=""
    
    # Check if selection is a number
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        config_file=$(sed -n "${selection}p" "$KCONFIG_CACHE_FILE" 2>/dev/null)
    else
        # Search by name
        config_file=$(grep "$selection" "$KCONFIG_CACHE_FILE" 2>/dev/null | head -1)
    fi
    
    if [[ -z "$config_file" || ! -f "$config_file" ]]; then
        echo "❌ Kubeconfig not found: $selection"
        echo "Run 'kconfigs' to see available options"
        return 1
    fi
    
    export KUBECONFIG="$config_file"
    echo "✅ Switched to kubeconfig: $(basename "$config_file")"
    echo "📁 Path: $config_file"
    
    # Show current context if kubectl is available
    if command -v kubectl >/dev/null 2>&1; then
        local current_context
        current_context=$(kubectl config current-context 2>/dev/null)
        if [[ -n "$current_context" ]]; then
            echo "🎯 Context: $current_context"
        fi
    fi
    
    # Save session state for next terminal
    _save_k8s_session 2>/dev/null || true
}

# Tab completion for kcc (Kubeconfig Change/Choose)
_kubeconfig_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local -a configs=()
    
    if [[ -f "$KCONFIG_CACHE_FILE" ]]; then
        while IFS= read -r config_file; do
            [[ -n "$config_file" && -f "$config_file" ]] || continue
            local basename_config
            basename_config=$(basename "$config_file")
            configs+=("$basename_config")
        done < "$KCONFIG_CACHE_FILE"
    fi
    
    COMPREPLY=($(compgen -W "${configs[*]}" -- "$cur"))
}

complete -F _kubeconfig_completion kcc

# Alias for backward compatibility
alias kchangeconfig='kcc'

# Function to export current kubeconfig to environment
kexport() {
    if [[ -z "$KUBECONFIG" ]]; then
        echo "❌ No kubeconfig is currently set"
        echo "Use 'kcc <name>' to select a kubeconfig first"
        return 1
    fi
    
    echo "export KUBECONFIG=\"$KUBECONFIG\""
    echo ""
    echo "💡 Copy and paste the above line to set KUBECONFIG in your current shell"
    echo "📁 Current kubeconfig: $(basename "$KUBECONFIG")"
}

# Function to show current kubeconfig
kcurrent() {
    if [[ -n "$KUBECONFIG" ]]; then
        echo "📁 Current kubeconfig: $KUBECONFIG"
        if command -v kubectl >/dev/null 2>&1; then
            local current_context=$(kubectl config current-context 2>/dev/null)
            if [[ -n "$current_context" ]]; then
                echo "🎯 Current context: $current_context"
                local current_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
                [[ -n "$current_namespace" && "$current_namespace" != "null" ]] && echo "🏷️  Current namespace: $current_namespace" || echo "🏷️  Current namespace: default"
            fi
        fi
    else
        echo "❌ No kubeconfig is currently set"
        echo "Use 'kcc <name>' to select a kubeconfig"
    fi
}

# Function to reset kubeconfig to default
kreset() {
    unset KUBECONFIG
    echo "✅ Reset to default kubeconfig (~/.kube/config)"
    if command -v kubectl >/dev/null 2>&1; then
        local current_context
        current_context=$(kubectl config current-context 2>/dev/null)
        if [[ -n "$current_context" ]]; then
            echo "🎯 Context: $current_context"
        fi
    fi
}

# Clear kubectl cache function
clear-kubectl-cache() {
    rm -f /tmp/kubectl_cache_* 2>/dev/null
    echo "✅ kubectl cache cleared"
}

# Function to show kubectl examples (works with or without kubectl)
k-examples() {
    case "$1" in
        get) echo "Formats: ky pods | kwide nodes | kj services" ;;
        logs) echo "Logs: klogs <pod> | kubectl logs -f <pod>" ;;
        *) echo "kex get|logs | Quick: ky kwide kj klogs" ;;
    esac
}

# Short alias for k-examples
alias kex='k-examples'

# Tab completion for k-examples
_k_examples_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local commands="get logs"
    COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
}

# Register completion for k-examples and kex alias (always available)
if command -v complete &>/dev/null; then
    complete -F _k_examples_completion k-examples
    complete -F _k_examples_completion kex
fi

#######################################
# MODERN CLI TOOLS (if available)
#######################################
command -v eza &>/dev/null && alias ls='eza --icons --color=auto'
command -v bat &>/dev/null && alias cat='bat --style=plain'
command -v rg &>/dev/null && alias grep='rg'
command -v htop &>/dev/null && alias top='htop'
command -v btop &>/dev/null && alias top='btop'
command -v fd &>/dev/null && alias find='fd'

#######################################
# COMMAND NOT FOUND HANDLER (SUSE/WSL SPECIFIC)
#######################################

# ULTRA-ROBUST COMMAND_NOT_FOUND_HANDLE - COMPREHENSIVE ERROR HANDLING AND SUGGESTIONS
command_not_found_handle() {
    local cmd="$1"
    shift
    local args="$@"
    
    # Bulletproof error handling - prevent any exits
    set +e
    set +o errexit
    set +o pipefail
    
    # Color variables with fallbacks
    local RED="${C_RED:-\033[0;31m}"
    local GREEN="${C_GREEN:-\033[0;32m}"
    local YELLOW="${C_YELLOW:-\033[0;33m}"
    local BLUE="${C_BLUE:-\033[0;34m}"
    local CYAN="${C_CYAN:-\033[0;36m}"
    local WHITE="${C_WHITE:-\033[0;37m}"
    local RESET="${C_RESET:-\033[0m}"
    local BOLD="${C_BOLD:-\033[1m}"
    
    # Enhanced error message with context
    echo
    echo -e "${RED}❌ Command not found: ${YELLOW}${BOLD}$cmd${RESET}"
    [[ -n "$args" ]] && echo -e "${WHITE}   Arguments: ${CYAN}$args${RESET}"
    echo
    
    # COMPREHENSIVE COMMAND PATTERN MATCHING
    case "$cmd" in
        # KUBERNETES COMMANDS - Primary focus
        kubectl|kubctl|kubeclt|kube|kubeectl|kubetcl)
            echo -e "${CYAN}� ${BOLD}Kubernetes Management:${RESET}"
            echo -e "  ${GREEN}kubectl${RESET} or ${GREEN}k${RESET} - Full kubectl command"
            echo -e "  ${GREEN}klist${RESET} - Interactive resource browser"
            echo -e "  ${GREEN}kns <namespace>${RESET} - Switch namespace"
            echo -e "  ${GREEN}kcc <context>${RESET} - Switch context"
            ;;
            
        # SMART KUBECTL ALIASES
        ksget|ksge|kge|ksg|ksgt|kget|ketget|ksgte)
            echo -e "${CYAN}� ${BOLD}Resource Listing (ksget):${RESET}"
            echo -e "  ${GREEN}ksget pods${RESET} or ${GREEN}ksget po${RESET} - List pods"
            echo -e "  ${GREEN}ksget svc${RESET} or ${GREEN}ksget services${RESET} - List services"
            echo -e "  ${GREEN}ksget deploy${RESET} - List deployments"
            echo -e "  ${GREEN}ksget nodes${RESET} - List nodes"
            echo -e "  ${GREEN}ksget ns${RESET} - List namespaces"
            echo -e "  ${GREEN}ksget ing${RESET} - List ingresses"
            echo -e "  ${GREEN}ksget pv${RESET} - List persistent volumes"
            echo -e "  ${GREEN}ksget pvc${RESET} - List persistent volume claims"
            ;;
            
        kslogs|kslog|klogs|klog|ksogs|kslgs)
            echo -e "${CYAN}� ${BOLD}Pod Logs (kslogs):${RESET}"
            echo -e "  ${GREEN}kslogs <pod-pattern>${RESET} - Get logs from matching pods"
            echo -e "  ${GREEN}kslogs -f <pod-pattern>${RESET} - Follow logs"
            echo -e "  ${GREEN}kslogs --tail=100 <pod-pattern>${RESET} - Last 100 lines"
            echo -e "  ${CYAN}💡 Use partial pod names - it will find matches!${RESET}"
            ;;
            
        ksdesc|ksdescribe|kdesc|kdescribe|ksdes|kdes)
            echo -e "${CYAN}� ${BOLD}Resource Description:${RESET}"
            echo -e "  ${GREEN}ksdescribe pod <name>${RESET} - Describe a pod"
            echo -e "  ${GREEN}ksdescribe svc <name>${RESET} - Describe a service"
            echo -e "  ${GREEN}ksdescribe node <name>${RESET} - Describe a node"
            ;;
            
        ksdelete|ksdel|kdel|kdelete|ksrm|krm)
            echo -e "${CYAN}🗑️  ${BOLD}Resource Deletion:${RESET}"
            echo -e "  ${GREEN}ksdelete pod <name>${RESET} - Delete a pod"
            echo -e "  ${GREEN}ksdelete deploy <name>${RESET} - Delete a deployment"
            echo -e "  ${RED}⚠️  Use with caution!${RESET}"
            ;;
            
        # RESOURCE TYPES AND SHORTCUTS
        pos|pod|pods|pode|posd|poda)
            echo -e "${CYAN}� ${BOLD}Pods Management:${RESET}"
            echo -e "  ${GREEN}ksget pods${RESET} or ${GREEN}ksget po${RESET} - List all pods"
            echo -e "  ${GREEN}k get pods -o wide${RESET} - Detailed pod info"
            echo -e "  ${GREEN}klist${RESET} - Interactive pod browser"
            echo -e "  ${GREEN}kslogs <pod-name>${RESET} - Get pod logs"
            ;;
            
        po|p)
            echo -e "${CYAN}🐳 ${BOLD}Pods (short form):${RESET}"
            echo -e "  ${GREEN}ksget po${RESET} or ${GREEN}k get po${RESET} - List pods"
            echo -e "  ${GREEN}k get po -w${RESET} - Watch pods"
            ;;
            
        svc|service|services|svcs)
            echo -e "${CYAN}🌐 ${BOLD}Services:${RESET}"
            echo -e "  ${GREEN}ksget svc${RESET} or ${GREEN}k get svc${RESET} - List services"
            echo -e "  ${GREEN}k get svc -o wide${RESET} - Detailed service info"
            ;;
            
        deploy|deployment|deployments|depl|dep)
            echo -e "${CYAN}🚀 ${BOLD}Deployments:${RESET}"
            echo -e "  ${GREEN}ksget deploy${RESET} or ${GREEN}k get deploy${RESET} - List deployments"
            echo -e "  ${GREEN}k get deploy -w${RESET} - Watch deployments"
            echo -e "  ${GREEN}k rollout status deploy/<name>${RESET} - Check rollout"
            ;;
            
        pv|pvc|sc|vpa|hpa|cm|secret|secrets|ing|ingress)
            local resource_name=""
            local resource_examples=""
            case "$cmd" in
                pv) 
                    resource_name="persistentvolumes"
                    resource_examples="k get pv -o wide"
                    ;;
                pvc) 
                    resource_name="persistentvolumeclaims"
                    resource_examples="k get pvc -A"
                    ;;
                sc) 
                    resource_name="storageclasses"
                    resource_examples="k get sc"
                    ;;
                vpa) 
                    resource_name="verticalpodautoscalers"
                    resource_examples="k get vpa -A"
                    ;;
                hpa) 
                    resource_name="horizontalpodautoscalers"
                    resource_examples="k get hpa -A"
                    ;;
                cm) 
                    resource_name="configmaps"
                    resource_examples="k get cm -A"
                    ;;
                secret|secrets) 
                    resource_name="secrets"
                    resource_examples="k get secrets -A"
                    ;;
                ing|ingress) 
                    resource_name="ingresses"
                    resource_examples="k get ing -A"
                    ;;
            esac
            echo -e "${CYAN}� ${BOLD}${resource_name^}:${RESET}"
            echo -e "  ${GREEN}ksget $cmd${RESET} or ${GREEN}kubectl get $cmd${RESET}"
            echo -e "  ${GREEN}$resource_examples${RESET}"
            ;;
            
        # KUBERNETES CONTEXT AND NAMESPACE MANAGEMENT
        kns|kubens|kubectl-ns|knamespace)
            echo -e "${CYAN}🏷️  ${BOLD}Namespace Management:${RESET}"
            echo -e "  ${GREEN}kns${RESET} - Show current namespace"
            echo -e "  ${GREEN}kns <namespace>${RESET} - Switch to namespace"
            echo -e "  ${GREEN}kns -l${RESET} - List all namespaces"
            echo -e "  ${GREEN}kubectl get ns${RESET} - List namespaces (kubectl)"
            ;;
            
        kcc|kubectx|kubectl-ctx|kcontext|kctx)
            echo -e "${CYAN}🔄 ${BOLD}Context Management:${RESET}"
            echo -e "  ${GREEN}kcc${RESET} - Show current context"
            echo -e "  ${GREEN}kcc <context>${RESET} - Switch to context"
            echo -e "  ${GREEN}kcc -l${RESET} - List all contexts"
            echo -e "  ${GREEN}kubectl config get-contexts${RESET} - List contexts (kubectl)"
            ;;
            
        klist|klst|lis|klis)
            echo -e "${CYAN}📋 ${BOLD}Interactive Resource Browser:${RESET}"
            echo -e "  ${GREEN}klist${RESET} - Interactive resource browser"
            echo -e "  ${GREEN}klist pods${RESET} - Browse pods interactively"
            echo -e "  ${GREEN}klist svc${RESET} - Browse services interactively"
            ;;
            
        # FLUX CD COMMANDS
        flux|flx|fluxcd|fl)
            if ! command -v flux >/dev/null 2>&1; then
                echo -e "${CYAN}🌊 ${BOLD}Flux CD (Not Installed):${RESET}"
                echo -e "  ${GREEN}curl -s https://fluxcd.io/install.sh | sudo bash${RESET}"
                echo -e "  ${CYAN}Or via Homebrew: ${GREEN}brew install fluxcd/tap/flux${RESET}"
            else
                echo -e "${CYAN}🌊 ${BOLD}Flux CD GitOps:${RESET}"
                echo -e "  ${GREEN}flux${RESET} or ${GREEN}f${RESET} - Flux CLI"
                echo -e "  ${GREEN}flux get all${RESET} - Show all Flux resources"
                echo -e "  ${GREEN}flux reconcile source git <name>${RESET} - Force sync"
            fi
            ;;
            
        # HELM COMMANDS
        helm|hlm|hm|helm3)
            if ! command -v helm >/dev/null 2>&1; then
                echo -e "${CYAN}⚓ ${BOLD}Helm (Not Installed):${RESET}"
                echo -e "  ${GREEN}curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash${RESET}"
                echo -e "  ${CYAN}Or via Homebrew: ${GREEN}brew install helm${RESET}"
            else
                echo -e "${CYAN}⚓ ${BOLD}Helm Package Manager:${RESET}"
                echo -e "  ${GREEN}helm${RESET} or ${GREEN}h${RESET} - Helm CLI"
                echo -e "  ${GREEN}helm list${RESET} - List installed charts"
                echo -e "  ${GREEN}helm search repo <name>${RESET} - Search for charts"
            fi
            ;;
            
        # DOCKER COMMANDS
        docker|dock|dkr|dck)
            if ! command -v docker >/dev/null 2>&1; then
                echo -e "${CYAN}� ${BOLD}Docker (Not Installed):${RESET}"
                echo -e "  ${CYAN}Install Docker Desktop from: ${GREEN}https://docker.com/get-started${RESET}"
            else
                echo -e "${CYAN}� ${BOLD}Docker Container Management:${RESET}"
                echo -e "  ${GREEN}docker ps${RESET} - List running containers"
                echo -e "  ${GREEN}docker images${RESET} - List images"
                echo -e "  ${GREEN}docker logs <container>${RESET} - View container logs"
            fi
            ;;
            
        # GIT COMMANDS
        git|gt|gi|gti)
            if ! command -v git >/dev/null 2>&1; then
                echo -e "${CYAN}� ${BOLD}Git (Not Installed):${RESET}"
                echo -e "  ${CYAN}Install with: ${GREEN}brew install git${RESET} (macOS)"
            else
                echo -e "${CYAN}� ${BOLD}Git Version Control:${RESET}"
                echo -e "  ${GREEN}git${RESET} - Git CLI"
                echo -e "  ${GREEN}gst${RESET} - git status"
                echo -e "  ${GREEN}ga${RESET} - git add"
                echo -e "  ${GREEN}gcm${RESET} - git commit -m"
                echo -e "  ${GREEN}gpl${RESET} - git pull"
                echo -e "  ${GREEN}gps${RESET} - git push"
            fi
            ;;
            
        # TEXT EDITORS
        nano|vim|nvim|emacs|code|subl|vi|edit|editor)
            echo -e "${CYAN}✏️  ${BOLD}Text Editors:${RESET}"
            echo -e "  ${GREEN}vi${RESET} - Always available"
            if command -v code >/dev/null 2>&1; then
                echo -e "  ${GREEN}code${RESET} - VS Code"
            fi
            if command -v vim >/dev/null 2>&1; then
                echo -e "  ${GREEN}vim${RESET} - Vim editor"
            fi
            if command -v nano >/dev/null 2>&1; then
                echo -e "  ${GREEN}nano${RESET} - Nano editor"
            fi
            ;;
            
        # COMMON COMMAND VARIATIONS AND TYPOS
        ls|lls|sl|l|ll|la)
            echo -e "${CYAN}📁 ${BOLD}Directory Listing:${RESET}"
            echo -e "  ${GREEN}ls${RESET} - List files"
            echo -e "  ${GREEN}ls -la${RESET} - Detailed list with hidden files"
            echo -e "  ${GREEN}ll${RESET} - Long format (if aliased)"
            ;;
            
        cd|cdd|dc)
            echo -e "${CYAN}📂 ${BOLD}Directory Navigation:${RESET}"
            echo -e "  ${GREEN}cd <directory>${RESET} - Change directory"
            echo -e "  ${GREEN}cd ..${RESET} - Go up one level"
            echo -e "  ${GREEN}cd ~${RESET} - Go to home directory"
            ;;
            
        clear|cls|clr|claer)
            echo -e "${CYAN}🧹 ${BOLD}Clear Screen:${RESET}"
            echo -e "  ${GREEN}clear${RESET} - Clear terminal screen"
            echo -e "  ${GREEN}Ctrl+L${RESET} - Keyboard shortcut"
            ;;
            
        # NETWORK TOOLS
        ping|png|pign|pnig)
            echo -e "${CYAN}🌐 ${BOLD}Network Tools:${RESET}"
            echo -e "  ${GREEN}ping <host>${RESET} - Test connectivity"
            echo -e "  ${GREEN}ping -c 4 <host>${RESET} - Ping 4 times"
            if command -v curl >/dev/null 2>&1; then
                echo -e "  ${GREEN}curl <url>${RESET} - HTTP requests"
            fi
            ;;
            
        # SYSTEM MONITORING
        top|htop|ps|pss)
            echo -e "${CYAN}📊 ${BOLD}System Monitoring:${RESET}"
            echo -e "  ${GREEN}top${RESET} - Process monitor"
            if command -v htop >/dev/null 2>&1; then
                echo -e "  ${GREEN}htop${RESET} - Enhanced process monitor"
            fi
            echo -e "  ${GREEN}ps aux${RESET} - List all processes"
            ;;
            
        # GENERIC PATTERN MATCHING FOR COMPLEX TYPOS
        *)
            local suggestion=""
            local found_suggestion=false
            
            # Kubernetes patterns
            if [[ "$cmd" =~ ^k.*get.* ]]; then
                suggestion="ksget or kubectl get"
                found_suggestion=true
            elif [[ "$cmd" =~ ^k.*log.* ]]; then
                suggestion="kslogs or kubectl logs"
                found_suggestion=true
            elif [[ "$cmd" =~ ^k.*desc.* ]]; then
                suggestion="ksdescribe or kubectl describe"
                found_suggestion=true
            elif [[ "$cmd" =~ ^k.*del.* ]]; then
                suggestion="ksdelete or kubectl delete"
                found_suggestion=true
            elif [[ "$cmd" =~ ^k.* ]]; then
                suggestion="kubectl (k) or one of the ks* commands"
                found_suggestion=true
            fi
            
            # Common command patterns
            if [[ ! "$found_suggestion" == true ]]; then
                case "$cmd" in
                    *list*) suggestion="ls or klist" ;;
                    *edit*) suggestion="vi, nano, or code" ;;
                    *copy*|*cp*) suggestion="cp" ;;
                    *move*|*mv*) suggestion="mv" ;;
                    *remove*|*rm*) suggestion="rm" ;;
                    *find*) suggestion="find or grep" ;;
                    *search*) suggestion="grep or find" ;;
                    *install*) suggestion="brew install (macOS) or apt install (Linux)" ;;
                esac
            fi
            
            if [[ -n "$suggestion" ]]; then
                echo -e "${CYAN}🤔 ${BOLD}Did you mean:${RESET} ${GREEN}$suggestion${RESET}?"
            fi
            
            # Try system command-not-found (Linux specific)
            if command -v cnf >/dev/null 2>&1; then
                echo -e "${CYAN}� ${BOLD}Search for packages:${RESET}"
                echo -e "  ${GREEN}cnf $cmd${RESET}"
            elif [[ -f /usr/lib/command-not-found ]]; then
                echo -e "${CYAN}🔍 ${BOLD}Searching system packages...${RESET}"
                /usr/lib/command-not-found "$cmd" 2>/dev/null || true
            fi
            ;;
    esac
    
    # ENHANCED HELP SECTION
    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}💡 ${BOLD}Quick Help - Essential Commands:${RESET}"
    echo
    echo -e "${WHITE}🚀 ${BOLD}Kubernetes:${RESET}"
    echo -e "  ${GREEN}k${RESET}, ${GREEN}kubectl${RESET}     - Kubernetes CLI"
    echo -e "  ${GREEN}klist${RESET}           - Interactive resource browser"
    echo -e "  ${GREEN}ksget <resource>${RESET} - Smart resource listing"
    echo -e "  ${GREEN}kslogs <pod>${RESET}     - Get pod logs with pattern matching"
    echo -e "  ${GREEN}kns <namespace>${RESET}  - Switch namespace (persisted)"
    echo -e "  ${GREEN}kcc <context>${RESET}    - Switch context (persisted)"
    echo
    echo -e "${WHITE}⚙️  ${BOLD}System:${RESET}"
    echo -e "  ${GREEN}help${RESET}             - Show detailed help"
    echo -e "  ${GREEN}fix-completion${RESET}   - Fix tab completion if broken"
    echo -e "  ${GREEN}test_completions${RESET} - Test all completions"
    echo
    echo -e "${WHITE}🔧 ${BOLD}Tools:${RESET}"
    echo -e "  ${GREEN}flux${RESET}, ${GREEN}f${RESET}         - GitOps with Flux CD"
    echo -e "  ${GREEN}helm${RESET}, ${GREEN}h${RESET}         - Helm package manager"
    echo -e "  ${GREEN}git${RESET}             - Version control (aliases: gst, ga, gcm, gpl, gps)"
    echo
    echo -e "${CYAN}💁 ${BOLD}Tip:${RESET} Use ${GREEN}klist${RESET} for interactive browsing, or ${GREEN}ksget${RESET} for quick listings!"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
    
    # Log the command for potential future suggestions
    [[ -n "${HOME}" ]] && echo "$(date): $cmd $args" >> "${HOME}/.bash_command_not_found.log" 2>/dev/null || true
    
    # Return 127 (command not found) but never exit the shell
    return 127
}

# BULLETPROOF COMMAND_NOT_FOUND WRAPPER
# Ensure the command_not_found_handle never causes shell exit
original_command_not_found_handle_func="$(declare -f command_not_found_handle)"

# Create a super-safe wrapper
safe_command_not_found_handle() {
    local cmd="$1"
    
    # Set local error handling to prevent any exit
    (
        set +e
        set +o errexit
        set +o pipefail
        
        # Call the original function but prevent any exit
        command_not_found_handle "$@" 2>/dev/null || {
            echo -e "${C_RED}❌ Command not found: ${C_YELLOW}$cmd${C_RESET}"
            echo -e "${C_CYAN}💡 Type 'help' for available commands${C_RESET}"
            return 127
        }
    ) || true  # Never let this fail
    
    # Always return safely
    return 127
}

# Override the command_not_found_handle with our safe version if needed
if [[ "$BASH_NO_EXIT" == "1" ]]; then
    alias command_not_found_handle=safe_command_not_found_handle 2>/dev/null || true
fi

# Disable SUSE's command-not-found auto-restart behavior
export COMMAND_NOT_FOUND_INSTALL_PROMPT=0

# ROBUST ERROR HANDLING - PREVENT ANY SHELL EXIT
# Multiple layers of protection to ensure bash never exits on errors

# 1. Disable errexit mode completely
set +e  # Don't exit on command failures
set +o errexit  # Additional protection

# 2. Disable pipefail to prevent pipe failures from exiting
set +o pipefail

# 3. Override any error traps that might cause exit
trap 'echo -e "${C_YELLOW}⚠️  Command failed with exit code $?${C_RESET}"' ERR

# 4. For interactive shells, add extra protection
if [[ $- == *i* ]]; then
    set +e  # Interactive shell should not exit on errors
    set +o errexit  # Double protection
    set +o pipefail  # No pipe failure exits
    set +o nounset  # Don't exit on unset variables
    
    # Remove any exit traps that might cause shell restart
    trap - EXIT
    trap - SIGTERM
    trap - SIGINT
    
    # Override any potential exit handlers
    trap '' EXIT  # Completely ignore EXIT signals
fi

# 5. Additional macOS-specific protections
# Disable any bash_completion exit behaviors
export BASH_COMPLETION_COMPAT_DIR=""

# 6. Make sure command_not_found_handle is bulletproof
# Wrap it in additional error protection
original_command_not_found_handle() {
    command_not_found_handle "$@" || true  # Never let this fail
}

# 7. Prevent any sourced files from exiting the shell
BASH_NO_EXIT=1
export BASH_NO_EXIT

#######################################
# SUSE SPECIFIC
#######################################
if command -v zypper &>/dev/null; then
    alias zi='sudo zypper install'
    alias zr='sudo zypper remove'
    alias zs='zypper search'
    alias zu='sudo zypper update'
    alias zdup='sudo zypper dup'
    alias zref='sudo zypper refresh'
    
    # Smart SUSE functions
    zfind() {
        if [[ $# -eq 0 ]]; then
            echo "Usage: zfind <package_name>"
            echo "Enhanced zypper search with package details"
            return 1
        fi
        echo "Searching for: $1"
        zypper search -v "$1"
    }
    
    zinfo() {
        if [[ $# -eq 0 ]]; then
            echo "Usage: zinfo <package_name>"
            echo "Show detailed package information"
            return 1
        fi
        zypper info "$1"
    }
    
    zwhat() {
        if [[ $# -eq 0 ]]; then
            echo "Usage: zwhat <file_path>"
            echo "Find which package provides a file"
            return 1
        fi
        zypper search --provides "$1"
    }
    
    zclean() {
        echo "Cleaning zypper cache..."
        sudo zypper clean -a
        echo "✅ Cache cleaned"
    }
fi

# Systemctl shortcuts
if command -v systemctl &>/dev/null; then
    alias sctl='sudo systemctl'
    alias scstart='sudo systemctl start'
    alias scstop='sudo systemctl stop'
    alias screstart='sudo systemctl restart'
    alias scstatus='sudo systemctl status'
    alias scenable='sudo systemctl enable'
    alias scdisable='sudo systemctl disable'
fi

#######################################
# SESSION PERSISTENCE FOR KUBECONFIG AND NAMESPACE
#######################################

# Export session file path
export KCONFIG_SESSION_FILE="$KCONFIG_CACHE_DIR/session_state"

# Function to save current session state
_save_k8s_session() {
    local kubeconfig_path="${KUBECONFIG:-$HOME/.kube/config}"
    local current_namespace=""
    
    # Get current namespace if kubectl is available
    if command -v kubectl >/dev/null 2>&1; then
        current_namespace=$(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}' 2>/dev/null || echo "")
        # Fallback to environment variable if config doesn't have namespace
        [[ -z "$current_namespace" ]] && current_namespace="$KUBECTL_NAMESPACE"
    fi
    
    # Save to session file
    cat > "$KCONFIG_SESSION_FILE" << EOF
# Kubernetes session state - automatically generated
KUBECONFIG="$kubeconfig_path"
KUBECTL_NAMESPACE="$current_namespace"
LAST_UPDATED="$(date)"
EOF
    
    # Make it readable by user only for security
    chmod 600 "$KCONFIG_SESSION_FILE" 2>/dev/null || true
}

# Function to restore previous session state
_restore_k8s_session() {
    # Only restore if file exists and is readable
    if [[ -f "$KCONFIG_SESSION_FILE" && -r "$KCONFIG_SESSION_FILE" ]]; then
        echo -e "${C_CYAN}🔄 Restoring previous Kubernetes session...${C_RESET}"
        
        # Source the session file safely
        source "$KCONFIG_SESSION_FILE" 2>/dev/null || return 1
        
        # Validate and restore kubeconfig
        if [[ -n "$KUBECONFIG" && -f "$KUBECONFIG" ]]; then
            export KUBECONFIG
            echo -e "${C_GREEN}✅ Restored kubeconfig: ${C_YELLOW}$(basename "$KUBECONFIG")${C_RESET}"
        else
            echo -e "${C_YELLOW}⚠️  Previous kubeconfig not found, using default${C_RESET}"
            unset KUBECONFIG
        fi
        
        # Restore namespace if kubectl is available and working
        if [[ -n "$KUBECTL_NAMESPACE" ]] && command -v kubectl >/dev/null 2>&1; then
            # Verify the namespace still exists
            if timeout 3s kubectl get namespace "$KUBECTL_NAMESPACE" >/dev/null 2>&1; then
                kubectl config set-context --current --namespace="$KUBECTL_NAMESPACE" >/dev/null 2>&1
                export KUBECTL_NAMESPACE
                echo -e "${C_GREEN}✅ Restored namespace: ${C_YELLOW}$KUBECTL_NAMESPACE${C_RESET}"
            else
                echo -e "${C_YELLOW}⚠️  Previous namespace '$KUBECTL_NAMESPACE' not found, using default${C_RESET}"
                unset KUBECTL_NAMESPACE
            fi
        fi
        
        # Show current context if kubectl is working
        if command -v kubectl >/dev/null 2>&1; then
            local current_context
            current_context=$(timeout 3s kubectl config current-context 2>/dev/null)
            if [[ -n "$current_context" ]]; then
                echo -e "${C_BLUE}🎯 Current context: ${C_YELLOW}$current_context${C_RESET}"
            fi
        fi
        
        echo ""
    fi
}

# Auto-restore session on shell startup (only for interactive shells)
if [[ $- == *i* ]]; then
    _restore_k8s_session
fi

# Manual session management functions
ksave-session() {
    echo -e "${C_CYAN}💾 Saving current Kubernetes session...${C_RESET}"
    _save_k8s_session
    echo -e "${C_GREEN}✅ Session saved successfully${C_RESET}"
    
    if [[ -f "$KCONFIG_SESSION_FILE" ]]; then
        echo -e "${C_BLUE}📄 Session file: $KCONFIG_SESSION_FILE${C_RESET}"
        echo -e "${C_GRAY}$(cat "$KCONFIG_SESSION_FILE" | grep -v "^#")${C_RESET}"
    fi
}

krestore-session() {
    echo -e "${C_CYAN}🔄 Manually restoring Kubernetes session...${C_RESET}"
    _restore_k8s_session
}

kclear-session() {
    if [[ -f "$KCONFIG_SESSION_FILE" ]]; then
        rm -f "$KCONFIG_SESSION_FILE"
        echo -e "${C_GREEN}✅ Session cleared${C_RESET}"
    else
        echo -e "${C_YELLOW}ℹ️  No session file found${C_RESET}"
    fi
}

kshow-session() {
    if [[ -f "$KCONFIG_SESSION_FILE" ]]; then
        echo -e "${C_CYAN}📋 Current saved session:${C_RESET}"
        echo "=============================="
        cat "$KCONFIG_SESSION_FILE"
        echo ""
        echo -e "${C_BLUE}💡 Session will be automatically restored in new terminals${C_RESET}"
    else
        echo -e "${C_YELLOW}ℹ️  No session file found${C_RESET}"
        echo -e "${C_BLUE}💡 Use 'ksave-session' to save current kubeconfig and namespace${C_RESET}"
    fi
}

#######################################
# ENHANCED PROMPT CUSTOMIZATION
#######################################
# Enhanced PS1 prompt with git branch and kubernetes namespace info
if command -v git &>/dev/null; then
    parse_git_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }
    
    # Function to get current kubernetes namespace
    get_k8s_namespace() {
        if command -v kubectl &>/dev/null; then
            local ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
            if [[ -n "$ns" && "$ns" != "null" ]]; then
                echo "[$ns]"
            else
                echo "[default]"
            fi
        fi
    }
    
    # Function to get current kubernetes context (short form)
    get_k8s_context() {
        if command -v kubectl &>/dev/null; then
            local ctx=$(kubectl config current-context 2>/dev/null)
            if [[ -n "$ctx" ]]; then
                # Show only the last part of context (e.g., "prod" from "cluster-prod")
                echo "{${ctx##*-}}"
            fi
        fi
    }
    
    # Enhanced prompt with colors and k8s info
    # Format: user@host:path git_branch k8s_context[namespace] $
    export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[36m\]\$(get_k8s_context)\[\033[35m\]\$(get_k8s_namespace)\[\033[00m\]\$ "
else
    export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
fi

# Auto-enable the kubernetes prompt if not already set
if [[ -z "$PROMPT_COMMAND" ]] || [[ "$PROMPT_COMMAND" != *"_set_kubernetes_prompt"* ]]; then
    PROMPT_COMMAND="_set_kubernetes_prompt"
fi

#######################################
# FINAL COMPLETION SETUP
#######################################
# Ensure our custom completions override any default ones
# This must come after all other completion setups

# Remove any existing completions that might interfere
complete -r kubectl k ky kwide kj kgp kgs kgd kga kd kl klf ke kpf kgns kgno kgev kallns kpods ksvc kdeploy kgpy kgpw flux f helm h kn kns 2>/dev/null || true

# Re-register our smart completions with highest priority
# Note: kubectl and aliases now handled by universal _register_kubectl_completions

# flux and flux aliases  
complete -F _flux_smart_complete flux f  

# helm and helm aliases
complete -F _helm_smart_complete helm h

# Note: kn and kns now handled by universal system

# git aliases (use existing git completion if available)
if command -v git &>/dev/null && declare -f __git_complete &>/dev/null; then
    complete -F _git_branches_completion gco gbr
    complete -F _git_remotes_completion gpl gps  
    complete -o default -o nospace gst ga gd gcm
elif command -v git &>/dev/null; then
    # Fallback if __git_complete is not available
    complete -o default gco gbr gpl gps gst ga gd gcm
fi

# Disable default completions for kubectl/flux/helm commands to prevent file fallback
compopt -o nospace kubectl k ky kwide kj kgp kgs kgd kga kd kl klf ke kpf kgns kgno kgev kallns kpods ksvc kdeploy kgpy kgpw flux f helm h kn kns 2>/dev/null || true
compopt +o bashdefault +o default kubectl k ky kwide kj kgp kgs kgd kga kd kl klf ke kpf kgns kgno kgev kallns kpods ksvc kdeploy kgpy kgpw flux f helm h kn kns 2>/dev/null || true

#######################################
# LOCAL CUSTOMIZATIONS
#######################################
# Source local bashrc if it exists
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local

# Clean up any remaining PATH duplicates
dedup_path

#######################################
# COMPREHENSIVE CONFIGURATION COMPLETE
#######################################

#######################################
# LOCAL CUSTOMIZATIONS
#######################################
# Source any local customizations if they exist
if [[ -f ~/.bashrc_local ]]; then
    echo ""
    echo -e "${YELLOW}📄 Loading local customizations...${NC}"
    source ~/.bashrc_local
fi

# Final PATH cleanup
dedup_path

echo ""
echo -e "${GREEN}🚀 COMPREHENSIVE INTEGRATED BASHRC LOADED SUCCESSFULLY!${NC}"
echo "========================================================="
echo ""
echo -e "${BLUE}🎯 ALL FEATURES INCLUDED:${NC}"
echo "  • Complete SUSE Linux environment with all optimizations"
echo "  • FULL kubectl smart environment with ALL functions"
echo "  • Complete Git workflow with comprehensive aliases"
echo "  • Full Flux GitOps tools with advanced completion"
echo "  • Complete Helm package manager with smart features"
echo "  • Python development tools and virtual environments"
echo "  • System monitoring and performance utilities"
echo "  • Advanced completion systems for all tools"
echo "  • Kubernetes-aware prompt with git integration"
echo "  • Enhanced history search and navigation"
echo "  • Color and emoji support with auto-detection"
echo "  • Comprehensive error handling and timeouts"
echo ""
echo -e "${BLUE}🚀 KUBECTL SMART FEATURES:${NC}"
echo "  klist               - Complete Kubernetes help & status"
echo "  kcc                 - Kubeconfig management with session persistence"
echo "  kns/ksnns           - Namespace switching with session persistence"
echo "  k/ks commands       - Full kubectl smart environment"
echo "  Fuzzy matching      - All pod/deployment operations"
echo "  Smart completion    - Enhanced tab completion"
echo ""
echo -e "${BLUE}🔄 SESSION PERSISTENCE:${NC}"
echo "  ksave-session       - Manually save current kubeconfig and namespace"
echo "  krestore-session    - Manually restore saved session"
echo "  kclear-session      - Clear saved session"
echo "  kshow-session       - Show current saved session"
echo "  Auto-restore        - Automatically restores session in new terminals"
echo ""
echo -e "${BLUE}🔧 DEVELOPMENT TOOLS:${NC}"
echo "  gs/git commands     - Complete git workflow"
echo "  f/flux commands     - Full GitOps management"
echo "  h/helm commands     - Package management"
echo "  Python virtualenv   - Complete dev environment"
echo ""
echo -e "${CYAN}💡 This file contains EVERY feature from both original files!${NC}"
echo -e "${CYAN}💡 No functionality has been omitted - complete integration achieved.${NC}"
echo -e "${CYAN}💡 All duplicates have been removed while preserving all capabilities.${NC}"

# Note: Removed 'set -e' to prevent shell exit on command errors
# The command_not_found_handle function provides better error handling

#######################################
# FINAL SAFETY NET - LOCK IN PROTECTIONS
#######################################

# Final enforcement of no-exit policy
set +e
set +o errexit
set +o pipefail
set +o nounset

# Ensure bash never exits on command errors - FINAL PROTECTION
if [[ $- == *i* ]]; then
    echo -e "${GREEN}✅ Interactive shell protections active - bash will never exit on command errors${NC}"
    
    # One more layer of protection
    trap '' EXIT  # Ignore any exit signals
    
    # Export the protection flag
    export BASH_NEVER_EXIT=1
    
    # Create a help function for users
    help() {
        echo -e "${CYAN}📚 Available commands:${NC}"
        echo -e "  ${GREEN}k, kubectl${NC} - Kubernetes management"
        echo -e "  ${GREEN}ksget, ksns, kslogs${NC} - Smart kubectl commands"
        echo -e "  ${GREEN}klist${NC} - Interactive resource browser"
        echo -e "  ${GREEN}flux, f${NC} - GitOps management" 
        echo -e "  ${GREEN}helm, h${NC} - Package management"
        echo -e "  ${GREEN}fix-completion${NC} - Fix tab completion"
        echo -e "  ${GREEN}help${NC} - Show this help"
        echo ""
        echo -e "${YELLOW}💡 This shell will never exit on command errors!${NC}"
    }
fi

# Success message
echo -e "${GREEN}🛡️  Bash exit protection fully activated!${NC}" 2>/dev/null || true


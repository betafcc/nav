csi() {
    local CSI="${CSI:-\e[}"
    case "${1}" in
    cuu | cursor-up) echo -ne "${CSI}${2:-1}A" ;;
    cud | cursor-down) echo -ne "${CSI}${2:-1}B" ;;
    cuf | cursor-forward) echo -ne "${CSI}${2:-1}C" ;;
    cub | cursor-back) echo -ne "${CSI}${2:-1}D" ;;
    cnl | cursor-next-line) echo -ne "${CSI}${2:-1}E" ;;
    cpl | cursor-previous-line) echo -ne "${CSI}${2:-1}F" ;;
    cha | cursor-horizontal-absolute) echo -ne "${CSI}${2:-1}G" ;;

    move | cup | cursor-position) echo -ne "${CSI}${2:-1};${3:-1}H" ;;
    clear | ed | erase-in-display) echo -ne "${CSI}${2:-0}J" ;;
    kill | el | erase-in-line) echo -ne "${CSI}${2:-0}K" ;;

    su | scroll-up) echo -ne "${CSI}${2:-1}S" ;;
    sd | scroll-down) echo -ne "${CSI}${2:-1}T" ;;
    hvp | horizontal-vertical-position) echo -ne "${CSI}${2:-1};${3:-1}f" ;;
    sgr | select-graphic-rendition) echo -ne "${CSI}${2:-0}m" ;;
    dsr | device-status-report) echo -ne "${CSI}6n" ;;

    save | scp | save-current-cursor-position) echo -ne "${CSI}s" ;;
    restore | rcp | restore-saved-cursor-position) echo -ne "${CSI}u" ;;
    esac
}

overlay() {
    local message="${1}"
    local timeout="${2:-1}"
    local row="${3:-1}"
    local start_col=$((($(tput cols) / 2) - (${#message} / 2)))

    csi save
    csi move ${row} ${start_col}

    csi kill

    echo -ne "\e[1m${message}\e[0m"

    csi restore

    sleep $timeout

    csi save
    csi move ${row} ${start_col}
    csi kill
    csi restore
}

# PS1 with line break for the top overlay be centered and not disturbed by fzf
PS1="%~ ❱ "
source "${HOME}/Desktop/projects/nav/nav.zsh"

message_row=6

_loc-up() {
    overlay '[ alt + ↑ ] - up a folder' 1 "${message_row}"
    clear

    _loc-up() {
        overlay '[ alt + ↑ ] - up a folder' 0.3 "${message_row}"
        clear
        _nav-up
    }

    _nav-up
}

_loc-down() {
    overlay '[ alt + ↓ ] - fuzzy find folder' 1 "${message_row}"
    clear
    _loc-down() {
        overlay '[ alt + ↓ ] - fuzzy find folder' 0.3 "${message_row}"
        clear
        _nav-down
    }

    _nav-down
}

_loc-back() {
    overlay '[ alt + ← ] - dir history back' 0.5 "${message_row}"
    clear
    _nav-back
}

_loc-forward() {
    overlay '[ alt + → ] - dir history forward' 0.5 "${message_row}"
    clear
    _nav-forward
}

_loc-prompt-stays() {
    overlay '↖ prompt stays in place' 2 2

    _loc-up() {
        overlay '[ alt + ↑ ]' 0.3 "${message_row}"
        clear
        _nav-up
    }

    _loc-down() {
        overlay '[ alt + ↓ ]' 0.3 "${message_row}"
        clear
        _nav-down
    }

    _loc-back() {
        overlay '[ alt + ← ]' 0.3 "${message_row}"
        clear
        _nav-back
    }

    _loc-forward() {
        overlay '[ alt + → ]' 0.3 "${message_row}"
        clear
        _nav-forward
    }
}

_loc-preserve-command() {
    overlay 'preserves command ↗' 2 2
}

zle -N _loc-prompt-stays && bindkey '^Z' _loc-prompt-stays
zle -N _loc-preserve-command && bindkey '^X' _loc-preserve-command

zle -N loc-up _loc-up && bindkey '^[[1;5A' loc-up             # cmd + up
zle -N loc-down _loc-down && bindkey '^[[1;5B' loc-down       # cmd + down
zle -N loc-back _loc-back && bindkey '^[[1;5C' loc-forward    # cmd + right
zle -N loc-forward _loc-forward && bindkey '^[[1;5D' loc-back # cmd + left

nav() {
    local command="${1:-help}"

    case "${command}" in
    bindkeys)
        bindkey '^[[1;9A' nav-up      # alt + up
        bindkey '^[[1;9B' nav-down    # alt + down
        bindkey '^[[1;9C' nav-forward # alt + right
        bindkey '^[[1;9D' nav-back    # alt + left
        ;;

    history)
        local dir
        local i=1
        for dir in "${_nav_history[@]}"; do
            if [ $i -eq $_nav_index ]; then
                printf '\033[1;32m%q\033[0m\n' "${dir}"
            else
                printf '%q\n' "${dir}"
            fi
            i=$((i + 1))
        done
        ;;

    push)
        local path="${2:-$PWD}"
        if [ "${#_nav_history[@]}" -eq 0 ] || [ "${path}" != "${_nav_history[-1]}" ]; then
            _nav_history=(${_nav_history[@]:0:$_nav_index})
            _nav_history+=(${path})
            _nav_index=$((${#_nav_history[@]}))
        fi
        ;;

    back)
        [[ $_nav_index -gt 1 ]] && _nav_index=$((_nav_index - 1))
        _nav_push=false
        cd "${_nav_history[$_nav_index]}"
        ;;

    forward)
        [[ $_nav_index -lt ${#_nav_history[@]} ]] && _nav_index=$((_nav_index + 1))
        _nav_push=false
        cd "${_nav_history[$_nav_index]}"
        ;;
    *)
        echo "Usage:"
        echo "    nav bindkeys"
        echo "    nav history"
        ;;
    esac
}

_nav_precmd() {
    if [ "$_nav_push" = true ] && [ "$PWD" != "$_nav_history[$_nav_index]" ]; then
        nav push
    else
        _nav_push=true
    fi
}

_nav-up() {
    cd ..
    nav push
    zle reset-prompt
}

_nav-down() {
    print -n "\r"
    eval $(_nav-descend)
    nav push
    zle reset-prompt
}

_nav-back() {
    nav back
    zle reset-prompt
}

_nav-forward() {
    nav forward
    zle reset-prompt
}

_nav-descend() {
    local fzf_prompt preview_cmd selected
    case "${PWD}" in
    '/') fzf_prompt='/' ;;
    "${HOME}") fzf_prompt='~/' ;;
    "${HOME}/"*) fzf_prompt='./' ;;
    *) fzf_prompt="${PWD}/" ;;
    esac

    selected=$(
        eval "${NAV_FIND_COMMAND}" |
            sed 's:$:/:' |
            fzf --prompt "${fzf_prompt}" --query "" --info hidden --filepath-word \
                --height 80% --layout reverse --preview "${NAV_PREVIEW_COMMAND}" --preview-window 'right:60%' \
                --color 'light' --color 'gutter:-1,bg+:#ff6666,fg+:-1:bold,hl:#66ff66:bold' \
                --no-sort --tiebreak=index --no-multi --bind 'tab:replace-query+top,shift-tab:backward-kill-word+top'
    )
    [ -z "${selected}" ] && printf '' || printf 'cd %q\n' "${fzf_prompt/#\~/${HOME}}${selected}"
}

typeset -g -a _nav_history=()
typeset -g _nav_index=0
typeset -g _nav_push=true

if [[ ! -v NAV_PREVIEW_COMMAND ]]; then
    typeset -g NAV_PREVIEW_COMMAND
    if command -v eza >/dev/null 2>&1; then
        NAV_PREVIEW_COMMAND="eza --color=always --group-directories-first --all --icons --oneline {}"
    else
        NAV_PREVIEW_COMMAND="ls -1A {}"
    fi
fi

if [[ ! -v NAV_FIND_COMMAND ]]; then
    typeset -g NAV_FIND_COMMAND
    if command -v bfs >/dev/null 2>&1; then
        NAV_FIND_COMMAND="bfs -x -type d -exclude -name '.git' -exclude -name 'node_modules' 2>/dev/null"
    else
        NAV_FIND_COMMAND="find . -type d \( ! -name '.git' -a ! -name 'node_modules' \) 2>/dev/null"
    fi
fi

nav push

autoload -U add-zsh-hook && add-zsh-hook precmd _nav_precmd

zle -N nav-up _nav-up
zle -N nav-down _nav-down
zle -N nav-back _nav-back
zle -N nav-forward _nav-forward

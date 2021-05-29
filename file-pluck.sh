#!/bin/bash

file-pluck() {
    cache_root='/tmp/gitpicker'
    case "$1" in
        --reset|-r)
            rm -rf "$cache_root/*"
            return 0
            ;;
        --clean|-c)
            target="$(git rev-parse --verify "$2" 2>/dev/null)"
            cache="$cache_root/$(basename `git rev-parse --show-toplevel`)/$(git branch --show-current)/$target"
            rm -rf "$cache"
            ;;
        *)
            target="$(git rev-parse --verify "$1" 2>/dev/null)"
            cache="$cache_root/$(basename `git rev-parse --show-toplevel`)/$(git branch --show-current)/$target"
            ;;
    esac

    [ -z "$target" ] && echo "error: pathspec '$1' did not match any destination known to git" && return 1  # fail fast

    mkdir -p "$cache" # /tmp/gitpicker/{repo}/{branch}/{target}

    index="$(git diff-index --diff-filter=a --find-copies --find-renames --summary "$target")"
    if [ ! -f "$cache/files" ] || [ ! -f "$cache/index" ] || [[ $(< "$cache/index") != "$index" ]]; then
        echo $index > "$cache/index"
        printf "%s\n" "$(echo $index | perl -ne 's/^ (?:(?:rename|copy) ((.*?){)?(.+?) => (.+)(?(1)}(.*)|) \(\d+%\)|\w+ mode \d+ (.*))$/$6\t$2$3$5\t$2$4$5/; print ($6 ? "$6\n" : "$2$3$5\t$2$4$5\n")')" > "$cache/files"
    fi

    selected=( $( echo "$index" | fzf -m --preview "git diff $target --color=always -- \$( sed \"\$(( {n} + 1 ))q;d\" '$cache/files' )" ) ) || return 1  # fail if fzf was interrupted/exited

    echo "restored:"
    for line in "$selected";
    do
        file="$( sed "$(awk 'match($0,v){print NR; exit}' v=$line "$cache/index")q;d" "$cache/files" | cut -f1 )"
        git restore --source="$target" --merge -- "$file"
        git add -N "$file"
        echo "  $file"
    done
}

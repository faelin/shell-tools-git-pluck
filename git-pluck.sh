#!/bin/bash

git-pluck() {
	cache_root='/tmp/git-pluck'
	case "$1" in
		--help)
			cat <<-EOF
			Command line tool to pluck files from any branch or commit within your git repo, and add them to the current working tree.

			    git-pluck <branch|commit>
			    # Select files from a branch or commit.
			    # If a plucked file conflicts with an existing file, changes will be merged.

			    git-pluck --clean <branch>
			    # As above, but with a clean cache.

			    git-pluck --reset
			    # Completely clear the git-pluck cache

			Plucked files are automatically tracked (but not staged).   
			EOF
			return 0
			;;
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

	mkdir -p "$cache" # /tmp/git-pluck/{repo}/{branch}/{target}

	index="$(git diff-index --diff-filter=a --find-copies --find-renames --summary "$target")"
	if [ ! -f "$cache/files" ] || [ ! -f "$cache/index" ] || [[ $(< "$cache/index") != "$index" ]]; then
		echo $index > "$cache/index"
		printf "%s\n" "$(echo $index | perl -pe 's/^ (?:(?:rename|copy) ((.*?){)?(.+?) => (.+)(?(1)}(.*)|) \(\d+%\)|\w+ mode \d+ (.*))$/$6\t$2$3$5\t$2$4$5/;')" > "$cache/files"
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

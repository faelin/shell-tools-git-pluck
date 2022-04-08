# git-pluck
Command line tool to pluck files from any branch or commit within your git repo. Plucked files are added to the current working tree. If a plucked file conflicts with an existing file, changes will be merged.

Plucked files are automatically tracked (but not staged).

Change-trees are cached for expediency.

## usage

```
git-pluck [options] [branch] [commit|files...]
# cherry-pick the indicated commit or files from the specified branch and add them to the working tree
#
# OPTIONS:
# -i,--interactive  #TODO
#
#       enters an interactive search utility to visualize changes
#         - if an entire commit is selected, all changes will be shown in diff format
#         - after selecting a commit, specific filestates at that commit can be selected
#           to apply only the changes for that specific file

git-pluck --clean <branch>
# as above, but with a clean cache.

git-pluck --reset
# completely clear the git-pluck cache
```

## installation

Currently, git-pluck must be installed manually through `git clone`.

## dependencies

Requires [fzf](https://github.com/junegunn/fzf)

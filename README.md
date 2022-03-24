# git-pluck
Command line tool to pluck files from any branch or commit within your git repo. Plucked files are added to the current working tree. If a plucked file conflicts with an existing file, changes will be merged.

Plucked files are automatically tracked (but not staged).

## usage

```
git-pluck <branch|commit>
# select files from a branch or commit

git-pluck --clean <branch>
# as above, but with a clean cache.

git-pluck --reset
# completely clear the git-pluck cache
```

## installation

Currently, git-pluck must be installed manually through `git clone`.

## dependencies

Requires [fzf](https://github.com/junegunn/fzf)

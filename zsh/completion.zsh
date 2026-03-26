# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# highlight selected item in completion menu
zstyle ':completion:*' menu select

# color directories, files, etc. using LS_COLORS
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

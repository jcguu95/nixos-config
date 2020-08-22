set bg=light
set clipboard+=unnamedplus
set number relativenumber
set nocompatible
syntax on

autocmd BufWritePre * %s/\s\+$//e

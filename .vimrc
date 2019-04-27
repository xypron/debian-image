filetype on
set viminfo='20,f1,<1000
set mouse=
set showmode
set showcmd
set shortmess+=r
set wrap
set shiftwidth=8
set tabstop=8
set shiftround
set noexpandtab
set autoindent
set number
syntax on

" Remap arrow keys (enter escape sequence via CTRL-V ESC)
map! OA ka
map! OB ja
map! OC la
map! OD ha

" Git commit: text width  75 characters, enable spell check
autocmd FileType gitcommit set spell|set tw=75

" PEM 8 requires four spaces indention for Python
autocmd FileType python set tabstop=4|set shiftwidth=4|set expandtab

" Mark trailing spaces, use nbsp for tab (enter via CTRL-K space space)
set listchars=tab:  ,trail:·
set list

" Mark letters in column 81
highlight ColorColumn ctermbg=brown
call matchadd('ColorColumn', '\%81v', 100)

" Default spell language
set spelllang=en_us
highlight SpellBad ctermbg=blue ctermfg=white
highlight SpellCap ctermbg=blue ctermfg=white
highlight SpellRare ctermbg=blue ctermfg=white
highlight SpellLocal ctermbg=blue ctermfg=white

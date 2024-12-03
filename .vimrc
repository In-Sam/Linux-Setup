set ruler
set nu
set cindent
set hlsearch
set showmatch
set laststatus=2

if has("syntax")
 syntax on
endif

nnoremap q <c-v>
nnoremap j h
nnoremap k j
nnoremap l k
nnoremap ; l

colorscheme PaperColor

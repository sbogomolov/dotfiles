" Plugins
call plug#begin()
    Plug 'preservim/nerdtree'
call plug#end()

" NERDTree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTreeToggle<CR>

" Indentation settings
set tabstop=8
set softtabstop=0
set expandtab
set shiftwidth=4
set smarttab
set autoindent

" Always start on first line of git commit message
autocmd FileType gitcommit call setpos('.', [0, 1, 1, 0])

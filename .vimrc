syntax on

set number

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" https://github.com/junegunn/vim-plug
" Specify a directory for plugins
call plug#begin('~/.vim/plugged')

Plug 'sirver/ultisnips'
    let g:UltiSnipsExpandTrigger = '<tab>'
    let g:UltiSnipsJumpForwardTrigger = '<tab>'
    let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

Plug 'lervag/vimtex'
    let g:tex_flavor='latex'
    let g:vimtex_view_method='skim'
    let g:vimtex_quickfix_mode=0

Plug 'KeitaNakamura/tex-conceal.vim'
    set conceallevel=1
    let g:tex_conceal='abdmg'
    hi Conceal ctermbg=none

setlocal spell
set spelllang=en_us
"inoremap <C-s> <c-g>u<Esc>[s1z=`]a<c-g>u

imap <C-s> <c-g>u<Esc>[s1z=`]a<c-g>u
nmap <C-s> [s1z=<c-o>

set
   rtp^="/Users/geo/.opam/default/share/ocp-indent/vim"

" Initialize plugin system
call plug#end()

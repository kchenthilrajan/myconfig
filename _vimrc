set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

set ignorecase
set hlsearch
set smartcase
set incsearch

" I like highlighting strings inside C comments
let c_comment_strings=1

" Switch on syntax highlighting if it wasn't on yet.
if !exists("syntax_on")
syntax on
endif

" Switch on search pattern highlighting.
set hlsearch

set number
au GUIEnter * simalt ~x
color corporation
set cursorline
hi CursorLine   cterm=NONE ctermbg=darkred ctermfg=white
augroup CursorLine
au!
au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
au WinLeave * setlocal nocursorline
augroup END

set wildchar=<Tab> wildmenu wildmode=full

if has("gui_running")
if has("gui_gtk2")
set guifont=Inconsolata\ 10
elseif has("gui_win32")
set guifont=Consolas:h10:cANSI
endif
endif

set diffexpr=MyDiff()
function MyDiff()
let opt = '-a --binary '
if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
let arg1 = v:fname_in
if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
let arg2 = v:fname_new
if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
let arg3 = v:fname_out
if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
let eq = ''
if $VIMRUNTIME =~ ' '
if &sh =~ '\<cmd'
let cmd = '""' . $VIMRUNTIME . '\diff"'
let eq = '"'
else
let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
endif
else
let cmd = $VIMRUNTIME . '\diff'
endif
silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction
" disable arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>
set ignorecase

function! MarkWindowSwap()
let g:markedWinNum = winnr()
endfunction

function! DoWindowSwap()
"Mark destination
let curNum = winnr()
let curBuf = bufnr( "%" )
exe g:markedWinNum . "wincmd w"
"Switch to source and shuffle dest->source
let markedBuf = bufnr( "%" )
"Hide and open so that we aren't prompted and keep history
exe 'hide buf' curBuf
"Switch to dest and shuffle source->dest
exe curNum . "wincmd w"
"Hide and open so that we aren't prompted and keep history
exe 'hide buf' markedBuf
endfunction
set nocompatible   " Disable vi-compatibility
set laststatus=2   " Always show the statusline
set encoding=utf-8 " Necessary to show Unicode glyphs
call pathogen#infect()
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=10      "deepest fold is 10 levels
set nofoldenable        "dont fold by default
set foldlevel=1         "this is just what i use

" use 4 spaces for tabs
set tabstop=4 softtabstop=4 shiftwidth=4

" display indentation guides
set list listchars=tab:❘-,trail:·,extends:»,precedes:«,nbsp:×

" convert spaces to tabs when reading file
autocmd! bufreadpost * set noexpandtab | retab! 4

" convert tabs to spaces before writing file
autocmd! bufwritepre * set expandtab | retab! 4

" convert spaces to tabs after writing file (to show guides again)
autocmd! bufwritepost * set noexpandtab | retab! 4
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
"change buffer
nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>



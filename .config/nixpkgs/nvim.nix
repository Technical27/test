''
set number
set hidden
set nobackup
set nowritebackup
set updatetime=100
set shortmess+=c
set signcolumn=yes
set ignorecase
set smartcase

set encoding=utf-8

set foldmethod=syntax
set foldnestmax=10
set foldlevel=2
set nofoldenable

set lazyredraw
set synmaxcol=180

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smarttab
set clipboard+=unnamedplus
set re=2

set termguicolors

set showmatch

set mouse=a

set undofile

set background=dark

let g:AutoPairsFlyMode    = 1
let g:lion_squeeze_spaces = 1
let g:gruvbox_italic      = 1

let g:coc_global_extensions = [
  \'coc-json',
  \'coc-css',
  \'coc-html',
  \'coc-lists',
  \'coc-snippets',
  \'coc-syntax',
  \'coc-emoji',
  \'coc-git',
  \'coc-rust-analyzer',
  \'coc-prettier',
  \'coc-tsserver',
  \'coc-tabnine',
  \'coc-eslint',
  \]

let g:airline#extensions#tabline#enabled     = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline_powerline_fonts                = 1
let g:airline#extensions#tabline#formatter   = 'unique_tail_improved'

fun! Fzf_dev()
  let s:fzf_files_options =
        \'--preview "bat --theme="OneHalfDark" --style=numbers,changes --color always {2..-1} | head -'.&lines.'"'
  let s:fzf_command = 'rg --files --hidden --follow --glob "!{.git,build,node_modules,target}"'

  fun! s:get_open_files()
    let l:buffers = map(filter(copy(getbufinfo()), 'v:val.listed'), 'v:val.name')
    let l:len = len(fnamemodify(".", ":p"))
    return map(l:buffers, 'v:val[l:len:]')
  endf

  fun! s:files()
    let l:buffers = s:get_open_files()
    let l:files = filter(split(system(s:fzf_command), '\n'), 'index(l:buffers, v:val) == -1')
    return s:prepend_icon(l:files)
  endf

  fun! s:prepend_icon(candidates)
    let l:result = []
    for l:candidate in a:candidates
      if filereadable(l:candidate)
        let l:filename = fnamemodify(l:candidate, ':p:t')
        let l:icon = WebDevIconsGetFileTypeSymbol(l:filename, isdirectory(l:filename))
        call add(l:result, printf('%s %s', l:icon, l:candidate))
      endif
    endfor

    return l:result
  endf

  fun! s:edit_file(item)
    let l:pos = stridx(a:item, ' ')
    let l:file_path = a:item[pos+1:-1]
    execute 'silent e' l:file_path
  endf

 call fzf#run({
       \ 'source' : <sid>files(),
       \ 'sink'   : function('s:edit_file'),
       \ 'options': '--color bg+:-1 -m ' . s:fzf_files_options,
       \ 'down'   : '40%' })
endf

fun! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endf

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap T :bprev<CR>
nnoremap Y :bnext<CR>

nnoremap <C-u> :UndotreeToggle<CR>

nnoremap <silent> <C-p> :call Fzf_dev()<CR>

inoremap <silent><expr> <c-space> coc#refresh()

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

noremap <right> <C-w>l
noremap <left>  <C-w>h
noremap <down>  <C-w>j
noremap <up>    <C-w>k

" clear whitespace on save
fun! TrimWhitespace ()
  let l:save = winsaveview()
  %s/\\\@<!\s\+$//e
  call winrestview(l:save)
endf

augroup ClearWhitespace
  autocmd BufWritePre * call TrimWhitespace()
augroup end

colorscheme gruvbox

hi clear SignColumn

hi! link CocErrorSign   GruvboxRed
hi! link CocWarningSign GruvboxOrange
hi! link CocInfoSign    GruvboxYellow

''
# vim: set ft=vim:

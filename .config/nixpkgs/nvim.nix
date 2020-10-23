# vim: set ft=vim:
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
set title
set foldmethod=syntax
set foldnestmax=10
set nofoldenable
set lazyredraw
set synmaxcol=180
set tabstop=2
set shiftwidth=2
set linebreak
set expandtab
set clipboard=unnamedplus
set termguicolors
set showmatch
set mouse=a
set undofile
set background=dark

let g:lion_squeeze_spaces = 1
let g:gruvbox_italic      = 1

let g:airline#extensions#tabline#enabled     = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline_powerline_fonts                = 1
let g:airline#extensions#tabline#formatter   = 'unique_tail_improved'

if ($TERM == "xterm-kitty")
  let g:coc_snippet_next = '<S-CR>'
else
  let g:coc_snippet_next = '<M-CR>'
endif

function! Fzf_dev() abort
  let s:fzf_files_options =
        \'--preview "bat --theme="OneHalfDark" --style=numbers,changes --color always {2..-1} | head -'.&lines.'"'
  let s:fzf_command = 'rg --files --hidden --follow --glob "!{.git,build,node_modules,target}"'

  function! s:get_open_files() abort
    let l:buffers = map(filter(copy(getbufinfo()), 'v:val.listed'), 'v:val.name')
    let l:len = len(fnamemodify(".", ":p"))
    return map(l:buffers, 'v:val[l:len:]')
  endf

  function! s:files() abort
    let l:buffers = s:get_open_files()
    let l:files = filter(split(system(s:fzf_command), '\n'), 'index(l:buffers, v:val) == -1')
    return s:prepend_icon(l:files)
  endf

  function! s:prepend_icon(candidates) abort
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

  function! s:edit_file(item) abort
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

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endf

function! s:show_documentation() abort
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endf

" clear whitespace on save
function! TrimWhitespace() abort
  let l:save = winsaveview()
  %s/\\\@<!\s\+$//e
  call winrestview(l:save)
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

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
nnoremap <silent> K :call <SID>show_documentation()<CR>

" I will probably never record a macro
nnoremap q <nop>

augroup Buffer
  autocmd!
  autocmd BufWritePre * call TrimWhitespace()
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup end

augroup Color
  autocmd!
  autocmd ColorScheme * hi clear SignColumn
                    \ | hi link CocErrorSign GruvboxRed
                    \ | hi link CocWarningSign GruvboxOrange
                    \ | hi link CocInfoSign GruvboxYellow
augroup end

nmap f <Plug>(coc-smartf-forward)
nmap F <Plug>(coc-smartf-backward)
nmap ; <Plug>(coc-smartf-repeat)
nmap , <Plug>(coc-smartf-repeat-opposite)

augroup Smartf
  autocmd!
  autocmd User SmartfEnter :hi link Conceal GruvboxAqua
  autocmd User SmartfLeave :hi link Conceal GruvboxGray
augroup end

colorscheme gruvbox
''

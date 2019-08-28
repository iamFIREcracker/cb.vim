if exists("g:loaded_cb")
  finish
endif
let g:loaded_cb = 1

if !exists('g:cb_copy_prg')
  let g:cb_copy_prg = 'cb'
endif
if !exists('g:cb_paste_prg')
  let g:cb_paste_prg = 'cb --force-paste'
endif

function! s:error(msg) abort "{{{
  echohl ErrorMsg | echomsg 'Clipboard: ' . a:msg | echohl None
endf "}}}

function! s:copyselection(selection) abort "{{{
  let job_cmd = [g:cb_copy_prg]
  let jobid = async#job#start(job_cmd, {})
  if jobid <= 0
    call s:error('Failed to run the following command: ' . string(job_cmd))
  else
    let ret = async#job#send(jobid, a:selection, 1)
    if ret != 0
      call s:error('Failed to send selection the following command: ' . ret)
    endif
  endif
endfunction "}}}

function! s:copy(type) abort " {{{
  let reg_save = @@

  if a:type ==# 'v'
      silent execute "normal! `<" . a:type . "`>y"
  elseif a:type ==# 'V'
      silent execute "normal! `<" . a:type . "`>y"
  elseif a:type ==# 'char'
      silent execute "normal! `[v`]y"
  endif

  call s:copyselection(@@)

  let @@ = reg_save
endfunction "}}}

function! s:paste() " {{
  let reg_save = @@

  let @@ = system(g:cb_paste_prg)
  setlocal paste
  exe 'normal p'
  setlocal nopaste

  let @@ = reg_save
endfunction " }}}

nnoremap <silent> <Plug>CBCopy :set opfunc=<SID>copy<CR>g@
xnoremap <silent> <Plug>CBCopy :<C-U>call <SID>copy(visualmode())<CR>
nnoremap <silent> <Plug>CBPaste :<c-u>call <SID>paste()<CR>

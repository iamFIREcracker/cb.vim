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
    let ret = async#job#send(jobid, a:selection, { 'close_stdin': 1 })
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
  elseif a:type ==# 'line'
      silent execute "normal! `[V`]y"
  endif

  call s:copyselection(@@)

  let @@ = reg_save
endfunction "}}}

function! s:paste(...) " {{{
  let l:after = get(a:, 1, 1)
  let reg_save = @@

  let @@ = system(g:cb_paste_prg)
  " XXX pasting multi-line text on Windows somehow leaves trailing ^M
  " on the buffer; I gotta figure out a better way to fix this, but
  " for now, manually stripping those \r\n will do just fine
  let @@ = substitute(@@, "\r\n", "\n", "g")
  setlocal paste
  if l:after
    exe 'normal p'
  else
    exe 'normal P'
  endif
  setlocal nopaste

  let @@ = reg_save
endfunction " }}}

nnoremap <silent> <Plug>CBCopy :<C-U>set opfunc=<SID>copy<CR>g@
xnoremap <silent> <Plug>CBCopy :<C-U>call <SID>copy(visualmode())<CR>
nnoremap <silent> <Plug>CBPasteAfter :<C-U>call <SID>paste()<CR>
nnoremap <silent> <Plug>CBPasteBefore :<C-U>call <SID>paste(0)<CR>

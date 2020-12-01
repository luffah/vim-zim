function! Ftdetect_zim()
  " No change if we didn't start with a txt file
  if  &ft != '' && &ft != 'text'
    return
  endif
  if getline(1) =~ "Content-Type: text/x-zim-wiki"
        \ || expand('%') =~ g:zim_notebooks_dir
    set ft=zim
  endif
endfunction


augroup Zim
for s:ext in get(g:, 'zim_note_extensions', ['txt'])
  exe 'au BufNewFile,BufRead *.'.s:ext.' call Ftdetect_zim()'
endfor
augroup END

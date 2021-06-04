let s:zim_python_path=''
let s:zim_not_found=0

function! zim#plugins#get_zim_src_dir()
  if s:zim_python_path == '' && ! s:zim_not_found
      let s:zim_python_path=substitute(
            \ system("find /usr/lib/python* -name 'zim' -type d"),
            \"\n.*",'','')
      let s:zim_not_found = (s:zim_python_path == '')
  endif
  return s:zim_python_path
endfu
command! ZimArithmetic call zim#plugins#arithmetic#processfile()

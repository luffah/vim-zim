" Zim syntax highlighting
" Authors:
"" Jack Mudge <jakykong@theanythingbox.com>
""   * I declare this file to be public domain.
"" Luffah  
""   * Thanks to vim-zimwiki-syntax authors
""      (YaoPo Wang and joanrivera), i added some styles
""   * Please enjoy the render of this syntax file, and feel free to customize
""      it for the funniest usage
" Changelog:
" 2016-09-12 - Jack Mudge - v0.1
"   * Initial creation
" 2017-05-30 - Luffah - v0.3
"   * More detailed syntax
" 2018-05-14 - Luffah
"   * add inline verbatim and blocks
"
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif


" Force Lang spelling for each note (to system if 1)
if get(g:,'zim_wiki_spelllang',0)
  exe 'silent! setlocal spell spelllang='.(g:zim_wiki_spelllang==1?strpart(expand("$LANG"),0,2):g:zim_wiki_spelllang)
endif

" Zim Header
syn match zimHeader /^[^:]*:/ contained contains=@NoSpell nextgroup=ZimHeaderParam
syn match zimHeaderParam /.*/ contained contains=@NoSpell
syn region zimHeaderRegion
      \ start=/\%1l^\(Content-Type\|Wiki-Format\|Creation-Date\):\%1l\c/
      \ end=/\%4l\([A-Z]*:.*\)\?\c/
      \ contains=zimHeader transparent fold keepend extend
hi link vimModeline LineNr
hi link zimHeader LineNr
hi link zimHeaderParam TabLine

" Titles (h1 to h5)
try
  silent hi markdownH1
  syn match Title1 /^\s*\(=\{6}\)[^=].*\1\s*$/ contains=Todo
  syn match Title2 /^\s*\(=\{5}\)[^=].*\1\s*$/ contains=Todo
  syn match Title3 /^\s*\(=\{4}\)[^=].*\1\s*$/ contains=Todo
  syn match Title4 /^\s*\(=\{3}\)[^=].*\1\s*$/ contains=Todo
  syn match Title5 /^\s*\(=\{2}\)[^=].*\1\s*$/ contains=Todo
  syn match Title6 /^\s*\(=\{1}\)[^=].*\1\s*$/ contains=Todo
  hi link Title1 markdownH1
  hi link Title2 markdownH2
  hi link Title3 markdownH3
  hi link Title4 markdownH4
  hi link Title5 markdownH5
  hi link Title6 markdownH6
catch 
  syn match Title /^\s*\(=\{1,6}\)[^=].*\1\s*$/ contains=Todo
endtry

" Checkbox
syn match zimEltCheckbox /^\( \{4}\|\t\)*\[[ ]\]\(\s\|$\)/me=e-1 contains=zimConcealEltCheckbox,zimTab
syn match zimEltCheckboxYes /^\( \{4}\|\t\)*\[\*\]\(\s\|$\)/me=e-1 contains=zimConcealEltCheckboxYes,zimTab
syn match zimEltCheckboxNo  /^\( \{4}\|\t\)*\[x\]\(\s\|$\)/me=e-1 contains=zimConcealEltCheckboxNo,zimTab
syn match zimEltCheckboxMoved  /^\( \{4}\|\t\)*\[>\]\(\s\|$\)/me=e-1 contains=zimConcealEltCheckboxMoved,zimTab
hi zimEltCheckbox gui=bold guifg=black guibg=#dcdcdc term=bold ctermfg=0 ctermbg=7
hi zimEltCheckboxYes gui=bold guifg=#65B616 guibg=#dcdcdc term=standout ctermfg=2 ctermbg=15
hi zimEltCheckboxNo  gui=bold guifg=#AF0000 guibg=#dcdcdc term=standout ctermfg=1 ctermbg=15
hi zimEltCheckboxMoved gui=bold guifg=#AFAF00 guibg=#dcdcdc term=standout ctermfg=3 ctermbg=15
"syn match zimTab '^\(  \)\+\(  \[\)'
"hi def link zimTab Ignore

" Lists
syn match ZimEltBulletItem /^\( \{4}\|\t\)*\*\(\s\|$\)/me=e-1
syn match ZimEltNumberedItem /^\( \{4}\|\t\)*\d\+\.\(\s\|$\)/me=e-1
"hi zimBulletItem gui=bold guifg=black guibg=#f4f4f4 term=bold ctermfg=0
hi link ZimEltBulletItem Special 
hi link ZimEltNumberedItem Special 

" Style : bold
syn match zimStyleBold /\*\*[^*]*\*\*/ contains=zimConcealStyleBold
hi zimStyleBold gui=bold term=standout cterm=bold
syn match zimConcealStyleBold /\*\*/ conceal contained transparent

" Style : italic
syn match zimStyleItalic +//[^/]*//+ contains=zimConcealStyleItalic
hi zimStyleItalic gui=italic cterm=italic
syn match zimConcealStyleItalic +//+ conceal contained transparent

" Style : hightlighted
syn match      zimStyleHighlighted /__[^_]*__/ contains=zimConcealStyleHighlighted
hi link zimStyleHighlighted DiffChange 
syn match zimConcealStyleHighlighted +__+ conceal contained transparent

" Style : strikethrough
syn match      zimStyleStrikethrough /\~\~[^~]*\~\~/
hi link zimStyleStrikethrough NonText

" url link
syn match   zimEltUrl '\(^\|\s\)\(www\.\|https\?:\/\/\)\S\+\c' contains=@NoSpell
hi def link zimEltUrl Tag

" tags
syn match   zimEltTag '\(^\|\s\)\(@[a-zA-Z-_0-9]\+\)\c' contains=@NoSpell
hi def link zimEltTag Identifier

syn match   zimEltFile '\(^\|\s\)\([.~]*\)\(/[^ /&|^[\]]\+\)\+' contains=@NoSpell
hi def link zimEltFile diffNewFile

" Links
syn match Identifier /\[\[[^[\]|]*\]\]/
syn match zimEltLinks /\[\[[^[\]|]*|[^[\]|]*\]\]/ contains=zimEltUrlHiddenA,zimEltUrlHiddenB keepend
syn match zimEltUrlHiddenA /\[\[[^|]*|/ contained conceal cchar=› transparent
syn match zimEltUrlHiddenB /\]\]/ contained conceal cchar=¸ transparent
try
  silent hi htmlBoldUnderline
  hi def link zimEltLinks htmlBoldUnderline
catch
  hi def link zimEltLinks Underlined
endtry

"" --------------------
" Style : block
syn match zimBlock '{{{[^{}]*}}}'
syn region zimBlock matchgroup=Comment start=/^{{{\a*/ end=/^}}}/ transparent

" Style : Codeblock (zim add-on)
fu! s:activate_codeblock()
  " generate by :read!%:p:h/getsourcesfiletype.py
  " the selection is reduced for optimisation and because some syntax files
  " break spell
  let l:languages = get(g:,'zim_codeblock_syntax',
        \{"python": "python","sh": "sh","sourcecode": "sh",  "vim": "vim",
        \ "html": "html", "css": "css", "xml": "xml",
        \ "javascript": "javascript", "sql": "sql"}
        \)

  exe 'syn include @zimcodeblockundef syntax/'.get(g:,'zim_codeblock_default_syntax', 'abc').'.vim contained'
  syn region zimCodeBlockUndef start="\s*$"ms=e+1
          \ end="^\s*}}}\ze\s*$"me=e-3 contained contains=@zimcodeblockundef
  " syn region markdownCode matchgroup=Delimiter start="^\s*```.*$" end="^\s*```\ze\s*$" keepend
  for l:i in keys(l:languages)
    let l:l = l:languages[l:i]
    let b:current_syntax=''
    unlet b:current_syntax
    exe 'syn include @zimcodeblock'.l:l.' syntax/'.l:l.'.vim contained'
    exe 'syn region zimCodeBlock'.l:l.' start=|lang="'.l:i.'".*$|ms=e+1'.
          \' end=|^\s*}}}\ze\s*$|me=e-3 contained contains=@zimcodeblock'.l:l

    " markdown code support
    exe 'syn region markdownHighlight'.l:l.'  matchgroup=Delimiter start="^\s*```\s*'.l:l.'\>.*$" end="^\s*```\ze\s*$" keepend contains=@zimcodeblock'.l:l

  endfor
  syn region zimCodeBlock start="^\s*{{{code" end="^\s*}}}\ze\s*$" matchgroup=Delimiter
        \ keepend contains=@NoSpell,ZimCodeBlock.*
  hi def link ZimCodeBlock Comment
endfu
call s:activate_codeblock()

" Style : verbatim
syn region zimStyleVerbatim start=/''/ end=/''/ contains=@NoSpell
syn region zimStyleVerbatim start=/^\s*'''/ end=/\s*'''/ contains=@NoSpell
hi def link zimStyleVerbatim	SpecialComment

" Style : sub and sup
syn match zimStyleSub '_{.\{-1,}}'
syn match zimStyleSup '\^{.\{-1,}}'
hi def link zimStyleSub Number
hi def link zimStyleSup Number

" Image
syn match zimEltImage '\(^\| \){{[^ {}][^{}]\{-1,}[^ {}]}}' contains=@NoSpell
hi def link zimEltImage Float

" Line
syn match zimStyleHorizontalLine /^\(-\{20}\)$/ contains=@NoSpell
hi link zimStyleHorizontalLine Underlined


"" --------------------
" Bonus
syn match vimModeline +\(/\*\s*vim\s*:.*\*/\|//\s*vim\s*:.*\)+

" IdentedDetails 
syn region zimwikiIndentedCheckboxDetails start=/^\z(\( \{4\}\|\t\)*\)\(\[[x*]\]\)[^:{}[\]]*\( :.*\|\\\s*$\)\n\(\s*\S\|^$\)/ end=/^\z1\?\( \{0,3\}\)\S/me=s-1 contains=zimElt.*,zimStyle.*,Title.*,zimwikiIndentedCheckboxDetails,zimwikiIndentedDetails fold transparent
syn region zimwikiIndentedDetails start=/^\S[^:{}[\]]* [^:{}[\]]*\(:.*\|\\\s*$\)\n\s*\S/ end=/^\( \{0,3\}\)\S/me=s-1 contains=zimElt.*,zimStyle.*,Title.* fold transparent
"syn region zimIndentedfold start=/^\( \{4,\}\|\t\)\S/ end=/^\s\{0,3\}\S/me=s-1 contained fold transparent contains=zimElt.*,zimStyle.*
"syn region zimwikiIndentedDetails start=/^\( \{4\}|\t\)*\(\[.\]\)\?[_a-z 0-9]*:/ end=/^\s\{0,3\}\S/me=s-1 contains=zimIndentedFold,zimElt.*,zimStyle.* transparent

"" --------------------
" Finalize
let b:current_syntax = "zim"
setlocal conceallevel=1
setlocal foldmethod=syntax
syn sync fromstart

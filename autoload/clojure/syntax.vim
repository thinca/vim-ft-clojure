" Supports for clojure syntax.
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:clojure#syntax#paren_colors_dark')
  let g:clojure#syntax#paren_colors_dark = [
  \   'ctermfg=yellow  guifg=orange1',
  \   'ctermfg=green   guifg=yellow1',
  \   'ctermfg=cyan    guifg=greenyellow',
  \   'ctermfg=magenta guifg=green1',
  \   'ctermfg=red     guifg=springgreen1',
  \   'ctermfg=yellow  guifg=cyan1',
  \   'ctermfg=green   guifg=slateblue1',
  \   'ctermfg=cyan    guifg=magenta1',
  \   'ctermfg=magenta guifg=purple1'
  \ ]
endif

if !exists('g:clojure#syntax#paren_colors_light')
  let g:clojure#syntax#paren_colors_light = [
  \   'ctermfg=darkyellow  guifg=orangered3',
  \   'ctermfg=darkgreen   guifg=orange2',
  \   'ctermfg=blue        guifg=yellow3',
  \   'ctermfg=darkmagenta guifg=olivedrab4',
  \   'ctermfg=red         guifg=green4',
  \   'ctermfg=darkyellow  guifg=paleturquoise3',
  \   'ctermfg=darkgreen   guifg=deepskyblue4',
  \   'ctermfg=blue        guifg=darkslateblue',
  \   'ctermfg=darkmagenta guifg=darkviolet'
  \ ]
endif

function! s:colors()
  return &background ==# 'dark' ? g:clojure#syntax#paren_colors_dark
  \                             : g:clojure#syntax#paren_colors_light
endfunction


function! clojure#syntax#define_numbers()
  let radix_chars = '0123456789abcdefghijklmnopqrstuvwxyz'
  for radix in range(2, 36)
    execute 'syntax match clojureIntNumber display ' .
    \ printf('"\c\<[-+]\?%d[rR][%s]\+N\?\>"', radix, radix_chars[: radix - 1])
  endfor
  syntax match clojureIntNumber display "\<[-+]\?\%(0\|([1-9][0-9]*)\|0[xX]([0-9A-Fa-f]\+)\|0([0-7]\+)\)N\?\>"
  syntax match clojureFloatNumber display "\<[-+]\?[0-9]\+\%(\.[0-9]*\)\?\%([eE][-+]\?[0-9]\+\)\?M\?"
  syntax match clojureRatioNumber display "\<[-+]\?[0-9]\+/[0-9]\+\>"
  syntax cluster clojureAtoms add=clojureIntNumber,clojureFloatNumber,clojureRatioNumber,clojureNumber

  highlight default link clojureIntNumber clojureNumber
  highlight default link clojureFloatNumber clojureNumber
  highlight default link clojureRatioNumber clojureNumber
  highlight default link clojureNumber Number
endfunction

function! clojure#syntax#define_rainbows()
  let colors = s:colors()
  let len = len(colors)
  for i in range(len)
    let next = (i + 1) % len
    execute printf('syntax region clojureAnonFnLevel%d matchgroup=clojureParenLevelTop start=/#(/ end=/)/ contained contains=@clojureNestLevel%d,clojureAnonFnArgs', i, i)
    execute printf('syntax region clojureExprLevel%d matchgroup=clojureParenLevel%d start=/(/ end=/)/ contained contains=@clojureNestLevel%d', i, i, next)
    execute printf('syntax region clojureVectorLevel%d matchgroup=clojureParenLevelTop start=/\[/ end=/\]/ contained contains=@clojureNestLevel%d', i, i)
    execute printf('syntax region clojureSetLevel%d matchgroup=clojureParenLevelTop start=/#{/ end=/}/ contained contains=@clojureNestLevel%d', i, i)
    execute printf('syntax region clojureMapLevel%d matchgroup=clojureParenLevelTop start=/{/ end=/}/ contained contains=@clojureNestLevel%d', i, i)
    execute printf('syntax cluster clojureNestLevel%d contains=@clojureTop,clojure.*Level%d', i, i)
  endfor

  call clojure#syntax#define_rainbow_colors()
  augroup filetype-clojure
    autocmd! ColorScheme * call clojure#syntax#define_rainbow_colors()
  augroup END
endfunction

function! clojure#syntax#define_rainbow_colors()
  let colors = s:colors()
  for i in range(len(colors))
    execute printf('highlight clojureParenLevel%d %s', i, colors[i - 1])
  endfor
endfunction

function! clojure#syntax#define_keywords()
  let files = globpath(&runtimepath, 'dict/clojure/**.txt', 1)
  let highlights = {}
  let links = {
  \   'Var': 'Identifier',
  \   'Protocol': 'Type',
  \   'Record': 'Type',
  \ }
  for file in filter(split(files, "\n"), 'filereadable(v:val)')
    for line in readfile(file)
      let list = split(line, "\t", 1)
      if len(list) != 3
        continue
      endif
      let [ns, type, symbol] = list
      let esymbol = escape(symbol, '\')
      let highlights[type] = 1
      if ns !=# ''
        execute printf('syntax keyword clojure%s %s/%s', type, ns, symbol)
      endif
      if ns ==# '' || ns ==# 'clojure.core'
        execute printf('syntax keyword clojure%s %s', type, symbol)
      endif
    endfor
  endfor
  for hl in keys(highlights)
    let link = get(links, hl, hl)
    execute printf('highlight default link clojure%s %s', hl, link)
    execute 'syntax cluster clojureAtoms add=clojure' . hl
  endfor
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

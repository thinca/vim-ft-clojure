" Supports for clojure syntax.
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:clojure#syntax#paren_colors')
  let g:clojure#syntax#paren_colors = {
  \   'dark': {
  \     'gui': ['Red1', 'Orange1', 'Yellow1', 'Greenyellow', 'Green1',
  \       'Springgreen1', 'Cyan1', 'Slateblue1', 'Purple1', 'Magenta1'],
  \     'cterm256': [196, 214, 226, 155, 46, 48, 51, 141, 135, 201],
  \     'cterm': ['Red', 'Yellow', 'Green', 'Cyan', 'Blue', 'Magenta'],
  \   },
  \   'light': {
  \     'gui': ['Red3', 'Orangered3', 'Orange2', 'Yellow3', 'Olivedrab4',
  \       'Green4', 'Paleturquoise3', 'Deepskyblue4', 'Darkslateblue', 'Darkviolet'],
  \     'cterm256': [160, 166, 214, 184, 107, 34, 152, 31, 61, 128],
  \     'cterm': ['DarkRed', 'DarkYellow', 'DarkGreen', 'DarkCyan', 'DarkMagenta'],
  \   },
  \ }
endif

function! s:colors()
  let base = get(g:clojure#syntax#paren_colors, &background, {})
  if has('gui_running') && has_key(base, 'gui')
    return {'colors': base.gui, 'type': 'gui'}
  elseif has_key(base, 'cterm' . &t_Co)
    return {'colors': base['cterm' . &t_Co], 'type': 'cterm'}
  elseif has_key(base, 'cterm')
    return {'colors': base.cterm, 'type': 'cterm'}
  endif
  return {'colors': [], 'type': ''}
endfunction


function! clojure#syntax#define_numbers()
  let radix_chars = '0123456789abcdefghijklmnopqrstuvwxyz'
  for radix in range(2, 36)
    execute 'syntax match clojureIntNumber display ' .
    \ printf('"\c\<[-+]\?%dr[%s]\+N\?\>"', radix, radix_chars[: radix - 1])
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

function! clojure#syntax#define_parens()
  let colors = s:colors().colors
  syntax region clojureAnnonFnLevelTop matchgroup=clojureParenLevelTop start=/#(/ end=/)/ contains=@clojureNestLevelTop
  syntax region clojureExprLevelTop matchgroup=clojureParenLevelTop start=/(/ end=/)/ contains=@clojureNestLevelTop
  syntax region clojureVectorLevelTop matchgroup=clojureParenLevelTop start=/\[/ end=/\]/ contains=@clojureNestLevelTop
  syntax region clojureSetLevelTop matchgroup=clojureParenLevelTop start=/#{/ end=/}/ contains=@clojureNestLevelTop
  syntax region clojureMapLevelTop matchgroup=clojureParenLevelTop start=/{/ end=/}/ contains=@clojureNestLevelTop
  if empty(colors)
    syntax cluster clojureNestLevelTop contains=@clojureTop,clojure.*LevelTop
  else
    syntax cluster clojureNestLevelTop contains=@clojureTop,@clojureNestLevel0
    call clojure#syntax#define_rainbows(colors)
  endif
endfunction

function! clojure#syntax#define_rainbows(colors)
  let len = len(a:colors)
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
  let dict = s:colors()
  let colors = dict.colors
  let type = dict.type
  for i in range(len(colors))
    execute printf('highlight clojureParenLevel%d %sfg=%s', i, type, colors[i])
  endfor
endfunction

function! clojure#syntax#define_keywords()
  let files = globpath(&runtimepath, 'dict/clojure/**.txt', 1)
  let highlights = {}
  let dup = {}
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
      let key = ns . '/' . symbol
      if has_key(dup, key)
        continue
      else
        let dup[key] = 1
      endif
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

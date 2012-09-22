" Supports for clojure indent.
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

let s:default_special = '^$'
let s:default_proxy = '\%(proxy\|reify\)$'
let g:clojure#indent#special =
\   get(g:, 'clojure#indent#special', s:default_special)
let g:clojure#indent#proxy =
\   get(g:, 'clojure#indent#proxy', s:default_proxy)

function! s:match_option(name, target)
  return a:target =~# g:clojure#indent#{a:name} ||
  \      a:target =~# get(b:, 'clojure_indent_' . a:name, s:default_{a:name})
endfunction

let s:paren_types = {
\   '(': ['(', ')'],
\   '{': ['{', '}'],
\   '[': ['\[', '\]'],
\ }

let s:PAREN_PATTERN = 'clojureParenLevel\w\+'

function! s:syn_name()
  let stack = synstack(line('.'), col('.'))
  return empty(stack) ? '' : synIDattr(stack[-1], "name")
endfunction

function! s:match_pairs(type, flag, ...)
  let [open, close] = s:paren_types[a:type]
  let stop = a:0 ? a:1 : 0
  return searchpairpos(open, '', close, a:flag,
  \                    's:syn_name() !~# s:PAREN_PATTERN', stop)
endfunction

function! s:cmp_pos(pos1, pos2)
  for i in range(2)
    if a:pos1[i] > a:pos2[i]
      return -1
    elseif a:pos1[i] < a:pos2[i]
      return 1
    endif
  endfor
  return 0
endfunction

function! s:max_pos(positions)
  let max = ''
  let maxpos = [0, 0]
  for [key, pos] in items(a:positions)
    if 0 < s:cmp_pos(maxpos, pos)
      let max = key
      let maxpos = pos
    endif
  endfor
  return max
endfunction

function! s:get_head(pos)
  return getline(a:pos[0])[a:pos[1] :]
endfunction

function! s:is_special(word)
  return &l:lispwords =~# '\V\<' . a:word . '\>' ||
  \      s:match_option('special', a:word)
endfunction

function! clojure#indent#get(lnum)
  if a:lnum == 1
    return 0
  endif

  " Inside of String or Regexp
  if s:syn_name() =~# '^clojure\%(String\|Regexp\)'
    let line = search('\\\@<!"', 'bW')
    if line
      return virtcol('.') - 1
    endif
  endif

  " Search nearest opening paren
  call cursor(0, 1)
  let pos = {}
  let top_limit = search('^(', 'bWn')
  let pos.paren = s:match_pairs('(', 'bWn', top_limit)
  let limit = max([top_limit, pos.paren[0]])
  let pos.bracket = s:match_pairs('[', 'bWn', limit)
  let limit = max([limit, pos.bracket[0]])
  let pos.curly = s:match_pairs('{', 'bWn', limit)
  let nearest = s:max_pos(pos)

  if nearest ==# ''
    " An opening paren was not found
    return 0
  elseif nearest !=# 'paren'
    " [ or { was found
    return virtcol(pos[nearest])
  endif

  let indent = virtcol(pos.paren)
  let head = s:get_head(pos.paren)
  let [func, follow] = matchlist(head, '^\s*\(\S*\)\(\s*\)')[1 : 2]

  " ((func arg) foo
  "             bar)
  if func =~# '[({[]'
    call cursor(pos.paren)
    call search('[({[]')
    let ch = getline(line('.'))[col('.') - 1]
    call s:match_pairs(ch, 'W')
    let head = s:get_head([line('.'), col('.')])
    let func = ''
    let follow = matchstr(head, '^\s*')
    if follow !=# ''
      let indent = virtcol('.')
    endif
  endif

  let use_special = follow ==# ''
  if !use_special
    call cursor(pos.paren)
    let parent = s:match_pairs('(', 'bWn', top_limit)
    let head = s:get_head(parent)
    let pfunc = matchstr(head, '^\s*\zs\w\+')
    if pfunc =~# g:clojure#indent#proxy
      let use_special = 1
    endif
  endif

  if use_special || s:is_special(func)
    " Follow nothing:
    " (func
    "   something)
    " Special case:
    " (let [x 10]
    "   something)
    let indent += &shiftwidth - 1
  else
    " Normal case:
    " (func [x 10]
    "       something)
    let indent += len(func . follow)
  endif

  " Adjust for #_(...)
  let [line, col] = pos.paren
  let comment = getline(line)[col - 3 : col - 2] ==# '#_'
  if comment
    let indent -= 2
  endif

  return indent
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" Supports for clojure indent.
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

let s:paren_types = {
\   '(': ['(', ')'],
\   '{': ['{', '}'],
\   '[': ['\[', '\]'],
\ }

function! s:syn_name(...)
  let stack = synstack(line('.'), col('.'))
  return empty(stack) ? '' : synIDattr(stack[-1], "name")
endfunction

function! s:match_pairs(type, flag, ...)
  let [open, close] = s:paren_types[a:type]
  let stop = a:0 ? a:1 : 0
  let pat = 'clojureParenLevel\w\+'
  return searchpairpos(open, '', close, a:flag,
  \                    's:syn_name() !~# pat', stop)
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

function! clojure#indent#get(lnum)
  if a:lnum == 1
    return 0
  endif

  if s:syn_name() =~# '^clojure\%(String\|Regexp\)'
    let line = search('\\\@<!"', 'bW')
    if line
      return virtcol('.') - 1
    endif
  endif

  call cursor(0, 1)
  let pos = {}
  let pos.paren = s:match_pairs('(', 'bWn')
  let pos.bracket = s:match_pairs('[', 'bWn', pos.paren[0])
  let pos.curly = s:match_pairs('{', 'bWn', pos.bracket[0])
  let nearest = s:max_pos(pos)
  if nearest ==# ''
    return 0
  elseif nearest !=# 'paren'
    return virtcol(pos[nearest])
  endif

  let [line, col] = pos.paren
  let indent = virtcol([line, col])
  let head = getline(line)[col :]
  let [func, follow] = matchlist(head, '^\s*\(\S*\)\(\s*\)')[1 : 2]
  if func =~# '[({[]'
    call cursor(pos.paren)
    call search('[({[]')
    let ch = getline(line('.'))[col('.') - 1]
    call s:match_pairs(ch, 'W')
    let head = getline(line('.'))[col('.') :]
    let func = ''
    let follow = matchstr(head, '^\s*')
    if follow !=# ''
      let indent = virtcol('.')
    endif
  endif
  if follow !=# '' && &l:lispwords !~# '\V\<' . func . '\>'
    let indent += len(func . follow)
  else
    let indent += &shiftwidth - 1
  endif

  return indent
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

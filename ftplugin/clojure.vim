" Vim filetype plugin
" Language:    Clojure (http://clojure.org)
" Maintainer:  thinca <thinca+vim@gmail.com>

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal expandtab
setlocal iskeyword+=?,-,*,!,&,+,=,<,>,.,:,/

let &l:define = '^\s*(def\%(-\|n\|n-\|macro\|struct\|multi\)\?'
setlocal commentstring=;%s

let b:undo_ftplugin = "setlocal expandtab< iskeyword< commentstring< define<"


if has('browsefilter') && !exists('b:browsefilter')
  let b:browsefilter =
  \ "Clojure Source Files (*.clj)\t*.clj\n" .
  \ "Jave Source Files (*.java)\t*.java\n" .
  \ "All Files (*.*)\t*.*\n"
endif

" for matchit.vim
let b:match_words = '(:),{:},[:],\<try\>:\<catch\>'
let b:match_skip = 's:comment\|string\|character'

let &cpo = s:save_cpo
unlet s:save_cpo

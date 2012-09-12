" Vim filetype plugin
" Language:    Clojure (http://clojure.org)
" Maintainer:  thinca <thinca+vim@gmail.com>

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

setlocal iskeyword+=?,-,*,!,+,=,<,>,.,:,/

let &l:define = '^\s*(def\%(-\|n\|n-\|macro\|struct\|multi\)\?'
setlocal commentstring=;%s

let b:undo_ftplugin = "setlocal isk< cms< def<"

if has('browsefilter') && !exists('b:browsefilter')
  let b:browsefilter =
  \ "Clojure Source Files (*.clj)\t*.clj\n" .
  \ "Jave Source Files (*.java)\t*.java\n" .
  \ "All Files (*.*)\t*.*\n"
endif

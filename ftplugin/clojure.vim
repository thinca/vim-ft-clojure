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

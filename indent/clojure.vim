" Vim indent file
" Language:    Clojure (http://clojure.org)
" Maintainer:  thinca <thinca+vim@gmail.com>

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal lispwords=
" Defintions:
setlocal lispwords+=def,def-,defn,defn-,defmacro,defmacro-,defmethod,defmulti
setlocal lispwords+=defonce,defvar,defvar-,defunbound,let,fn,letfn,binding,proxy
setlocal lispwords+=defnk,definterface,defproject,defprotocol,deftype,defrecord,reify
setlocal lispwords+=extend,extend-protocol,extend-type,bound-fn

" Conditionals and Loops:
setlocal lispwords+=if,if-not,if-let,when,when-not,when-let,when-first
setlocal lispwords+=condp,case,loop,dotimes,for,while

" Blocks:
setlocal lispwords+=do,doto,try,catch,locking,with-in-str,with-out-str,with-open
setlocal lispwords+=dosync,with-local-vars,doseq,dorun,doall,->,->>,future
setlocal lispwords+=with-bindings

" Namespaces:
setlocal lispwords+=ns,clojure.core/ns

" Java Classes:
setlocal lispwords+=gen-class,gen-interface

" clojure.test package:
setlocal lispwords+=deftest,deftest-,testing

setlocal indentexpr=clojure#indent#get(v:lnum)

setlocal noautoindent nosmartindent
setlocal indentkeys=!^F,o,O

let b:undo_indent = 'setlocal lispwords< indentexpr< autoindent< smartindent< indentkeys<'

let &cpo = s:save_cpo
unlet s:save_cpo

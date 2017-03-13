" Author: Stephen Robinson <sblazerobinson@gmail.com>
" Version: 0.1

if exists("g:loaded_vprojman") || &cp || v:version < 700
  finish
endif

if exists("g:vprojman_enable") && ! g:vprojman_enable
  finish
endif

let g:loaded_vprojman   = 0.1
let s:keepcpo           = &cpo
set cpo&vim

" Global Variables {{{
if !exists("g:vprojman_autoinit")
  let g:vprojman_autoinit = 1
endif
if !exists("g:vprojman_changedir")
  let g:vprojman_changedir = 1
endif

if !exists("g:vprojman_signature")
  let g:vprojman_signature = ""
endif
if !exists("g:vprojman_projfile")
  let g:vprojman_projfile = "proj.vim"
endif
if !exists("g:vprojman_sessionfile")
  let g:vprojman_sessionfile = "proj.session.vim"
endif

if !exists("g:vprojman_patches_dir")
  let g:vprojman_patches_dir = g:vprojman_projfile . "_patches"
endif
if !exists("g:vprojman_patchbin")
  let g:vprojman_patchbin = "patch"
endif
if !exists("g:vprojman_patch_pval")
  let g:vprojman_patch_pval = "0"
endif
if !exists("g:vprojman_patch_dir")
  let g:vprojman_patch_dir = "."
endif

if !exists("g:vprojman_make_autowrite")
  let g:vprojman_make_autowrite = 1
endif
if !exists("g:vprojman_make_dir")
  let g:vprojman_make_dir = "."
endif
if !exists("g:vprojman_make_target")
  let g:vprojman_make_target = ""
endif
if !exists("g:vprojman_make_args")
  let g:vprojman_make_args = ""
endif
if !exists("g:vprojman_make_autojump")
  let g:vprojman_make_autojump = 0
endif
if !exists("g:vprojman_copen_pos")
  let g:vprojman_copen_pos = ""
endif
if !exists("g:vprojman_copen_autofocus")
  let g:vprojman_copen_autofocus = 0
endif
" }}}

if g:vprojman_autoinit
  autocmd VimEnter * call vprojman#init()
endif


"" Public Interface:
"" AppFunction: is a function you expect your users to call
"" PickAMap: some sequence of characters that will run your AppFunction
"" Repeat these three lines as needed for multiple functions which will
"" be used to provide an interface for the user
"if !hasmapto('<Plug>AppFunction')
"  map <unique> <Leader>PickAMap <Plug>AppFunction
"endif
"
"" Global Maps:
""
"noremap <silent> <unique> <script> <Plug>AppFunction
" \ :set lz<CR>:call <SID>AppFunction()<CR>:set nolz<CR>
"
"" ------------------------------------------------------------------------------
"" s:AppFunction: 
"fun s:AppFunction()
"  ..whatever..
"
"  " your script function can set up maps to internal functions
"  nnoremap <silent> <Left> :set lz<CR>:silent! call <SID>AppFunction2()<CR>:set nolz<CR>
"
"  " your app can call functions in its own script and not worry about name
"  " clashes by preceding those function names with <SID>
"  call s:InternalAppFunction(...)
"
"  " or you could call it with
"  call s:InternalAppFunction(...)
"endfun
"
"" ------------------------------------------------------------------------------
"" s:InternalAppFunction: this function cannot be called from outside the
"" script, and its name won't clash with whatever else the user has loaded
"fun! s:InternalAppFunction(...)
"
"  ..whatever..
"endfun

" ------------------------------------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo

" vim:ft=vim:fdm=marker

if !exists("g:loaded_vprojman")
  echoe "vprojman not loaded!"
  finish
endif

if exists("g:loaded_vprojman_autoload")
    finish
endif
let g:loaded_vprojman_autoload = 1

" SECTION: private variables {{{
let s:proj_root = ""
" }}}

" SECTION: helper functions {{{

func s:check_init()
  if s:proj_root == ""
    echoe "You must initialize vprojman with vprojman#init() first."
    return 0
  endif
  return 1
endfun

function s:init_projconf()
  let orig_cwd = getcwd()
  let found_proj = 0
  while getcwd() != expand("~") && getcwd() != "/"

    if filereadable(g:vprojman_projfile)

      try
        execute "silent vimgrep /" . g:vprojman_signature . "/j proj.vim"
        cexpr []
        let found_proj = 1
      catch /No match/
        " Ask the user if they trust it.
        let proj = fnamemodify(g:vprojman_projfile, ":p")
        let source = confirm("UNSIGNED " . proj . " file found. Source it?", "&yes\n&no", 2)
        if source == 1
          let found_proj = 1
        endif
      endtry

      if found_proj
        execute "source " . g:vprojman_projfile
        let s:proj_root = getcwd()

        if ! g:vprojman_changedir
          execute "cd " . orig_cwd
        endif

        return
      endif

    endif
    cd ..
  endwhile
  " No proj.vim file found / sourced
  execute "cd " . orig_cwd
  let s:proj_root = getcwd()
endfunc

func s:choice(prompt, default, choices)
  let prompt = a:prompt
  let choices = ""

  if a:0 > 36
    echoe "Too many arguemnts to vprojman#choice. Max is 38."
    return 0
  endif

  let a = char2nr('a')
  let i = 1
  let default = 0
  for choice in a:choices

    if choice == a:default
      let default = i
    endif

    let prompt .= "\n" . nr2char(a) . " : " . choice
    if choices != ""
      let choices .= "\n"
    endif
    let choices .= nr2char(a)
    let a += 1
    let i += 1
    if a > char2nr('z')
      let a = char2nr('0')
    endif
  endfor
  return confirm(prompt, choices, default)
endfunc
" }}}

" SECTION: Interface functions {{{
fun vprojman#init()
  call s:init_projconf()
endfun

fun vprojman#choice(prompt, default, ...)
  let choice = s:choice(a:prompt, a:default, a:000)
  if choice == 0
    return a:default
  endif
  return a:000[choice - 1]
endfun

fun vprojman#setenv(var, ...)
  execute "let default = $" . a:var
  let choice = s:choice("Set $" . a:var . " to:", default, a:000)
  if choice == 0
    return
  endif
  execute "let $" . a:var . " = '" . a:000[choice - 1] . "'"
endfun

fun vprojman#patch()
  if ! s:check_init() | return | endif
  let orig_cwd = getcwd()

  execute "cd " . s:proj_root . "/" . g:vprojman_patches_dir
  let patches = split(system("ls"))
  execute "cd " . s:proj_root
  execute "cd " . g:vprojman_patch_dir

  if len(patches) == 0
    echom "No patches found."
    execute "cd " . orig_cwd
    return
  endif

  let patchlist = []
  let patchactionlist = []

  for patch in patches
    let patch = s:proj_root . "/" . g:vprojman_patches_dir . "/" . patch

    call system(g:vprojman_patchbin . " -p" . g:vprojman_patch_pval . " -N --dry-run < " . patch)
    if v:shell_error == 0
      call add(patchlist, "Apply   : " . patch)
      call add(patchactionlist, " ")
    else
      call system(g:vprojman_patchbin  . " -p" . g:vprojman_patch_pval . " -R -N --dry-run < " . patch)
      if v:shell_error == 0
        call add(patchlist, "Unapply : " . patch)
      call add(patchactionlist, " -R ")
      else
        call add(patchlist, "Inval   : " . patch)
        call add(patchactionlist, "")
      endif
    endif
  endfor

  let choice = s:choice("Choose patch to apply/unapply:", "", patchlist)

  if choice == 0
    echom "Not patching"
    execute "cd " . orig_cwd
    return
  endif

  let patch = patches[choice - 1]
  let patchaction = patchactionlist[choice - 1]

  if patchaction == ""
    echo "Invalid patch selected"
    execute "cd " . orig_cwd
    return
  endif

  let patch = s:proj_root . "/" . g:vprojman_patches_dir . "/" . patch
  echo g:vprojman_patchbin . patchaction . " -p" . g:vprojman_patch_pval . " < " . patch
  echo system(g:vprojman_patchbin . patchaction . " -p" . g:vprojman_patch_pval . " < " . patch)

  if v:shell_error != 0
    echoe "Error applying patch!"
  endif

  execute "cd " . orig_cwd

  if confirm("Reload files?", "&yes\n&no") == 1
    bufdo e
  endif
endfun

func vprojman#make(...)
  if ! s:check_init() | return | endif

  let orig_cwd = getcwd()
  execute "cd " . s:proj_root

  if g:vprojman_make_autowrite
    wa
  endif

  let dir = get(a:000, 0, g:vprojman_make_dir)
  let args = get(a:000, 1, g:vprojman_make_args)
  let target = get(a:000, 2, g:vprojman_make_target)

  if g:vprojman_make_autojump
    let make = "make"
  else
    let make =  "make!"
  endif

  execute "silent ".make." -C ".dir." ".args." ".target
  execute g:vprojman_copen_pos . "  copen"
  if g:vprojman_copen_autofocus == 0
    wincmd p
  endif

  execute "cd " . orig_cwd
endfunc

"}}}

" vim:ft=vim:fdm=marker

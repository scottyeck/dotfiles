function! PlugLoaded(name)
    return (
        \ has_key(g:plugs, a:name) &&
        \ isdirectory(g:plugs[a:name].dir) &&
        \ stridx(&rtp, g:plugs[a:name].dir) >= 0)
endfunction

function! IdempotentPlug(name)
  if PlugLoaded(a:name)
    " noop
  else
    Plug a:name
  endif
endfunction

command! -nargs=1 IdempotentPlug call IdempotentPlug(<f-args>)

" Deps for Telescope and Spectre
IdempotentPlug 'nvim-lua/plenary.nvim'


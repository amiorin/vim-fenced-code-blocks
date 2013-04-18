" fenced-code-blocks.vim - For ```<code>```
" Maintainer:   Alberto Miorin <http://albertomiorin.com>
" Version:      1.0

if exists('g:loaded_fenced_code_blocks') || &cp || v:version < 700
  finish
endif
let g:loaded_fenced_code_blocks = 1

function! s:E(cmd,bang) abort
  let cmds = {'E': 'edit', 'S': 'split', 'V': 'vsplit', 'T': 'tabedit'}
  let cmd = cmds[a:cmd] . a:bang
  let b:pos = getpos(".")
  let pos = copy(b:pos)
  let pos[2] = 0
  call setpos(".", pos)
  let start = search('^```.\+$', 'cbnW')
  let end = search('^```$', 'cnW')
  let end2 = search('^```$', 'cbnW')
  if end2 > start && end2 < end || end == 0 || start == 0
    return
  endif
  let lines = getline(start + 1,end - 1)
  let ext = substitute(getline(start), '```', '.', '')
  let target = tempname().ext
  call writefile(lines,target)
  let b:start = start
  let b:end = end
  let b:target = target
  augroup sync
    autocmd BufEnter <buffer> call s:sync()
  augroup END
  execute cmd.' '.target
  autocmd BufLeave <buffer> write
endfunction

function! s:sync() abort
  augroup sync
    autocmd!
  augroup END
  augroup! sync
  if (b:end - b:start > 1)
    execute (b:start+1).",".(b:end-1). " delete _"
  endif
  call append(b:start, readfile(b:target))
  execute "bwipeout! ".b:target
  call setpos('.', b:pos)
endfunction

augroup FencedCodeBlocks
  autocmd!
  autocmd FileType markdown call s:init()
augroup END

function! s:init() abort
  call s:define_commands()
endfunction

function! s:define_commands()
  for command in s:commands
    exe 'command! -buffer '.command
  endfor
endfunction

let s:commands = []
function! s:command(definition) abort
  let s:commands += [a:definition]
endfunction

call s:command("-bang -nargs=0 E  :call s:E('E','<bang>')")
call s:command("-bang -nargs=0 EE :call s:E('E','<bang>')")
call s:command("-bang -nargs=0 ES :call s:E('S','<bang>')")
call s:command("-bang -nargs=0 EV :call s:E('V','<bang>')")
call s:command("-bang -nargs=0 ET :call s:E('T','<bang>')")

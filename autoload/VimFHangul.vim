scriptencoding utf-8

let s:HSTART = 44032
let s:HLAST = 55203
let s:HUNIT = 588

let s:hrange = {}
let s:hrange['ㄱ'] = { 'start': s:HSTART + s:HUNIT * 0 - 0, 'end': s:HSTART + s:HUNIT * 2 - 1 }
let s:hrange['ㄴ'] = { 'start': s:HSTART + s:HUNIT * 2 - 0, 'end': s:HSTART + s:HUNIT * 3 - 1 }
let s:hrange['ㄷ'] = { 'start': s:HSTART + s:HUNIT * 3 - 0, 'end': s:HSTART + s:HUNIT * 5 - 1 }
let s:hrange['ㄹ'] = { 'start': s:HSTART + s:HUNIT * 5 - 0, 'end': s:HSTART + s:HUNIT * 6 - 1 }
let s:hrange['ㅁ'] = { 'start': s:HSTART + s:HUNIT * 6 - 0, 'end': s:HSTART + s:HUNIT * 7 - 1 }
let s:hrange['ㅂ'] = { 'start': s:HSTART + s:HUNIT * 7 - 0, 'end': s:HSTART + s:HUNIT * 9 - 1 }
let s:hrange['ㅅ'] = { 'start': s:HSTART + s:HUNIT * 9 - 0, 'end': s:HSTART + s:HUNIT * 11 - 1 }
let s:hrange['ㅇ'] = { 'start': s:HSTART + s:HUNIT * 11 - 0, 'end': s:HSTART + s:HUNIT * 12 - 1 }
let s:hrange['ㅈ'] = { 'start': s:HSTART + s:HUNIT * 12 - 0, 'end': s:HSTART + s:HUNIT * 14 - 1 }
let s:hrange['ㅊ'] = { 'start': s:HSTART + s:HUNIT * 14 - 0, 'end': s:HSTART + s:HUNIT * 15 - 1 }
let s:hrange['ㅋ'] = { 'start': s:HSTART + s:HUNIT * 15 - 0, 'end': s:HSTART + s:HUNIT * 16 - 1 }
let s:hrange['ㅌ'] = { 'start': s:HSTART + s:HUNIT * 16 - 0, 'end': s:HSTART + s:HUNIT * 17 - 1 }
let s:hrange['ㅍ'] = { 'start': s:HSTART + s:HUNIT * 17 - 0, 'end': s:HSTART + s:HUNIT * 18 - 1 }
let s:hrange['ㅎ'] = { 'start': s:HSTART + s:HUNIT * 18 - 0, 'end': s:HSTART + s:HUNIT * 19 - 1 }

let s:alias = {}
let s:alias['q'] = s:hrange['ㅂ']
let s:alias['w'] = s:hrange['ㅈ']
let s:alias['e'] = s:hrange['ㄷ']
let s:alias['r'] = s:hrange['ㄱ']
let s:alias['t'] = s:hrange['ㅅ']
let s:alias['a'] = s:hrange['ㅁ']
let s:alias['s'] = s:hrange['ㄴ']
let s:alias['d'] = s:hrange['ㅇ']
let s:alias['f'] = s:hrange['ㄹ']
let s:alias['g'] = s:hrange['ㅎ']
let s:alias['z'] = s:hrange['ㅋ']
let s:alias['x'] = s:hrange['ㅌ']
let s:alias['c'] = s:hrange['ㅊ']
let s:alias['v'] = s:hrange['ㅍ']

" HowToUse: 아랫줄의 Code와 같이 알파벳에 대응하는 한글 초성을 입력하면, 해당
" 알파벳으로 지정한 초성이 포함된 한글을 검색할 수 있습니다.
" Code: let g:vim_f_hangul_alias = { 'q': 'ㅅ', 'a': 'ㅂ' }
if exists('g:vim_f_hangul_alias')
    for s:key in keys(g:vim_f_hangul_alias)
        let s:val = g:vim_f_hangul_alias[s:key]
        let s:alias[s:key] = s:hrange[s:val]
    endfor
endif

let s:forward = 'zps'
let s:backward = 'pbs'
let s:backwardEnd = 'pbes'
let s:char = ''
let s:cmd = ''
let s:status = {'char': '', 'cmd': ''}

function! VimFHangul#forwardLookup() range
    let s:cmd = 'f'
    let s:char = nr2char(getchar())
    call s:lookup(s:forward)
endfunction

function! VimFHangul#backwardLookup() range
    let s:cmd = 'F'
    let s:char = nr2char(getchar())
    call s:lookup(s:backward)
endfunction

function! VimFHangul#tillBefore() range
    let s:cmd = 't'
    let s:char = nr2char(getchar())
    call s:tillBefore(s:forward)
endfunction

function! VimFHangul#tillAfter() range
    let s:cmd = 'T'
    let s:char = nr2char(getchar())
    call s:tillBefore(s:backwardEnd)
endfunction

" 검색에 사용할 regex string을 생성한다
function! s:createQuery(char, prefix, suffix)
    if !has_key(s:alias, a:char)
        return a:prefix . '['.escape(a:char, '\\').']' . a:suffix
    endif
    let l:alias = get(s:alias, a:char)
    let l:start = l:alias['start']
    let l:end = l:alias['end']
    return '\%#=2' . a:prefix . '['.escape(a:char, '\\').'\d'.l:start.'-\d'.l:end.']' . a:suffix
endfunction

function! s:createSimpleQuery(char)
    return s:createQuery(a:char, '', '')
endfunction

" f, F 기능을 구현한다
function! s:lookup(flag)

    let l:searchStr = s:createSimpleQuery(s:char)
    let l:success = s:search(l:searchStr, a:flag)
    call s:saveStatus()
    return l:success
endfunction

" t, T 기능(검색어 바로 앞에 커서를 점프)을 구현한다
function! s:tillBefore(flag)
    let l:searchStr = ''

    if a:flag ==# s:forward
        let l:searchStr = s:createQuery(s:char, '.', '')
    elseif a:flag ==# s:backwardEnd
        let l:searchStr = s:createQuery(s:char, '', '.')
    endif

    let l:success = s:search(l:searchStr, a:flag)
    call s:saveStatus()
    return l:success

endfunction

" 검색 정보를 저장한다
function! s:saveStatus()
    let l:forward = s:char =~# '[ft]'
    let l:until = s:char =~# '[tT]'
    call setcharsearch({'char': s:char, 'forward': l:forward, 'until': l:until})
    let s:status = {'char': s:char, 'cmd': s:cmd}
endfunction

function! s:search(searchStr, flag)
    let l:success = 0
    let l:count = v:count1
    while l:count > 0
        if search(a:searchStr, a:flag, line('.')) < 1
            break
        endif
        let l:success += 1
        let l:count -= 1
    endwhile
    return l:success
endfunction

function! VimFHangul#repeat()

    if s:status['char'] == ''
        return
    endif

    if s:status['cmd'] ==# 'f'
        return s:lookup(s:forward)
    endif

    if s:status['cmd'] ==# 'F'
        return s:lookup(s:backward)
    endif

    if s:status['cmd'] ==# 't'
        return s:tillBefore(s:forward)
    endif

    if s:status['cmd'] ==# 'T'
        return s:tillBefore(s:backwardEnd)
    endif

endfunction

function! VimFHangul#backwardRepeat()

    if s:status['char'] == ''
        return
    endif

    if s:status['cmd'] ==# 'f'
        return s:lookup(s:backward)
    endif

    if s:status['cmd'] ==# 'F'
        return s:lookup(s:forward)
    endif

    if s:status['cmd'] ==# 't'
        return s:tillBefore(s:backwardEnd)
    endif

    if s:status['cmd'] ==# 'T'
        return s:tillBefore(s:forward)
    endif
endfunction

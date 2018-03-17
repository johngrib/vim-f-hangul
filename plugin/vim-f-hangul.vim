scriptencoding utf-8

if exists('g:loaded_vim_f_hangul') && g:loaded_vim_f_hangul
    finish
endif

nnoremap <silent>f :<C-u>call VimFHangul#forwardLookup()<CR>
nnoremap <silent>F :<C-u>call VimFHangul#backwardLookup()<CR>
nnoremap <silent>t :<C-u>call VimFHangul#tillBefore()<CR>
nnoremap <silent>T :<C-u>call VimFHangul#tillAfter()<CR>
nnoremap <silent>; :<C-u>call VimFHangul#repeat()<CR>
nnoremap <silent>, :<C-u>call VimFHangul#backwardRepeat()<CR>

let g:loaded_vim_f_hangul = 1

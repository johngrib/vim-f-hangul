scriptencoding utf-8

if exists('g:loaded_vim_f_hangul') && g:loaded_vim_f_hangul
    finish
endif

nnoremap <silent>f :call VimFHangul#forwardLookup()<CR>
nnoremap <silent>F :call VimFHangul#backwardLookup()<CR>
nnoremap <silent>; :call VimFHangul#repeat()<CR>

let g:loaded_vim_f_hangul = 1

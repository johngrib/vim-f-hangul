scriptencoding utf-8

if exists('g:loaded_vim_f_hangul') && g:loaded_vim_f_hangul
    finish
endif

nnoremap <silent>q :call VimFHangul#forwardLookup()<CR>
nnoremap <silent>; :call VimFHangul#forwardLookupRepeat()<CR>

let g:loaded_vim_f_hangul = 1

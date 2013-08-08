" 事前処理
if exists('g:loaded_window_size_memorizer')
    finish
endif


let s:save_cpo = &cpo
set cpo&vim




" utility functions

" 文字列最後のスラッシュ・バックスラッシュを削除する
function! s:remove_last_slash(path)
    return substitute(a:path, '\v(/|\\)+$', '', '')
endfunction


" path結合
function! s:combined_path(...)
    let paths = map(deepcopy(a:000), 's:remove_last_slash(v:val)')
    return join(paths, '/')
endfunction


" コマンドの結果文字列を取得
function! s:get_cmd_result(cmd)
    redir => l:return
    execute 'silent ' . a:cmd
    redir end

    " redirでは先頭に必ず改行が入るため、その改行(最初の1文字目)を削除
    return l:return[1:-1]
endfunction


" error msg
function! s:error_msg(msg)
    echohl ErrorMsg
    echomsg a:msg
    echohl None
endfunction




" 保存ファイル名の設定
let s:file_name = fnamemodify(
\                       s:combined_path(
\                           get(g:, "window_size_memorizer_path", $HOME)
\                           , ".vim_window_size_memorizer")
\                       , ':p')




" winpos/lines/columnsの取得処理

" winposの値を取得
function! s:get_winpos()
    let l:winpos = s:get_cmd_result('winpos')
    let l:winpos = substitute(l:winpos, '^[^:]*:', '', '')
    let l:winpos = 'winpos ' . substitute(l:winpos, '\D', ' ', 'g')
    return substitute(l:winpos, '\s\{2,\}', ' ', 'g')
endfunction


" lines/columnsの値を取得
function! s:get_win_size()
    return 'set columns=' . &columns . ' lines=' . &lines
endfunction




" window sizeの復元・保存処理

" window size/winposの保存処理
function! window_size_memorizer#save_window_size()
    if empty(glob(fnamemodify(s:file_name, ':h')))
        call s:error_msg("path '" . s:file_name . "' is validate.")
        return
    endif

    try
        call writefile([s:get_winpos(), s:get_win_size()], s:file_name)
    catch /.*/
        call s:error_msg("unexpectedly error, please retry later")
    endtry
endfunction


" winpos/window sizeの復元処理
function! window_size_memorizer#read_window_size()
    try
        execute "source " . s:file_name
    catch /E484/
        " windowサイズの格納ファイルが無いという状態は十分あり得る(インストール直後など)ため
        " warning/errorメッセージなど表示しない
        " ただ、この処理で何度も失敗するようなことがあれば、
        " わかりやすいエラーメッセージを表示させることも必要かもしれない。
    endtry
endfunction




" 事後処理
let &cpo = s:save_cpo
unlet s:save_cpo


let g:loaded_window_size_memorizer = 1

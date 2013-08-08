if has('gui_running') && get(g:, 'window_size_memorizer_is_disable', 0) != 1
    augroup window_size_memorizer
        autocmd!
        autocmd GUIEnter            * call window_size_memorizer#read_window_size()
        autocmd VimLeave,VimResized * call window_size_memorizer#save_window_size()
    augroup end
endif

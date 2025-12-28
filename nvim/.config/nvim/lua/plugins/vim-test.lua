return {
  'vim-test/vim-test',
  dependencies = { 'preservim/vimux' },
  config = function()
    vim.cmd('nmap <silent> <leader>tt :TestNearest<CR>')
    vim.cmd('nmap <silent> <leader>tT :TestFile<CR>')
    vim.cmd('nmap <silent> <leader>ta :TestSuite<CR>')
    vim.cmd('nmap <silent> <leader>tl :TestLast<CR>')
    vim.cmd('nmap <silent> <leader>tg :TestVisit<CR>')
    vim.cmd('let test#strategy = "vimux"')
  end,
}

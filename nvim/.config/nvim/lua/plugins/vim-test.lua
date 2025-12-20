return {
  'vim-test/vim-test',
  dependencies = { 'preservim/vimux' },
  config = function()
    vim.cmd('nmap <silent> <leader>t :TestNearest<CR>')
    vim.cmd('nmap <silent> <leader>T :TestFile<CR>')
    vim.cmd('nmap <silent> <leader>a :TestSuite<CR>')
    vim.cmd('nmap <silent> <leader>l :TestLast<CR>')
    vim.cmd('nmap <silent> <leader>g :TestVisit<CR>')
    vim.cmd('let test#strategy = "vimux"')
  end,
}

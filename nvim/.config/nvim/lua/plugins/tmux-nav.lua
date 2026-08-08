return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  -- <c-h/j/k/l> belong to after/plugin/herdr-nav.lua, which drives herdr first
  -- and falls back to the TmuxNavigate* commands above when $TMUX is set.
  keys = {
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}

local M = {}

local dap = require("dap")

local function find_test_name()
  local line = vim.fn.getline(".")
  return line:match("fn%s+([%w_]+)")
end

local function is_executable(path)
  return vim.fn.getfperm(path):sub(3, 3) == "x"
end

local function find_test_binary()
  local dir = vim.fn.getcwd() .. "/target/debug/deps"
  local crate = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

  local candidates = vim.fn.glob(dir .. "/" .. crate .. "-*", false, true)

  for _, path in ipairs(candidates) do
    if is_executable(path) then
      return path
    end
  end

  vim.notify(
    "No executable test binary found. Run cargo test --no-run first.",
    vim.log.levels.ERROR
  )
  return nil
end

function M.debug_current_test()
  local test = find_test_name()
  if not test then
    vim.notify("Cursor is not on a test function", vim.log.levels.ERROR)
    return
  end

  vim.notify("Building tests…")
  vim.fn.system("cargo test --no-run")

  local program = find_test_binary()
  if not program then
    return
  end

  dap.run({
    name = "Rust: Debug test " .. test,
    type = "codelldb",
    request = "launch",
    program = program,
    args = { test },
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  })
end

return M

local M = {}

local function cargo_build(args)
  local cmd = "cargo build " .. args
  vim.notify("Running: " .. cmd)
  vim.fn.system(cmd)
end

local function pick_executable(dir)
  local files = vim.fn.glob(dir .. "/*", false, true)
  if #files == 0 then
    vim.notify("No executables found in " .. dir, vim.log.levels.ERROR)
    return nil
  end

  if #files == 1 then
    return files[1]
  end

  return vim.fn.inputlist(
    vim.tbl_extend("force", { "Select executable:" }, files)
  ) and files[vim.v.choice]
end

function M.debug_bin()
  cargo_build("")
  return pick_executable(vim.fn.getcwd() .. "/target/debug")
end

function M.debug_example()
  cargo_build("--examples")
  return pick_executable(vim.fn.getcwd() .. "/target/debug/examples")
end

function M.debug_tests()
  cargo_build("--tests --no-run")
  return pick_executable(vim.fn.getcwd() .. "/target/debug/deps")
end

return M

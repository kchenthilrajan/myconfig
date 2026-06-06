local M = {}

function M.get()
  local path = vim.fn.expand '%:p'
  if path == '' then return '' end
  local cwd = vim.fn.getcwd() .. '/'
  local rel = path:gsub('^' .. vim.pesc(cwd), '')
  return '%#Comment# ' .. rel .. '%*'
end

return M

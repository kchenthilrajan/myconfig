-- Symbol abbreviations (insert mode)
vim.cmd('iabbrev :right: →')
vim.cmd('iabbrev :left: ←')
vim.cmd('iabbrev :up: ↑')
vim.cmd('iabbrev :down: ↓')
vim.cmd('iabbrev :tick: ✓')
vim.cmd('iabbrev :cross: ✗')
vim.cmd('iabbrev :star: ★')
vim.cmd('iabbrev :bull: •')

-- Restore previous session on startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argc() == 0 then
      require('persistence').load()
    end
  end,
  nested = true,
})

-- netrw settings
vim.g.netrw_browse_split = 4
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.g.netrw_liststyle = 3

-- Safe buffer close — always leaves a real window open
local function safe_bd()
  local current = vim.api.nvim_get_current_buf()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  if #buffers <= 1 then
    vim.cmd 'enew'
  else
    vim.cmd 'bnext'
  end
  vim.cmd('bd ' .. current)
end

vim.keymap.set('n', '<leader>bd', safe_bd, { desc = '[B]uffer [d]elete' })
vim.keymap.set({ 'n', 'i' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })
vim.api.nvim_create_user_command('Bd', safe_bd, {})

-- Toggle [ ] <-> [x] checkbox (works in .txt or .md)
vim.keymap.set('n', '<leader>x', function()
  local line = vim.api.nvim_get_current_line()
  local new_line
  if line:match('%[x%]') then
    new_line = line:gsub('%[x%]', '[ ]', 1)
  elseif line:match('%[ %]') then
    new_line = line:gsub('%[ %]', '[x]', 1)
  else
    return
  end
  vim.api.nvim_set_current_line(new_line)
end, { desc = 'Toggle checkbox' })

-- Strikethrough highlight for [x] done lines (txt + md files)
local function apply_todo_highlights()
  vim.api.nvim_set_hl(0, 'TodoDone', { italic = true, fg = '#5a8a6a', bg = '#1e2f28' })
  vim.fn.clearmatches()
  vim.fn.matchadd('TodoDone', [[\[x\].*]])
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = { '*.txt', '*.md', '*.notes' },
  callback = apply_todo_highlights,
})

-- Apply immediately to current buffer if applicable
local ext = vim.fn.expand('%:e')
if ext == 'txt' or ext == 'md' or ext == 'notes' then
  apply_todo_highlights()
end

-- Toggle neo-tree
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = 'which_key_ignore' })

-- Make :q close nvim entirely when neo-tree is the only remaining window
vim.api.nvim_create_autocmd('QuitPre', {
  callback = function()
    local wins = vim.api.nvim_list_wins()
    local neo_tree_wins = vim.tbl_filter(function(w)
      return vim.bo[vim.api.nvim_win_get_buf(w)].filetype == 'neo-tree'
    end, wins)
    if #wins - #neo_tree_wins <= 1 then
      for _, w in ipairs(neo_tree_wins) do
        vim.api.nvim_win_close(w, true)
      end
    end
  end,
})


-- JS/TS: disable all computed indentexpr; rely on autoindent (copies previous line)
-- Vim's built-in javascript.vim and treesitter both return 0 for some class-body lines
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  callback = function()
    vim.opt_local.indentexpr = ''
    vim.opt_local.cindent = false
    vim.opt_local.smartindent = false
  end,
})

-- Reset terminal keypad mode when leaving nvim
vim.api.nvim_create_autocmd('VimLeave', {
  callback = function()
    io.write('\027[?1l\027>')
  end,
})

-- Command history via Telescope
vim.keymap.set('n', '<leader>sc', '<cmd>Telescope command_history<cr>', { desc = 'Search command history' })

-- Folding (nvim-ufo)
vim.keymap.set('n', 'zR', function() require('ufo').openAllFolds() end)
vim.keymap.set('n', 'zM', function() require('ufo').closeAllFolds() end)
vim.keymap.set('n', 'zK', function() require('ufo').peekFoldedLinesUnderCursor() end)

-- Bufferline navigation
vim.keymap.set('n', '<leader>bh', '<cmd>BufferLineCyclePrev<CR>', { desc = '[B]uffer previous' })
vim.keymap.set('n', '<leader>bl', '<cmd>BufferLineCycleNext<CR>', { desc = '[B]uffer next' })

-- Buffer management
vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<CR>', { desc = '[B]uffer [p]in toggle' })
vim.keymap.set('n', '<leader>bx', '<cmd>BufferLineCloseOthers<CR>', { desc = '[B]uffer close others' })
vim.keymap.set('n', '<leader>bn', function()
  -- find a non-neo-tree window to open the new buffer in
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(w)].filetype ~= 'neo-tree'
      and vim.api.nvim_win_get_config(w).relative == '' then
      vim.api.nvim_set_current_win(w)
      vim.cmd 'enew'
      return
    end
  end
  -- no normal window found, create a split
  vim.cmd 'vsplit enew'
end, { desc = 'New empty buffer' })

-- Winbar: show full relative file path at top of each buffer, auto-updates on buffer switch
vim.opt.winbar = "%{%v:lua.require('custom.winbar').get()%}"

-- Copy full file path to clipboard
vim.keymap.set('n', '<leader>yp', function()
  local path = vim.fn.expand '%:p'
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path)
end, { desc = 'Copy full file path to clipboard' })

-- Favorite commands palette — fuzzy pick and run
local favorites = {
  { label = 'SuperMaven Start',     cmd = 'SupermavenStart' },
  { label = 'SuperMaven Stop',      cmd = 'SupermavenStop' },
  { label = 'Markdown Preview',     cmd = 'MarkdownPreview' },
  { label = 'Markdown Preview Stop',cmd = 'MarkdownPreviewStop' },
  { label = 'Lazy Update',          cmd = 'Lazy update' },
  { label = 'Lazy Sync',            cmd = 'Lazy sync' },
  { label = 'Iron Open REPL',       cmd = 'IronRepl' },
  { label = 'Iron Restart REPL',    cmd = 'IronRestart' },
  { label = 'Diffview Open',        cmd = 'DiffviewOpen' },
  { label = 'Diffview Close',       cmd = 'DiffviewClose' },
  { label = 'Diffview File History',cmd = 'DiffviewFileHistory %' },
  { label = 'Noice Log',            cmd = 'Noice' },
  { label = 'LSP Info',             cmd = 'LspInfo' },
  { label = 'LSP Restart',          cmd = 'LspRestart' },
  { label = 'Format Buffer',        cmd = 'lua vim.lsp.buf.format()' },
}

vim.keymap.set('n', '<leader>oc', function()
  local pickers  = require 'telescope.pickers'
  local finders  = require 'telescope.finders'
  local conf     = require('telescope.config').values
  local actions  = require 'telescope.actions'
  local state    = require 'telescope.actions.state'

  pickers.new({}, {
    prompt_title = 'Commands',
    finder = finders.new_table {
      results = favorites,
      entry_maker = function(entry)
        return { value = entry, display = entry.label, ordinal = entry.label }
      end,
    },
    sorter = conf.generic_sorter {},
    attach_mappings = function(buf, map)
      actions.select_default:replace(function()
        actions.close(buf)
        vim.cmd(state.get_selected_entry().value.cmd)
      end)
      return true
    end,
  }):find()
end, { desc = 'Open favorite commands palette' })

-- Symbol abbreviations (insert mode)
vim.cmd('iabbrev :right: →')
vim.cmd('iabbrev :left: ←')
vim.cmd('iabbrev :up: ↑')
vim.cmd('iabbrev :down: ↓')
vim.cmd('iabbrev :tick: ✓')
vim.cmd('iabbrev :cross: ✗')
vim.cmd('iabbrev :star: ★')
vim.cmd('iabbrev :bull: •')

-- Superscript Latin letters beyond the stock 'n' (Ctrl-K nS). Vim's built-in
-- digraph table only ships superscript digits/n/+/-; Unicode defines the rest
-- of the alphabet too (IPA modifier letters block — no 'q' exists anywhere).
-- Same Ctrl-K <letter>S pattern, e.g. Ctrl-K aS -> ᵃ, Ctrl-K tS -> ᵗ.
-- Overwrites 3 rarely-used built-ins: aS (Arabic superscript alef), cS (♠), fS (■).
local superscript_letter_codepoints = {
  a = 0x1D43, b = 0x1D47, c = 0x1D9C, d = 0x1D48, e = 0x1D49, f = 0x1DA0,
  g = 0x1D4D, h = 0x02B0, i = 0x2071, j = 0x02B2, k = 0x1D4F, l = 0x02E1,
  m = 0x1D50, o = 0x1D52, p = 0x1D56, r = 0x02B3, s = 0x02E2, t = 0x1D57,
  u = 0x1D58, v = 0x1D5B, w = 0x02B7, x = 0x02E3, y = 0x02B8, z = 0x1DBB,
}
local superscript_digraphs = {}
for letter, codepoint in pairs(superscript_letter_codepoints) do
  table.insert(superscript_digraphs, { letter .. 'S', vim.fn.nr2char(codepoint) })
end
vim.fn.digraph_setlist(superscript_digraphs)

-- Restore previous session on startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argc() == 0 then
      require('persistence').load()
    end
  end,
  nested = true,
})

-- Workspace switching, VSCode-style: swap the whole buffer set for another
-- project folder. persistence.nvim handles saved-file layout per folder,
-- but session files never capture unsaved buffer text (verified:
-- :mksession only records file paths + cursor position). So unnamed and
-- unsaved-but-named buffers are stashed to disk per-folder here and
-- replayed (still marked modified, not written to their files) when that
-- folder is revisited — a mini "hot exit" scoped to each workspace.
--
-- A global, disk-backed history of every folder ever switched to/from
-- (most-recent-first) backs a picker so folders are reachable from any
-- nvim instance, not just the one that first visited them.
local workspace_stash_dir = vim.fn.stdpath 'state' .. '/workspace-stash'
local workspace_history_file = vim.fn.stdpath 'state' .. '/workspace-history.json'

local function read_json(path)
  if vim.fn.filereadable(path) == 0 then
    return nil
  end
  local file = io.open(path, 'r')
  if not file then
    return nil
  end
  local content = file:read '*a'
  file:close()
  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    return nil
  end
  return data
end

local function write_json(path, data)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  local file = io.open(path, 'w')
  if file then
    file:write(vim.json.encode(data))
    file:close()
  end
end

local function normalize_dir(dir)
  return (vim.fn.fnamemodify(dir, ':p'):gsub('/$', ''))
end

local function record_workspace_history(dir)
  dir = normalize_dir(dir)
  local history = read_json(workspace_history_file) or {}
  local updated = { dir }
  for _, d in ipairs(history) do
    if d ~= dir then
      table.insert(updated, d)
    end
  end
  write_json(workspace_history_file, updated)
end

local function stash_path(dir)
  return workspace_stash_dir .. '/' .. vim.fn.sha256(normalize_dir(dir)) .. '.json'
end

local function stash_unsaved_buffers(dir)
  local entries = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' and vim.bo[buf].modified then
      table.insert(entries, {
        name = vim.api.nvim_buf_get_name(buf),
        lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false),
        filetype = vim.bo[buf].filetype,
      })
    end
  end

  local path = stash_path(dir)
  if #entries == 0 then
    vim.fn.delete(path)
    return
  end

  vim.fn.mkdir(workspace_stash_dir, 'p')
  local file = io.open(path, 'w')
  if file then
    file:write(vim.json.encode(entries))
    file:close()
  end
end

local function restore_unsaved_buffers(dir)
  local entries = read_json(stash_path(dir))
  if not entries then
    return
  end

  for i, entry in ipairs(entries) do
    local bufnr
    if entry.name ~= '' then
      bufnr = vim.fn.bufnr(entry.name, true)
    else
      bufnr = vim.api.nvim_create_buf(true, false)
    end
    vim.fn.bufload(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, entry.lines)
    vim.bo[bufnr].modified = true
    if entry.filetype and entry.filetype ~= '' then
      vim.bo[bufnr].filetype = entry.filetype
    end
    -- first entry reuses the current window; only extras get their own tab
    if i == 1 then
      vim.cmd('buffer ' .. bufnr)
    else
      vim.cmd('tab sbuffer ' .. bufnr)
    end
  end

  vim.fn.delete(stash_path(dir))
end

local function switch_workspace(target_dir)
  if not target_dir or target_dir == '' then
    return
  end
  target_dir = normalize_dir(target_dir)
  if vim.fn.isdirectory(target_dir) == 0 then
    vim.notify('Not a directory: ' .. target_dir, vim.log.levels.ERROR)
    return
  end

  local current = normalize_dir(vim.fn.getcwd())
  if target_dir == current then
    return
  end

  require('persistence').save()
  stash_unsaved_buffers(current)
  record_workspace_history(current)
  vim.cmd 'silent! tabonly!'
  vim.cmd 'silent! %bd!'

  vim.cmd('cd ' .. vim.fn.fnameescape(target_dir))
  require('persistence').load()
  restore_unsaved_buffers(target_dir)
  record_workspace_history(target_dir)

  -- the jumplist (<C-o>/<C-i>) survives the buffer wipe above by filename,
  -- not bufnr — without this, jumping in the new workspace re-opens files
  -- from whichever workspace was open when those jumps were recorded.
  vim.cmd 'silent! clearjumps'
end

local function remove_from_history(dir)
  dir = normalize_dir(dir)
  local history = read_json(workspace_history_file) or {}
  write_json(
    workspace_history_file,
    vim.tbl_filter(function(d)
      return d ~= dir
    end, history)
  )
end

local function pick_workspace()
  local current = normalize_dir(vim.fn.getcwd())
  local history = vim.tbl_filter(function(d)
    return d ~= current
  end, read_json(workspace_history_file) or {})

  if #history == 0 then
    vim.ui.input({ prompt = 'Switch to workspace: ', default = current .. '/../', completion = 'dir' }, function(dir)
      if dir and dir ~= '' then
        switch_workspace(dir)
      end
    end)
    return
  end

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  pickers
    .new({}, {
      prompt_title = 'Switch Workspace (<C-d>/dd: remove)',
      finder = finders.new_table { results = history },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            switch_workspace(selection[1])
          end
        end)

        local function delete_selected()
          local selection = action_state.get_selected_entry()
          if not selection then
            return
          end
          remove_from_history(selection[1])
          local picker = action_state.get_current_picker(prompt_bufnr)
          picker:refresh(finders.new_table { results = read_json(workspace_history_file) or {} }, { reset_prompt = false })
        end

        map('i', '<C-d>', delete_selected)
        map('n', '<C-d>', delete_selected)
        map('n', 'dd', delete_selected)

        return true
      end,
    })
    :find()
end

vim.api.nvim_create_user_command('SwitchWorkspace', function(opts)
  if opts.args ~= '' then
    switch_workspace(opts.args)
  else
    pick_workspace()
  end
end, { nargs = '?', complete = 'dir', desc = 'Switch to another project workspace' })

vim.keymap.set('n', '<leader>pw', pick_workspace, { desc = '[P]roject [w]orkspace switch' })

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

  -- Real ~~strikethrough~~, via matchadd (not treesitter): render-markdown.nvim
  -- calls vim.treesitter.stop() on markdown buffers and its own markdown_inline
  -- handler doesn't implement the (strikethrough) node, so the base @markup.strikethrough
  -- capture never reaches the screen even though it parses correctly. matchadd
  -- is independent of that, so it works regardless.
  vim.api.nvim_set_hl(0, 'MdStrikethrough', { strikethrough = true })
  vim.fn.matchadd('MdStrikethrough', [[\~\~[^~]\+\~\~]], 1000)
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
vim.keymap.set('n', '<leader>e', ':Neotree toggle reveal<CR>', { desc = 'which_key_ignore' })

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


-- JS/TS: disable the computed indentexpr (Vim's javascript.vim and treesitter
-- both return 0 for some class-body lines), but keep smartindent on so a line
-- ending in `{` indents the next line one shiftwidth and `}` dedents.
-- smartindent is a separate heuristic from indentexpr, so it sidesteps that bug.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  callback = function()
    vim.opt_local.indentexpr = ''
    vim.opt_local.cindent = false
    vim.opt_local.smartindent = true
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

-- Native fold peek: float the contents of the closed fold under the cursor
-- (like ufo's zK, but works where ufo is disabled — HTML/CSS). One float at a
-- time; auto-closes when the cursor moves / you leave the buffer.
local peek_win = nil
local function close_peek()
  if peek_win and vim.api.nvim_win_is_valid(peek_win) then
    vim.api.nvim_win_close(peek_win, true)
  end
  peek_win = nil
end
local function peek_fold()
  close_peek()
  local cur = vim.fn.line '.'
  local fstart = vim.fn.foldclosed(cur)
  if fstart == -1 then
    return -- no closed fold under cursor
  end
  local fend = vim.fn.foldclosedend(cur)
  local lines = vim.api.nvim_buf_get_lines(0, fstart - 1, fend, false)
  local width = 20
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = math.min(width + 1, math.floor(vim.o.columns * 0.8))
  local height = math.min(#lines, math.floor(vim.o.lines * 0.6))
  local ft = vim.bo.filetype
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = ft -- syntax-highlight the preview
  peek_win = vim.api.nvim_open_win(buf, false, {
    relative = 'cursor', row = 1, col = 0,
    width = width, height = height,
    style = 'minimal', border = 'rounded',
  })
  vim.wo[peek_win].winblend = 15 -- slight transparency so the buffer shows through
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'InsertEnter', 'BufLeave' }, {
    once = true,
    callback = close_peek,
  })
end

-- HTML/CSS/etc: use Neovim's native treesitter folding (granular section
-- outline). ufo is disabled for these filetypes (see nvim-ufo
-- provider_selector), so drive folds with vim's own fold engine and restore
-- native zM/zR/zK (the global maps above call ufo, which isn't attached here).
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'html', 'css', 'scss', 'less', 'xml' },
  callback = function(ev)
    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt_local.foldtext = ''
    vim.opt_local.foldlevel = 99 -- start fully open; zM to collapse to outline
    vim.keymap.set('n', 'zR', 'zR', { buffer = ev.buf, remap = false, desc = 'Open all folds (native)' })
    vim.keymap.set('n', 'zM', 'zM', { buffer = ev.buf, remap = false, desc = 'Close all folds (native)' })
    vim.keymap.set('n', 'zK', peek_fold, { buffer = ev.buf, desc = 'Peek folded lines (native)' })

    -- Auto-peek: after a ~600ms dwell, if the cursor is at column 1 (start of
    -- a line) AND sitting on a closed fold, pop the peek overlay. The uv timer
    -- guarantees a real ~600ms pause independent of &updatetime.
    local timer
    vim.api.nvim_create_autocmd('CursorMoved', {
      buffer = ev.buf,
      callback = function()
        if timer then
          timer:stop()
          timer:close()
          timer = nil
        end
        timer = (vim.uv or vim.loop).new_timer()
        timer:start(600, 0, vim.schedule_wrap(function()
          if timer then
            timer:stop()
            timer:close()
            timer = nil
          end
          if vim.fn.mode() ~= 'n' then return end        -- normal mode only
          if vim.fn.col '.' ~= 1 then return end           -- leftmost column only
          if vim.fn.foldclosed(vim.fn.line '.') == -1 then return end -- closed fold only
          peek_fold()
        end))
      end,
    })
  end,
})

-- Bufferline navigation
vim.keymap.set('n', '<leader>bh', '<cmd>BufferLineCyclePrev<CR>', { desc = '[B]uffer previous' })
vim.keymap.set('n', '<leader>bl', '<cmd>BufferLineCycleNext<CR>', { desc = '[B]uffer next' })

-- Buffer management
vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<CR>', { desc = '[B]uffer [p]in toggle' })
vim.keymap.set('n', '<leader>bx', '<cmd>BufferLineCloseOthers<CR>', { desc = '[B]uffer close others' })
vim.keymap.set('n', '<leader>bn', function()
  -- A "normal" editable window: not floating, not neo-tree, not a terminal.
  local function is_normal(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.api.nvim_win_get_config(win).relative == ''
      and vim.bo[buf].filetype ~= 'neo-tree'
      and vim.bo[buf].buftype ~= 'terminal'
  end
  -- Prefer the current window so the cursor stays put; only hunt for another
  -- window if we're currently in neo-tree / the terminal / a float.
  if is_normal(vim.api.nvim_get_current_win()) then
    vim.cmd 'enew'
    return
  end
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if is_normal(w) then
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

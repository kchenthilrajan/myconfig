return {
  {
    'nvim-tree/nvim-web-devicons',
    lazy = false,
    config = function()
      require('nvim-web-devicons').setup { default = true }
    end,
  },
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {},
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'molokai',
          component_separators = { left = '', right = '' },
          section_separators   = { left = '', right = '' },
        },
        sections = {
          lualine_a = { { 'mode', right_padding = 2 } },
          lualine_b = {
            { 'branch',      color = { fg = '#fbb829', gui = 'bold' } },
            { 'diff',        colored = true },
            { 'diagnostics', colored = true },
          },
          lualine_c = {
            {
              function()
                local clients = vim.lsp.get_clients { bufnr = 0 }
                if #clients == 0 then return '' end
                local names = vim.tbl_map(function(c) return c.name end, clients)
                return ' ' .. table.concat(names, ', ')
              end,
              color = { fg = '#68a8e4', gui = 'italic' },
            },
          },
          lualine_x = { { 'filetype', colored = true, icon_only = false } },
          lualine_y = {
            {
              function()
                local cur = vim.fn.line '.'
                local total = vim.fn.line '$'
                return cur .. '/' .. total
              end,
              color = { fg = '#96a6c8' },
            },
            { 'progress', color = { fg = '#96a6c8' } },
          },
          lualine_z = { { 'location', left_padding = 2 } },
        },
      }
    end,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup {
        close_if_last_window = true,
        window = {
          position = 'right',
          width = 40,
          mappings = {
            ['Y'] = function(state)
              local node = state.tree:get_node()
              vim.fn.setreg('+', node.name)
              vim.notify('Copied: ' .. node.name)
            end,
            ['gy'] = function(state)
              local node = state.tree:get_node()
              vim.fn.setreg('+', node.path)
              vim.notify('Copied path: ' .. node.path)
            end,
          },
        },
      }
    end,
  },
  {
    'folke/persistence.nvim',
    lazy = false,
    opts = {},
  },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    config = function()
      vim.opt.foldcolumn = '1'
      vim.opt.fillchars:append {
        foldopen  = '▾',
        foldclose = '▸',
        fold      = ' ',
        foldsep   = ' ',
      }
      require('ufo').setup {
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      max_lines = 3,
      trim_scope = 'outer',
    },
  },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end,            { desc = 'Harpoon add file' })
      vim.keymap.set('n', '<leader>h', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon menu' })

      vim.keymap.set('n', '<C-1>', function() harpoon:list():select(1) end, { desc = 'Harpoon file 1' })
      vim.keymap.set('n', '<C-2>', function() harpoon:list():select(2) end, { desc = 'Harpoon file 2' })
      vim.keymap.set('n', '<C-3>', function() harpoon:list():select(3) end, { desc = 'Harpoon file 3' })
      vim.keymap.set('n', '<C-4>', function() harpoon:list():select(4) end, { desc = 'Harpoon file 4' })
    end,
  },
  {
    'jameswolensky/marker-groups.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
      require('marker-groups').setup { picker = 'telescope' }
    end,
    keys = {
      { '<leader>ma',  desc = 'Marker add' },
      { '<leader>mv',  desc = 'Marker toggle drawer' },
      { '<leader>mgc', desc = 'Marker group create' },
      { '<leader>mgl', desc = 'Marker group list' },
      { '<leader>mgs', desc = 'Marker group select' },
    },
  },
  -- ── Colorschemes (lazy = false so all appear in :colorscheme / Telescope
  --    completion; they only apply their highlights when selected) ─────────
  { 'catppuccin/nvim', name = 'catppuccin', lazy = false },
  { 'wurli/cobalt.nvim',              lazy = false },
  { 'silentium-theme/silentium.nvim', lazy = false },
  { 'navarasu/onedark.nvim',          lazy = false, opts = { style = 'deep' } },
  { 'ray-x/aurora',                   lazy = false },
  { 'marko-cerovac/material.nvim',    lazy = false, config = function() vim.g.material_style = 'darker' end },
  { 'yonatanperel/lake-dweller.nvim', lazy = false, config = function() require('lake-dweller').setup { variant = 'ocean-dweller' } end },
  { 'tpope/vim-vividchalk',           lazy = false },
  { 'christerso/voidlight-lazyvim-theme', lazy = false },
  { 'f4z3r/gruvbox-material.nvim',    lazy = false },
  { 'mhartington/oceanic-next',       lazy = false },                          -- :colorscheme OceanicNext
  { 'Shatur/neovim-ayu',              lazy = false, name = 'ayu' },             -- :colorscheme ayu
  { 'ellisonleao/gruvbox.nvim',       lazy = false },                          -- :colorscheme gruvbox
  { 'srcery-colors/srcery-vim',       lazy = false, init = function() vim.g.srcery_italic = 0 end }, -- :colorscheme srcery
  -- ── Active colorscheme ───────────────────────────────────────────────
  {
    'Abstract-IDE/Abstract-cs',
    priority = 1000,
    lazy = false,
    config = function()
      vim.cmd.colorscheme 'abscs'
      vim.opt.cursorline = true -- let abscs define CursorLine / CursorLineNr colors
    end,
  },
  {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup { disable_inline_completion = true }
    end,
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      terminal = { enabled = true },
      notifier = { enabled = true },
    },
    keys = {
      { '<leader>t', function() Snacks.terminal.toggle() end, desc = 'Toggle terminal' },
      { '<C-t>', function() Snacks.terminal.toggle() end, desc = 'Toggle terminal', mode = { 'n', 't' } },
    },
  },
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>',            desc = 'Open diff view' },
      { '<leader>gD', '<cmd>DiffviewClose<cr>',           desc = 'Close diff view' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>',   desc = 'File git history' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<cr>',     desc = 'Repo git history' },
    },
    opts = {},
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  },
  {
    'lervag/vimtex',
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_compiler_method = 'latexmk'
      vim.g.vimtex_compiler_latexmk = {
        build_dir = 'build',
        options = { '-pdf', '-interaction=nonstopmode', '-synctex=1' },
      }
      vim.g.vimtex_imaps_enabled = 0
    end,
  },
  {
    'mistweaverco/kulala.nvim',
    ft = { 'http', 'rest' },
    config = function()
      require('kulala').setup {
        default_view = 'body',
        winbar = true,
      }
      vim.keymap.set('n', '<leader>rr', function() require('kulala').run() end,         { desc = 'Run HTTP request' })
      vim.keymap.set('n', '<leader>ra', function() require('kulala').run_all() end,     { desc = 'Run all HTTP requests' })
      vim.keymap.set('n', '<leader>rn', function() require('kulala').jump_next() end,   { desc = 'Next HTTP request' })
      vim.keymap.set('n', '<leader>rp', function() require('kulala').jump_prev() end,   { desc = 'Prev HTTP request' })
      vim.keymap.set('n', '<leader>rc', function() require('kulala').copy() end,        { desc = 'Copy as curl command' })
      vim.keymap.set('n', '<leader>ri', function() require('kulala').inspect() end,     { desc = 'Inspect request' })
      vim.keymap.set('n', '<leader>rf', function() require('kulala').from_curl() end,  { desc = 'Import curl from clipboard → .http' })
    end,
  },
  {
    'Vigemus/iron.nvim',
    config = function()
      require('iron.core').setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            sh   = { command = { 'bash' } },
            zsh  = { command = { 'zsh' } },
            python = { command = { 'python3' } },
            javascript = { command = { 'node' } },
          },
          repl_open_cmd = require('iron.view').split.vertical.botright(0.4),
        },
        keymaps = {
          send_motion   = '<leader>ic',
          visual_send   = '<leader>ic',
          send_file     = '<leader>ia',
          send_line     = '<leader>il',
          send_until_cursor = '<leader>iu',
          send_mark     = '<leader>im',
          cr            = '<leader>i<cr>',
          interrupt     = '<leader>i<space>',
          exit          = '<leader>iq',
          clear         = '<leader>ix',
        },
        highlight = { italic = true },
      }
      vim.keymap.set('n', '<leader>io', '<cmd>IronRepl<cr>',   { desc = 'Open REPL' })
      vim.keymap.set('n', '<leader>ir', '<cmd>IronRestart<cr>', { desc = 'Restart REPL' })
      vim.keymap.set('n', '<leader>if', '<cmd>IronFocus<cr>',  { desc = 'Focus REPL' })
      vim.keymap.set('n', '<leader>ih', '<cmd>IronHide<cr>',   { desc = 'Hide REPL' })
    end,
  },
}

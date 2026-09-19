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
    -- Give the active buffer a solid, boxed-in look (OceanicNext's
    -- CursorLine shade + accent-blue indicator bar) instead of the default
    -- italic-only distinction, so it reads clearly at a glance.
    opts = {
      options = {
        indicator = { icon = '▎', style = 'icon' },
      },
      highlights = {
        fill = { bg = '#1b2b34' },
        background = { bg = '#1b2b34', fg = '#65737e' },
        buffer_visible = { bg = '#1b2b34', fg = '#65737e' },
        buffer_selected = { bg = '#343d46', fg = '#d8dee9', bold = true, italic = false },
        separator = { bg = '#1b2b34', fg = '#1b2b34' },
        separator_selected = { bg = '#343d46', fg = '#1b2b34' },
        indicator_selected = { bg = '#343d46', fg = '#6699cc' },
        modified = { bg = '#1b2b34' },
        modified_selected = { bg = '#343d46' },
        close_button = { bg = '#1b2b34' },
        close_button_selected = { bg = '#343d46' },
        numbers = { bg = '#1b2b34' },
        numbers_selected = { bg = '#343d46', bold = true },
      },
    },
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
          -- ufo's treesitter provider is coarse for markup (HTML/CSS fold
          -- all-or-nothing). Return '' to disable ufo for these filetypes so
          -- Neovim's native treesitter folding (granular) takes over — see
          -- the FileType autocmd in custom/keymaps.lua.
          local use_native = { html = true, css = true, scss = true, less = true, xml = true }
          if use_native[filetype] then
            return ''
          end
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
  -- ── Active colorscheme ───────────────────────────────────────────────
  {
    'mhartington/oceanic-next',
    priority = 1000,
    lazy = false,
    config = function()
      vim.cmd.colorscheme 'OceanicNext'
      vim.opt.cursorline = true
    end,
  },
  {
    'supermaven-inc/supermaven-nvim',
    enabled = false, -- off until LeetCode practice; flip to true (or remove) to re-enable
    config = function()
      require('supermaven-nvim').setup { disable_inline_completion = true }
    end,
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      terminal = {
        enabled = true,
        win = { position = 'bottom' }, -- open the terminal at the bottom of the editor
      },
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
  -- In-terminal rendered markdown (headings/code/tables/lists). Pairs with the
  -- global cursorline for a w3m-like read with current-line highlight (`mdview -n`).
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
  -- Smooth, animated scrolling — makes <C-e>/<C-y> (and <C-d>/<C-u>) glide
  -- instead of jumping. <C-e>/<C-y> still scroll the view without moving the
  -- cursor (mouse-wheel feel); hold the key for continuous smooth scroll.
  {
    'karb94/neoscroll.nvim',
    event = 'VeryLazy',
    config = function()
      local neoscroll = require 'neoscroll'
      neoscroll.setup {
        mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', 'zt', 'zz', 'zb' },
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true, -- viewport keeps scrolling at the edge
        easing = 'sine',
      }
      -- Custom <C-e>/<C-y>: ~3 lines per press, cursor stays put, short glide.
      vim.keymap.set({ 'n', 'v', 'x' }, '<C-e>', function()
        neoscroll.scroll(3, { move_cursor = false, duration = 90, easing = 'sine' })
      end, { desc = 'Smooth scroll view down' })
      vim.keymap.set({ 'n', 'v', 'x' }, '<C-y>', function()
        neoscroll.scroll(-3, { move_cursor = false, duration = 90, easing = 'sine' })
      end, { desc = 'Smooth scroll view up' })
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

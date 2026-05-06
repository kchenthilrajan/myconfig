return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {
      options = {
        numbers = 'ordinal', -- shows 1, 2, 3... so <leader>1-9 makes sense
      },
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { 'filetype' },
          lualine_y = {
            {
              function()
                local cur = vim.fn.line '.'
                local total = vim.fn.line '$'
                return cur .. '/' .. total
              end,
            },
            'progress',
          },
          lualine_z = { 'location' },
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
      require('ufo').setup {
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      }
    end,
  },
  {
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      require('onedark').setup { style = 'deep' }
      require('onedark').load()
      local function set_highlights()
        vim.api.nvim_set_hl(0, 'WinSeparator',            { fg = '#f9e2af', bold = true })
        vim.api.nvim_set_hl(0, 'NormalNC',               { bg = '#2a2b36', fg = '#6b7280' })
        vim.api.nvim_set_hl(0, 'CursorLine',             { bg = '#2d3550' })
        vim.api.nvim_set_hl(0, 'Visual',                 { bg = '#3d5a8a', fg = 'NONE' })
        vim.api.nvim_set_hl(0, 'TelescopeBorder',        { fg = '#89b4fa' })
        vim.api.nvim_set_hl(0, 'TelescopePromptBorder',  { fg = '#f38ba8' })
        vim.api.nvim_set_hl(0, 'TelescopeResultsBorder', { fg = '#89b4fa' })
        vim.api.nvim_set_hl(0, 'TelescopePreviewBorder', { fg = '#a6e3a1' })
        vim.api.nvim_set_hl(0, 'TelescopePromptTitle',   { fg = '#f38ba8', bold = true })
        vim.api.nvim_set_hl(0, 'TelescopeResultsTitle',  { fg = '#89b4fa', bold = true })
        vim.api.nvim_set_hl(0, 'TelescopePreviewTitle',  { fg = '#a6e3a1', bold = true })
      end
      set_highlights()
      vim.api.nvim_create_autocmd('ColorScheme', { callback = set_highlights })
    end,
  },
  {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup {}
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
}

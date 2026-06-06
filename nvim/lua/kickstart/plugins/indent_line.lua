return {
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      local dim = {
        'DimRed', 'DimYellow', 'DimBlue', 'DimOrange',
        'DimGreen', 'DimViolet', 'DimCyan',
      }
      local bright = {
        'BrightRed', 'BrightYellow', 'BrightBlue', 'BrightOrange',
        'BrightGreen', 'BrightViolet', 'BrightCyan',
      }

      local hooks = require 'ibl.hooks'
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'DimRed',       { fg = '#5a3035' })
        vim.api.nvim_set_hl(0, 'DimYellow',    { fg = '#5a4c2e' })
        vim.api.nvim_set_hl(0, 'DimBlue',      { fg = '#27435e' })
        vim.api.nvim_set_hl(0, 'DimOrange',    { fg = '#523d26' })
        vim.api.nvim_set_hl(0, 'DimGreen',     { fg = '#2e4a27' })
        vim.api.nvim_set_hl(0, 'DimViolet',    { fg = '#4a2757' })
        vim.api.nvim_set_hl(0, 'DimCyan',      { fg = '#1f4548' })
        vim.api.nvim_set_hl(0, 'BrightRed',    { fg = '#E06C75' })
        vim.api.nvim_set_hl(0, 'BrightYellow', { fg = '#E5C07B' })
        vim.api.nvim_set_hl(0, 'BrightBlue',   { fg = '#61AFEF' })
        vim.api.nvim_set_hl(0, 'BrightOrange', { fg = '#D19A66' })
        vim.api.nvim_set_hl(0, 'BrightGreen',  { fg = '#98C379' })
        vim.api.nvim_set_hl(0, 'BrightViolet', { fg = '#C678DD' })
        vim.api.nvim_set_hl(0, 'BrightCyan',   { fg = '#56B6C2' })
      end)

      require('ibl').setup {
        indent = { highlight = dim },
        scope  = { highlight = bright },
      }
    end,
  },
}

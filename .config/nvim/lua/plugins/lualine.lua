return {
  {
    'nvim-lualine/lualine.nvim',
    opts = function(_, opts)
      -- Remove the default lualine_c section ("nvim")
      table.remove(opts.sections.lualine_c, 1)

      -- After removal:
      -- [1] diagnostics
      -- [2] filetype
      -- [3] pretty_path

      local filetype = opts.sections.lualine_c[2]
      local pretty_path = opts.sections.lualine_c[3]

      -- Reorder the sections to have:
      -- diagnostics → pretty_path → filetype
      opts.sections.lualine_c[2] = pretty_path
      opts.sections.lualine_c[3] = filetype

      -- No separator after pretty_path
      pretty_path.separator = ''

      -- Chevron after filetype
      filetype.separator = ''

      -- Adjust spacing for the icon
      filetype.padding = {
        left = 1,
        right = 1,
      }

      -- Remove the copilot component from lualine_x
      table.remove(opts.sections.lualine_x, 2)

      -- Remove Lazy's updates component from lualine_x
      opts.sections.lualine_x = vim.tbl_filter(function(component)
        return not (type(component) == 'table' and component[1] == require('lazy.status').updates)
      end, opts.sections.lualine_x)
    end,
  },
}

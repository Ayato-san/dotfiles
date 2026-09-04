return {
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        astro = { 'prettier', 'oxfmt', stop_after_first = true },
        javascript = { 'prettier', 'oxfmt', stop_after_first = true },
        javascriptreact = { 'prettier', 'oxfmt', stop_after_first = true },
        json = { 'prettier', 'oxfmt', stop_after_first = true },
        jsonc = { 'prettier', 'oxfmt', stop_after_first = true },
        svelte = { 'prettier', 'oxfmt', stop_after_first = true },
        typescript = { 'prettier', 'oxfmt', stop_after_first = true },
        typescriptreact = { 'prettier', 'oxfmt', stop_after_first = true },
        vue = { 'prettier', 'oxfmt', stop_after_first = true },
      },

      formatters = {
        oxfmt = {
          prepend_args = function(_, ctx)
            local config = vim.fs.find({
              '.oxfmtrc.json',
              '.oxfmtrc.jsonc',
              'oxfmt.config.ts',
              'oxfmt.config.mts',
            }, {
              path = vim.fs.dirname(ctx.filename),
              upward = true,
            })[1]

            -- If a config file is found, use it;
            if config then
              return {}
            end

            -- If no config file is found, use the default config file in the user's home directory;
            return {
              '--config',
              vim.fn.expand('~/.config/oxfmt/.oxfmtrc.json'),
            }
          end,
        },
      },
    },
  },
}

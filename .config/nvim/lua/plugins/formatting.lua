return {
  {
    'stevearc/conform.nvim',
    opts = {
      formatters = {
        oxfmt = {
          prepend_args = function(self, ctx)
            local project_config = vim.fs.find({
              '.oxfmtrc.json',
              '.oxfmtrc.jsonc',
              'oxfmt.config.ts',
              'oxfmt.config.mts',
            }, {
              path = vim.fs.dirname(ctx.filename),
              upward = true,
            })[1]

            -- Config présente dans le projet :
            -- on laisse oxfmt la détecter tout seul.
            if project_config then
              return {}
            end

            -- Sinon, config personnelle globale.
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

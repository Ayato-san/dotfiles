return {
  'mrcjkb/rustaceanvim',
  version = '^5', -- Recommended
  lazy = false, -- This plugin is already lazy-loaded on rust files
  init = function()
    vim.g.rustaceanvim = {
      server = {
        cmd = function()
          return { 'rust-analyzer' } -- Resolves rust-analyzer dynamically from Nix PATH
        end,
      },
    }
  end,
}

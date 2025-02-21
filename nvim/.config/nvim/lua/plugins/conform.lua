return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        '<leader>F',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { "prettier" },
        typescript = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        go = { "gofumpt" },
        bicep = { "bicep" },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 

return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  }
--   "tadmccorkle/markdown.nvim",
--   event = "VeryLazy",
--   ft = {"markdown", "md"},
--   config = function()
--   require("markdown").setup(
--     {
--       -- disable all keymaps by setting mappings field to 'false'
--       -- selectively disable keymaps by setting corresponding field to 'false'
--       mappings = {
--         inline_surround_toggle = "ts", -- (string|boolean) toggle inline style
--         inline_surround_toggle_line = "tS", -- (string|boolean) line-wise toggle inline style
--         inline_surround_delete = "ds", -- (string|boolean) delete emphasis surrounding cursor
--         inline_surround_change = "cs", -- (string|boolean) change emphasis surrounding cursor
--         link_add = "mil", -- (string|boolean) add link
--         link_follow = "mgf", -- (string|boolean) follow link
--         go_curr_heading = "]c", -- (string|boolean) set cursor to current section heading
--         go_parent_heading = "]p", -- (string|boolean) set cursor to parent section heading
--         go_next_heading = "]]", -- (string|boolean) set cursor to next section heading
--         go_prev_heading = "[[", -- (string|boolean) set cursor to previous section heading
--       },
--       inline_surround = {
--         -- for the emphasis, strong, strikethrough, and code fields:
--         -- * key: used to specify an inline style in toggle, delete, and change operations
--         -- * txt: text inserted when toggling or changing to the corresponding inline style
--         emphasis = {
--           key = "i",
--           txt = "*",
--         },
--         strong = {
--           key = "b",
--           txt = "**",
--         },
--         strikethrough = {
--           key = "s",
--           txt = "~~",
--         },
--         code = {
--           key = "c",
--           txt = "`",
--         },
--       },
--       link = {
--         paste = {
--           enable = true, -- whether to convert URLs to links on paste
--         },
--       },
--       toc = {
--         -- comment text to flag headings/sections for omission in table of contents
--         omit_heading = "toc omit heading",
--         omit_section = "toc omit section",
--         -- cycling list markers to use in table of contents
--         -- use '.' and ')' for ordered lists
--         markers = { "-" },
--       },
--       -- hook functions allow for overriding or extending default behavior
--       -- fallback function with default behavior is provided as argument
--       hooks = {
--         -- called when following links with `dest` as the link destination
--         follow_link = nil, -- fun(dest: string, fallback: fun())
--       },
--       on_attach = function(bufnr)
--         local map = vim.keymap.set
--         local opts = { buffer = bufnr }
--         map({ 'n', 'i' }, 'mib', '<Cmd>MDListItemBelow<CR>', opts)
--         map({ 'n', 'i' }, 'mia', '<Cmd>MDListItemAbove<CR>', opts)
--         map('n', 'mt', '<Cmd>MDTaskToggle<CR>', opts)
--         map('x', '<M-c>', ':MDTaskToggle<CR>', opts)
--       end,
--  -- (fun(bufnr: integer)) callback when plugin attaches to a buffer
--     }
--     )
--   end
}

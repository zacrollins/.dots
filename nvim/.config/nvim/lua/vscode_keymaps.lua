--
-- Keymaps for vscode-neovim
--
local opts = { norepmap = true, silent = true }


vim.keymap.set("n", "<Space>", "", opts)

-- Navigation
vim.keymap.set({"n", "v"}, "<C-j>", ":call VSCodeNotify('workbench.action.naviageDown')<CR>", opts)
vim.keymap.set({"n", "v"}, "<C-k>", ":call VSCodeNotify('workbench.action.naviageUp')<CR>", opts)
vim.keymap.set({"n", "v"}, "<C-h>", ":call VSCodeNotify('workbench.action.naviageLeft')<CR>", opts)
vim.keymap.set({"n", "v"}, "<C-l>", ":call VSCodeNotify('workbench.action.naviageRight')<CR>", opts)

vim.keymap.set("n", "<C-w>_", ":call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>", opts)

-- yank/paste to system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", '"+y', opts)
vim.keymap.set({"n", "v"}, "<leader>p", '"+p', opts)

-- intent handling
vim.keymap.set("v", "<", '<gv', opts)
vim.keymap.set("v", ">", '>gv', opts)

-- remove hightlight after escaping vim search
vim.keymap.set("n", "<Esc>", "<Esc>:noh<CR>", opts)

-- whichkey
vim.keymap.set("n", "<Space>", ":call VSCodeNotify('whichkey.show')<CR>", opts)

-- 
vim.keymap.set({"n", "v"}, "<leader>tt", ":call VSCodeNotify('workbench.action.terminal.toggleTerminal')<CR>")
vim.keymap.set({"n", "v"}, "<leader>ta", ":call VSCodeNotify('workbench.action.toggleActivityBarVisibility')<CR>")



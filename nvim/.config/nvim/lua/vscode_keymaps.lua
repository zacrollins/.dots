--
-- Keymaps for vscode-neovim
--
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

--
-- Options

-- sync system clipboard
vim.opt.clipboard = 'unnamedplus'

-- search ignore case
vim.opt.ignorecase = true

-- disable "ignorecase" option if the search pattern contains upper case characters
vim.opt.smartcase = true

--
-- Keymaps

keymap("n", "<Space>", "", opts)

-- Navigation
-- keymap({"n", "v"}, "<C-j>", ":call VSCodeNotify('workbench.action.navigateDown')<CR>", opts)
-- keymap({"n", "v"}, "<C-k>", ":call VSCodeNotify('workbench.action.navigateUp')<CR>", opts)
-- keymap({"n", "v"}, "<C-h>", ":call VSCodeNotify('workbench.action.navigateLeft')<CR>", opts)
-- keymap({"n", "v"}, "<C-l>", ":call VSCodeNotify('workbench.action.navigateRight')<CR>", opts)
--
-- keymap("n", "<C-w>_", ":call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>", opts)

-- yank/paste to system clipboard
keymap({"n", "v"}, "<leader>y", '"+y', opts)
keymap({"n", "v"}, "<leader>p", '"+p', opts)

-- better indent handling
keymap("v", "<", '<gv', opts)
keymap("v", ">", '>gv', opts)

-- remove hightlight after escaping vim search
keymap("n", "<Esc>", "<Esc>:noh<CR>", opts)

-- move text up and down
keymap("v", "J", ":m .+1<CR>==", opts)
keymap("v", "K", ":m .-2<CR>==", opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- whichkey
-- keymap("n", "<Space>", ":call VSCodeNotify('whichkey.show')<CR>", opts)

-- show all open editors in popup
keymap("n", "<leader>,", "<Cmd>lua require('vscode').action('workbench.action.showAllEditors')<CR>")
-- splits
-- keymap("n", "ss", ":split")
-- keymap("n", "sv", ":vsplit<CR>")

--
-- keymap({"n", "v"}, "<leader>tt", ":call VSCodeNotify('workbench.action.terminal.toggleTerminal')<CR>")
-- keymap({"n", "v"}, "<leader>ta", ":call VSCodeNotify('workbench.action.toggleActivityBarVisibility')<CR>")

-- call vscode commands from neovim

-- general keymaps
keymap({"n", "v"}, "<leader>t", "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>")
keymap({"n", "v"}, "<leader>b", "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>")
keymap({"n", "v"}, "<leader>d", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>")
keymap({"n", "v"}, "<leader>a", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")
keymap({"n", "v"}, "<leader>sp", "<cmd>lua require('vscode').action('workbench.actions.view.problems')<CR>")
keymap({"n", "v"}, "<leader>cn", "<cmd>lua require('vscode').action('notifications.clearAll')<CR>")
keymap({"n", "v"}, "<leader>ff", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
keymap({"n", "v"}, "<leader>cp", "<cmd>lua require('vscode').action('workbench.action.showCommands')<CR>")
-- keymap({"n", "v"}, "<leader>pr", "<cmd>lua require('vscode').action('code-runner.run')<CR>")
keymap({"n", "v"}, "<leader>fd", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>")

-- project manager keymaps
keymap({"n", "v"}, "<leader>pa", "<cmd>lua require('vscode').action('projectManager.saveProject')<CR>")
keymap({"n", "v"}, "<leader>po", "<cmd>lua require('vscode').action('projectManager.listProjects')<CR>")
keymap({"n", "v"}, "<leader>pn", "<cmd>lua require('vscode').action('projectManager.listProjectsNewWindow')<CR>")
keymap({"n", "v"}, "<leader>pe", "<cmd>lua require('vscode').action('projectManager.editProjects')<CR>")

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

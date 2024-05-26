--
-- KEYMAPS
--
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Easier Saye and Quit
vim.keymap.set("n", "QQ", ":q!<enter>", { noremap = false })
vim.keymap.set("n", "WW", ":w!<enter>", { noremap = false })

-- Easy escape to normal mode
vim.keymap.set("i", "jk", "<Esc>")

-- Move selected lines up and down
vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv")

-- indent lines
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Remap for yanking and pasting from the system clipboard
vim.keymap.set({ "n", "v" }, "<Space>y", '"+y')
vim.keymap.set("n", "<Space>Y", '"+Y', { silent = true })
vim.keymap.set({ "n", "v" }, "<Space>p", '"+p', { silent = true })
vim.keymap.set({ "n", "v" }, "<Space>P", '"+P', { silent = true })

-- Get out of terminal mode easier
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]])
vim.keymap.set("n", "<leader>tt", ":lua require('FTerm').toggle()<CR>", { noremap = true })
vim.keymap.set("t", "<leader>tt", "<C-\\><C-n>:lua require('FTerm').toggle()<CR>", { noremap = true })
-- vim.keymap.set('n', '<leader>t', ':ToggleTerm name=scratch direction=float<CR>', { desc = 'Toggle floating terminal'})

-- Noice
vim.keymap.set("n", "<leader>nn", ":NoiceDismiss<CR>", { noremap = true })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Navigate vim panes better
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>", { desc = "Move focus to the right window" })

-- Buffers
-- vim.keymap.set("n", "<TAB>", ":bn<CR>")
-- vim.keymap.set("n", "<S-TAB>", ":bp<CR>")
-- vim.keymap.set("n", "<leader>bd", ":bd<CR>", {desc = "Buffer Delete"})
-- vim.keymap.set('n', 'tk', ':blast<enter>', { desc = 'Buffer Last' })
-- vim.keymap.set('n', 'tj', ':bfirst<enter>', { desc = 'Buffer First' })
-- vim.keymap.set('n', 'th', ':bprev<enter>', { desc = 'Buffer Previous' })
-- vim.keymap.set('n', 'tl', ':bnext<enter>', { desc = 'Buffer Next' })
-- vim.keymap.set('n', 'td', ':bdelete<enter>', { desc = 'Buffer Delete' })

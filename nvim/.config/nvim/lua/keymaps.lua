--
-- [[ KEYMAPS ]]
--
-- See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR><esc>', { desc = "Clear hlsearch and ESC" })

-- vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Easier Saye and Quit
vim.keymap.set("n", "QQ", ":q!<enter>", { noremap = false })
vim.keymap.set("n", "WW", ":w!<enter>", { noremap = false })

-- Easy escape to normal mode
vim.keymap.set("i", "jk", "<Esc>")

-- Move selected lines up and down
vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- indent lines
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Remap for yanking and pasting from the system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n"      }, "<leader>Y", '"+Y', { silent = true, desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { silent = true, desc = "Paste on next line" })
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P', { silent = true, desc = "Past above current line" })

-- Get out of terminal mode easier
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = 'Exit terminal mode' })

-- Noice
vim.keymap.set("n", "<leader>nn", ":NoiceDismiss<CR>", { noremap = true , desc = "Dismiss Noice notifications" })

--- highligh line number according to diagnostics
vim.diagnostic.config({
  signs = {
    -- text = {
    --   [vim.diagnostic.severity.ERROR] = "",
    --   [vim.diagnostic.severity.WARN] = "",
    --   [vim.diagnostic.severity.INFO] = "",
    --   [vim.diagnostic.severity.HINT] = "",
    -- },
    numhl = {
      [vim.diagnostic.severity.WARN] = "WarningMsg",
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticHint",
    },
  },
})

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>dj", function() vim.diagnostic.jump({ count = 1}) end, { desc = "Next [d]iagnostic [j]" })
vim.keymap.set("n", "<leader>dk", function() vim.diagnostic.jump({ count = -1}) end, { desc = "Prev [d]iagnostic [k]" })
vim.keymap.set("n", "<leader>dl", function() vim.diagnostic.open_float() end, { desc = "Toggle current [d]iagnostic [l]ist" })
vim.keymap.set("n", "<leader>dq", function() vim.diagnostic.setqflist() end, { desc = "Open [d]iag [q]uickfix list" })

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

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

local opt = vim.opt

-- Set highlight on search
opt.hlsearch = false

-- Make line numbers default
-- vim.wo.number = true
-- vim.wo.relativenumber = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true

-- Enable mouse mode
opt.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
opt.clipboard = 'unnamedplus'

-- Disable word wrapping, that shit has no place on code
vim.o.wrap = false

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- search settings
-- Case-insensitive searching UNLESS \C or capital in search
opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = 'yes'

-- Decrease update time
opt.updatetime = 250
-- Decrease Mapped sequenc wait time; make whichkey popup sooner
opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
-- opt.list = true
-- opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type
opt.inccommand = 'split'

-- show which line your cursor is on
opt.cursorline = true

-- min # of screen lines to keep above and below cursor
opt.scrolloff = 10

-- Set completeopt to have a better completion experience
opt.completeopt = 'menuone,noselect'

-- Concealer for Obsidian.nvim
opt.conceallevel=2

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

-- NOTE: You should make sure your terminal supports this
opt.termguicolors = true

-- Set tab and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

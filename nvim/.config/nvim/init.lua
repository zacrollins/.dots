-- -----------------
-- ZR Neovim Config
-- -----------------

-- Set <space> as the leader key
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

if vim.g.vscode then
  -- VSCode Neovim config
  require "vscode_keymaps"

else
  -- Set to true if you have a Nerd Font installed
  vim.g.have_nerd_font = true

  -- [[ Install `lazy.nvim` plugin manager ]]
  require('lazy-bootstrap')

  -- [[ Setting options ]]
  require('options')

  -- [[ Basic Keymaps ]]
  require('keymaps')

  -- [[ Configure plugins ]]
  require('lazy').setup('plugins')
end

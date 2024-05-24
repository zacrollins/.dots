return {
	-- Git related plugins
	{
		"tpope/vim-fugitive",
	},
	{
		"tpope/vim-rhubarb",
	},
	{
		-- Detect tabstop and shiftwidth automatically
		"tpope/vim-sleuth",
	},
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
}
-- vim: ts=2 sts=2 sw=2 et

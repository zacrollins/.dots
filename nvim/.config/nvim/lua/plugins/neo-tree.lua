return {
	"nvim-neo-tree/neo-tree.nvim",
	-- branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require('neo-tree').setup({
			close_if_last_window = true,
			window = {
				position = 'right',
				width = 30,
			},
			buffers = {
				follow_current_file = {
					enabled = true,
				},
			},
			filesystem = {
				follow_current_file = {
					enabled = true,
				},
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_by_name = {
						'node_modules'
					},
					never_show = {
						'.DS_Store',
						'thumbs.db'
					},
				},
				hijack_netrw_behavior = "open_current",
			},
		})
		vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal right toggle<CR>", {})
		vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
	end,
}

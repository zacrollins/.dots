return {
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').load_extension 'file_browser'
    end
  },
	{ -- Fuzy Finder
		'nvim-telescope/telescope.nvim',
		event = 'VimEnter',
		branch = '0.1.x',
		dependencies = {
			{ 'nvim-lua/plenary.nvim' },
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				'nvim-telescope/telescope-fzf-native.nvim',
				build = 'make',
				cond = function()
					return vim.fn.executable 'make' == 1
				end,
			},
			{	'nvim-telescope/telescope-ui-select.nvim' },
			{ 'nvim-tree/nvim-web-devicons' },
      { 'nvim-telescope/telescope-file-browser.nvim' },
		},
		config = function()
			-- [[ Configure Telescope ]]
			-- See `:help telescope` and `:help telescope.setup()`
			require('telescope').setup {
				defaults = {
					mappings = {
						i = {
							['<C-u>'] = false,
							['<C-d>'] = false,
							['<A-d>'] = require('telescope.actions').delete_buffer,
							["<C-j>"] = require('telescope.actions').move_selection_next,
							["<C-k>"] = require('telescope.actions').move_selection_previous,
						},
					},
				},
        pickers = {
          find_files = {
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "-u" },
          },
        },
				extentions = {
					['ui-select'] = {
						require('telescope.themes').get_dropdown(),
					},
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                             -- the default case_mode is "smart_case"
          },
          file_browser = {
            hijack_netrw = true,
          }
				},
			}

			-- Enable telescope extensions, if installed
			pcall(require('telescope').load_extension, 'fzf')
			pcall(require('telescope').load_extension, 'ui-select')
			pcall(require('telescope').load_extension, 'file_browser')

			-- See `:help telescope.builtin`
			local builtin = require 'telescope.builtin'
			vim.keymap.set('n', '<leader>?',       builtin.oldfiles,   { desc = '[?] Find recently opened files' })
			vim.keymap.set('n', '<leader><space>', builtin.buffers,    { desc = '[ ] Find existing buffers' })
			vim.keymap.set('n', '<leader>/',       function()
				-- You can pass additional configuration to telescope to change theme, layout, etc.
				builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
					winblend = 10,
					previewer = false,
				})
			end, { desc = '[/] Fuzzily search in current buffer' })

			vim.keymap.set('n', '<leader>s/',			 function()
				--  See `:help telescope.builtin.live_grep()` for information about particular keys
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>fb',   ':Telescope file_browser<CR>', { desc = '[F]ile [B]rowser' })
			-- vim.keymap.set('n', '<leader>gf',    builtin.git_files,   { desc = 'Search [G]it [F]iles' })
			vim.keymap.set('n', '<leader>sd',    builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
			vim.keymap.set('n', '<leader>sf',    builtin.find_files,  { desc = '[S]earch [F]iles' })
			vim.keymap.set('n', '<leader>sg',    builtin.live_grep,   { desc = '[S]earch by [G]rep' })
			vim.keymap.set('n', '<leader>sh',    builtin.help_tags,   { desc = '[S]earch [H]elp' })
			vim.keymap.set('n', '<leader>sk',    builtin.keymaps,     { desc = '[S]earch [K]eymaps' })
			vim.keymap.set('n', '<leader>sr',    builtin.resume,      { desc = '[S]earch [R]esume' })
			vim.keymap.set('n', '<leader>ss',    builtin.builtin,     { desc = '[S]earch [S]elect Telescope' })
			vim.keymap.set('n', '<leader>sw',    builtin.grep_string, { desc = '[S]earch current [W]ord' })
			vim.keymap.set('n', '<leader><tab>', builtin.commands,    { desc = 'Options through Telescope'})
		end,
	},
}
-- vim: ts=2 sts=2 sw=2 et

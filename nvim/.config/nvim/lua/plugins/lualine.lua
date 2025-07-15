return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup({
			options = {
				theme = "catppuccin",
				globalstatus = true,
				-- icons_enabled = true,
				-- component_seperators = '|',
				-- section_seperators = '',
			},
			sections = {
				lualine_x = {
          {
            require("noice").api.status.message.get_hl,
            cond = require("noice").api.status.message.has,
          },
          {
            require("noice").api.status.command.get,
            cond = require("noice").api.status.command.has,
            color = { fg = "#ff9e64" },
          },
          {
            require("noice").api.status.mode.get,
            cond = require("noice").api.status.mode.has,
            color = { fg = "#ff9e64" },
          },
          {
            require("noice").api.status.search.get,
            cond = require("noice").api.status.search.has,
            color = { fg = "#ff9e64" },
          },
          {
            'filetype',
            colored = true,   -- Displays filetype icon in color if set to true
            icon_only = false, -- Display only an icon for filetype
            icon = { align = 'right' }, -- Display filetype icon on the right hand side
          }
				},
				lualine_a = {
					{
						'buffers',
					}
				},
        lualine_c = {
          {
            function()
              return ("%s"):format(require("schema-companion.context").get_buffer_schema().name)
            end,
            cond = function()
              return package.loaded["schema-companion"]
            end,
          },
        },
			},
			extensions = { }
		})
	end,
	dependencies = { 'nvim-tree/nvim-web-devicons' }
}
-- vim: ts=2 sts=2 sw=2 et

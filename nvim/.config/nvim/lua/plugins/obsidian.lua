return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  -- lazy = true,
  -- ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  event = {
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
    "BufReadPre " .. vim.fn.expand "~" .. "znotes/znotes/**.md",
    "BufNewFile " .. vim.fn.expand "~" .. "znotes/znotes/**.md"
  },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>on", "<cmd>ObsidianNew<cr>",         desc = "New Obsidian Note",               mode = "n" },
    { "<leader>oo", "<cmd>ObsidianSearch<cr>",      desc = "Search Obsidian notes",           mode = "n" },
    { "<leader>os", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch",                    mode = "n" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>",   desc = "Show location list of backlinks", mode = "n" },
    { "<leader>ot", "<cmd>ObsidianTemplate<cr>",    desc = "Follow link under cursor",        mode = "n" },
  },

  opts = {
    workspaces = {
      {
        name = "znotes",
        path = "~/znotes/znotes",
      }
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },

    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Toggle check-boxes
      ["<leader>ch"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      -- Create a new note
      -- ["<leader>nn"] = {
      --   action = function()
      --     return require("obsidian").commands.new_note()
      --   end,
      --   opts = { buffer = true },
      -- },
    },

    ui = { enable = false },

    new_notes_location = "zk",

    wiki_link_func = function(opts)
      if opts.id == nil then
        return string.format("[[%s]]", opts.label)
      elseif opts.label ~= opts.id then
        return string.format("[[%s|%s]]", opts.id, opts.label)
      else
        return string.format("[[%s]]", opts.id)
      end
    end,

    -- Either 'wiki' or 'markdown'.
    preferred_link_style = "wiki",

    -- Optional, customize how names/IDs for new notes are created.
    note_id_func = function(title)
      -- Create note name. if title is given, convert title to proper file name.
      -- If no title, create file name with date - 4 uppercase chars
      -- create a new note with title 'My new note' will create new note named 'my-new-node.md'
      -- if no title, new note name will be 'yyyymmdd-DEVX' )
      local note_name = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        note_name = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add date - 4 random uppercase letters
        for _ = 1, 4 do
          note_name = tostring(os.date("%Y%m%d")) .. string.char(math.random(65, 90))
        end
      end
      -- return new note title
      return note_name
    end,

    note_frontmatter_func = function(note)
      -- This is equivalent to the default frontmatter function.
      -- local out = { id = note.id, aliases = note.aliases, tags = note.tags, area = "", project = "" }
      local out = { id = note.id, aliases = note.aliases, tags = note.tags }

      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      return out
    end,

    templates = {
      subdir = "Templates",
      date_format = "%Y%m%d",
      time_format = "%H:%M",
      tags = "",
    },

  },
}
-- vim: ts=2 sts=2 sw=2 et

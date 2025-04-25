-- ---------------------------------------
-- init.lua file to configure yazi plugins
-- ---------------------------------------

-- allow cross session yank
require("session"):setup {
	sync_yanked = true,
}

-- enable update_db for zoxide plugin
require("zoxide"):setup({
  update_db = true,
})

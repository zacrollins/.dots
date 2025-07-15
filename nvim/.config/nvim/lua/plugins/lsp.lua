return {
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE `opts = {}` is the same as calling `require('mason').setup({})`
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      -- schema store plugin
      'b0o/schemastore.nvim',

      -- helm plugin to start yamlls for helm files
      { 'towolf/vim-helm',  ft = 'helm' },
      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with an lsp
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- Function that more easily define mappings specific for LSP related items
          -- It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')                         -- Jump to the definition of the word under you cursor (go back with <C-t>)
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')                          -- Find references for the word under you cursor
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')                 -- Jump to the implementation of the word under you cursor
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')               -- Jump to type of the word under you cursor
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')           -- Fuzzy find all symbols in current document
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols') -- Fuzzy find all symbols in workspace
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')                                                    -- rename variable under cursor
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')                                          -- Execute a code action
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')                                             -- Jump to Declaration NOT Definition
          map('K', vim.lsp.buf.hover, 'Hover Documentation')                                                     -- Opens a popup that displays documentation about the word under your cursor

          -- Lesser used LSP functionality
          map('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')       -- Add folder to workspace
          map('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder') -- Remove folder from workspace
          -- List workspace folders
          map('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })


      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable language servers
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        bashls = {},
        bicep = {},
        jsonls = {
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          -- Have to add this for yamlls to understand that we support line folding
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
              },
            },
          },
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.yaml.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.yaml.schemas or {},
              require("schemastore").yaml.schemas()
            )
          end,
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              format = {
                enable = true,
                singleQuote = true,
                printWidth = 120,
              },
              keyOrdering = false,
              validate = true,
              completion = true,
              schemaStore = {
                -- Must disable built-in schemaStore support to use
                -- schemas from SchemaStore.nvim plugin
                enabled = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = '',
              },
              -- schemas = require('schemastore').yaml.schemas(),
              -- schemas = {
              --   kubernetes = "*.yaml",
              --   ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
              --   ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
              --   ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/**/*.{yml,yaml}",
              --   ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
              --   ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
              --   ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
              -- },
            },
          },
        },
        powershell_es = {},
        helm_ls = {
          settings = {
            ['helm-ls'] = {
              yamlls = {
                path = "yaml-language-server",
              },
            },
          },
        },
        -- gopls = {},
        marksman = { filetypes = { 'md', 'markdown' } },
        terraformls = {},
        tflint = {},
        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of the installed tools an/or manually install other tools you can run
      --    :Mason
      --
      -- `mason` had to be setup earlier: to config its options, see the `dependencies` table for `nvim-lspconfig` above
      -- require('mason').setup()
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
}

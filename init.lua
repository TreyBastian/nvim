local o = vim.opt
o.nu = true
o.relativenumber = true
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.smartindent = true
o.wrap = true
o.breakindent = true
o.linebreak = true
o.swapfile = false
o.backup = false
o.undofile = true
o.undodir = vim.fn.stdpath("data") .. "/undodir"
o.updatetime = 50
o.termguicolors = true
o.scrolloff = 8
o.hlsearch = false
o.incsearch = true
o.clipboard = "unnamedplus"
o.spell = true
o.signcolumn = "yes"
o.spelllang = "en_gb"
vim.g.mapleader = " "
vim.g.maplocalleader = ";"

local set = vim.keymap.set

set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

set("v", "<Tab>", ">gv")
set("v", "<S-Tab>", "<gv")
set("n", "<Tab>", "v><C-\\><C-N>")
set("n", "<S-Tab>", "v<<C-\\><C-N>")
set("i", "<S-Tab>", "<C-\\><C-N>v<<C-\\><C-N>^i")

set("n", "<leader>bn", "<CMD>bn<CR>")
set("n", "<leader>bp", "<CMD>bp<CR>")
set("n", "<leader>bd", "<CMD>bd<CR>")

set("t", "<Esc>", "<C-\\><C-N>")

-- register file extensions
vim.filetype.add({
  extension = { templ = "templ" },
  -- remove once intelephense is fixed
  pattern = { ['.*%.blade%.php'] = 'php', },
})

-- begin our packages
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end
o.rtp:prepend(lazypath)
require("lazy").setup({
  checker = { enabled = true },
  { "jessarcher/vim-heritage" },
  { "tpope/vim-fugitive" },
  { "tpope/vim-eunuch" },
  { "lewis6991/gitsigns.nvim", config = true },
  {
    "ricardoramirezr/blade-nav.nvim",
    ft = { "blade", "php" },
  },
  {
    "mbbill/undotree",
    lazy = false,
    keys = { { "<leader>u", "<CMD>UndotreeToggle<CR>", { mode = "n" } } },
  },
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function() vim.cmd [[colorscheme gruvbox-material]] end
  },
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function() o.background = "dark" end,
      set_light_mode = function() o.background = "light" end,
    },
    config = true,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = true,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { { "nvim-lua/plenary.nvim" } },
    keys = {
      { "<leader>ff",       "<CMD>Telescope find_files<CR>", mode = { "n" } },
      { "<leader>fb",       "<CMD>Telescope buffers<CR>",    mode = { "n" } },
      { "<leader>fg",       "<CMD>Telescope git_files<CR>",  mode = { "n" } },
      { "<leader><leader>", "<CMD>Telescope live_grep<CR>",  mode = { "n" } },
    },
  },
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-dotenv",
      "MunifTanjim/nui.nvim",
      "nvimtools/none-ls.nvim",
    },
    cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel", },
    keys = {
      { "<leader>la", "<CMD>Laravel artisan<CR>", mode = { "n" } },
    },
    event = { "VeryLazy" },
    config = function()
      require("laravel").setup({
        lsp_server = "intelephense",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
      "windwp/nvim-ts-autotag",
      "HiPhish/rainbow-delimiters.nvim",
    },
    main = 'nvim-treesitter.configs',
    build = ":TSUpdate",
    opts = {
      sync_install = false,
      auto_install = true,
      ensure_installed = { "php_only", "blade", "php" },
      highlight = {
        enable = true,
      },
      autotag = {
        enable = true,
      },
      rainbow = {
        enable = true,
        extended_mode = true,
      },

    },
    config = function(_, opts)
      require("nvim-treesitter.parsers").get_parser_configs().blade = {
        install_info = {
          url = "https://github.com/EmranMR/tree-sitter-blade",
          files = { "src/parser.c" },
          branch = "main",
        },
        filetype = "blade",
      }

      require('nvim-treesitter.configs').setup(opts)
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>bf", function() require("conform").format({ async = true, lsp_fallback = true }) end, mode = { "n" } },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylelua" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        mdx = { "prettier" },
        html = { "prettier" },
        go = { "goimports", "gofmt" },
        templ = { "templ" },
        php = { "pint", },
        blade = { "blade-formatter", "pint" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
  {
    "mfussenegger/nvim-jdtls",
    config = function()
      local java_cmds = vim.api.nvim_create_augroup('java_cmds', { clear = true })
      local cache_vars = {}

      local root_files = {
        '.git',
        'mvnw',
        'gradlew',
        'pom.xml',
        'build.gradle',
      }

      local features = {
        codelens = true,
        debugger = false,
      }

      local function get_jdtls_paths()
        if cache_vars.paths then
          return cache_vars.paths
        end

        local path = {}

        path.data_dir = vim.fn.stdpath('cache') .. '/nvim-jdtls'

        local jdtls_install = require('mason-registry')
            .get_package('jdtls')
            :get_install_path()

        path.java_agent = jdtls_install .. '/lombok.jar'
        path.launcher_jar = vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar')

        if vim.fn.has('mac') == 1 then
          path.platform_config = jdtls_install .. '/config_mac'
        elseif vim.fn.has('unix') == 1 then
          path.platform_config = jdtls_install .. '/config_linux'
        elseif vim.fn.has('win32') == 1 then
          path.platform_config = jdtls_install .. '/config_win'
        end

        path.bundles = {}

        local java_test_path = require('mason-registry')
            .get_package('java-test')
            :get_install_path()

        local java_test_bundle = vim.split(
          vim.fn.glob(java_test_path .. '/extension/server/*.jar'),
          '\n'
        )

        if java_test_bundle[1] ~= '' then
          vim.list_extend(path.bundles, java_test_bundle)
        end

        local java_debug_path = require('mason-registry')
            .get_package('java-debug-adapter')
            :get_install_path()

        local java_debug_bundle = vim.split(
          vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'),
          '\n'
        )

        if java_debug_bundle[1] ~= '' then
          vim.list_extend(path.bundles, java_debug_bundle)
        end

        cache_vars.paths = path

        return path
      end

      local function enable_codelens(bufnr)
        pcall(vim.lsp.codelens.refresh)

        vim.api.nvim_create_autocmd('BufWritePost', {
          buffer = bufnr,
          group = java_cmds,
          desc = 'refresh codelens',
          callback = function()
            pcall(vim.lsp.codelens.refresh)
          end,
        })
      end

      local function enable_debugger(bufnr)
        require('jdtls').setup_dap({ hotcodereplace = 'auto' })
        require('jdtls.dap').setup_dap_main_class_configs()

        local opts = { buffer = bufnr }
        vim.keymap.set('n', '<leader>df', "<cmd>lua require('jdtls').test_class()<cr>", opts)
        vim.keymap.set('n', '<leader>dn', "<cmd>lua require('jdtls').test_nearest_method()<cr>", opts)
      end

      local function jdtls_on_attach(client, bufnr)
        if features.debugger then
          enable_debugger(bufnr)
        end

        if features.codelens then
          enable_codelens(bufnr)
        end

        local opts = { buffer = bufnr }
        vim.keymap.set('n', '<A-o>', "<cmd>lua require('jdtls').organize_imports()<cr>", opts)
        vim.keymap.set('n', 'crv', "<cmd>lua require('jdtls').extract_variable()<cr>", opts)
        vim.keymap.set('x', 'crv', "<esc><cmd>lua require('jdtls').extract_variable(true)<cr>", opts)
        vim.keymap.set('n', 'crc', "<cmd>lua require('jdtls').extract_constant()<cr>", opts)
        vim.keymap.set('x', 'crc', "<esc><cmd>lua require('jdtls').extract_constant(true)<cr>", opts)
        vim.keymap.set('x', 'crm', "<esc><Cmd>lua require('jdtls').extract_method(true)<cr>", opts)
      end

      local function jdtls_setup(event)
        local jdtls = require('jdtls')

        local path = get_jdtls_paths()
        local data_dir = path.data_dir .. '/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

        if cache_vars.capabilities == nil then
          jdtls.extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

          local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
          cache_vars.capabilities = vim.tbl_deep_extend(
            'force',
            vim.lsp.protocol.make_client_capabilities(),
            ok_cmp and cmp_lsp.default_capabilities() or {}
          )
        end

        local cmd = {
          'java',
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ALL',
          '-javaagent:' .. path.java_agent,
          '-Xms1g',
          '--add-modules=ALL-SYSTEM',
          '--add-opens',
          'java.base/java.util=ALL-UNNAMED',
          '--add-opens',
          'java.base/java.lang=ALL-UNNAMED',
          '-jar',
          path.launcher_jar,
          '-configuration',
          path.platform_config,
          '-data',
          data_dir,
        }

        local lsp_settings = {
          java = {
            eclipse = {
              downloadSources = true,
            },
            configuration = {
              updateBuildConfiguration = 'interactive',
              runtimes = path.runtimes,
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            -- inlayHints = {
            --   parameterNames = {
            --     enabled = 'all' -- literals, all, none
            --   }
            -- },
            format = {
              enabled = true,
            }
          },
          signatureHelp = {
            enabled = true,
          },
          completion = {
            favoriteStaticMembers = {
              'org.hamcrest.MatcherAssert.assertThat',
              'org.hamcrest.Matchers.*',
              'org.hamcrest.CoreMatchers.*',
              'org.junit.jupiter.api.Assertions.*',
              'java.util.Objects.requireNonNull',
              'java.util.Objects.requireNonNullElse',
              'org.mockito.Mockito.*',
            },
          },
          contentProvider = {
            preferred = 'fernflower',
          },
          extendedClientCapabilities = jdtls.extendedClientCapabilities,
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            }
          },
          codeGeneration = {
            toString = {
              template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
            },
            useBlocks = true,
          },
        }

        jdtls.start_or_attach({
          cmd = cmd,
          settings = lsp_settings,
          on_attach = jdtls_on_attach,
          capabilities = cache_vars.capabilities,
          root_dir = jdtls.setup.find_root(root_files),
          flags = {
            allow_incremental_sync = true,
          },
          init_options = {
            bundles = path.bundles,
          },
        })
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = java_cmds,
        pattern = { 'java' },
        desc = 'Setup jdtls',
        callback = jdtls_setup,
      })
    end,
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "rafamadriz/friendly-snippets",
    },
    lazy = false,
    config = function()
      local lsp_zero = require("lsp-zero")

      lsp_zero.on_attach(function(_, bufnr)
        lsp_zero.default_keymaps({ buffer = bufnr })
      end)

      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),
      })

      require('luasnip.loaders.from_vscode').lazy_load()

      require('flutter-tools').setup({
        lsp = {
          capabilities = lsp_zero.get_capabilities()
        }
      })

      require("mason").setup({})
      require("mason-lspconfig").setup({
        ensure_installed = {
          "tsserver",
          "emmet_ls",
          "eslint",
          "gopls",
          "html",
          "lua_ls",
          "tailwindcss",
          "jsonls",
          "dockerls",
          "bashls",
          "intelephense",
          "yamlls",
          "templ",
          "jdtls",
        },
        handlers = {
          lsp_zero.default_setup,
          jdtls = lsp_zero.noop,
          intelephense = function()
            require("lspconfig").intelephense.setup({
              filetypes = { "php", "blade" },
            })
          end,
          lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require("lspconfig").lua_ls.setup(lua_opts)
          end,
          html = function()
            require("lspconfig").html.setup({
              filetypes = { "html", "htm", "xml", "php", "templ", "blade", },
            })
          end,
          emmet_ls = function()
            require("lspconfig").emmet_ls.setup({
              filetypes = { "html", "htm", "xml", "php", "templ", "blade", },
            })
          end,
          tailwindcss = function()
            require("lspconfig").tailwindcss.setup({
              filetypes = {
                "html",
                "htm",
                "css",
                "postcss",
                "javascript",
                "javascriptreact",
                "typescript",
                "typescriptreact",
                "react",
                "php",
                "templ",
                "blade",
              }
            })
          end,
        },
      })
    end,
  },
})

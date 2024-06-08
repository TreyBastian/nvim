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
vim.filetype.add({ extension = { templ = "templ" } })

-- begin our packages
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
  { "jessarcher/vim-heritage" },
  { "tpope/vim-fugitive" },
  { "tpope/vim-eunuch" },
  { "lewis6991/gitsigns.nvim", config = true },
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
        php = { "blade-formatter", "pint", },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
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
        },
        handlers = {
          lsp_zero.default_setup,
          lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require("lspconfig").lua_ls.setup(lua_opts)
          end,
          html = function()
            require("lspconfig").html.setup({
              filetypes = { "html", "htm", "xml", "php", "templ", },
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
              }
            })
          end,
        },
      })
    end,
  },
})

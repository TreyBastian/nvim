vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.showbreak = string.rep(" ", 3)
vim.opt.linebreak = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 350
vim.o.background = "dark"

vim.g.mapleader = " "

vim.keymap.set("v", "<Tab>", ">gv")
vim.keymap.set("n", "<Tab>", "v><C-\\><C-N>")
vim.keymap.set("v", "<S-Tab>", "<gv")
vim.keymap.set("n", "<S-Tab>", "v<<C-\\><C-N>")
vim.keymap.set("i", "<S-Tab>", "<C-\\><C-N>v<<C-\\><C-N>^i")

vim.keymap.set("n", "<leader>bn", "<cmd>bn<cr>")
vim.keymap.set("n", "<leader>bp", "<cmd>bp<cr>")
vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>")

vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- init lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
{
    "nvim-telescope/telescope.nvim",
    tag = "0.1.1",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", mode = { "n" } },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    mode = { "n" } },
      { "<leader>fg", "<cmd>Telescope git_files<cr>",  mode = { "n" } },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",  mode = { "n" } },
      { "<leader>fs", "<cmd>Telescope live_grep<cr>",  mode = { "n" } },
    },
    config = true
  },
  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = false,
    priority = 1000,
    config = function()
            vim.cmd[[colorscheme moonfly]]
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "css",
          "sql",
          "bash",
          "dockerfile",
          "html",
          "javascript",
          "typescript",
          "toml",
          "yaml",
          "json",
          "tsx",
          "rust",
        },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
        rainbow = {
          enable = true,
          extended_mode = true
        },
        autotag = {
          enable = true
        }
      }
    end
  },
  { "nvim-treesitter/nvim-treesitter-context" },
  { "mrjones2014/nvim-ts-rainbow" },
  { "windwp/nvim-ts-autotag" },
  {
    "VonHeikemen/lsp-zero.nvim",
    lazy = false,
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      { "lukas-reineke/lsp-format.nvim", config = true }
    },
    keys = {
      { "<leader>bf", "<cmd>lua vim.lsp.buf.format()<cr>", mode = { "n" } }
    },
    config = function()
      local lsp = require("lsp-zero")
      lsp.preset("recommended")
      lsp.ensure_installed({
        'tsserver',
        'emmet_ls',
        'eslint',
        'html',
        'lua_ls',
        'rust',
      })
      lsp.on_attach(function(client, bufnr)
        require("lsp-format").on_attach(client, bufnr)
      end)
      lsp.set_sign_icons({
        error = "✘",
        warn = "",
        hint = "",
        info = ""
      })

      require("lspconfig").ltex.setup({
        filetypes = { "markdown", "md", "html" },
        flags = { debounce_text_changes = 300 },
        settings = {
          ltex = {
            language = "en"
          }
        }
      })

      lsp.nvim_workspace()
      lsp.setup()
      vim.diagnostic.config { virtual_text = true }

      local cmp = require("cmp")
      cmp.setup({
        mapping = {
          ['<CR>'] = cmp.mapping.confirm({ select = true })
        }
      })
    end
  },
  {
    "terrortylor/nvim-comment",
    keys = {
      { "<leader>\\", "<cmd>CommentToggle<CR>j",         mode = { "n" } },
      { "<leader>\\", ":'<,'>CommentToggle<CR>gv<esc>j", mode = { "v" } }
    },
    config = function()
      require("nvim_comment").setup()
    end
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons",
      "MunifTanjim/nui.nvim"
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", mode = { "n", "v" } }
    },
    config = true
  },
  {
    "fedepujol/move.nvim",
    keys = {
      { "<A-j>", "<cmd>MoveLine(1)<cr>",              mode = { "n" } },
      { "<A-k>", "<cmd>MoveLine(-1)<cr>",             mode = { "n" } },
      { "<A-j>", "<cmd>MoveBlock(1)<cr>",             mode = { "v" } },
      { "<A-k>", "<cmd>MoveBlock(-1)<cr>",            mode = { "v" } },
      { "<A-j>", "<C-\\><C-N><cmd>MoveLine(1)<CR>i",  mode = { "i" } },
      { "<A-k>", "<C-\\><C-N><cmd>MoveLine(-1)<CR>i", mode = { "i" } }
    }
  },
  { "lewis6991/gitsigns.nvim",     config = true },
  { "windwp/nvim-autopairs",       config = true },
  { "norcalli/nvim-colorizer.lua", config = function() require("colorizer").setup() end },
  {
    "akinsho/toggleterm.nvim",
    config = { open_mapping = [[<leader>t]], direction = "float", insert_mappings = false }
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "tpope/vim-dotenv"
    },
    keys = {
      { "<leader>db", "<cmd>DBUI<cr>", mode = { "n" } }
    }
  },
  {
    "LintaoAmons/scratch.nvim",
    event = 'VimEnter',
    keys = {
      { "<leader>sn", "<cmd>Scratch<cr>",     mode = { "n" } },
      { "<leader>so", "<cmd>ScratchOpen<cr>", mode = { "n" } }
    }
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  }
})

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
o.showbreak = string.rep(" ", 3)
o.linebreak = true
o.swapfile = false
o.backup = false
o.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
o.undofile = true
o.hlsearch = false
o.incsearch = true
o.termguicolors = true
o.scrolloff = 8
o.signcolumn = "yes"
o.updatetime = 50
o.spell = true
o.spelllang = "en_gb"
o.clipboard = "unnamedplus"
vim.g.mapleader = " "

-- register unknown file extensions
vim.filetype.add({ extension = { templ = "templ" } })

local set = vim.keymap.set
set("v", "<Tab>", ">gv")
set("n", "<Tab>", "v><C-\\><C-N>")
set("v", "<S-Tab>", "<gv")
set("n", "<S-Tab>", "v<<C-\\><C-N>")
set("i", "<S-Tab>", "<C-\\><C-N>v<<C-\\><C-N>^i")

set("n", "<leader>bn", "<CMD>bn<CR>")
set("n", "<leader>bp", "<CMD>bp<CR>")
set("n", "<leader>bd", "<CMD>bd<CR>")

set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

set("n", "<leader>k", "<CMD>wincmd k<CR>", { silent = true })
set("n", "<leader>j", "<CMD>wincmd j<CR>", { silent = true })
set("n", "<leader>h", "<CMD>wincmd h<CR>", { silent = true })
set("n", "<leader>l", "<CMD>wincmd l<CR>", { silent = true })

set("x", "<leader>p", [["_dp]])
set({ "n", "v" }, "<leader>y", [["+y]])
set("n", "<leader>Y", [["+Y]])
set({ "n", "v" }, "<leader>d", [["_d]])

-- auto commands --
local autocmd = vim.api.nvim_create_autocmd
-- format on save --
autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "go" then
      return
    end
    if vim.bo.filetype == "templ" then
      local bufnr = vim.api.nvim_get_current_buf()
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local cmd = "templ fmt " .. vim.fn.shellescape(filename)

      vim.fn.jobstart(cmd, {
        on_exit = function()
          if vim.api.nvim_get_current_buf() == bufnr then
            vim.cmd [[e!]]
          end
        end,
      })
    else
      vim.cmd [[lua vim.lsp.buf.format()]]
    end
  end
})

-- go imports --
autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({ async = false })
  end
})


-- bootstrap lazy --
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
-- plugins here --
require("lazy").setup({
  {
    "ellisonleao/gruvbox.nvim",
    config = function() vim.cmd [[colorscheme gruvbox]] end
  },
  { "github/copilot.vim",      branch = "release" },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
      "windwp/nvim-ts-autotag",
      "HiPhish/rainbow-delimiters.nvim",
    },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
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
      }
    end
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
  },
  {
    "terrortylor/nvim-comment",
    keys = {
      { "<leader>\\", "<CMD>CommentToggle<CR>j",         mode = { "n" } },
      { "<leader>\\", ":'<,'>CommentToggle<CR>gv<esc>j", mode = { "v" } }
    },
    config = function() require("nvim_comment").setup() end
  },
  { "lewis6991/gitsigns.nvim", config = true },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { { "nvim-lua/plenary.nvim" } },
    keys = {
      { "<leader>ff", "<CMD>Telescope find_files<CR>",               mode = { "n" } },
      { "<leader>fb", "<CMD>Telescope buffers<CR>",                  mode = { "n" } },
      { "<leader>fg", "<CMD>Telescope git_files<CR>",                mode = { "n" } },
      { "<leader>fh", "<CMD>Telescope help_tags<CR>",                mode = { "n" } },
      { "<leader>fr", "<CMD>Telescope live_grep<CR>",                mode = { "n" } },
      { "<leader>fs", "<CMD>Telescope lsp_document_symbols<CR>",     mode = { "n" } },
      { "<leader>fw", "<CMD>Telescope lsp_workspace_symbols<CR>",    mode = { "n" } },
      { "<leader>fd", "<CMD>Telescope lsp_definitions<CR>",          mode = { "n" } },
      { "<leader>fi", "<CMD>Telescope lsp_implementations<CR>",      mode = { "n" } },
      { "<leader>ft", "<CMD>Telescope lsp_type_definitions<CR>",     mode = { "n" } },
      { "<leader>fc", "<CMD>Telescope lsp_code_actions<CR>",         mode = { "n" } },
      { "<leader>fm", "<CMD>Telescope lsp_references<CR>",           mode = { "n" } },
      { "<leader>fo", "<CMD>Telescope lsp_document_diagnostics<CR>", mode = { "n" } },
      { "<leader>fq", "<CMD>Telescope quickfix<CR>",                 mode = { "n" } },
      { "<leader>fl", "<CMD>Telescope loclist<CR>",                  mode = { "n" } },
    }
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    dependencies = {
      { "neovim/nvim-lspconfig" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-buffer" },
      { "L3MON4D3/LuaSnip" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
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
          ["<CR>"] = cmp.mapping.confirm({ select = false })
        }),
      })

      require("mason").setup({})
      require("mason-lspconfig").setup({
        ensure_installed = {
          "tsserver",
          "emmet_ls",
          "eslint",
          "gopls",
          "templ",
          "html",
          "htmx",
          "lua_ls",
          "tailwindcss",
          "jsonls",
          "yamlls",
          "dockerls",
          "bashls",
        },
        handlers = {
          lsp_zero.default_setup,
          lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require("lspconfig").lua_ls.setup(lua_opts)
          end,
          html = function()
            require("lspconfig").html.setup({
              filetypes = { "html", "htm", "xml", "templ" },
            })
          end,
          htmx = function()
            require("lspconfig").htmx.setup({
              filetypes = { "html", "templ" },
            })
          end,
          tailwindcss = function()
            require("lspconfig").tailwindcss.setup({
              filetypes = { "html", "htm", "css", "scss", "sass", "less", "postcss", "javascript", "typescript", "react", "templ" },
            })
          end,
        }
      })
    end
  }
})

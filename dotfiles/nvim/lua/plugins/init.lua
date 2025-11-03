return {
  -- Theme + statusline
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, config = function()
      require("lualine").setup({ options = { theme = "auto" } })
    end
  },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    opts = { highlight = { enable = true }, ensure_installed = { "lua", "vim", "bash", "json", "yaml", "markdown" } },
    config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end },

  -- Telescope
  { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local t = require("telescope")
      t.setup({ defaults = { mappings = { i = { ["<C-h>"] = "which_key" } } } })
      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Buffers" })
    end },

  -- File explorer
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle explorer" })
    end },

  -- Git signs
  { "lewis6991/gitsigns.nvim", config = function() require("gitsigns").setup() end },

  -- Helpful UX
  { "folke/which-key.nvim", config = function() require("which-key").setup() end },
  { "numToStr/Comment.nvim", config = function() require("Comment").setup() end },
  { "windwp/nvim-autopairs", config = function() require("nvim-autopairs").setup() end },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  { "echasnovski/mini.surround", version = false, config = function() require("mini.surround").setup() end },

  -- LSP & tools
  { "williamboman/mason.nvim", build = ":MasonUpdate", config = function() require("mason").setup() end },
  { "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      local lspconfig = require("lspconfig")
      local mason_lsp = require("mason-lspconfig")
      mason_lsp.setup({ ensure_installed = { "lua_ls", "bashls", "jsonls", "yamlls" } })
      mason_lsp.setup_handlers({
        function(server) lspconfig[server].setup({}) end,
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            settings = { Lua = { diagnostics = { globals = { "vim" } } } }
          })
        end
      })
    end },
}

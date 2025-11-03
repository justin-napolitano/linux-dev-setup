-- Bootstrap lazy.nvim
local fn = vim.fn
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options for headless/TTY use
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.clipboard = (vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1) and "unnamedplus" or ""
vim.g.mapleader = " "

require("lazy").setup("plugins", {
  ui = { border = "rounded" },
  change_detection = { notify = false },
})

-- Colorscheme
pcall(vim.cmd.colorscheme, "catppuccin")

-- Minimal Neovim: sensible defaults, no plugin manager.
-- Grow this file, or drop in lazy.nvim later.

vim.g.mapleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.wrap = false
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = false
o.scrolloff = 8
o.signcolumn = "yes"
o.termguicolors = true
o.undofile = true
o.updatetime = 250
o.clipboard = "unnamedplus"
o.splitright = true
o.splitbelow = true

-- Quality of life
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
})

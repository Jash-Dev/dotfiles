-- =========================
-- Minimal Modern Neovim (C#, JS/TS, Python)
-- =========================

-- ---------- Basics ----------
vim.g.mapleader = " "
local o = vim.opt
o.number = true
o.relativenumber = true
o.termguicolors = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.cursorline = true
o.wrap = false
o.scrolloff = 6
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true

-- ---------- Keymaps ----------
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("i", "jk", "<Esc>")

-- ---------- lazy.nvim bootstrap ----------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ---------- Plugins ----------
require("lazy").setup({
	-- Snippets
	{ "L3MON4D3/luasnip", dependencies = { "rafamadriz/friendly-snippets" } },

	-- UI
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({})
		end,
	},
	{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"c_sharp",
					"javascript",
					"typescript",
					"python",
					"lua",
					"bash",
					"json",
					"yaml",
					"markdown",
					"regex",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- LSP & completion
	"neovim/nvim-lspconfig",
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",

	-- Formatting
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					javascript = { "prettier" },
					typescript = { "prettier" },
					javascriptreact = { "prettier" },
					typescriptreact = { "prettier" },
					json = { "prettier" },
					css = { "prettier" },
					html = { "prettier" },
					python = { "black", "isort" },
					cs = { "csharpier" }, -- if installed
					lua = { "stylua" },
				},
				format_on_save = function(_)
					return { lsp_fallback = true, async = false, timeout_ms = 2000 }
				end,
			})
		end,
	},
})

-- ---------- Colorscheme ----------
vim.cmd.colorscheme("catppuccin")

-- ---------- Telescope ----------
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help" })

-- ---------- LSP / Mason / CMP ----------
local cmp = require("cmp")
local luasnip = require("luasnip")

-- nvim-cmp
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "path" },
	},
})

-- LSP defaults
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(_, bufnr)
	local buf = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
	end
	buf("n", "K", vim.lsp.buf.hover, "Hover")
	buf("n", "gd", vim.lsp.buf.definition, "Goto Def")
	buf("n", "gr", vim.lsp.buf.references, "References")
	buf("n", "gi", vim.lsp.buf.implementation, "Goto Impl")
	buf("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
	buf("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
	buf("n", "[d", vim.diagnostic.goto_prev, "Prev diag")
	buf("n", "]d", vim.diagnostic.goto_next, "Next diag")
	buf("n", "<leader>f", function()
		vim.lsp.buf.format({ async = false })
	end, "Format")
end

-- ---------- Mason + mason-lspconfig ----------
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		-- C#
		"omnisharp",
		-- JS/TS
		"ts_ls", -- was tsserver
		"eslint",
		-- Python
		"pyright",
		"ruff", -- was ruff_lsp
		-- Lua (for editing this config)
		"lua_ls",
	},
	automatic_installation = true,
})

-- ---------- New-style LSP config (Neovim 0.11) ----------

-- Global defaults for all servers
vim.lsp.config("*", {
	capabilities = capabilities,
	on_attach = on_attach,
})

-- Lua (extra settings)
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
		},
	},
})

-- C# (OmniSharp)
vim.lsp.config("omnisharp", {
	-- Shared capabilities/on_attach already applied via "*"
})

-- JavaScript/TypeScript (ts_ls replaces tsserver)
vim.lsp.config("ts_ls", {
	on_attach = function(client, bufnr)
		-- Let Prettier (conform.nvim) handle formatting
		client.server_capabilities.documentFormattingProvider = false
		on_attach(client, bufnr)
	end,
})

-- ESLint
vim.lsp.config("eslint", {
	-- defaults are fine
})

-- Python (Pyright)
vim.lsp.config("pyright", {
	-- defaults are fine
})

-- Ruff (replaces ruff_lsp)
vim.lsp.config("ruff", {
	on_attach = function(client, bufnr)
		-- Ruff: diagnostics + quickfix; keep Pyright hover
		client.server_capabilities.hoverProvider = false
		on_attach(client, bufnr)
	end,
})

-- Enable all the servers
vim.lsp.enable({
	"lua_ls",
	"omnisharp",
	"ts_ls",
	"eslint",
	"pyright",
	"ruff",
})

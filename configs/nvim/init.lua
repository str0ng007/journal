vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
--vim.cmd("set clipboard+=unnamedplus")
vim.api.nvim_set_option("clipboard", "unnamedplus")
vim.cmd("set number")
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local plugins = {

	{ "LazyVim/LazyVim", import = "lazyvim.plugins" },

	-- Catppuccino
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	-- end Catppuccino
	-- NVIM Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = { "lua", "go", "yaml", "json", "terraform", "kdl", "toml" },
			sync_install = false,
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		},
	},
	-- end NVIM Treesitter
	-- NeoTree
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"s1n7ax/nvim-window-picker",
		},
		-- end NeoTree
	},
	-- Lua Line
	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
	},

	{
		"folke/tokyonight.nvim",
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	{
		"folke/which-key.nvim",
		lazy = true,
	},
	-- End of LuaLine
	-- GitSigns
	{
		"lewis6991/gitsigns.nvim",
	},
	-- End of GitSigns

	-- Comment
	{
		"numToStr/Comment.nvim",
		opts = {
			-- add any options here
		},
		lazy = false,
	},
	-- end of Comment
	-- Mason LSP
	{
		"mason-org/mason.nvim",
	},
	{
		"mason-org/mason-lspconfig.nvim",
	},
	{
		"neovim/nvim-lspconfig",
	},
}

local opts = {}

require("lazy").setup(plugins, opts)

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", function()
	builtin.find_files({ follow = true })
end, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

-- NeoTree
vim.keymap.set("n", "<leader>fe", ":Neotree filesystem reveal left<CR>")
vim.keymap.set("n", "<leader>gs", ":Neotree float git_status <CR>")

require("catppuccin").setup()
vim.cmd.colorscheme("catppuccin")

require("gitsigns").setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end)

		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end)

		-- Actions
		map("n", "<leader>hs", gitsigns.stage_hunk)
		map("n", "<leader>hr", gitsigns.reset_hunk)
		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end)
		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end)
		map("n", "<leader>hS", gitsigns.stage_buffer)
		map("n", "<leader>hu", gitsigns.undo_stage_hunk)
		map("n", "<leader>hR", gitsigns.reset_buffer)
		map("n", "<leader>hp", gitsigns.preview_hunk)
		map("n", "<leader>hb", function()
			gitsigns.blame_line({ full = true })
		end)
		map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
		map("n", "<leader>hd", gitsigns.diffthis)
		map("n", "<leader>hD", function()
			gitsigns.diffthis("~")
		end)
		map("n", "<leader>td", gitsigns.toggle_deleted)

		-- Text object
		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
	end,
})

-- This is for WSL clipboard copy/paste
--  local clip = '/mnt/c/Windows/System32/clip.exe' -- Change this path according to your mount point
-- if vim.fn.executable(clip) == 1 then
--    vim.cmd([[
--        augroup WSLYank
--            autocmd!
--            autocmd TextYankPost * if v:event.operator == 'y' | call system("]]..clip..[[", @0) | endif
--        augroup END
--    ]])
--end

require("Comment").setup()

require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "terraformls", "tflint" },
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("terraformls")
vim.lsp.enable("tflint")
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})

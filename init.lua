-- space as leader key (set before plugins so they bind correctly)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- using Nerd Font in terminal
vim.g.have_nerd_font = true

-- show line numbers
vim.o.number = true
-- optional: relative numbers for jump distances
-- vim.o.relativenumber = true

-- enable mouse (for splits etc.)
vim.o.mouse = "a"

-- don't show mode in cmd area (already in statusline)
vim.o.showmode = false

-- clipboard sync with OS after UI loads
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- break indent for wrapped lines
vim.o.breakindent = true

-- keep undo history
vim.o.undofile = true

-- smart case-insensitive search
vim.o.ignorecase = true
vim.o.smartcase = true

-- always show sign column
vim.o.signcolumn = "yes"

-- improve responsiveness
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- autosave delay (1 minute = 60000ms)
vim.g.autosave_updatetime = 60000

-- splits open to right/below
vim.o.splitright = true
vim.o.splitbelow = true

-- show visible markers for certain whitespace
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- split view for live substitution preview
vim.o.inccommand = "split"

-- highlight current line
vim.o.cursorline = true

-- keep some buffer space above/below cursor
vim.o.scrolloff = 10

-- ask for confirmation instead of failing when unsaved
vim.o.confirm = true

-- disable swapfile (has caused issues before)
vim.o.swapfile = false

-- [[ Keymaps ]]
-- clear search highlight on Esc in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
-- diagnostics quickfix
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics Quickfix" })
-- easier exit from terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- easier split navigation: CTRL+h/j/k/l
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Upper window" })

-- toggle terminal with \t
vim.keymap.set({ "n", "t" }, "\\t", function()
	local term_buf = vim.g.toggle_term_buf
	if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
		local term_win = vim.fn.bufwinid(term_buf)
		if term_win ~= -1 then
			vim.api.nvim_win_close(term_win, false)
		else
			vim.cmd("botright split")
			vim.api.nvim_win_set_buf(0, term_buf)
			vim.cmd("resize 15")
			vim.cmd("startinsert")
		end
	else
		vim.cmd("botright split | resize 15 | terminal")
		vim.g.toggle_term_buf = vim.api.nvim_get_current_buf()
		vim.cmd("startinsert")
	end
end, { desc = "Toggle terminal" })

-- [[GIT keymaps]]
vim.keymap.set("n", "<leader>gs", function()
	vim.cmd("Neotree toggle source=git_status")
end, { desc = "Git [S]tatus (Neo-tree)" })

-- [[ Autocommands ]]
-- highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yank",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- spell checking for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us"
	end,
})

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	desc = "Autosave after inactivity",
	group = vim.api.nvim_create_augroup("autosave", { clear = true }),
	callback = function(event)
		local timer_started = vim.b[event.buf].autosave_timer_started
		if not timer_started then
			vim.b[event.buf].autosave_timer_started = true
			vim.defer_fn(function()
				if vim.api.nvim_buf_is_valid(event.buf) and vim.bo[event.buf].modified and vim.bo[event.buf].buftype == "" and vim.fn.expand("%") ~= "" then
					vim.cmd("silent! write")
					print("Autosaved")
				end
				vim.b[event.buf].autosave_timer_started = false
			end, vim.g.autosave_updatetime)
		end
	end,
})

-- lazy.nvim plugin manager bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

vim.opt.rtp:prepend(lazypath)

-- [[ Plugins ]]
require("lazy").setup({

	"NMAC427/guess-indent.nvim", -- auto tabstop detection

	{ import = "git" },

	{ -- keymap hints
		"folke/which-key.nvim",
		event = "VimEnter",
		opts = {
			delay = 300,
			icons = {
				mappings = vim.g.have_nerd_font,
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
				},
			},
			spec = {
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>g", group = "[G]it" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},

	{ -- telescope
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				extensions = { ["ui-select"] = require("telescope.themes").get_dropdown() },
			})
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			local builtin = require("telescope.builtin")
			-- quick file and text searches
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch Files" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch Grep" })
			vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]earch Buffers" })
		end,
	},

	{ -- Lua dev LSP tweaks
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	{ -- LSP setup
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.cmp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					map("grn", vim.lsp.buf.rename, "[R]ename")
					map("gra", vim.lsp.buf.code_action, "[A]ction", { "n", "x" })
					map("grr", require("telescope.builtin").lsp_references, "[R]eferences")
					map("gri", require("telescope.builtin").lsp_implementations, "[I]mplementation")
					map("grd", require("telescope.builtin").lsp_definitions, "[D]efinition")
					map("grD", vim.lsp.buf.declaration, "[D]eclaration")
					map("gO", require("telescope.builtin").lsp_document_symbols, "Doc Symbols")
					map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "WS Symbols")
					map("grt", require("telescope.builtin").lsp_type_definitions, "[T]ype Def")
				end,
			})

			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
			})

			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
						},
					},
				},
			}

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, { "stylua" })
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	{ -- autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return { timeout_ms = 500, lsp_format = "fallback" }
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
			},
		},
	},

	{ -- autocomplete
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				opts = {},
			},
			"folke/lazydev.nvim",
		},
		opts = {
			keymap = { preset = "default" },
			appearance = { nerd_font_variant = "mono" },
			completion = {
				documentation = { auto_show = false, auto_show_delay_ms = 500 },
			},
			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = { lazydev = { module = "lazydev.integrations.blink", score_offset = 100 } },
			},
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
			signature = { enabled = true },
		},
	},

	{ -- theme
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				styles = { comments = { italic = false } },
			})
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},

	{ -- highlight TODO etc.
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{ -- mini.nvim collection
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},

	{ -- treesitter
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
	},

	{ -- neo-tree file explorer
		"nvim-neo-tree/neo-tree.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{ "\\e", ":Neotree toggle<CR>", desc = "NeoTree toggle" },
		},
		opts = {
			filesystem = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				window = {
					mappings = {
						["\\e"] = "close_window",
						["H"] = "toggle_hidden",
						["<tab>"] = { "toggle_preview", config = { use_float = true } },
						["P"] = "toggle_preview",
						["<space>"] = "open",
						["S"] = "open_split",
						["s"] = "open_vsplit",
						["t"] = "open_tabnew",
					},
				},
			},
		},
	},
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- vim: ts=2 sts=2 sw=2 et

return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				map("n", "<leader>hs", gs.stage_hunk, { desc = "[S]tage hunk" })
				map("n", "<leader>hr", gs.reset_hunk, { desc = "[R]eset hunk" })
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "[S]tage hunk" })
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "[R]eset hunk" })
				map("n", "<leader>hS", gs.stage_buffer, { desc = "[S]tage buffer" })
				map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "[U]ndo stage hunk" })
				map("n", "<leader>hR", gs.reset_buffer, { desc = "[R]eset buffer" })
				map("n", "<leader>hp", gs.preview_hunk, { desc = "[P]review hunk" })
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, { desc = "[B]lame line" })
				map("n", "<leader>hd", gs.diffthis, { desc = "[D]iff this" })
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, { desc = "[D]iff this ~" })
				map("n", "]h", gs.next_hunk, { desc = "Next hunk" })
				map("n", "[h", gs.prev_hunk, { desc = "Previous hunk" })

				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
			end,
		},
	},

	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "[D]iffview" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File [H]istory" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo [H]istory" },
		},
		opts = {},
	},

	{
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "Lazy[G]it" },
			{ "<leader>gc", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit [C]urrent file" },
		},
	},
}

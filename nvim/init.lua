-- =========================
-- BASIC SETTINGS
-- =========================
vim.g.mapleader = " "
vim.o.termguicolors = true
vim.o.background = "dark"
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.mouse = "a"

-- =========================
-- KEYMAPS
-- =========================
local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- RMarkdown knit to PDF
map("n", "<leader>rr", function()
    local file = vim.fn.expand("%:p")
    vim.cmd("!" .. "Rscript -e \"rmarkdown::render('" .. file .. "', output_format='pdf_document')\"")
end)

-- Open PDF after render
map("n", "<leader>rv", function()
    local pdf = vim.fn.expand("%:p:r") .. ".pdf"
    vim.cmd("vsplit | terminal pdftotext " .. pdf .. " - | less")
end)

-- =========================
-- LAZY BOOTSTRAP
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- =========================
-- PLUGINS
-- =========================
require("lazy").setup({

    rocks = { enabled = false },

    -- THEME
    {
        "morhetz/gruvbox",
        priority = 1000,
        config = function()
            vim.cmd("colorscheme gruvbox")
        end,
    },

    -- FILE TREE
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup()
            map("n", "<leader>e", ":NvimTreeToggle<CR>")
        end,
    },

    -- STATUS LINE
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup()
        end,
    },

    -- BUFFERLINE
    {
        "akinsho/bufferline.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("bufferline").setup()
            map("n", "<Tab>",   ":BufferLineCycleNext<CR>")
            map("n", "<S-Tab>", ":BufferLineCyclePrev<CR>")
        end,
    },

    -- =========================
    -- TELESCOPE
    -- =========================
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({})
            telescope.load_extension("fzf")
            map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
            map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
            map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
        end,
    },

    -- =========================
    -- LSP + MASON
    -- =========================
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "clangd", "r_language_server" },
                handlers = {
                    function(server_name)
                        require("lspconfig")[server_name].setup({})
                    end,
                },
            })
        end,
    },

    -- =========================
    -- AUTOCOMPLETE
    -- =========================
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"]   = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                    ["<CR>"]    = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                },
            })
        end,
    },

    -- =========================
    -- DATA SCIENCE TOOLS
    -- =========================
    {
        "dccsillag/magma-nvim",
        build = ":UpdateRemotePlugins",
        config = function()
            vim.g.magma_automatically_open_output = false
            map("n", "<leader>r", ":MagmaEvaluateLine<CR>")
            map("v", "<leader>r", ":<C-u>MagmaEvaluateVisual<CR>")
            map("n", "<leader>o", ":MagmaShowOutput<CR>")
        end,
    },
    {
        "cameron-wags/rainbow_csv.nvim",
        config = true,
    },

    -- =========================
    -- GIT
    -- =========================
    {
        "tpope/vim-fugitive",
        config = function()
            map("n", "<leader>gs", ":Git<CR>")
        end,
    },

    -- =========================
    -- TERMINAL
    -- =========================
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup({
                open_mapping    = [[<leader>`]],
                direction       = "horizontal",
                size            = function() return vim.o.lines * 0.25 end,
                shade_terminals = true,
                shading_factor  = 2,
                start_in_insert = true,
                persist_size    = true,
            })
        end,
    },

    -- =========================
    -- DEBUG (DAP)
    -- =========================
    {
        "mfussenegger/nvim-dap",
        dependencies = { "mfussenegger/nvim-dap-python" },
        config = function()
            require("dap-python").setup(
                vim.fn.expand("$HOME/.cache/pypoetry/virtualenvs/nvim-*/bin/python")
            )
            map("n", "<F5>",      ":lua require'dap'.continue()<CR>")
            map("n", "<F10>",     ":lua require'dap'.step_over()<CR>")
            map("n", "<F11>",     ":lua require'dap'.step_into()<CR>")
            map("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
        end,
    },

    -- =========================
    -- LATEX
    -- =========================
    {
        "lervag/vimtex",
        config = function()
            vim.g.vimtex_view_method = "zathura"
        end,
    },
})

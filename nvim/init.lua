-- Set leader key to Space
vim.g.mapleader = " "

-- Enable true colors and theme
vim.o.termguicolors = true
vim.o.background = "dark"

-- Line numbers & indentation
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

-- Searching
vim.o.ignorecase = true
vim.o.smartcase = true

-- Mouse support
vim.o.mouse = "a"

-- Keybindings
vim.api.nvim_set_keymap("n", "<leader>w", ":w<CR>", { noremap = true, silent = true }) -- Save
vim.api.nvim_set_keymap("n", "<leader>q", ":q<CR>", { noremap = true, silent = true }) -- Quit

-- Window navigation
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true })

-- Terminal (Toggle with Shift+`)
vim.api.nvim_set_keymap("n", "<S-`>", ":split | terminal<CR>", { noremap = true, silent = true })

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
    end
    vim.opt.rtp:prepend(lazypath) -- Ensure lazy.nvim actually gets loaded

    -- Install and configure plugins
    require("lazy").setup({
        -- File Explorer (Sidebar)
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
        require("nvim-tree").setup()
        vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
        end,
    },

    -- Gruvbox Theme
    {
        "morhetz/gruvbox",
        config = function()
        vim.cmd("colorscheme gruvbox")
        end,
    },

    -- Status Line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
        require("lualine").setup()
        end,
    },

    -- Tabs / Bufferline
    {
        "akinsho/bufferline.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
        require("bufferline").setup()
        vim.api.nvim_set_keymap("n", "<Tab>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })
        end,
    },

    -- Syntax Highlighting (Treesitter)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
        require("nvim-treesitter.configs").setup {
            ensure_installed = { "python", "cpp", "r", "lua", "bash", "sql", "latex", "rust" },
            highlight = { enable = true },
        }
        end,
    },

    -- Terminal (ToggleTerm for bottom terminal)
    {
        "akinsho/toggleterm.nvim",
        config = function()
        require("toggleterm").setup({
            open_mapping = [[<leader>`]], -- Space + ` to toggle the terminal
            direction = "horizontal",
            size = function(term)
            return vim.o.lines * 0.25  -- Set terminal height to 1/4th of the screen
            end,
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            persist_size = true,
        })
        end,
    },

    -- Fuzzy Finder (Telescope)
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
        local builtin = require("telescope.builtin")
        vim.api.nvim_set_keymap("n", "<leader>ff", ":Telescope find_files<CR>", { noremap = true, silent = true })
        end,
    },

    -- Language Server Protocol (LSP) & Auto-completion
    {
        "neovim/nvim-lspconfig",
        config = function()
        require("lspconfig").pyright.setup{} -- Python LSP
        require("lspconfig").clangd.setup{}  -- C++ LSP
        require("lspconfig").r_language_server.setup{}  -- R LSP
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
        },
        config = function()
        local cmp = require("cmp")
        cmp.setup({
            mapping = cmp.mapping.preset.insert({
                ["<Tab>"] = cmp.mapping.select_next_item(),
                                                ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                                                ["<CR>"] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "buffer" },
                { name = "path" },
            }),
        })
        end,
    },

    -- Git Integration
    {
        "tpope/vim-fugitive",
        config = function()
        vim.api.nvim_set_keymap("n", "<leader>gs", ":Git<CR>", { noremap = true, silent = true })
        end,
    },

    -- LaTeX Support
    {
        "lervag/vimtex",
        config = function()
        vim.g.vimtex_view_method = "zathura"
        end,
    },

    -- Jupyter Notebook Execution (Magma)
    {
        "dccsillag/magma-nvim",
        build = ":UpdateRemotePlugins",
        config = function()
        vim.g.magma_automatically_open_output = false
        vim.api.nvim_set_keymap("n", "<leader>r", ":MagmaEvaluateLine<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("v", "<leader>r", ":<C-u>MagmaEvaluateVisual<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("n", "<leader>o", ":MagmaShowOutput<CR>", { noremap = true, silent = true })
        end,
    },

    -- Debugging (nvim-dap)
    {
        "mfussenegger/nvim-dap",
        dependencies = { "mfussenegger/nvim-dap-python" },
        config = function()
        local dap_python = require("dap-python")
        dap_python.setup(vim.fn.expand("$HOME/.cache/pypoetry/virtualenvs/nvim-*/bin/python"))

        vim.api.nvim_set_keymap("n", "<F5>", ":lua require'dap'.continue()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("n", "<F10>", ":lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("n", "<F11>", ":lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true })
        end,
    },
    })

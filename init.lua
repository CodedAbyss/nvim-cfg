vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

 ---------------------------------------------- [ All Keymaps ] -----------------------------------------------

local setup_basic_keymaps = function()
    local telescope = require('telescope.builtin')

    vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

    -- Nagivate tabs
    for i = 1,9 do
        vim.keymap.set('n', '<leader>' .. i, i .. 'gt', { noremap = true })
    end

    -- Tab or untab selection
    vim.keymap.set('v', '<S-Tab>', '<gv', { noremap = true })
    vim.keymap.set('v', '<Tab>', '>gv', { noremap = true })

    -- Exit terminal without wanting to kill yourself
    vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true })

    -- moves current line up or down, it's overcomplicated to paste in place with no buffer jittering
    vim.keymap.set('n', '<A-j>', 'YjVpkVpj', { noremap = true })
    vim.keymap.set('n', '<A-k>', 'YkVpjVpk', { noremap = true })

    -- Remap for dealing with word wrap
    vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
    vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

    -- See `:help telescope.builtin`
    vim.keymap.set('n', '<leader>g', telescope.git_files, { desc = 'Search [G]it files' })
    vim.keymap.set('n', '<leader>f', telescope.find_files, { desc = 'Search [F]iles' })
    vim.keymap.set('n', '<leader>h', telescope.help_tags, { desc = 'Search [H]elp' })
    vim.keymap.set('n', '<leader>w', telescope.diagnostics, { desc = 'Search [W]arnings' })
    vim.keymap.set('n', '<leader>?', telescope.oldfiles, { desc = '[?] Find recently opened files' })
    vim.keymap.set('n', '<leader><space>', telescope.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        telescope.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
        })
        end,
        { desc = '[/] Fuzzily search in current buffer' })
end

local setup_lsp_keymaps = function(bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    local telescope = require('telescope.builtin')
    local lsp = vim.lsp.buf

    nmap('<leader>r', vim.lsp.buf.rename, '[R]ename')

    nmap('gd', lsp.definition, '[G]oto [D]efinition')
    nmap('gD', lsp.declaration, '[G]oto [D]eclaration')
    nmap('gr', telescope.lsp_references, '[G]oto [R]eferences')
    nmap('gI', lsp.implementation, '[G]oto [I]mplementation')
    nmap('<leader>t', lsp.type_definition, 'Type [D]efinition')
    nmap('<leader>s', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>sa', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', lsp.hover, 'Hover Documentation')
    nmap('<C-k>', lsp.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('<leader>wa', lsp.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', lsp.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(lsp.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')
end

local setup_deubgging_keymaps = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })

    vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
    dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })
end

setup_basic_keymaps()

 ---------------------------------------------- [ End of Keymaps ] -----------------------------------------------

-- order id X241125989635

 ------------------------------------------[ DEBUGGER ]------------------------------------------
local function setup_debugger()
    return {
        'mfussenegger/nvim-dap',
        dependencies = {
            { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
            'williamboman/mason.nvim',
            'jay-babu/mason-nvim-dap.nvim',
        },
        config = function()
            local dap = require 'dap'
            local dapui = require 'dapui'
            require('mason-nvim-dap').setup {
                automatic_setup = true,
                handlers = {},
                ensure_installed = { 'codelldb' }
            }
            dapui.setup {
                icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
                controls = {
                    icons = {
                        pause = '⏸',
                        play = '▶',
                        step_into = '⏎',
                        step_over = '⏭',
                        step_out = '⏮',
                        step_back = 'b',
                        run_last = '▶▶',
                        terminate = '⏹',
                        disconnect = '⏏',
                    },
                },
            }

            setup_deubgging_keymaps()

            dap.listeners.after.event_initialized['dapui_config'] = dapui.open
            dap.listeners.before.event_terminated['dapui_config'] = dapui.close
            dap.listeners.before.event_exited['dapui_config'] = dapui.close
            dap.adapters.codelldb = {
                type = 'server',
                port = '${port}',
                executable = {
                    command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
                    args = { '--port', '${port}' }
                }
            }
            local actions = require('telescope.actions')
            local state = require('telescope.actions.state')
            local cfg = require('telescope.config')

            local debug_info = {}
            vim.keymap.set('n', '<F5>', function()
                -- this will force telescope to only show executables (files without extensions)
                -- this will need to be fixed for .exe's on windows
                cfg.set_defaults({ file_ignore_patterns = { '%w%.%w' } })

                -- this will reset the ignore list when the dialog closes
                local close_and_reset = function(bufno)
                    actions.close(bufno)
                    cfg.set_defaults({ file_ignore_patterns = {} })
                end

                -- this gets the executable path from telescope and launches a debug session
                local debug_executable = function(bufno)
                    local entry = state.get_selected_entry()
                    debug_info.executable = entry[1]
                    close_and_reset(bufno)
                    dap.continue()
                end

                -- this initializes the executable-search dialog
                require('telescope.builtin').find_files({
                    previewer = false,
                    prompt_title = 'Find Executable',
                    attach_mappings = function (_, map)
                        actions.select_default:replace(debug_executable)
                        map('i', '<C-c>', close_and_reset)
                        map('n', '<ESC>', close_and_reset)
                        return true
                    end
                })
            end, { desc = 'Debug: Start/Continue' })

            local basic_llvm_cfg = function(info)
                return {
                    name = 'Launch',
                    type = 'codelldb',
                    request = 'launch',
                    program = function()
                        print('getting executable ' .. info.executable)
                        return info.executable
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},
                }
            end
            dap.configurations.c = { basic_llvm_cfg(debug_info) }
            dap.configurations.cpp = { basic_llvm_cfg(debug_info) }
            local basic_rust_cfg = basic_llvm_cfg(debug_info);
            basic_rust_cfg.initCommands = function()
                -- Find out where to look for the pretty printer Python module
                local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))
                local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
                local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'
                local commands = {}
                local file = io.open(commands_file, 'r')
                if file then
                    for line in file:lines() do
                        table.insert(commands, line)
                    end
                    file:close()
                end
                table.insert(commands, 1, script_import)
                return commands
            end
            dap.configurations.rust = { basic_rust_cfg };
        end
    }
end

-- local empty = require('lualine.component'):extend()

require('lazy').setup({
    { 'xiyaowong/transparent.nvim' }, -- transparency
    { -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'williamboman/mason.nvim', config = true }, -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason-lspconfig.nvim',
            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
            'folke/neodev.nvim', -- Additional lua configuration, makes nvim stuff amazing!
        },
    },
    { -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            { 'L3MON4D3/LuaSnip', version = "v2.*" }, -- Snippet Engine & its associated nvim-cmp source
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-nvim-lsp', -- Adds LSP completion capabilities
            'rafamadriz/friendly-snippets', -- Adds a number of user-friendly snippets
        },
    },
    { -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        opts = {}
    },
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
            on_attach = function(bufnr)
                vim.keymap.set('n', '<leader>gp', function() require('gitsigns').nav_hunk('prev') end, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
                vim.keymap.set('n', '<leader>gn', function() require('gitsigns').nav_hunk('next') end, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
                vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
            end,
        },
    },
    { -- Theme
        'catppuccin/nvim',
        priority = 1000,
        config = function()
          vim.cmd.colorscheme 'catppuccin'
        end,
    },
    { -- Status line
        'nvim-lualine/lualine.nvim',
        opts = {
            options = {
                icons_enabled = false,
                theme = 'catppuccin',
                component_separators = '|',
                section_separators = '',
            },
            sections = {
                lualine_x = {'encoding', 'fileformat', 'filetype', function () return vim.lsp.buf_get_active_clients()[1].name end },
            }
        },
    },
    { -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        main = 'ibl',
        opts = {
            indent = { char = '┊' }
        },
    },
    { -- "gc" to comment visual regions/lines
        'numToStr/Comment.nvim',
        opts = {
            toggler = {
                line = '<A-/>',
                block = '<A-*>'
            },
            opleader = {
                line = '<A-/>',
                block = '<A-*>'
            }
        }
    },
    { -- Fuzzy Finder (files, lsp, etc)
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { -- uses make to build stuff from source
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
        },
    },
    { -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        build = ':TSUpdate',
    },
    setup_debugger()
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or capital in search
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect' -- Set completeopt to have a better completion experience
vim.o.termguicolors = true

-- Edit settings easily
vim.api.nvim_create_user_command('Settings', function()
    vim.cmd('e ' .. vim.fn.stdpath('config') .. '/init.lua')
end, {})

vim.api.nvim_create_autocmd('TermOpen', {
    callback = function()
        vim.opt_local.relativenumber = false
    end
})
-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
}

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'lua', 'python', 'zig', 'rust', 'haskell' },
    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
            },
            goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
            },
            goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
            },
            goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
                ['<leader>A'] = '@parameter.inner',
            },
        },
    },
}

-- Diagnostic keymaps
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
    clangd = {},
    rust_analyzer = {},
    typst_lsp = {
        exportPdf = "onType",
        root_dir = function(_)
            return vim.loop.cwd()
        end
    },
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = {
                disable = { "missing-fields" }
            }
        }
    },
    hls = {},
    zls = {}
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}

local on_lsp_attach = function(_, bufnr)
    setup_lsp_keymaps(bufnr)
    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

mason_lspconfig.setup_handlers {
    function(server_name)
        print('setting up ' .. server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_lsp_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
        }
    end
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
}

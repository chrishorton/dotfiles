vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

vim.o.relativenumber = true
vim.o.number = true

vim.o.mouse = 'a'

vim.o.showmode = false

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \\C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 5

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<leader>h', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<leader>l', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<leader>j', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<leader>k', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically

  {
    'shortcuts/no-neck-pain.nvim',
    version = '*',
    config = function()
      require('no-neck-pain').setup {
        width = 100,
        mappings = {
          enabled = false, -- we’re doing our own keymaps
        },
      }

      local map = vim.keymap.set

      -- Toggle NoNeckPain
      map('n', '<leader>np', '<cmd>NoNeckPain<CR>', { desc = 'Toggle NoNeckPain' })

      -- Toggle right buffer
      map('n', '<leader>nr', '<cmd>NoNeckPainToggleRightSide<CR>', { desc = 'Toggle Right Buffer' })

      -- Toggle left buffer
      map('n', '<leader>nl', '<cmd>NoNeckPainToggleLeftSide<CR>', { desc = 'Toggle Left Buffer' })

      -- Increase padding (width +10)
      map('n', '<leader>n+', '<cmd>NoNeckPainWidthUp<CR>', { desc = 'Increase Padding' })

      -- Decrease padding (width -10)
      map('n', '<leader>n-', '<cmd.NoNeckPainWidthDown<CR>', { desc = 'Decrease Padding' })

      -- Width presets via :NoNeckPainResize INT
      map('n', '<leader>n1', '<cmd>NoNeckPainResize 80<CR>', { desc = 'NoNeckPain Width 80' })
      map('n', '<leader>n2', '<cmd.NoNeckPainResize 100<CR>', { desc = 'NoNeckPain Width 100' })
      map('n', '<leader>n3', '<cmd.NoNeckPainResize 120<CR>', { desc = 'NoNeckPain Width 120' })
    end,
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
    },
  },
  -- DAP core
  {
    'mfussenegger/nvim-dap',
    keys = {
      {
        '<F5>',
        function()
          require('dap').continue()
        end,
        desc = 'DAP Continue',
      },
      {
        '<F10>',
        function()
          require('dap').step_over()
        end,
        desc = 'DAP Step Over',
      },
      {
        '<F11>',
        function()
          require('dap').step_into()
        end,
        desc = 'DAP Step Into',
      },
      {
        '<F12>',
        function()
          require('dap').step_out()
        end,
        desc = 'DAP Step Out',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'DAP Breakpoint',
      },
    },
    config = function()
      -- Java adapter is usually set up by jdtls; we only add a convenience attach config.
      local dap = require 'dap'
      dap.configurations.java = {
        {
          type = 'java',
          request = 'attach',
          name = 'Debug (Attach) - Remote',
          hostName = '127.0.0.1',
          port = 5005,
        },
      }
    end,
  },

  -- DAP UI
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      require('dapui').setup()
      local dap, dapui = require 'dap', require 'dapui'
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
  },

  -- DAP virtual text
  {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      require('nvim-dap-virtual-text').setup()
    end,
  },

  {
    'rcasia/neotest-java',
    ft = 'java',
    dependencies = {
      'mfussenegger/nvim-jdtls',
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
  },

  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'rcasia/neotest-java',
    },
    config = function()
      local neotest = require 'neotest'
      neotest.setup {
        adapters = {
          require 'neotest-java' {
            junit_jar = nil, -- default: stdpath("data") .. /nvim/neotest-java/junit-platform-console-standalone-[version].jar
            incremental_build = true,
          },
        },
      }
      -- Run nearest test
      vim.keymap.set('n', '<leader>tn', function()
        neotest.run.run()
      end, { desc = 'Run nearest test' })

      -- Run tests in current file
      vim.keymap.set('n', '<leader>tf', function()
        neotest.run.run(vim.fn.expand '%')
      end, { desc = 'Run tests in file' })

      -- Toggle summary view
      vim.keymap.set('n', '<leader>ts', function()
        neotest.summary.toggle()
      end, { desc = 'Toggle test summary' })

      -- Show test output
      vim.keymap.set('n', '<leader>to', function()
        neotest.output.open { enter = true }
      end, { desc = 'Show test output' })

      -- ⭐ Run matching test for the matching source file
      vim.keymap.set('n', '<leader>tr', function()
        -- Jump to the mirrored test file:
        -- src/main/java/... -> src/test/java/...Test.java
        local src = vim.api.nvim_buf_get_name(0)
        local test = src:gsub('src/main/java', 'src/test/java'):gsub('([^/]+)%.java$', '%1Test.java')

        neotest.run.run(test)
      end, { desc = 'Run test file for source file' })
    end,
  },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = { ['ui-select'] = { require('telescope.themes').get_dropdown() } },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = { ensure_installed = { 'java-debug-adapter', 'java-test' } } },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        gopls = {},
        pyright = {},
        rust_analyzer = {},
        ts_ls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { 'stylua' })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
  {
    'scalameta/nvim-metals',
    dependencies = {
      {
        'j-hui/fidget.nvim',
        opts = {},
      },
      {
        'mfussenegger/nvim-dap',
        config = function(self, opts)
          local dap = require 'dap'

          dap.configurations.scala = {
            {
              type = 'scala',
              request = 'launch',
              name = 'RunOrTest',
              metals = {
                runType = 'runOrTestFile',
              },
            },
            {
              type = 'scala',
              request = 'launch',
              name = 'Test Target',
              metals = {
                runType = 'testTarget',
              },
            },
          }
        end,
      },
    },
    ft = { 'scala', 'sbt' },
    opts = function()
      local metals_config = require('metals').bare_config()

      -- Example of settings
      metals_config.settings = {
        showImplicitArguments = true,
        excludedPackages = { 'akka.actor.typed.javadsl', 'com.github.swagger.akka.javadsl' },
      }

      -- *READ THIS*
      -- I *highly* recommend setting statusBarProvider to either "off" or "on"
      --
      -- "off" will enable LSP progress notifications by Metals and you'll need
      -- to ensure you have a plugin like fidget.nvim installed to handle them.
      --
      -- "on" will enable the custom Metals status extension and you *have* to have
      -- a have settings to capture this in your statusline or else you'll not see
      -- any messages from metals. There is more info in the help docs about this
      metals_config.init_options.statusBarProvider = 'off'

      -- -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
      -- metals_config.capabilities = require('cmp_nvim_lsp').default_capabilities()

      metals_config.on_attach = function(client, bufnr)
        local map = vim.keymap.set
        require('metals').setup_dap()
        map('n', '<leader>ws', function()
          require('metals').hover_worksheet()
        end)

        -- all workspace diagnostics
        map('n', '<leader>aa', vim.diagnostic.setqflist)

        -- all workspace errors
        map('n', '<leader>ae', function()
          vim.diagnostic.setqflist { severity = 'E' }
        end)

        -- all workspace warnings
        map('n', '<leader>aw', function()
          vim.diagnostic.setqflist { severity = 'W' }
        end)

        -- buffer diagnostics only
        map('n', '<leader>d', vim.diagnostic.setloclist)

        -- Example mappings for usage with nvim-dap. If you don't use that, you can
        -- skip these
        map('n', '<leader>dc', function()
          require('dap').continue()
        end)

        map('n', '<leader>dr', function()
          require('dap').repl.toggle()
        end)

        map('n', '<leader>dK', function()
          require('dap.ui.widgets').hover()
        end)

        map('n', '<leader>dt', function()
          require('dap').toggle_breakpoint()
        end)

        map('n', '<leader>dso', function()
          require('dap').step_over()
        end)

        map('n', '<leader>dsi', function()
          require('dap').step_into()
        end)

        map('n', '<leader>dl', function()
          require('dap').run_last()
        end)
      end

      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = self.ft,
        callback = function()
          require('metals').initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,
  },
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return { timeout_ms = 500, lsp_format = 'fallback' }
        end
      end,
      formatters_by_ft = { lua = { 'stylua' } },
    },
  },

  {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' },
    dependencies = {
      'folke/which-key.nvim',
      {
        'mason-org/mason.nvim',
        opts = { ensure_installed = { 'jdtls', 'java-debug-adapter', 'java-test' } },
      },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    opts = function()
      -- Base jdtls command (installed via Mason)
      local cmd = { vim.fn.exepath 'jdtls' }

      -- Lombok (optional) if present in Mason
      local mason = vim.fn.stdpath 'data' .. '/mason'
      local lombok_candidates = {
        mason .. '/packages/jdtls/lombok.jar',
        mason .. '/share/jdtls/lombok.jar',
      }
      for _, p in ipairs(lombok_candidates) do
        if vim.uv.fs_stat(p) then
          table.insert(cmd, ('--jvm-arg=-javaagent:%s'):format(p))
          break
        end
      end

      -- Root detection via jdtls helper
      local find_root = function(path)
        return require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }, path)
      end

      return {
        -- Find project root
        root_dir = function(path)
          return find_root(path)
        end,

        -- Project name from root dir
        project_name = function(root_dir)
          return root_dir and vim.fs.basename(root_dir) or nil
        end,

        -- Where to put per-project config/workspace
        jdtls_config_dir = function(project_name)
          return vim.fn.stdpath 'cache' .. '/jdtls/' .. project_name .. '/config'
        end,
        jdtls_workspace_dir = function(project_name)
          return vim.fn.stdpath 'cache' .. '/jdtls/' .. project_name .. '/workspace'
        end,

        -- How to run jdtls
        cmd = cmd,
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local out = vim.deepcopy(opts.cmd)
          if project_name then
            vim.list_extend(out, {
              '-configuration',
              opts.jdtls_config_dir(project_name),
              '-data',
              opts.jdtls_workspace_dir(project_name),
            })
          end
          return out
        end,

        -- DAP/test toggles
        dap = { hotcodereplace = 'auto', config_overrides = {} },
        -- IMPORTANT: disable main-class autoscan to avoid resolveMainClass errors
        dap_main = false,
        test = true,

        -- JDTLS settings
        settings = {
          java = {
            inlayHints = { parameterNames = { enabled = 'all' } },
          },
        },

        -- Optional override table you can set from elsewhere
        jdtls = nil,
      }
    end,
    config = function(_, opts)
      -- Collect debug/test bundles if present
      local mason = vim.fn.stdpath 'data' .. '/mason'
      local function glob(p)
        local r = vim.fn.glob(p, false, true)
        if type(r) == 'string' then
          if r == '' then
            return {}
          end
          return vim.split(r, '\n', { trimempty = true })
        end
        return r
      end

      local bundles = {}
      for _, p in ipairs(glob(mason .. '/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar')) do
        table.insert(bundles, p)
      end
      for _, p in ipairs(glob(mason .. '/share/java-test/*.jar')) do
        table.insert(bundles, p)
      end

      -- Capabilities (blink.cmp → cmp_nvim_lsp → none)
      local function get_capabilities()
        local ok_blink, blink = pcall(require, 'blink.cmp')
        if ok_blink and blink.get_lsp_capabilities then
          return blink.get_lsp_capabilities()
        end
        local ok_cmp, cmp = pcall(require, 'cmp_nvim_lsp')
        if ok_cmp and cmp.default_capabilities then
          return cmp.default_capabilities()
        end
        return nil
      end

      -- Attach jdtls for each Java buffer
      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)
        local base = {
          cmd = opts.full_cmd(opts),
          root_dir = opts.root_dir(fname),
          init_options = { bundles = bundles },
          settings = opts.settings,
          capabilities = get_capabilities(),
        }
        local cfg = opts.jdtls and vim.tbl_deep_extend('force', base, opts.jdtls) or base

        if not cfg.root_dir or cfg.root_dir == '' then
          return
        end

        require('jdtls').start_or_attach(cfg)
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'java' },
        callback = attach_jdtls,
      })

      -- which-key mappings + DAP wiring AFTER LSP attaches
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= 'jdtls' then
            return
          end

          -- which-key Java actions
          local ok_wk, wk = pcall(require, 'which-key')
          if ok_wk then
            wk.add {
              {
                mode = 'n',
                buffer = args.buf,
                { '<leader>cx', group = 'extract' },
                { '<leader>cxv', require('jdtls').extract_variable_all, desc = 'Extract Variable' },
                { '<leader>cxc', require('jdtls').extract_constant, desc = 'Extract Constant' },
                { '<leader>cgs', require('jdtls').super_implementation, desc = 'Goto Super' },
                { '<leader>cgS', require('jdtls.tests').goto_subjects, desc = 'Goto Subjects' },
                { '<leader>co', require('jdtls').organize_imports, desc = 'Organize Imports' },
              },
            }
            wk.add {
              {
                mode = 'x',
                buffer = args.buf,
                { '<leader>cx', group = 'extract' },
                { '<leader>cxm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], desc = 'Extract Method' },
                { '<leader>cxv', [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]], desc = 'Extract Variable' },
                { '<leader>cxc', [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]], desc = 'Extract Constant' },
              },
            }
          end

          -- DAP wiring (no main-class scan!)
          local ok_dap_j = pcall(require, 'jdtls.dap')
          if ok_dap_j and opts.dap then
            pcall(function()
              require('jdtls').setup_dap(opts.dap)
            end)
          end
        end,
      })
    end,
  },
  -- Autocompletion
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- { 'rafamadriz/friendly-snippets',
          --   config = function() require('luasnip.loaders.from_vscode').lazy_load() end, },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    opts = {
      keymap = { preset = 'default' },
      appearance = { nerd_font_variant = 'mono' },
      completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = { lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 } },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  -- COLORSCHEME
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 999,
    config = function()
      require('catppuccin').setup()
    end,
  },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup {
        styles = { comments = { italic = false } },
      }
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'java', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = { 'ruby' } },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
-- Theme toggle: cycles through the three schemes you want

-- Pick your themes
local light_theme = 'catppuccin-latte'
local dark_theme = 'tokyonight-night' -- or "catppuccin-mocha"

-- Helper function: determine if it's day or night
local function is_daytime()
  local hour = tonumber(os.date '%H') -- 00–23
  return hour >= 7 and hour < 19 -- 7am to 7pm = daytime
end

-- Apply correct theme based on time
local function set_theme_by_time()
  if is_daytime() then
    vim.cmd('colorscheme ' .. light_theme)
  else
    vim.cmd('colorscheme ' .. dark_theme)
  end
end

-- Run on startup
set_theme_by_time()

local themes = { dark_theme, 'catppuccin-mocha', light_theme }
local current = 1

function ToggleTheme()
  current = current + 1
  if current > #themes then
    current = 1
  end
  vim.cmd('colorscheme ' .. themes[current])
  print('Theme: ' .. themes[current])
end

vim.keymap.set('n', '<leader>ut', ToggleTheme, { desc = 'Toggle theme' })

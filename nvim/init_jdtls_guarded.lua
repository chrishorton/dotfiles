--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
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

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 5
vim.o.confirm = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>h', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<leader>l', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<leader>j', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<leader>k', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'NMAC427/guess-indent.nvim',
  { 'lewis6991/gitsigns.nvim', opts = { signs = { add = { text = '+' }, change = { text = '~' }, delete = { text = '_' }, topdelete = { text = '‾' }, changedelete = { text = '~' }, }, }, },

  -- nvim-dap and friends
  { 'mfussenegger/nvim-dap', config = function() local dap = require('dap'); dap.configurations.java = { { type = 'java', request = 'attach', name = 'Debug (Attach) - Remote', hostName = '127.0.0.1', port = 5005, }, } end },
  { 'rcarriga/nvim-dap-ui', dependencies = { 'mfussenegger/nvim-dap' }, config = function() require('dapui').setup() local dap, dapui = require('dap'), require('dapui'); dap.listeners.after.event_initialized['dapui_config']=function()dapui.open()end; dap.listeners.before.event_terminated['dapui_config']=function()dapui.close()end; dap.listeners.before.event_exited['dapui_config']=function()dapui.close()end end },
  { 'theHamsta/nvim-dap-virtual-text', dependencies = { 'mfussenegger/nvim-dap' }, config = function() require('nvim-dap-virtual-text').setup() end },

  -- Java + Neotest
  { 'rcasia/neotest-java', ft = 'java', dependencies = { 'mfussenegger/nvim-jdtls', 'mfussenegger/nvim-dap', 'rcarriga/nvim-dap-ui', 'theHamsta/nvim-dap-virtual-text', }, },
  { 'nvim-neotest/neotest', dependencies = { 'nvim-neotest/nvim-nio', 'nvim-lua/plenary.nvim', 'antoinemadec/FixCursorHold.nvim', 'nvim-treesitter/nvim-treesitter', 'rcasia/neotest-java', }, config = function() require('neotest').setup { adapters = { require('neotest-java')({ incremental_build = true }) } } end },

  -- jdtls full guarded setup
  {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' },
    dependencies = { 'folke/which-key.nvim', { 'mason-org/mason.nvim', opts = { ensure_installed = { 'jdtls', 'java-debug-adapter', 'java-test' } } }, 'WhoIsSethDaniel/mason-tool-installer.nvim', },
    opts = function()
      local cmd = { vim.fn.exepath 'jdtls' }
      local mason = vim.fn.stdpath 'data' .. '/mason'
      for _, p in ipairs({ mason .. '/packages/jdtls/lombok.jar', mason .. '/share/jdtls/lombok.jar' }) do
        if vim.uv.fs_stat(p) then table.insert(cmd, ('--jvm-arg=-javaagent:%s'):format(p)) break end
      end
      local find_root = function(path) return require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }, path) end
      return {
        root_dir = function(path) return find_root(path) end,
        project_name = function(root_dir) return root_dir and vim.fs.basename(root_dir) or nil end,
        jdtls_config_dir = function(project_name) return vim.fn.stdpath 'cache' .. '/jdtls/' .. project_name .. '/config' end,
        jdtls_workspace_dir = function(project_name) return vim.fn.stdpath 'cache' .. '/jdtls/' .. project_name .. '/workspace' end,
        cmd = cmd,
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local out = vim.deepcopy(opts.cmd)
          if project_name then vim.list_extend(out, { '-configuration', opts.jdtls_config_dir(project_name), '-data', opts.jdtls_workspace_dir(project_name), }) end
          return out
        end,
        dap = { hotcodereplace = 'auto', config_overrides = {} },
        dap_main = {},
        test = true,
        settings = { java = { inlayHints = { parameterNames = { enabled = 'all' } }, }, },
        jdtls = nil,
      }
    end,
    config = function(_, opts)
      local mason = vim.fn.stdpath 'data' .. '/mason'
      local function glob(p) local r = vim.fn.glob(p, false, true); if type(r) == 'string' then if r == '' then return {} end return vim.split(r, '\n', { trimempty = true }) end return r end
      local bundles = {}
      for _, p in ipairs(glob(mason .. '/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar')) do table.insert(bundles, p) end
      for _, p in ipairs(glob(mason .. '/share/java-test/*.jar')) do table.insert(bundles, p) end

      local function get_capabilities()
        local ok_blink, blink = pcall(require, 'blink.cmp')
        if ok_blink and blink.get_lsp_capabilities then return blink.get_lsp_capabilities() end
        local ok_cmp, cmp = pcall(require, 'cmp_nvim_lsp')
        if ok_cmp and cmp.default_capabilities then return cmp.default_capabilities() end
        return nil
      end

      local main_scan_done_by_root = {}
      local function jdtls_supports_resolve(client)
        local cmds = (((client.server_capabilities or {}).executeCommandProvider) or {}).commands or {}
        for _, c in ipairs(cmds) do if c == 'vscode.java.resolveMainClass' then return true end end
        return false
      end

      local function schedule_main_class_scan(client, root_dir, dap_main, max_retries)
        if not dap_main or main_scan_done_by_root[root_dir] then return end
        local tries = 0
        local function go()
          if not vim.lsp.get_client_by_id(client.id) or main_scan_done_by_root[root_dir] then return end
          if jdtls_supports_resolve(client) then
            local ok_dap_j = pcall(require, 'jdtls.dap')
            if ok_dap_j then
              pcall(function()
                require('jdtls').setup_dap({ hotcodereplace = 'auto' })
                require('jdtls.dap').setup_dap_main_class_configs(dap_main)
                main_scan_done_by_root[root_dir] = true
              end)
            end
            return
          end
          tries = tries + 1
          if tries < (max_retries or 10) then vim.defer_fn(go, 200) end
        end
        vim.defer_fn(go, 100)
      end

      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)
        local base = { cmd = opts.full_cmd(opts), root_dir = opts.root_dir(fname), init_options = { bundles = bundles }, settings = opts.settings, capabilities = get_capabilities(), }
        local cfg = opts.jdtls and vim.tbl_deep_extend('force', base, opts.jdtls) or base
        if not cfg.root_dir or cfg.root_dir == '' then return end
        require('jdtls').start_or_attach(cfg)
      end

      vim.api.nvim_create_autocmd('FileType', { pattern = { 'java' }, callback = attach_jdtls })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= 'jdtls' then return end

          local ok_wk, wk = pcall(require, 'which-key')
          if ok_wk then
            wk.add({
              { mode = 'n', buffer = args.buf,
                { '<leader>cx', group = 'extract' },
                { '<leader>cxv', require('jdtls').extract_variable_all, desc = 'Extract Variable' },
                { '<leader>cxc', require('jdtls').extract_constant, desc = 'Extract Constant' },
                { '<leader>cgs', require('jdtls').super_implementation, desc = 'Goto Super' },
                { '<leader>cgS', require('jdtls.tests').goto_subjects, desc = 'Goto Subjects' },
                { '<leader>co', require('jdtls').organize_imports, desc = 'Organize Imports' },
              },
            })
            wk.add({
              { mode = 'x', buffer = args.buf,
                { '<leader>cx', group = 'extract' },
                { '<leader>cxm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], desc = 'Extract Method' },
                { '<leader>cxv', [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]], desc = 'Extract Variable' },
                { '<leader>cxc', [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]], desc = 'Extract Constant' },
              },
            })
          end

          local ok_dap_j = pcall(require, 'jdtls.dap')
          if ok_dap_j and opts.dap then
            pcall(function() require('jdtls').setup_dap(opts.dap) end)
            local root_dir = client.config.root_dir or ''
            schedule_main_class_scan(client, root_dir, opts.dap_main, 12)
          end
        end,
      })
    end,
  },

  { 'folke/tokyonight.nvim', priority = 1000, config = function() require('tokyonight').setup { styles = { comments = { italic = false } } } vim.cmd.colorscheme 'tokyonight-night' end },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘', config = '🛠', event = '📅', ft = '📂', init = '⚙', keys = '🗝',
      plugin = '🔌', runtime = '💻', require = '🌙', source = '📄', start = '🚀',
      task = '📌', lazy = '💤 ',
    },
  },
})

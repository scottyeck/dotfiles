-- Autocompletion with nvim-cmp
return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- LSP completion source
      'hrsh7th/cmp-nvim-lsp',
      -- Buffer completions
      'hrsh7th/cmp-buffer',
      -- Path completions
      'hrsh7th/cmp-path',
      -- Snippet engine (required by nvim-cmp)
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        mapping = cmp.mapping.preset.insert({
          -- Select next/previous item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll docs
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Trigger completion manually
          ['<C-Space>'] = cmp.mapping.complete(),

          -- Confirm selection
          ['<CR>'] = cmp.mapping.confirm({ select = true }),

          -- Smart Tab: Copilot -> cmp -> snippet -> fallback
          ['<Tab>'] = cmp.mapping(function(fallback)
            local ok, copilot = pcall(require, "copilot.suggestion")
            if ok and copilot.is_visible() then
              copilot.accept()
            elseif cmp.visible() then
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
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        }, {
          { name = 'buffer' },
        }),
      })
    end,
  },

  -- Advertise LSP completion capabilities
  {
    'hrsh7th/cmp-nvim-lsp',
    lazy = true,
    config = function()
      -- Make completion capabilities available globally for LSP configs
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Store capabilities for LSP configs to use
      vim.g.lsp_capabilities = capabilities
    end,
  },
}

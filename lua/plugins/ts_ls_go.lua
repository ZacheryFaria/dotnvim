-- if not vim.g.ts_go_ls then return {} end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = function(plugin, opts)
    opts.servers = opts.servers or {}
    table.insert(opts.servers, "ts_go_ls")

    -- extend our configuration table to have our new prolog server
    opts.config = require("astrocore").extend_tbl(opts.config or {}, {
      -- this must be a function to get access to the `lspconfig` module
      ts_go_ls = {
        -- the command for starting the server
        cmd = {
          "tsgo",
          "--lsp",
          "--stdio",
        },
        -- the filetypes to attach the server to
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        -- root directory detection for detecting the project root
        root_dir = require("lspconfig.util").root_pattern ".git",
        -- Limit capabilities to only autocompletion and go-to-definition
        on_attach = function(client, _)
          -- Disable all capabilities except completion and definition
          local keep_completion = client.server_capabilities.completionProvider
          local keep_definition = client.server_capabilities.definitionProvider
          
          -- Preserve properties needed by the change tracking system
          local change_tracking_props = {
            "positionEncoding",
            "textDocumentSync",
          }
          
          -- Save the required properties
          local preserved = {}
          for _, prop in ipairs(change_tracking_props) do
            preserved[prop] = client.server_capabilities[prop]
          end
          
          -- Reset capabilities
          for k in pairs(client.server_capabilities) do
            client.server_capabilities[k] = nil
          end
          
          -- Restore only what we want to keep
          client.server_capabilities.completionProvider = keep_completion
          client.server_capabilities.definitionProvider = keep_definition
          
          -- Explicitly disable references provider (gr in Vim) to ensure vtsls handles it
          client.server_capabilities.referencesProvider = false
          -- Explicitly disable implementation provider to ensure vtsls handles it
          client.server_capabilities.implementationProvider = false
          
          -- Keep diagnostic capabilities
          client.server_capabilities.diagnosticProvider = true
          client.server_capabilities.publishDiagnosticsProvider = true
          
          -- Restore required properties for change tracking
          for prop, value in pairs(preserved) do
            client.server_capabilities[prop] = value
          end
        end,
      },
    })
  end,
}

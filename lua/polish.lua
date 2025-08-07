-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
--

function neo_tree_line_number(arg)
  vim.cmd [[
    setlocal relativenumber
  ]]
end

require("neo-tree").setup {
  event_handlers = {
    {
      event = "neo_tree_buffer_enter",
      handler = neo_tree_line_number,
    },
  },
}

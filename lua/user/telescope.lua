local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

local actions = require "telescope.actions"

telescope.setup {
  defaults = {

    prompt_prefix = " ",
    selection_caret = " ",
    layout_strategy = "vertical",
    path_display = function(opts, path)
      -- Do common substitutions
      path = path:gsub("^/google/src/cloud/[^/]+/[^/]+/google3/", "google3/", 1)
      path = path:gsub("^google3/java/com/google/", "g3/j/c/g/", 1)
      path = path:gsub("^google3/javatests/com/google/", "g3/jt/c/g/", 1)
      path = path:gsub("^google3/third_party/", "g3/3rdp/", 1)
      path = path:gsub("^google3/", "g3/", 1)

      -- Do truncation. This allows us to combine our custom display formatter
      -- with the built-in truncation.
      -- `truncate` handler in transform_path memoizes computed truncation length in opts.__length.
      -- Here we are manually propagating this value between new_opts and opts.
      -- We can make this cleaner and more complicated using metatables :)
      local new_opts = {
        path_display = {
          truncate = true,
        },
        __length = opts.__length,
      }
      path = require('telescope.utils').transform_path(new_opts, path)
      opts.__length = new_opts.__length
      return path
    end,

    mappings = {
      i = {
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,

        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<C-c>"] = actions.close,

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,

        ["<CR>"] = actions.select_default,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        ["<C-t>"] = actions.select_tab,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,

        ["<PageUp>"] = actions.results_scrolling_up,
        ["<PageDown>"] = actions.results_scrolling_down,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<C-l>"] = actions.complete_tag,
        ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
      },

      n = {
        ["<esc>"] = actions.close,
        ["<CR>"] = actions.select_default,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        ["<C-t>"] = actions.select_tab,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

        ["j"] = actions.move_selection_next,
        ["k"] = actions.move_selection_previous,
        ["H"] = actions.move_to_top,
        ["M"] = actions.move_to_middle,
        ["L"] = actions.move_to_bottom,

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,
        ["gg"] = actions.move_to_top,
        ["G"] = actions.move_to_bottom,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,

        ["<PageUp>"] = actions.results_scrolling_up,
        ["<PageDown>"] = actions.results_scrolling_down,

        ["?"] = actions.which_key,
      },
    },
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
    codesearch = {
      experimental = true           -- enable results from google3/experimental
    }
  },
}

-- These custom mappings let you open telescope-codesearch quickly:
-- Fuzzy find files in codesearch.
-- Search using codesearch queries.
local status_ok, _  = require("telescope").load_extension("codesearch")
if not status_ok then
  vim.notify('Codesearch extension not loaded!')
  return
end

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
keymap('n', '<leader>ss', ":lua require('telescope').extensions.codesearch.find_files({})<CR>", opts) 

keymap('n', '<leader>sd', ":lua require('telescope').extensions.codesearch.find_query({})<CR>", opts)

-- Search for the word under cursor.
keymap('n', '<leader>sD', ":lua require('telescope').extensions.codesearch.find_query({default_text_expand='<cword>'})<CR>", opts)

-- Search for a file having word under cursor in its name.
keymap('n', '<leader>sS', ":lua require('telescope').extensions.codesearch.find_files({default_text_expand='<cword>'})<CR>", opts)

keymap('v', '<leader>sd', ":lua require('telescope').extensions.codesearch.find_query({})<CR>", opts)

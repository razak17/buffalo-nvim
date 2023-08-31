local Dev = require("buffalo.dev")
local log = Dev.log
local buffer_is_valid = require("buffalo.utils").buffer_is_valid
local merge_tables = require("buffalo.utils").merge_tables
--
local M = {}

BuffaloConfig = BuffaloConfig or {}

M.marks = {}

function M.initialize_marks()
  local buffers = vim.api.nvim_list_bufs()

  for idx = 1, #buffers do
    local buf_id = buffers[idx]
    local buf_name = vim.api.nvim_buf_get_name(buf_id)
    local filename = buf_name
    -- if buffer is listed, then add to contents and marks
    if buffer_is_valid(buf_id, buf_name) then
      table.insert(
        M.marks,
        {
          filename = filename,
          buf_id = buf_id,
        }
      )
    end
  end
end

function M.setup(config)
  log.trace("setup(): Setting up...")

  if not config then
    config = {}
  end

  local default_config = {
    line_keys = "1234567890",
    select_menu_item_commands = {
      edit = {
        key = "<CR>",
        command = "edit"
      }
    },
    focus_alternate_buffer = false,
    short_file_names = false,
    short_term_names = false,
    loop_nav = true,
    highlight = "",
    win_extra_options = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  }

  local complete_config = merge_tables(default_config, config)

  BuffaloConfig = complete_config
  log.debug("setup(): Config", BuffaloConfig)
end

function M.get_config()
  log.trace("get_config()")
  return BuffaloConfig or {}
end

function M.buffers()
  local bufs = vim.api.nvim_list_bufs()
  bufs = vim.tbl_filter(function(buf)
    local is_loaded = vim.api.nvim_buf_is_loaded(buf)
    local is_listed = vim.fn.buflisted(buf) == 1

    if not (is_loaded and is_listed) then
      return false
    end

    return true
  end, bufs)
  local count = 0
  for _, buf in pairs(bufs) do
    count = count + 1
  end
  return count
end

-- Sets a default config with no values
M.setup()

M.initialize_marks()

return M

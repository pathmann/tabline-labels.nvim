local M = {}

---@class ConfigOptions
---@field render_full? fun(): string Full custom render function, if given all other options are ignored
---@field render? fun(RenderOptions): string Render a single tab
---@field remove_cwd boolean Remove the cwd part from the path
---@field should_shrink_section? fun(index: number, total_sections: number, renderopts: RenderOptions): boolean  controls which sections of the file path should be shortened in the tab label (if remove_cwd is true, the cwd is removed before this is called)
local defaults = {
  render_full = nil,
  render = nil,
  remove_cwd = true,
  should_shrink_section = function(index, total)
    return index ~= total
  end,
}

---@type ConfigOptions
M.options = defaults

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", defaults, opts or {})
end

return M

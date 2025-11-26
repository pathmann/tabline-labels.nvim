local M = {}

---@class ConfigOptions
---@field render_full? fun(): string Full custom render function, if given all other options are ignored
---@field render? fun(RenderOptions): string Render a single tab
---@field remove_cwd boolean Remove the cwd part from the path
---@field inactive_maxwidth number maximum width of inactive tabs, 0 to not shrink inactive tabs
---@field should_shrink_section? fun(index: number, total_sections: number, renderopts: RenderOptions): boolean  controls which sections of the file path should be shortened in the tab label (if remove_cwd is true, the cwd is removed before this is called)
---@field expand_policy string policy about which tabs are displayed when the tabline width exceeds the view size: "left-right" adds an element left to the current, then one to the right until the sizes adds up, "right-left" adds an element right to the current, then one to the left, until the sizes adds up, "left" adds all elements to the left first, "right" adds all elements to the right first 
local defaults = {
  render_full = nil,
  render = nil,
  remove_cwd = true,
  inactive_maxwidth = 0,
  should_shrink_section = function(index, total)
    return index ~= total
  end,
  expand_policy = "right",
}

---@type ConfigOptions
M.options = defaults

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", defaults, opts or {})
end

return M

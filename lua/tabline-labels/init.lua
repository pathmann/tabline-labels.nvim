local M = {}

local Config = require("tabline-labels.config")
local RendOpts = require("tabline-labels.renderoptions")

---Render a single tab label
---@param renderopts RenderOptions
M.render_single = function(renderopts)
  if Config.options.render then
    return Config.options.render(renderopts)
  end

  if renderopts.bufname == "" then
    return " [No Name] "
  end

  local fullpath = vim.fn.fnamemodify(renderopts.bufname, ":p")
  if Config.options.remove_cwd then
    local cwd = vim.fn.getcwd()

    if fullpath:sub(1, #cwd) == cwd then
      fullpath = fullpath:sub(cwd:len() + 1, fullpath:len())
    end
  end

  local parts = {}
  for part in string.gmatch(fullpath, "[^/]+") do
    table.insert(parts, part)
  end

  local ret = ""
  if renderopts.modified then
    ret = "+ "
  end

  for i = 1, #parts - 1, 1 do
    if Config.options.should_shrink_section(i, #parts -1, renderopts) then
      ret = ret .. parts[i]:sub(1, 1) .. "/"
    else
      ret = ret .. parts[i] .. "/"
    end
  end

  local file = parts[#parts] or ""

  if ret == "" and file == "" then
    return " [No Name] "
  end

  return " " .. ret .. file .. " "
end

M.render = function()
  if Config.options.render_full ~= nil then
    return Config.options.render_full()
  end

  local ret = ""
  local rendopts = RendOpts.make_render_options_table()
  local slabel = ""
  local maxwidth = Config.options.inactive_maxwidth

  for _, ropts in ipairs(rendopts) do
    slabel = M.render_single(ropts)

    if ropts.is_current then
      ret = ret .. "%#TabLineSel#"
    else
      ret = ret .. "%#TabLine#"

      if maxwidth ~= 0 then
        if vim.fn.strdisplaywidth(slabel) > maxwidth then
          slabel = slabel:sub(- maxwidth)
        end
      end
    end

    ret = ret .. slabel
  end

  ret = ret .. "%#TabLineFill#"

  return ret
end

M.setup = function(opts)
  Config.setup(opts)

  vim.o.tabline = "%!v:lua.require'tabline-labels'.render()"
end

return M

local M = {}

local Config = require("tabline-labels.config")
local RendOpts = require("tabline-labels.renderoptions")

---Calculate which tabs to display according to the maximum size
---@param renderopts RenderOptionsRendered[]
---@param curtabid number the current tab index
---@param maxwidth number the maximum width
---@param policy string policy used to expand @see Config.expand_policy
---@return number, number left and right index to include
local function calculate_display_tabs(renderopts, curtabid, maxwidth, policy)
  local used = renderopts[curtabid].width
  local left = curtabid
  local right = curtabid

  if policy == "right-left" then
    local expanded
    local w

    while true do
      expanded = false

      if right +1 <= #renderopts then
        w = renderopts[right +1].width

        if used + w < maxwidth then
          used = used + w
          right = right +1
          expanded = true
        end
      end

      if left -1 >= 1 then
        w = renderopts[left -1].width

        if used + w < maxwidth then
          used = used + w
          left = left -1
          expanded = true
        end
      end

      if not expanded then
        break
      end
    end
  elseif policy == "left" then
    local w

    for i = left -1, 1, -1 do
      w = renderopts[i].width

      if used + w < maxwidth then
        used = used + w
        left = i
      else
        break
      end
    end

    for i = right +1, #renderopts, 1 do
      w = renderopts[i].width

      if used + w < maxwidth then
        used = used + w
        right = i
      else
        break
      end
    end
  elseif policy == "right" then
    local w

    for i = right +1, #renderopts, 1 do
      w = renderopts[i].width

      if used + w < maxwidth then
        used = used + w
        right = i
      else
        break
      end
    end

    for i = left -1, 1, -1 do
      w = renderopts[i].width

      if used + w < maxwidth then
        used = used + w
        left = i
      else
        break
      end
    end
  else
    -- left-right
    local expanded
    local w

    while true do
      expanded = false

      if left -1 >= 1 then
        w = renderopts[left -1].width

        if used + w < maxwidth then
          used = used + w
          left = left -1
          expanded = true
        end
      end

      if right +1 <= #renderopts then
        w = renderopts[right +1].width

        if used + w < maxwidth then
          used = used + w
          right = right +1
          expanded = true
        end
      end

      if not expanded then
        break
      end
    end
  end

  return left, right
end

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
  ---@type RenderOptionsRendered[]
  local rendopts = RendOpts.make_render_options_table()
  local maxswidth = Config.options.inactive_maxwidth
  local curid
  local totalwidth = 0

  for i, ropts in ipairs(rendopts) do
    ropts.rendered = M.render_single(ropts)
    ropts.width = vim.fn.strdisplaywidth(ropts.rendered)

    if ropts.is_current then
      curid = i
    else
      if maxswidth ~= 0 then
        if ropts.width > maxswidth then
          ropts.rendered = ropts.rendered:sub(- maxswidth)
          ropts.width = vim.fn.strdisplaywidth(ropts.rendered)
        end
      end
    end

    totalwidth = totalwidth + ropts.width
  end

  local winwidth = vim.api.nvim_get_option_value("columns", {})

  local left = 1
  local right = vim.fn.tabpagenr('$')

  if totalwidth > winwidth then
    left, right = calculate_display_tabs(rendopts, curid, winwidth, Config.options.expand_policy)
  end

  for i = left, right do
    if rendopts[i].is_current then
      ret = ret .. "%#TabLineSel#"
    else
      ret = ret .. "%#TabLine#"
    end

    ret = ret .. rendopts[i].rendered
  end

  ret = ret .. "%#TabLineFill#"

  return ret
end

M.setup = function(opts)
  Config.setup(opts)

  vim.o.tabline = "%!v:lua.require'tabline-labels'.render()"
end

return M

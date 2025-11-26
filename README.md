# tabline-labels.nvim

> 🏷️ A simple, customizable plugin to control how tab labels are displayed in Neovim's native tabline.

---

## ✨ Features

- Customize how file paths appear in tab labels
- Optionally strip the current working directory from paths
- Shrink intermediate path segments (e.g. `~/P/s/t/s/s/main.cpp`)
- Fully extensible render logic via user-defined functions
- Lightweight and Lua-native — no dependencies

---

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
  "pathmann/tabline-labels.nvim",
  config = function()
    require("tabline-labels").setup()
  end
}
```

---

## ⚙️ Configuration

```lua
require("tabline-labels").setup({
  remove_cwd = true,  -- Remove the current working directory prefix from paths

  inactive_maxwidth = 0, -- Shrink labels of inactive tabs to this width, 0 to not shrink inactive tabs

  -- Customize which path sections get shrinked
  should_shrink_section = function(index, total)
    -- shrink all but the final path part 
    return index ~= total
  end,

  -- how to expand if the width exceeds the maximum size: 
  --    "left-right" adds an element left to the current, then one to the right until the sizes adds up
  --    "right-left" adds an element right to the current, then one to the left, until the sizes adds up
  --    "left" adds all elements to the left first
  --    "right" adds all elements to the right first 
  expand_policy = "right",

  -- Optional: override how each tab is rendered
  -- render = function(opts) return "..." end

  -- Optional: override the entire tabline rendering
  -- render_full = function() return "..." end
})
```

---

## 🔌 Advanced Usage

You can override the render function per-tab like this:

```lua
render = function(opts)
  return vim.fn.fnamemodify(opts.bufname, ":t") -- just the filename
end
```

Or override the full render logic:

```lua
render_full = function()
  return "%#TabLineSel# My Custom Tabline %#TabLineFill#"
end
```

---

## 💡 Why?

Neovim's default tabline shows the full path to each file, which can become cluttered. This plugin makes it easier to:

- See the file name and context (e.g. last directory)
- Avoid overly long or unreadable tab titles
- Customize your tabline without needing to replace it entirely with bufferline-like plugins

---

## ✅ Requirements

- Neovim 0.7+
- A tabline setup using native tabs (not buffers)

---

## 📄 License

MIT


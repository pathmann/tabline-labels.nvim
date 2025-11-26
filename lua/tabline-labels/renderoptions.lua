local M = {}

---@class RenderOptions
---@field winnr number The window number within the tab page (1-based, as per `tabpagewinnr()`)
---@field buflist table<number> A list of buffer numbers in the tab page (from `tabpagebuflist()`)
---@field bufnr number The active buffer number in the window (from `buflist[winnr]`)
---@field bufname string The full path of the buffer (from `bufname(bufnr)`)
---@field is_first boolean True if this is the first tab page (`tabpagenr() == 1`)
---@field is_last boolean True if this is the last tab page (`tabpagenr() == tabpagenr('$')`)
---@field is_current boolean True if this is the currently active tab page (`tabpagenr() == i`)
---@field modified boolean True if there are modified buffers on the tab page

---Returns a list of RenderOptions for all tabs
---@return RenderOptions[]
M.make_render_options_table = function()
  local ret = {}

  local lastpagenr = vim.fn.tabpagenr('$')
  for i = 1, lastpagenr do
    local opts = {}

    opts.winnr = vim.fn.tabpagewinnr(i)
    opts.buflist = vim.fn.tabpagebuflist(i)
    opts.bufnr = opts.buflist[opts.winnr]
    opts.bufname = vim.fn.bufname(opts.bufnr)
    opts.is_first = i == 1
    opts.is_last = i == lastpagenr
    opts.is_current = i == vim.fn.tabpagenr()

    opts.modified = false
    for _, b in ipairs(opts.buflist) do
      if vim.bo[b].modified then
        opts.modified = true
        break
      end
    end

    table.insert(ret, opts)
  end

  return ret
end

return M

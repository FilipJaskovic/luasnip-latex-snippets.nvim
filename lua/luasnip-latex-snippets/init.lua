local M = {}

local default_opts = {
  use_treesitter = false,
  allow_on_markdown = true,
}

local dir_sep = package.config:sub(1, 1)

local function dirname(path)
  if dir_sep == "\\" then
    return path:match("^(.*\\)") or ""
  end

  return path:match("^(.*" .. dir_sep .. ")") or ""
end

local script_dir = dirname(debug.getinfo(1, "S").source:sub(2))

local function resolve_chunk(file_name)
  local paths = {}

  if script_dir ~= "" then
    table.insert(paths, script_dir .. file_name)
  end

  if vim and vim.api and vim.api.nvim_get_runtime_file then
    local matches = vim.api.nvim_get_runtime_file(
      "lua"
        .. dir_sep
        .. "luasnip-latex-snippets"
        .. dir_sep
        .. file_name,
      false
    )
    vim.list_extend(paths, matches)
  end

  for _, path in ipairs(paths) do
    local chunk = loadfile(path)
    if chunk then
      return chunk
    end
  end

  return nil
end

local function load_snippet_module(module_name, file_name)
  local ok, mod = pcall(require, module_name)
  if ok then
    return mod
  end

  local chunk = resolve_chunk(file_name)
  if not chunk then
    return nil
  end

  local loaded = chunk()
  package.loaded[module_name] = loaded
  return loaded
end

M.setup = function(opts)
  opts = vim.tbl_deep_extend("force", default_opts, opts or {})

  local augroup = vim.api.nvim_create_augroup("luasnip-latex-snippets", {})
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    group = augroup,
    once = true,
    callback = function()
      local utils = require("luasnip-latex-snippets.util.utils")
      local is_math = utils.with_opts(utils.is_math, opts.use_treesitter)
      local not_math = utils.with_opts(utils.not_math, opts.use_treesitter)
      M.setup_tex(is_math, not_math)
    end,
  })

  if opts.allow_on_markdown then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "quarto" },
      group = augroup,
      once = true,
      callback = function()
        M.setup_markdown()
      end,
    })
  end
end

local _autosnippets = function(is_math, not_math)
  local autosnippets = {}

  for _, s in ipairs({
    "math_wRA_no_backslash",
    "math_rA_no_backslash",
    "math_wA_no_backslash",
    "math_iA_no_backslash",
    "math_iA",
    "math_wrA",
  }) do
    vim.list_extend(
      autosnippets,
      require(("luasnip-latex-snippets.%s"):format(s)).retrieve(is_math)
    )
  end

  for _, s in ipairs({
    "wA",
    "bwA",
  }) do
    vim.list_extend(
      autosnippets,
      require(("luasnip-latex-snippets.%s"):format(s)).retrieve(not_math)
    )
  end

  local custom = load_snippet_module(
    "luasnip-latex-snippets.luasnip-latex-snippets.custom",
    "luasnip-latex-snippets.custom.lua"
  )
  if custom then
    vim.list_extend(autosnippets, custom.retrieve(is_math))
  end

  return autosnippets
end

M.setup_tex = function(is_math, not_math)
  local ls = require("luasnip")
  ls.add_snippets("tex", {
    ls.parser.parse_snippet(
      { trig = "pac", name = "Package" },
      "\\usepackage[${1:options}]{${2:package}}$0"
    ),

    -- ls.parser.parse_snippet({ trig = "nn", name = "Tikz node" }, {
    --   "$0",
    --   -- "\\node[$5] (${1/[^0-9a-zA-Z]//g}${2}) ${3:at (${4:0,0}) }{$${1}$};",
    --   "\\node[$5] (${1}${2}) ${3:at (${4:0,0}) }{$${1}$};",
    -- }),
  })

  local math_i = require("luasnip-latex-snippets/math_i").retrieve(is_math)

  ls.add_snippets("tex", math_i, { default_priority = 0 })

  local mine = load_snippet_module(
    "luasnip-latex-snippets.luasnip-latex-snippets.mine",
    "luasnip-latex-snippets.mine.lua"
  )
  if mine then
    local snips = mine.retrieve(is_math)
    local regular, autos = {}, {}

    for _, snip in ipairs(snips) do
      if snip.snippetType == "autosnippet" then
        table.insert(autos, snip)
      else
        table.insert(regular, snip)
      end
    end

    if #regular > 0 then
      ls.add_snippets("tex", regular, { default_priority = 0 })
    end

    if #autos > 0 then
      ls.add_snippets("tex", autos, {
        type = "autosnippets",
        default_priority = 0,
      })
    end
  end

  ls.add_snippets("tex", _autosnippets(is_math, not_math), {
    type = "autosnippets",
    default_priority = 0,
  })
end

M.setup_markdown = function()
  local ls = require("luasnip")
  local utils = require("luasnip-latex-snippets.util.utils")
  local pipe = utils.pipe

  local is_math = utils.with_opts(utils.is_math, true)
  local not_math = utils.with_opts(utils.not_math, true)

  local markdown_filetypes = { "markdown", "quarto" }

  local math_i = require("luasnip-latex-snippets/math_i").retrieve(is_math)
  for _, ft in ipairs(markdown_filetypes) do
    ls.add_snippets(ft, math_i, { default_priority = 0 })
  end

  local autosnippets = _autosnippets(is_math, not_math)
  local trigger_of_snip = function(s)
    return s.trigger
  end

  local to_filter = {}
  for _, str in ipairs({
    "wA",
    "bwA",
  }) do
    local t = require(("luasnip-latex-snippets.%s"):format(str)).retrieve(not_math)
    vim.list_extend(to_filter, vim.tbl_map(trigger_of_snip, t))
  end

  local filtered = vim.tbl_filter(function(s)
    return not vim.tbl_contains(to_filter, s.trigger)
  end, autosnippets)

  local parse_snippet = ls.extend_decorator.apply(ls.parser.parse_snippet, {
    condition = pipe({ not_math }),
  }) --[[@as function]]

  -- tex delimiters
  local normal_wA_tex = {
    parse_snippet({ trig = "mk", name = "Math" }, "$${1:${TM_SELECTED_TEXT}}$"),
    parse_snippet({ trig = "dm", name = "Block Math" }, "$$\n\t${1:${TM_SELECTED_TEXT}}\n.$$"),
  }
  vim.list_extend(filtered, normal_wA_tex)

  for _, ft in ipairs(markdown_filetypes) do
    ls.add_snippets(ft, filtered, {
      type = "autosnippets",
      default_priority = 0,
    })
  end
end

return M

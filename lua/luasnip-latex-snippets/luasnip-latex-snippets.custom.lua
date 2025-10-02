-- lua/luasnip-latex-snippets.custom.lua
-- Put your future custom TeX snippets here.

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local sn = ls.snippet_node
local c = ls.choice_node
local d = ls.dynamic_node

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local postfix = require("luasnip.extras.postfix").postfix

local utils = require("luasnip-latex-snippets.util.utils")
local pipe = utils.pipe
local no_backslash = utils.no_backslash

local M = {}

function M.retrieve(is_math)
  -- Parser-style helper (literal triggers) that shows only in math and
  -- won’t trigger immediately after a backslash.
  local parse_snippet = ls.extend_decorator.apply(ls.parser.parse_snippet, {
    condition = pipe({ is_math, no_backslash }),
    show_condition = is_math,
  }) --[[@as function]]

  -- Convenience wrapper when you want a bit higher priority.
  local with_priority = ls.extend_decorator.apply(parse_snippet, {
    priority = 10,
  }) --[[@as function]]

  -- Boundary helper: not immediately after a letter or a backslash.
  local function no_letter_before(line_to_cursor, matched_trigger)
    local start = #line_to_cursor - #matched_trigger + 1
    local prev = line_to_cursor:sub(start - 1, start - 1)
    return not prev:match("[%a\\]")
  end

  -- Node-style helper (for regex, snippetType, etc.) with same conditions
  -- plus boundary check to avoid mid-word expansions.
  local S = ls.extend_decorator.apply(s, {
    condition = pipe({ is_math, no_backslash, no_letter_before }),
    show_condition = is_math,
  }) --[[@as function]]

  return {
    -- Example: ddt -> d/dt (autosnippet)
    with_priority(
      { trig = "ddt", name = "d/dt" },
      "\\frac{\\mathrm{d}}{\\mathrm{d}t} $0"
    ),

-- f(x) helper: only fx -> f(x)
S({
  trig = "([f])(x)",
  name = "f(x) from fx",
  trigEngine = "pattern",
  snippetType = "autosnippet",
  priority = 120,
}, f(function(_, snip)
  local fn, arg = snip.captures[1], snip.captures[2]
  return string.format("%s(%s) ", fn, arg)
end)),

-- Prime variant: only f'x -> f'(x)
S({
  trig = "([f])'(x)",
  name = "f'(x) from f'x",
  trigEngine = "pattern",
  snippetType = "autosnippet",
  priority = 120,
}, f(function(_, snip)
  local fn, arg = snip.captures[1], snip.captures[2]
  return string.format("%s'(%s) ", fn, arg)
end)),

    -- Examples you can copy/uncomment for later:
    -- S({ trig = "ddx", name = "d/dx", snippetType = "autosnippet" },
    --   fmt("\\frac{{\\mathrm{{d}}}}{{\\mathrm{{d}}}x} {}", { i(0) })
    -- ),
    -- S({ trig = "pdt", name = "∂/∂t", snippetType = "autosnippet" },
    --   fmt("\\frac{{\\partial}}{{\\partial t}} {}", { i(0) })
    -- ),
    -- S({ trig = "brn", name = "( )", snippetType = "autosnippet" },
    --   fmt("\\left( {} \\right) {}", { i(1), i(0) })
    -- ),
    -- postfix({ trig = "/", match_pattern = "[%w_%)%}%]]+$", condition = is_math }, {
    --   f(function(_, parent) return "\\frac{" .. parent.snippet.env.POSTFIX_MATCH .. "}{" end),
    --   i(1), t("}")
    -- }),
  }
end

return M

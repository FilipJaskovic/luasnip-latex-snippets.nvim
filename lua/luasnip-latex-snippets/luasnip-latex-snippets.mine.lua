-- lua/luasnip-latex-snippets.mine.lua
-- Your TeX snippets (main + add-ons), filtered per your preferences.
-- Excludes: sum, ==, <=, >=, lra, dm, dint, and auto-bracing (_/^/double-letter).
-- Keeps and bumps priority: abs, norm, case, **, geq/leq/neq.

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local utils = require("luasnip-latex-snippets.util.utils")
local pipe = utils.pipe
local no_backslash = utils.no_backslash
local conds = require("luasnip.extras.expand_conditions")

local M = {}

function M.retrieve(is_math)
  -- Conditions
  local function in_math()
    return is_math()
  end
  local function not_math()
    return not is_math()
  end
  local function line_begin()
    return conds.line_begin
  end

  -- Boundary: “not preceded by a backslash or letter”
  local function clean_boundary(_, snip)
    local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
    local pos = col - #snip.trigger
    local prev = (pos > 0) and line:sub(pos, pos) or ""
    return not prev:match("[%a\\]")
  end

  -- Helpers for tables/matrices
  local function tab_cols(n, with_rules)
    n = tonumber(n) or 1
    if with_rules then
      return ("c|"):rep(math.max(n - 1, 0)) .. "c"
    else
      return ("c"):rep(n)
    end
  end

  local function grid(rows, cols, start_index)
    rows, cols = tonumber(rows) or 1, tonumber(cols) or 1
    local k = start_index or 1
    local out = {}
    for r = 1, rows do
      local cells = {}
      for _c = 1, cols do
        table.insert(cells, string.format("${%d}", k))
        k = k + 1
      end
      table.insert(out, "            " .. table.concat(cells, " & ") .. " \\\\")
      if r == 1 and rows > 1 then
        table.insert(out, "            \\midrule")
      end
    end
    return table.concat(out, "\n")
  end

  local function sym_snip(trig, body, desc, opts)
    opts = opts or {}
    return s({
      trig = trig,
      wordTrig = opts.wordTrig ~= false,
      regTrig = opts.regTrig or false,
      snippetType = opts.auto and "autosnippet" or "snippet",
      priority = opts.priority,
    }, t(body), { condition = opts.cond })
  end

  local snips = {}

  -- ===================== Text-mode / general =====================
  table.insert(
    snips,
    s(
      { trig = "%--", name = "Divider", snippetType = "autosnippet" },
      fmt([[%────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
{}]], { i(0) }),
      { condition = not_math }
    )
  )

  table.insert(
    snips,
    s(
      { trig = "fig", name = "Figure", snippetType = "snippet" },
      fmt(
        [[
\begin{{figure}}[{opt}]
	\centering
	\includegraphics[width=0.8\textwidth]{{{path}}}
	\caption{{{cap}}}
	\label{{fig:{lbl}}}
\end{{figure}}
]],
        { opt = i(1, "H"), path = i(2), cap = i(3), lbl = i(4) }
      ),
      { condition = not_math }
    )
  )

  table.insert(
    snips,
    s(
      { trig = "atf", name = "\\autoref{}", snippetType = "snippet" },
      fmt("\\autoref{{{}}} {}", { i(1), i(0) }),
      { condition = not_math }
    )
  )

  table.insert(
    snips,
    s(
      { trig = "hpr", name = "\\hyperref[]{}", snippetType = "snippet" },
      fmt("\\hyperref[{}]{{{}}} {}", { i(1), i(2), i(0) }),
      { condition = not_math }
    )
  )

  table.insert(
    snips,
    s({ trig = "lbl", name = "\\label{}", wordTrig = false }, fmt("\\label{{{}}}", { i(1) }))
  )

  table.insert(
    snips,
    s(
      { trig = "rmk", name = "remark env", snippetType = "snippet" },
      fmt("\\begin{remark}\n\t{}\n\\end{remark}", { i(0) }),
      { condition = not_math }
    )
  )

  table.insert(
    snips,
    s(
      { trig = "dfn", name = "definition env", snippetType = "snippet" },
      fmt("\\begin{definition}\n\t{}\n\\end{definition}", { i(0) }),
      { condition = not_math }
    )
  )

  -- Optimization blocks (kept)
  table.insert(
    snips,
    s(
      { trig = "opmin", name = "opt min", snippetType = "snippet" },
      fmt(
        [[
\[
	\begin{{aligned}}
		\min~ & {}  \\
        	& {}  \\
        	& {}
	\end{{aligned}}
\]
{}
]],
        { i(1), i(2), i(3), i(0) }
      ),
      { condition = not_math }
    )
  )

  table.insert(
    snips,
    s(
      { trig = "opmax", name = "opt max", snippetType = "snippet" },
      fmt(
        [[
\[
	\begin{{aligned}}
		\max~ & {}  \\
        	& {}  \\
        	& {}
	\end{{aligned}}
\]
{}
]],
        { i(1), i(2), i(3), i(0) }
      ),
      { condition = not_math }
    )
  )

  table.insert(
    snips,
    s(
      { trig = "opPD", name = "opt PD", snippetType = "snippet" },
      t([[
\[
	\begin{alignedat}{5}
		\min~&c^{\top}x\qquad\qquad&&\max ~&&y^{\top}b\\
		&Ax = b 				&&		&&y^{\top}A\leq c^{\top}\\
		(\mathrm{P})\quad	&x\geq  0 	&&(\mathrm{D})\quad&&
	\end{alignedat}.
\]$0
]]),
      { condition = not_math }
    )
  )

  -- quick text abbrevs
  table.insert(snips, s({ trig = "wrt", name = "w.r.t.", snippetType = "snippet" }, t("w.r.t.\\ "), { condition = not_math }))
  table.insert(snips, s({ trig = "iid", name = "i.i.d.", snippetType = "snippet" }, t("i.i.d.\\ "), { condition = not_math }))
  table.insert(snips, s({ trig = "wp", name = "w.p.", snippetType = "snippet" }, t("w.p.\\ ")))

  -- ===================== Math delimiters / wrappers =====================
  table.insert(
    snips,
    s(
      { trig = "fm", name = "inline math", snippetType = "autosnippet" },
      fmt("\\({}\\){}", { i(1), i(0) })
    )
  )

  -- dm: excluded (you prefer new)

  table.insert(
    snips,
    s(
      { trig = "<>", name = "⟨⟩", snippetType = "autosnippet" },
      fmt("\\langle {} \\rangle {}", { i(1), i(0) }),
      { condition = in_math }
    )
  )
  table.insert(
    snips,
    s(
      { trig = "lr,", name = "⟨⟩ lr", snippetType = "autosnippet" },
      fmt("\\left\\langle {} \\right\\rangle {}", { i(1), i(0) }),
      { condition = in_math }
    )
  )
  table.insert(
    snips,
    s(
      { trig = "lrd", name = "()", snippetType = "autosnippet" },
      fmt("\\left( {} \\right) {}", { i(1), i(0) }),
      { condition = in_math }
    )
  )
  table.insert(
    snips,
    s(
      { trig = "{}", name = "{}", wordTrig = false, snippetType = "autosnippet" },
      fmt("\\{{ {} \\}} {}", { i(1), i(0) }),
      { condition = in_math }
    )
  )
  -- lra: excluded (prefer new)
  table.insert(
    snips,
    s(
      { trig = "lrq", name = "[]", snippetType = "autosnippet" },
      fmt("\\left[ {} \\right] {}", { i(1), i(0) }),
      { condition = in_math }
    )
  )

  table.insert(snips, s({ trig = "ceil", name = "ceil" }, fmt("\\lceil {} \\rceil {}", { i(1), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "Ceil", name = "Ceil" }, fmt("\\left\\lceil {} \\right\\rceil {}", { i(1), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "flr", name = "floor" }, fmt("\\lfloor {} \\rfloor{}", { i(1), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "Flr", name = "Floor" }, fmt("\\left\\lfloor {} \\right\\rfloor{}", { i(1), i(0) }), { condition = in_math }))

  -- abs (yours, high prio)
  table.insert(
    snips,
    s(
      { trig = "abs", name = "abs via \\vert", priority = 300 },
      fmt("\\vert {} \\vert {}", { i(1), i(0) }),
      { condition = in_math }
    )
  )
  table.insert(snips, s({ trig = "Abs", name = "Abs" }, fmt("\\left\\vert {} \\right\\vert {}", { i(1), i(0) }), { condition = in_math }))

  -- norm (yours, high prio)
  table.insert(
    snips,
    s(
      { trig = "norm", name = "norm via \\lVert", priority = 300 },
      fmt("\\lVert {} \\rVert {}", { i(1), i(0) }),
      { condition = in_math }
    )
  )
  table.insert(snips, s({ trig = "Norm", name = "Norm" }, fmt("\\left\\lVert {} \\right\\rVert {}", { i(1), i(0) }), { condition = in_math }))

  -- ===================== Math environments =====================
  table.insert(snips, s({ trig = "split", name = "split" }, fmt("\\begin{{split}}\n\t{}\n\\end{{split}}{}", { i(1), i(0) }), { condition = in_math }))

  -- case (yours)
  table.insert(
    snips,
    s(
      { trig = "case", name = "dcases scaffold", priority = 300 },
      fmt(
        [[
\begin{{dcases}}
	{}, &\text{{ if }} {} ;\\
	{}, &\text{{ if }} {} ;\\
	{}, &\text{{ otherwise}} .
\end{{dcases}}{}
]],
        { i(1), i(3), i(2), i(4), i(5), i(0) }
      ),
      { condition = in_math }
    )
  )

  -- ===================== Tables / Arrays / Matrices =====================
  table.insert(
    snips,
    s(
      {
        trig = [[table(%d) (%d)]],
        regTrig = true,
        snippetType = "autosnippet",
        name = "table rc",
      },
      fmt(
        [[
\begin{{table}}[H]
	\centering
	\begin{{tabular}}{{{spec}}}
	    \toprule
{rows}
    	\bottomrule
	\end{{tabular}}
	\caption{{{cap}}}
	\label{{tab:{lbl}}}
\end{{table}}
]],
        {
          spec = f(function(_, snip)
            return tab_cols(snip.captures[2], true)
          end),
          rows = f(function(_, snip)
            return grid(snip.captures[1], snip.captures[2], 4)
          end),
          cap = i(2, "caption"),
          lbl = i(3, "label"),
        }
      ),
      { condition = pipe({ line_begin(), not_math }) }
    )
  )

  table.insert(
    snips,
    s(
      { trig = [[ary(%d) (%d)]], regTrig = true, snippetType = "autosnippet", name = "array rc" },
      fmt(
        [[
\begin{{array}}{{{spec}}}
{rows}
\end{{array}}
]],
        {
          spec = f(function(_, snip)
            return tab_cols(snip.captures[2], false)
          end),
          rows = f(function(_, snip)
            return grid(snip.captures[1], snip.captures[2], 1)
          end),
        }
      ),
      { condition = in_math }
    )
  )

  table.insert(
    snips,
    s(
      { trig = [[(b|p)mat(%d) (%d)]], regTrig = true, snippetType = "autosnippet", name = "b/p matrix", priority = 2000 },
      fmt(
        [[
\begin{{{kind}matrix}}
{rows}
\end{{{kind}matrix}}{}
]],
        {
          kind = f(function(_, snip)
            return (snip.captures[1] == "b") and "b" or "p"
          end),
          rows = f(function(_, snip)
            return grid(snip.captures[2], snip.captures[3], 1)
          end),
          i(0),
        }
      ),
      { condition = in_math }
    )
  )

  -- ===================== Fractions & friends =====================
  table.insert(snips, s({ trig = "//", name = "\\frac", snippetType = "autosnippet" }, fmt("\\frac{{{}}}{{{}}}{}", { i(1), i(2), i(0) }), { condition = in_math }))

  -- ===================== Comparisons & logic =====================
  -- <=, >=: excluded (prefer new)
  table.insert(snips, sym_snip("!=", "\\neq ", "neq", { cond = in_math, auto = true }))
  table.insert(snips, s({ trig = "mdl", name = "\\models" }, t("\\models "), { condition = in_math }))
  table.insert(snips, s({ trig = "vdh", name = "\\vdash" }, t("\\vdash "), { condition = in_math }))
  table.insert(snips, s({ trig = "suc", name = "\\succ" }, t("\\succ "), { condition = in_math }))
  table.insert(snips, s({ trig = "seq", name = "\\succeq" }, t("\\succeq "), { condition = in_math }))
  table.insert(snips, s({ trig = "prec", name = "\\prec" }, t("\\prec "), { condition = in_math }))
  table.insert(snips, s({ trig = "peq", name = "\\preceq" }, t("\\preceq "), { condition = in_math }))
  -- ==: excluded (prefer new)
  table.insert(snips, s({ trig = "~~", name = "\\thickapprox" }, t("\\thickapprox "), { condition = in_math }))
  table.insert(snips, s({ trig = "~=", name = "\\cong" }, t("\\cong "), { condition = in_math }))
  table.insert(snips, s({ trig = "~-", name = "\\simeq" }, t("\\simeq "), { condition = in_math }))
  table.insert(snips, s({ trig = "cir", name = "\\circ" }, t("\\circ "), { condition = in_math }))
  table.insert(snips, s({ trig = "@>", name = "\\hookrightarrow" }, t("\\hookrightarrow "), { condition = in_math }))
  table.insert(snips, s({ trig = "||", name = "\\mid" }, t(" \\mid "), { condition = in_math }))
  table.insert(snips, s({ trig = "->", name = "\\to" }, t("\\to "), { condition = in_math }))
  table.insert(snips, s({ trig = "<->", name = "\\leftrightarrow" }, t("\\leftrightarrow "), { condition = in_math }))
  table.insert(snips, s({ trig = "!>", name = "\\mapsto" }, t("\\mapsto "), { condition = in_math }))
  table.insert(snips, s({ trig = "=>", name = "\\implies", snippetType = "autosnippet" }, t("\\implies "), { condition = in_math }))
  table.insert(snips, s({ trig = "=<", name = "\\impliedby", snippetType = "autosnippet" }, t("\\impliedby "), { condition = in_math }))
  table.insert(
    snips,
    s(
      { trig = "iff", name = "\\iff", snippetType = "autosnippet" },
      t("\\iff "),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )

  -- ===================== Sets / sums / limits / products =====================
  -- sum: excluded (prefer new)
  table.insert(snips, s({ trig = "Sum", name = "\\sum big" }, fmt("\\sum_{{{}={}}}^{{{}}} {}", { i(1, "i"), i(2, "1"), i(3, "\\infty"), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "scup", name = "\\sqcup" }, t("\\sqcup "), { condition = in_math }))
  table.insert(snips, s({ trig = "cup", name = "\\cup" }, t("\\cup "), { condition = in_math }))
  table.insert(snips, s({ trig = "Cup", name = "\\bigcup" }, fmt("\\bigcup_{{{}={}}}^{{{}}} {}", { i(1, "i"), i(2, "1"), i(3, "\\infty"), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "cap", name = "\\cap" }, t("\\cap "), { condition = in_math }))
  table.insert(snips, s({ trig = "Cap", name = "\\bigcap" }, fmt("\\bigcap_{{{}={}}}^{{{}}} {}", { i(1, "i"), i(2, "1"), i(3, "\\infty"), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "Conj", name = "\\bigwedge" }, fmt("\\bigwedge_{{{}={}}}^{{{}}} {}", { i(1, "i"), i(2, "1"), i(3, "\\infty"), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "Disj", name = "\\bigvee" }, fmt("\\bigvee_{{{}={}}}^{{{}}} {}", { i(1, "i"), i(2, "1"), i(3, "\\infty"), i(0) }), { condition = in_math }))

  table.insert(snips, s({ trig = "sub ", name = "\\subset", snippetType = "autosnippet" }, t("\\subset "), { condition = in_math }))
  table.insert(snips, s({ trig = "nsub", name = "\\nsubseteq" }, t("\\nsubseteq "), { condition = in_math }))
  table.insert(snips, s({ trig = "sube", name = "\\subseteq" }, t("\\subseteq "), { condition = in_math }))
  table.insert(snips, s({ trig = "subn", name = "\\subsetneq" }, t("\\subsetneq "), { condition = in_math }))
  table.insert(snips, s({ trig = "\\sups", name = "\\supset", regTrig = true }, t("\\supset "), { condition = in_math }))
  table.insert(snips, s({ trig = "nsup", name = "\\nsupseteq" }, t("\\nsupseteq "), { condition = in_math }))
  table.insert(snips, s({ trig = "\\supe", name = "\\supseteq", regTrig = true }, t("\\supseteq "), { condition = in_math }))
  table.insert(snips, s({ trig = "\\supn", name = "\\supsetneq", regTrig = true }, t("\\supsetneq "), { condition = in_math }))

  table.insert(snips, s({ trig = "nlim", name = "\\nolimits" }, t("\\nolimits"), { condition = in_math }))
  table.insert(
    snips,
    s(
      { trig = "lim", name = "\\lim" },
      fmt("\\lim_{{{} \\to {}}} {}", { i(1, "n"), i(2, "\\infty"), i(0) }),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )
  table.insert(snips, s({ trig = "lsup", name = "\\limsup" }, fmt("\\limsup_{{{} \\to {}}} {}", { i(1, "n"), i(2, "\\infty"), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "linf", name = "\\liminf" }, fmt("\\liminf_{{{} \\to {}}} {}", { i(1, "n"), i(2, "\\infty"), i(0) }), { condition = in_math }))

  table.insert(
    snips,
    s({ trig = "prd", name = "\\prod" }, t("\\prod "), {
      condition = function(...)
        return in_math() and clean_boundary(...)
      end,
    })
  )
  table.insert(snips, s({ trig = "Prd", name = "\\prod big" }, fmt("\\prod_{{{}={}}}^{{{}}} {}", { i(1, "n"), i(2, "1"), i(3, "\\infty"), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "coprd", name = "\\coprod" }, fmt("\\coprod_{{{}={}}}^{{{}}} {}", { i(1, "n"), i(2, "1"), i(3, "\\infty"), i(0) }), { condition = in_math }))

  -- ===================== Calculus, quantifiers, misc =====================
  table.insert(snips, s({ trig = "pt", name = "\\partial" }, t("\\partial "), { condition = in_math }))
  table.insert(snips, s({ trig = "pdif", name = "∂/∂" }, fmt("\\frac{{\\partial {}}}{{\\partial {}}} {}", { i(1, "V"), i(2, "x"), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "dif", name = "d/dx" }, fmt("\\frac{{\\mathrm{{d}}{}}}{{\\mathrm{{d}}{}}} {}", { i(1, "y"), i(2, "x"), i(0) }), { condition = in_math }))

  table.insert(
    snips,
    s(
      { trig = "sq", name = "\\sqrt{}", snippetType = "autosnippet" },
      fmt("\\sqrt{{{}}} {}", { i(1), i(0) }),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )

  table.insert(snips, s({ trig = "oo", name = "\\infty" }, t("\\infty "), { condition = in_math, priority = 200 }))
  table.insert(snips, s({ trig = "^oo", name = "^{\\infty}", regTrig = true }, t("^{\\infty} "), { condition = in_math }))
  table.insert(snips, s({ trig = "EE", name = "\\exists" }, t("\\exists "), { condition = in_math, priority = 200 }))
  table.insert(snips, s({ trig = "AA", name = "\\forall" }, t("\\forall "), { condition = in_math, priority = 200 }))
  table.insert(snips, s({ trig = "nin", name = "\\notin" }, t("\\notin "), { condition = in_math }))
  table.insert(snips, s({ trig = "inv", name = "^{-1}" }, t("^{-1} "), { condition = in_math }))
  table.insert(
    snips,
    s(
      { trig = "tp", name = "^{\\top}" },
      t("^{\\top} "),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )
  table.insert(snips, s({ trig = "prp", name = "^{\\perp}" }, t("^{\\perp} "), { condition = in_math }))
  table.insert(snips, s({ trig = "cp", name = "^{c}" }, t("^{c} "), { condition = in_math }))
  table.insert(snips, s({ trig = "qs", name = "^{2}" }, t("^{2} "), { condition = in_math }))
  table.insert(
    snips,
    s(
      { trig = "int", name = "\\int" },
      t("\\int "),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )
  -- dint: excluded (prefer new)

  table.insert(
    snips,
    s(
      { trig = "not", name = "\\lnot" },
      t("\\lnot "),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )
  table.insert(snips, s({ trig = "--", name = "\\setminus" }, t("\\setminus "), { condition = in_math }))
  table.insert(
    snips,
    s(
      { trig = "st", name = "^{\\star}" },
      t("^{\\star} "),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )
  -- ** (yours, ^{\ast}) wins
  table.insert(snips, s({ trig = "**", name = "^{\\ast}", priority = 300 }, t("^{\\ast} "), { condition = in_math }))
  table.insert(snips, s({ trig = "_*", name = "_{\\ast}" }, t("_{\\ast} "), { condition = in_math }))
  table.insert(snips, s({ trig = "^.", name = "\\dot{}", regTrig = true }, fmt("\\dot{{{}}} {}", { i(1), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "dot{.", name = "\\ddot{}", regTrig = true }, fmt("\\ddot{{{}}} {}", { i(1), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = ">>", name = "\\gg" }, t("\\gg "), { condition = in_math }))
  table.insert(snips, s({ trig = "<<", name = "\\ll" }, t("\\ll "), { condition = in_math }))

  table.insert(snips, s({ trig = "ind", name = "indicator" }, fmt("\\mathbbm{{1}}_{{{}}} {}", { i(1), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "spt", name = "supp", priority = 200 }, fmt("\\mathop{{\\mathrm{{supp}}}}({}) {}", { i(1), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "mean", name = "E[ ]" }, fmt("\\mathbb{{E}}_{{{}}}\\left[{} \\right] {}", { i(1), i(2), i(0) }), { condition = in_math }))
  table.insert(
    snips,
    s(
      { trig = "Var", name = "\\Var" },
      fmt("\\Var_{{{}}}\\left[{} \\right] {}", { i(1), i(2), i(0) }),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )
  table.insert(
    snips,
    s(
      { trig = "Cov", name = "\\Cov" },
      fmt("\\Cov_{{{}}}\\left[{} \\right] {}", { i(1), i(2), i(0) }),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )
  table.insert(
    snips,
    s(
      { trig = "Pr", name = "\\Pr" },
      fmt("\\Pr_{{{}}}({}) {}", { i(1), i(2), i(0) }),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )
  table.insert(
    snips,
    s(
      { trig = "sim", name = "\\sim", priority = 200 },
      t("\\sim "),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )
  table.insert(snips, s({ trig = "apx", name = "\\approx" }, t("\\approx "), { condition = in_math }))
  table.insert(
    snips,
    s({ trig = "bino", name = "\\binom" }, fmt("\\binom{{{}}}{{{}}} {}", { i(1), i(2), i(0) }), {
      condition = function(...)
        return in_math() and clean_boundary(...)
      end,
    })
  )
  table.insert(snips, s({ trig = "ems", name = "\\varnothing" }, t("\\varnothing "), { condition = in_math }))
  table.insert(snips, s({ trig = "emph", name = "\\emph{}", wordTrig = false }, fmt("\\emph{{{}}}{}", { i(1), i(0) })))
  table.insert(snips, s({ trig = "begg", name = "begin/end" }, fmt("\\begin{{{}}}\n\t{}\n\\end{{{}}}", { i(1, "eg"), i(0), rep(1) })))
  table.insert(snips, s({ trig = ":=", name = "\\coloneqq" }, t("\\coloneqq "), { condition = in_math }))
  table.insert(snips, s({ trig = "=:", name = "\\eqqcolon" }, t("\\eqqcolon "), { condition = in_math }))
  table.insert(snips, s({ trig = "::", name = "\\colon" }, t("\\colon "), { condition = in_math }))
  table.insert(snips, s({ trig = "idd", name = "\\identity" }, fmt("\\identity_{{{}}} {}", { i(1), i(0) }), { condition = in_math }))
  table.insert(
    snips,
    s(
      { trig = "quo", name = "\\quotient" },
      fmt("\\quotient{{{}}}{{{}}} {}", { i(1), i(2), i(0) }),
      { condition = function(...)
        return in_math() and clean_boundary(...)
      end }
    )
  )
  table.insert(snips, s({ trig = "|_", name = "\\at", regTrig = true }, fmt("\\at{{{}}}{{{}}}{{{}}} {}", { i(1), i(2), i(3), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "vph", name = "\\vphantom" }, fmt("\\vphantom{{{}}} {}", { i(1), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "hom", name = "\\Homomorphism" }, t("\\Homomorphism "), { condition = in_math }))
  table.insert(snips, s({ trig = "Obj", name = "\\Object" }, t("\\Object "), { condition = in_math }))
  table.insert(snips, s({ trig = "mor", name = "\\Morphism" }, t("\\Morphism "), { condition = in_math }))
  table.insert(snips, s({ trig = "__", name = "\\underset" }, fmt("\\underset{{{}}}{{{}}} {}", { i(1), i(2), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "^^", name = "\\overset" }, fmt("\\overset{{{}}}{{{}}} {}", { i(1), i(2), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "fk", name = "\\mathfrak" }, fmt("\\mathfrak{{{}}} {}", { i(1), i(0) }), { condition = in_math }))
  table.insert(snips, s({ trig = "tg", name = "\\triangle" }, t("\\triangle "), { condition = in_math }))
  table.insert(snips, s({ trig = "qed", name = "\\qed" }, t("\\qed"), { condition = not_math }))

  -- ===================== Typeface helpers =====================
  table.insert(snips, s({ trig = "rm", name = "\\mathrm" }, fmt("\\mathrm{{{}}} {}", { i(1), i(0) }), { condition = in_math }))

  table.insert(
    snips,
    s(
      { trig = "([a-zA-Z])(c|C)al", name = "\\mathcal{A}", regTrig = true },
      f(function(_, snip)
        return "\\mathcal{" .. snip.captures[1]:upper() .. "} "
      end),
      { condition = in_math }
    )
  )
  table.insert(
    snips,
    s(
      { trig = "([a-zA-Z])(s|S)cr", name = "\\mathscr{A}", regTrig = true },
      f(function(_, snip)
        return "\\mathscr{" .. snip.captures[1]:upper() .. "} "
      end),
      { condition = in_math }
    )
  )
  table.insert(
    snips,
    s(
      { trig = "\\([A-Za-z])", name = "\\mathbb{A}", regTrig = true, wordTrig = false },
      f(function(_, snip)
        return "\\mathbb{" .. snip.captures[1]:upper() .. "} "
      end),
      { condition = in_math }
    )
  )

  -- ===================== Greek & common operators (programmatic) =====================
  local function add_many(list)
    for _, x in ipairs(list) do
      table.insert(
        snips,
        s(
          {
            trig = x.trig,
            wordTrig = x.wordTrig ~= false,
            regTrig = x.regTrig or false,
            snippetType = x.auto and "autosnippet" or "snippet",
            priority = x.priority,
          },
          t(x.out),
          {
            condition = function(...)
              return in_math() and clean_boundary(...)
            end,
          }
        )
      )
    end
  end

  add_many({
    { trig = ";a", out = "\\alpha ", auto = true },
    { trig = "alpha", out = "\\alpha ", auto = true },
    { trig = ";b", out = "\\beta ", auto = true },
    { trig = "beta", out = "\\beta ", auto = true },
    { trig = ";g", out = "\\gamma ", auto = true },
    { trig = "gamma", out = "\\gamma ", auto = true },
    { trig = ";G", out = "\\Gamma ", auto = true },
    { trig = "Gamma", out = "\\Gamma ", auto = true },
    { trig = ";d", out = "\\delta ", auto = true },
    { trig = "delta", out = "\\delta ", auto = true },
    { trig = ";D", out = "\\Delta ", auto = true },
    { trig = "Delta", out = "\\Delta ", auto = true },
    { trig = ";e", out = "\\eta ", auto = true },
    { trig = "eta", out = "\\eta ", auto = true },
    { trig = ";z", out = "\\zeta ", auto = true },
    { trig = "zeta", out = "\\zeta ", auto = true },
    { trig = ";t", out = "\\theta ", auto = true },
    { trig = "theta", out = "\\theta ", auto = true },
    { trig = ";vt", out = "\\vartheta ", auto = true },
    { trig = "vartheta", out = "\\vartheta ", auto = true },
    { trig = ";T", out = "\\Theta ", auto = true },
    { trig = "Theta", out = "\\Theta ", auto = true },
    { trig = ";k", out = "\\kappa ", auto = true },
    { trig = "kappa", out = "\\kappa ", auto = true },
    { trig = ";l", out = "\\lambda ", auto = true },
    { trig = "lambda", out = "\\lambda ", auto = true },
    { trig = ";L", out = "\\Lambda ", auto = true },
    { trig = "Lambda", out = "\\Lambda ", auto = true },
    { trig = ";m", out = "\\mu ", auto = true },
    { trig = "mu", out = "\\mu ", auto = true },
    { trig = ";n", out = "\\nu ", auto = true },
    { trig = "nu", out = "\\nu ", auto = true },
    { trig = ";p", out = "\\pi ", auto = true },
    { trig = "pi", out = "\\pi ", auto = true },
    { trig = ";P", out = "\\Pi ", auto = true },
    { trig = "Pi", out = "\\Pi ", auto = true },
    { trig = ";r", out = "\\rho ", auto = true },
    { trig = "rho", out = "\\rho ", auto = true },
    { trig = ";s", out = "\\sigma ", auto = true },
    { trig = "sigma", out = "\\sigma ", auto = true },
    { trig = ";S", out = "\\Sigma ", auto = true },
    { trig = "Sigma", out = "\\Sigma ", auto = true },
    { trig = ";u", out = "\\upsilon ", auto = true },
    { trig = "Upsilon", out = "\\Upsilon ", auto = true },
    { trig = ";U", out = "\\Upsilon ", auto = true },
    { trig = ";vp", out = "\\varphi ", auto = true },
    { trig = "varphi", out = "\\varphi ", auto = true },
    { trig = ";c", out = "\\chi ", auto = true },
    { trig = "chi", out = "\\chi ", auto = true },
    { trig = ";;;p", out = "\\psi ", auto = true },
    { trig = "Psi", out = "\\Psi ", auto = true },
    { trig = ";o", out = "\\omega ", auto = true },
    { trig = "omega", out = "\\omega ", auto = true },
    { trig = ";O", out = "\\Omega ", auto = true },
    { trig = "Omega", out = "\\Omega ", auto = true },
    { trig = "ell", out = "\\ell ", auto = true },
    { trig = "eps", out = "\\epsilon ", auto = true },
    { trig = "veps", out = "\\varepsilon ", auto = true },
    { trig = "; ;n", out = "\\nabla ", auto = true, priority = 200 },
  })

  for _, name in
    ipairs({
      "sin",
      "cos",
      "tan",
      "cot",
      "csc",
      "sec",
      "ln",
      "log",
      "exp",
      "perp",
      "inf",
      "sup",
      "Tr",
      "diag",
      "rank",
      "det",
      "dim",
      "ker",
      "Im",
      "Re",
      "dom",
      "arg",
      "min",
      "max",
      "sgn",
      "OPT",
      "land",
      "lor",
    })
  do
    table.insert(
      snips,
      s({ trig = name, snippetType = "autosnippet" }, t("\\" .. name .. " "), {
        condition = function(...)
          return in_math() and clean_boundary(...)
        end,
      })
    )
  end

  table.insert(
    snips,
    s(
      { trig = "1..n", name = "x_1...x_n", snippetType = "autosnippet" },
      fmt("{}_1, \\dots, {}_n {}", { i(1, "x"), rep(1), i(0) }),
      { condition = in_math }
    )
  )

  -- ===================== Add-ons kept (UltiSnips parity) =====================

  -- 4) Postfix wrappers: \overline, \widetilde, \hat, \mathbf, \bm
  local function wrap(cmd)
    return function(_, snip)
      return "\\" .. cmd .. "{" .. snip.captures[1] .. "} "
    end
  end

  -- Safer explicit captures per wrapper (vim regex)
  table.insert(
    snips,
    s(
      { trig = [[(\\?\k+|\\[^\s]+})\(b\|B\)\(ar\)]], regTrig = true, trigEngine = "vim", name = "overline", snippetType = "autosnippet" },
      f(wrap("overline")),
      { condition = in_math }
    )
  )
  table.insert(
    snips,
    s(
      { trig = [[(\\?\k+|\\[^\s]+})\(t\|T\)\(d\)]], regTrig = true, trigEngine = "vim", name = "widetilde", snippetType = "autosnippet" },
      f(wrap("widetilde")),
      { condition = in_math }
    )
  )
  table.insert(
    snips,
    s(
      { trig = [[(\\?\k+|\\[^\s]+})\(h\|H\)\(t\)]], regTrig = true, trigEngine = "vim", name = "hat", snippetType = "autosnippet" },
      f(wrap("hat")),
      { condition = in_math }
    )
  )
  table.insert(
    snips,
    s(
      { trig = [[(\\?\k+|\\[^\s]+})\(b\|B\)\(f\)]], regTrig = true, trigEngine = "vim", name = "mathbf", snippetType = "autosnippet" },
      f(wrap("mathbf")),
      { condition = in_math }
    )
  )
  table.insert(
    snips,
    s(
      { trig = [[(\\?\k+|\\[^\s]+})\(b\|B\)\(m\)]], regTrig = true, trigEngine = "vim", name = "bm", snippetType = "autosnippet" },
      f(wrap("bm")),
      { condition = in_math }
    )
  )

  -- 5) Vector postfix: token followed by ",." or ".,"
  table.insert(
    snips,
    s(
      { trig = [[(\\?\k+|\\[^\s]+})\(,\.\|\.,\)]], regTrig = true, trigEngine = "vim", name = "\\vec{}", snippetType = "autosnippet" },
      f(wrap("vec")),
      { condition = in_math }
    )
  )

  -- 6) \A → \mathbb{A}
  table.insert(
    snips,
    s(
      { trig = [[\\\([A-Za-z]\)]], regTrig = true, trigEngine = "vim", name = "\\mathbb{A}", snippetType = "autosnippet" },
      f(function(_, snip)
        return "\\mathbb{" .. snip.captures[1]:upper() .. "} "
      end),
      { condition = in_math }
    )
  )

  -- 7) \bXYn → X_{Y+n}
  table.insert(
    snips,
    s(
      { trig = [[\<\([A-Za-z]\)\([A-Za-z]\)\(\d\)]], regTrig = true, trigEngine = "vim", name = "X_{Y+n}", snippetType = "autosnippet" },
      f(function(_, snip)
        local a, b, n = snip.captures[1], snip.captures[2], snip.captures[3]
        return a .. "_{ " .. b .. "+" .. n .. " }"
      end),
      { condition = in_math }
    )
  )

  -- 8) Smart fractions: postfix token/
  table.insert(
    snips,
    ls.extras and require("luasnip.extras.postfix").postfix({ trig = "/", match_pattern = "[%w_%)%}%]]+$", condition = in_math }, {
      f(function(_, parent)
        local sfx = parent.snippet.env.POSTFIX_MATCH
        if sfx:sub(-1) == ")" then
          local depth = 0
          for idx = #sfx, 1, -1 do
            local ch = sfx:sub(idx, idx)
            if ch == ")" then
              depth = depth + 1
            elseif ch == "(" then
              depth = depth - 1
              if depth == 0 then
                sfx = sfx:sub(idx + 1, #sfx - 1)
                break
              end
            end
          end
        end
        return "\\frac{" .. sfx .. "}{"
      end),
      i(1),
      t("}"),
    })
      or s({ trig = "___never__", hidden = true }, t(""))
  )

  -- 9) Words geq/leq/neq (yours; boundary-checked; autosnippets)
  local function wordy(tr, out)
    table.insert(
      snips,
      s(
        { trig = tr, name = tr, snippetType = "autosnippet", priority = 300 },
        t(out .. " "),
        {
          condition = function(...)
            return in_math() and clean_boundary(...)
          end,
        }
      )
    )
  end
  wordy("geq", "\\geq")
  wordy("leq", "\\leq")
  wordy("neq", "\\neq")

  return snips
end

return M

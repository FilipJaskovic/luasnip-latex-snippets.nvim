Here’s a complete quick-reference for all snippets: the “new” pack plus your overlay (mine) and your custom file. I grouped them by category. Columns:
- Trigger: what you type (regex/patterns shown where relevant)
- Expands to: final LaTeX inserted
- Mode: Math / Text / Both
- Auto?: Yes for autosnippet (expands as you type), No for manual (expand key)
- Notes: boundary checks, line-start, packages, custom macros, etc.

Legend for conditions
- Boundary: won’t fire if immediately after a letter or backslash
- NoBackslash: won’t fire if immediately after a backslash
- LineStart: must be at line start

Text-mode and general
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| pac | \usepackage[options]{package} | Text | No | New pack |
| ali | \begin{align*} … .\end{align*} | Text | No | LineStart |
| beg | \begin{env} … \end{env} | Text | No | LineStart |
| bigfun | Align* function mapping skeleton | Text | No | LineStart |
| fig | figure env with includegraphics/caption/label | Text | No | Overlay |
| atf | \autoref{…} … | Text | No | Overlay |
| hpr | \hyperref[ID]{text} … | Text | No | Overlay |
| lbl | \label{…} | Both | No | wordTrig=false |
| rmk | \begin{remark} … \end{remark} | Text | No | Overlay |
| dfn | \begin{definition} … \end{definition} | Text | No | Overlay |
| wrt | w.r.t.\ | Text | No | Overlay |
| iid | i.i.d.\ | Text | No | Overlay |
| wp | w.p.\ | Both | No | Overlay |
| %-- | Unicode divider line | Text | Yes | Overlay, visual separator |
| letw | “Let \Omega \subset \C be open.” | Text | No | New pack |
| qed | \qed | Text | No | Overlay |

Math delimiters and wrappers
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| mk | \( … \) | Text | Yes | New pack (TeX); also available in markdown setup |
| dm | \[ … \] | Text | Yes | New pack (TeX/markdown variants) |
| fm | \( … \) | Both | Yes | Overlay |
| lrd | \left( … \right) | Math | Yes | Overlay |
| lrq | \left[ … \right] | Math | Yes | Overlay |
| {} | \{ … \} | Math | Yes | Overlay; wordTrig=false |
| <> | \langle … \rangle | Math | Yes | Overlay |
| lr, | \left\langle … \right\rangle | Math | Yes | Overlay |
| lr | \left( … \right) | Math | No | New pack |
| lr( | \left( … \right) | Math | No | New pack |
| lr[ | \left[ … \right] | Math | No | New pack |
| lr{ | \left\{ … \right\} | Math | No | New pack |
| lr| | \left| … \right| | Math | No | New pack |
| lrb | \left\{ … \right\} | Math | No | New pack |
| lra | \left< … \right> | Math | No | New pack (you chose this “new” lra) |
| ceil | \lceil … \rceil | Math | No | Overlay |
| Ceil | \left\lceil … \right\rceil | Math | No | Overlay |
| flr | \lfloor … \rfloor | Math | No | Overlay |
| Flr | \left\lfloor … \right\rfloor | Math | No | Overlay |
| abs | \vert … \vert | Math | No | Overlay wins (priority), instead of new’s \abs{…} |
| Abs | \left\vert … \right\vert | Math | No | Overlay |
| norm | \lVert … \rVert | Math | No | Overlay wins (priority) |
| Norm | \left\lVert … \right\rVert | Math | No | Overlay |
| rm | \mathrm{…} | Math | No | Overlay |
| Acal/acal | \mathcal{A} | Math | No | Overlay (pattern) |
| Ascr/ascr | \mathscr{A} | Math | No | Overlay (pattern) |
| \a (any letter) | \mathbb{A} | Math | Yes | Both sets provide; same result |

Math environments
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| split | \begin{split} … \end{split} | Math | No | Overlay |
| case | dcases scaffold with “if/otherwise” | Math | No | Overlay wins (priority) |
| opmin | aligned min problem skeleton | Text | No | Overlay |
| opmax | aligned max problem skeleton | Text | No | Overlay |
| opPD | primal/dual LP alignedat skeleton | Text | No | Overlay |

Tables / arrays / matrices
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| table(r) (c) | full table+tabular with booktabs | Text | Yes | LineStart; Overlay |
| ary(r) (c) | \begin{array}{…} … \end{array} | Math | Yes | Overlay |
| (b|p)mat(r) (c) | bmatrix/pmatrix grid r×c | Math | Yes | Overlay |
| pmat | \begin{pmatrix} … \end{pmatrix} | Math | No | New pack |
| bmat | \begin{bmatrix} … \end{bmatrix} | Math | No | New pack |
| cvec | column vector pmatrix skeleton | Math | No | New pack |

Fractions and auto-bracing
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| // | \frac{…}{…} | Math | Yes | Overlay |
| expr/ | \frac{expr}{…} | Math | Yes | New pack and overlay both provide; supports peeling (…) |
| (pattern) .*)/ | \frac{…}{…} with (…) peeling | Math | Yes | New pack (pattern fraction) |
| (pattern) (\w)/ etc. | \frac{token}{…} | Math | Yes | New pack more cases |
| ([a])(\d) | a_{d} | Math | Yes | New pack: auto-subscript letter+digit |
| ([a])_(\d\d) | a_{dd} | Math | Yes | New pack: a_11 → a_{11} |
| Note | You chose the new auto-bracing; old a_12/a^12/xx rules are excluded from overlay | | | |

Comparisons and logic
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| <= | \le | Math | No | New pack wins (you chose “new”) |
| >= | \ge | Math | No | New pack wins |
| geq | \geq | Math | Yes | Overlay word form; Boundary |
| leq | \leq | Math | Yes | Overlay word form; Boundary |
| neq | \neq | Math | Yes | Overlay word form; Boundary |
| != | \neq | Math | Yes/No | Both sets define; same result |
| == | &= … \\ (align step) | Math | No | New pack wins |
| -> | \to | Math | No | Both sets; same |
| <-> | \leftrightarrow | Math | No | Both sets; same |
| => | \implies | Math | Yes | Overlay |
| =< | \impliedby | Math | Yes | Overlay |
| iff | \iff | Math | Yes | Boundary |
| ~~ | \thickapprox | Math | No | Overlay |
| ~= | \cong | Math | No | Overlay |
| ~- | \simeq | Math | No | Overlay |
| cir | \circ | Math | No | Overlay |
| @> | \hookrightarrow | Math | No | Overlay |
| || | \mid | Math | No | Both; overlay includes leading space |

Sets, sums, limits, products
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| sum | \sum_{n=1}^{\infty} a_n z^n | Math | No | New pack wins (series scaffold) |
| Sum | \sum_{i=1}^{\infty} … | Math | No | Overlay |
| scup | \sqcup | Math | No | Overlay |
| cup | \cup | Math | No | Both |
| Cup | \bigcup_{…}^{…} … | Math | No | Overlay |
| cap | \cap | Math | No | Both |
| Cap | \bigcap_{…}^{…} … | Math | No | Overlay |
| Conj | \bigwedge_{…}^{…} … | Math | No | Overlay |
| Disj | \bigvee_{…}^{…} … | Math | No | Overlay |
| sub␠ | \subset | Math | Yes | Overlay (trigger includes space) |
| nsub | \nsubseteq | Math | No | Overlay |
| sube | \subseteq | Math | No | Overlay |
| subn | \subsetneq | Math | No | Overlay |
| \sups | \supset | Math | No | Overlay (regTrig) |
| nsup | \nsupseteq | Math | No | Overlay |
| \supe | \supseteq | Math | No | Overlay (regTrig) |
| \supn | \supsetneq | Math | No | Overlay (regTrig) |
| nlim | \nolimits | Math | No | Overlay |
| lim | \lim_{n \to \infty} … | Math | No | Both; overlay boundary-checked |
| limsup | \limsup_{n \to \infty} … | Math | No | New pack |
| lsup | \limsup_{n \to \infty} … | Math | No | Overlay |
| linf | \liminf_{n \to \infty} … | Math | No | Overlay |
| prod | \prod_{n=1}^{\infty} … | Math | No | New pack |
| prd | \prod | Math | No | Overlay (boundary) |
| Prd | \prod_{n=1}^{\infty} … | Math | No | Overlay |
| coprd | \coprod_{n=1}^{\infty} … | Math | No | Overlay |
| sequence | (a_n)_{n=m}^{\infty} | Math | No | New pack |

Calculus, operators, and common math
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| pt | \partial | Math | No | Overlay |
| pdif | \frac{\partial V}{\partial x} … | Math | No | Overlay |
| part | \frac{\partial …}{\partial …} | Math | No | New pack |
| dif | \frac{\mathrm{d}y}{\mathrm{d}x} … | Math | No | Overlay |
| ddx | \frac{\mathrm{d/…}}{\mathrm{d…}} … | Math | No | New pack |
| sq | \sqrt{…} … | Math | Yes | Both; overlay boundary-checked |
| oo | \infty | Math | No | Overlay |
| ooo | \infty | Math | No | New pack |
| ^oo | ^{\infty} | Math | No | Overlay (regTrig) |
| EE | \exists | Math | No | Both |
| AA | \forall | Math | No | Both |
| nin | \notin | Math | No | Overlay |
| notin | \not\in | Math | No | New pack |
| inv | ^{-1} | Math | No | Overlay |
| invs | ^{-1} | Math | No | New pack (alt trigger) |
| tp | ^{\top} | Math | No | Overlay; Boundary |
| prp | ^{\perp} | Math | No | Overlay |
| cp | ^{c} | Math | No | Overlay |
| qs | ^{2} | Math | No | Overlay |
| int | \int | Math | No | Overlay; Boundary |
| dint | \int_{-∞}^{∞} … | Math | No | New pack wins |
| not | \lnot | Math | No | Overlay; Boundary |
| -- | \setminus | Math | No | Overlay |
| \\\\\ | \setminus | Math | No | New pack (literal backslashes) |
| st | ^{\star} | Math | No | Overlay; Boundary |
| ** | ^{\ast} | Math | No | Overlay wins (priority) |
| _* | _{\ast} | Math | No | Overlay |
| ^. | \dot{…} … | Math | No | Overlay (regTrig) |
| dot{. | \ddot{…} … | Math | No | Overlay (regTrig) |
| >> | \gg | Math | No | Both |
| << | \ll | Math | No | Both |
| ind | \mathbbm{1}_{…} … | Math | No | Overlay (needs bbm) |
| spt | \mathop{\mathrm{supp}}(… ) … | Math | No | Overlay |
| mean | \mathbb{E}_{…}[…] … | Math | No | Overlay |
| Var | \Var_{…}[…] … | Math | No | Overlay (custom macro) |
| Cov | \Cov_{…}[…] … | Math | No | Overlay (custom macro) |
| Pr | \Pr_{…}(…) … | Math | No | Overlay |
| sim | \sim | Math | No | Overlay |
| apx | \approx | Math | No | Overlay |
| bino | \binom{…}{…} … | Math | No | Overlay |
| ems | \varnothing | Math | No | Overlay |
| :: | \colon | Math | No | Overlay |
| := | \coloneqq | Math | No | Overlay |
| =: | \eqqcolon | Math | No | Overlay |
| idd | \identity_{…} … | Math | No | Overlay (custom macro) |
| quo | \quotient{…}{…} … | Math | No | Overlay (custom macro) |
| |_ (regex) | \at{…}{…}{…} … | Math | No | Overlay (custom macro) |
| vph | \vphantom{…} … | Math | No | Overlay |
| tg | \triangle | Math | No | Overlay |
| <> (in new pack) | \diamond | Math | No | New pack (NB: different from overlay’s angle trigger) |
| norm (new) | \| … \| | Math | No | New pack still exists; overlay version wins |
| stt | _\text{…} … | Math | No | New pack |
| tt | \text{…} … | Math | No | New pack |
| xx | \times | Math | No | New pack |

Greek letters and math operators (names without backslash)
- From both sets (autosnippets; NoBackslash/Boundary): typing the bare word inserts the backslashed macro.
- Triggers
  - Greek (lowercase, plus uppercase where defined by LaTeX): alpha, beta, gamma/Gamma, delta/Delta, theta/Theta, vartheta, lambda/Lambda, mu, nu, pi/Pi, rho, sigma/Sigma, upsilon/Upsilon, varphi, chi, psi/Psi, omega/Omega, eta, zeta, kappa, epsilon, varepsilon, ell
    - Note: Some uppercase like Alpha, Beta, Epsilon, … do not exist in LaTeX; avoid those.
  - Functions/operators: sin, cos, tan, cot, csc, sec, ln, log, exp, inf, sup, Tr, diag, rank, det, dim, ker, Im, Re, dom, arg, min, max, sgn, OPT, land, lor, perp, int, star
  - Spacing: quad/qquad (pattern “q?quad”)
- Also available: semicolon aliases from your overlay: ;a, ;b, ;g, ;G, … ;vt, ;vp, ;o, ;O, etc. (all autosnippets)

Postfix wrappers (attach a short marker after a token)
- Overlay (tokens can be words/macros ending with }):
  - tokenbar → \overline{token}
  - tokentd → \widetilde{token}
  - tokenht → \hat{token}
  - tokenbf → \mathbf{token}
  - tokenbm → \bm{token} (needs bm)
  - token,. or token., → \vec{token}
  - \a (any letter) → \mathbb{A}
  - \bXYn → X_{Y+n} (single letters, n digit)
- New pack (no-backslash word wrappers):
  - xbar → \overline{x}
  - xund → \underline{x}
  - xdot → \dot{x}
  - xhat → \hat{x}
  - xora → \overrightarrow{x}
  - xola → \overleftarrow{x}

Quick sequences and sets
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| 1..n | x_1, \dots, x_n | Math | Yes | Overlay; x editable |
| rij | (x_n)_{n \in \N} | Math | No | New pack |
| nnn | \bigcap_{i \in I} … | Math | No | New pack |
| uuu | \bigcup_{i \in I} … | Math | No | New pack |
| UU | \cup | Math | No | New pack |
| Nn | \cap | Math | No | New pack |

Blackboard, calligraphic, etc.
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| RR/QQ/ZZ/NN/DD/HH | \mathbb{R}/… | Math | No | New pack |
| lll | \ell | Math | No | New pack |
| R0+ | \mathbb{R}_0^+ | Math | No | New pack |
| mcal | \mathcal{…} | Math | No | New pack |

Arrows and maps
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| !> | \mapsto | Math | No | Overlay |
| --> | \longrightarrow | Math | No | New pack |
| ora/ola wrappers | over/left arrows | Math | No | New pack |
| fun | f : X \R \to \R : … | Math | No | New pack |

Misc
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| floor | \left\lfloor … \right\rfloor | Math | No | New pack |
| ceil | \left\lceil … \right\rceil | Math | No | Both |
| <> (diamond) | \diamond | Math | No | New pack |
| <! | \triangleleft | Math | No | New pack |
| SI | \SI{…}{…} | Math | No | New pack (siunitx) |
| compl | ^{c} | Math | No | New pack |
| conj | \overline{…} | Math | No | New pack |

Your custom file
| Trigger | Expands to | Mode | Auto? | Notes |
| --- | --- | --- | --- | --- |
| ddt | \frac{\mathrm{d}}{\mathrm{d}t} | Math | No | Custom example; NoBackslash |

Notes
- Custom macros used by your overlay: \Var, \Cov, \identity, \quotient, \at, \Homomorphism, \Object, \Morphism — make sure these are defined in your preamble.
- Packages: bm for \bm, amsfonts/amssymb for \mathbb, bbm (or similar) for \mathbbm{1}, siunitx for \SI.

local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

local fmt = require("luasnip.extras.fmt").fmt

local snippets, autosnippets = {}, {}

table.insert(autosnippets, s("begin", fmt([[
\begin{{{}}} 
  {}
\end{{{}}}
]],
  { i(1, ""), i(3, ""), i(2, "") }
)))

table.insert(autosnippets, s("bcode", fmt([[
\begin{{lstlisting}}[language={}]
{}
\end{{lstlisting}}
]],{
  i(1, ""), i(2, "")
})))

local replace_insert_0 = {
  {":al", "\\alpha"},
  {":Al", "\\Alpha"},
  {":be", "\\beta"},
  {":Be", "\\Beta"},
  {":ga", "\\gama"},
  {":Ga", "\\Gama"},
  {":mu", "\\mu"},
  {":Mu", "\\Mu"},
  {":mk", "$$ $$"},
  {":  ", "\\\\"}
}

local replace_insert_1 = {
  {":c", "\\section{{{}}}"},
  {":sc", "\\subsection{{{}}}"},
  {":ssc", "\\subsubsection{{{}}}"}
}

local replace_insert_2 = {
  {"frac", "\\frac{{{}}}{{{}}}"}
}

for _, item in ipairs(replace_insert_0) do
  table.insert(autosnippets, s(item[1], t(item[2])))
end

for _, item in ipairs(replace_insert_1) do
  table.insert(autosnippets, s(item[1], fmt(item[2], {i(1, "")} )))
end

for _, item in ipairs(replace_insert_2) do
  table.insert(autosnippets, s(item[1], fmt(item[2], {i(1, ""), i(2, "")} )))
end

return snippets, autosnippets

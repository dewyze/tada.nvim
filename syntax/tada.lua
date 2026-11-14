if vim.b.current_syntax then
  return
end

-- A topic indented past the third level: topics nest three deep
vim.cmd([[syntax match tadaTooDeep /^\s\{6,}-\s\+\%(\[.\{-}\]\s\)\@!.\+:$/]])
vim.cmd([[highlight default link tadaTooDeep Error]])

vim.b.current_syntax = "tada"

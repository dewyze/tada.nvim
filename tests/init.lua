-- Runs every spec under tests/, each in its own headless Neovim

require("plenary.test_harness").test_directory("tests", {
  minimal_init = "tests/minimal_init.lua",
  timeout = 5000,
})

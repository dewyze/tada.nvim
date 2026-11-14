# Contributing

I am open to feature adds and pull requests and issues. Feel free to open them and I will take a look!

I can't promise all features will be added, but feel free to open an issue to
  discuss before starting.

## Testing

Tests are [plenary](https://github.com/nvim-lua/plenary.nvim) specs that drive
a real buffer in headless Neovim. Run them with:

```
bin/test
```

The first run uses the plenary that lazy.nvim has installed, or clones one
into `.deps/`.

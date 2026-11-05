return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      pipe = {
        -- Render table borders on virtual text lines instead of trying to place
        -- them in empty buffer lines above/below the table (default). When a
        -- table is the last block in a note there is no empty line below it, so
        -- the bottom border used to overflow the rendered footnote. Virtual
        -- borders need no trailing blank lines, so the table (and footnote)
        -- render cleanly without padding the real file.
        border_virtual = true,
      },
    },
  },
}

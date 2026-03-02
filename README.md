# ZxLean

Install the [Lean 4 VS Code extension](https://marketplace.visualstudio.com/items?itemName=leanprover.lean4)

## ZX viewing widget

The InfoView widget lives in `zx_view_widget/src/`

It is a React component, written in Typescript, bundled with rollup

`lake` handles `npm install` and the JS bundle automatically

## PyZX dameon

The widget sends diagram data to a local Flask server for processing

Start it in a terminal

```sh
cd pyzx_daemon
uv sync
uv run python app.py
```

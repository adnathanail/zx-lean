# ZxLean

## Widget development

The InfoView widget lives in `widget/src/`. After editing the TypeScript source:

```sh
cd widget
npm install   # first time only
npm run build # compiles TS, bundles JS, and invalidates Lean cache
cd ..
lake build    # picks up the new widget JS
```
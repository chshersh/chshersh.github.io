# chshersh.com

My website:

- [chshersh.com](https://chshersh.com)

## Dev

Common instructions to develop this website:

- `./rerender.sh`: generate all HTML files from Markdown
- `elm-watch make hot`: build website with hot reloading
- `elm-watch hot "dev"`: run website with hot reloading
- `elm-watch make --optimize`: build website for production release
- `find src -name '*.elm' | grep -v /Model/Blog.elm | xargs elm-format --yes`:
  format all files inside the `src/` directory except the automatically generated files
- `explorer.exe index.html`: open the file in the browser for viewing
- Working with dependencies
  - **Install:** `elm install elm/time`
  - **Uninstall:** `elm-json uninstall elm/time`
    - _Requires:_ `npm install --global elm-json`

You also need to install `pandoc` to build the website.

# RepLine

> Track every reputation that matters to you in a single dark, minimal side panel.
> Color-coded by tier from Hated to Exalted, compact and expanded views, in-window
> watchlist editor. Zero dependencies.

![Expanded view — full detail per faction](https://raw.githubusercontent.com/gabcinder2004/RepLine/main/screenshots/expanded.png)

## What it does

RepLine shows every reputation you care about as a stacked column of progress bars in a clean, dark, always-on side panel. Pick your factions once via an in-window editor; the panel updates live as you gain rep, color-coded by tier so you can read your standing at a glance.

The default WoW UI only shows **one** watched faction at the bottom of the screen. Switching between Cenarion Expedition, Sha'tar, Keepers of Time and the rest means opening the character pane every time. RepLine fixes that.

## Features

- **Watchlist of any size** (up to 20 factions). Pick yours from an in-window picker with a colored dot, standing label, and one-click checkbox per faction.
- **Two view modes**, toggled by a small minimize button or `/rep compact`:
  - *Expanded* — accent strip, faction name, percent, thin progress bar, and a detail line showing standing + raw numbers (`Honored · 3,513 / 12,000`).
  - *Compact* — single 18px row per faction. Letter tier indicator on the left (`F`/`H`/`R`/`E`), name and percent overlaid on the colored fill.
- **Distinct color progression** for each tier, tuned for the dark panel: red → orange → gold → taupe → green → turquoise → royal blue → magenta. No more squinting to tell Friendly from Honored.
- **Subtle pulse animation** when a tracked faction gains rep — the accent strip briefly dims and the fill smoothly animates to the new value.
- **Movable, hideable, persistent.** Drag to position; right-click to edit; toggle with `/rep`. Position is account-wide; watchlist is per-character.
- **No libraries.** Pure WoW API. Zero dependencies. ~800 lines total.

![Compact view — tier letter, name, and percent overlaid on each bar](https://raw.githubusercontent.com/gabcinder2004/RepLine/main/screenshots/compact.png)

## Slash commands

| Command | Action |
|---|---|
| `/rep` | Toggle the panel on/off |
| `/rep edit` | Open the watchlist picker (also: right-click the panel) |
| `/rep compact` | Toggle compact / expanded mode |
| `/rep reset` | Snap the panel back to its default right-edge position |
| `/rep show` / `/rep hide` | Force visibility state |
| `/rep debug` | Print tracked faction data to chat (for bug reports) |

![Edit watchlist — colored dot, standing, one-click checkbox per faction](https://raw.githubusercontent.com/gabcinder2004/RepLine/main/screenshots/edit-watchlist.png)

## Installation

1. Download from [CurseForge](https://www.curseforge.com/wow/addons/repline) and extract into `World of Warcraft\_anniversary_\Interface\AddOns\`
2. Make sure the folder is literally named `RepLine`
3. `/reload` or restart WoW
4. Right-click the panel that appears on the right edge to add factions

## Compatibility

- **TBC Anniversary Classic** (Interface 20505, client 2.5.5)
- Should also work on regular Burning Crusade Classic clients

## Credits

Logo: "Network bars" by [Delapouite](https://delapouite.com/) under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/), from [game-icons.net](https://game-icons.net/).

Bundled font: [Inconsolata](https://fonts.google.com/specimen/Inconsolata) under the SIL Open Font License.

## Bug reports & suggestions

[Open an issue on GitHub.](https://github.com/gabcinder2004/RepLine/issues) Run `/rep debug` in-game and include the output if you're reporting a faction that doesn't track correctly.

## License

[MIT](LICENSE)

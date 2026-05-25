# RepLine

Track all your reputations in one small panel on the side of the screen. No more opening the character pane to check where you stand with Cenarion Expedition, then closing it, then opening it again ten minutes later.

![Expanded view](https://raw.githubusercontent.com/gabcinder2004/RepLine/main/screenshots/expanded.png)

## Why you might want it

Blizzard's default UI shows one reputation at the bottom of the screen — the one you've "watched." If you're working on several factions at once (and in TBC, you usually are), you have to keep swapping which one is watched. RepLine just shows them all, all the time, in a small movable panel.

## How to use it

When you first install RepLine, an empty panel appears on the right edge of the screen with a hint: **Right-click to add factions.** Do that. You'll get a picker listing every faction you currently have any reputation with — your active standings, sorted alphabetically — and a checkbox next to each.

![Edit watchlist](https://raw.githubusercontent.com/gabcinder2004/RepLine/main/screenshots/edit-watchlist.png)

Tick the ones you care about. They appear in the panel immediately. Untick to remove. You can track up to 20.

Each bar shows the faction name, your current standing, the numbers, and a progress bar. As you gain rep, the bar fills in smoothly and the accent strip on the left pulses briefly so your eye catches it.

### Panel controls

Three small icons sit in the top-right corner of the panel:

- **≡** — open the options window (sort order, hide in combat)
- **–** — toggle compact mode
- **✕** — hide the panel. It stays hidden until you bring it back with `/rep` (or `/rep show`).

### Compact mode

If your watchlist gets long, click the small `–` icon in the top-right of the panel to switch to compact mode. Each bar collapses to a single thin row with a tier letter on the left (F for Friendly, H for Honored, R for Revered, E for Exalted), the name, and a percent.

![Compact view](https://raw.githubusercontent.com/gabcinder2004/RepLine/main/screenshots/compact.png)

Click the icon again to expand back. Your choice is remembered across `/reload`s.

### Reading the colors

Every standing tier has its own color, both on the left accent strip and inside the progress bar:

- **Red / orange / gold** — Hated, Hostile, Unfriendly
- **Taupe** — Neutral
- **Green** — Friendly
- **Turquoise** — Honored
- **Blue** — Revered
- **Magenta** — Exalted

So if you glance over and see a row of turquoise bars and one suddenly shows up blue, you know that faction just hit Revered.

### Moving the panel

Click-and-drag anywhere on the panel to move it. The position is saved across all your characters. If you ever lose track of where you put it, type `/rep reset` and it'll snap back to the right edge.

### Options

Click the **≡** icon (or type `/rep options`) to open the options window:

- **Hide in combat** — when ticked, the panel disappears the moment you enter combat and comes back when you leave it. If you've manually hidden the panel with **✕**, it stays hidden.
- **Sort order** — choose how the bars are ordered:
  - *Watchlist order* — the order you added them (default)
  - *Name (A–Z)* — alphabetical
  - *Reputation (high → low)* — most reputation first, so your Exalted factions float to the top
  - *Reputation (low → high)* — least reputation first

Both settings are remembered across `/reload`s. Sort order is shared across all your characters; the watchlist itself stays per-character.

## Slash commands

| Command | What it does |
|---|---|
| `/rep` | Show or hide the panel |
| `/rep edit` | Open the watchlist picker (same as right-clicking the panel) |
| `/rep options` | Open the options window (sort order, hide in combat) |
| `/rep compact` | Switch between compact and expanded views |
| `/rep reset` | Move the panel back to the default position |
| `/rep show` / `/rep hide` | Force the panel visible or hidden |

## Installation

Download from [CurseForge](https://www.curseforge.com/wow/addons/repline), extract into your `World of Warcraft\_anniversary_\Interface\AddOns\` folder, and `/reload` (or restart WoW). The folder inside the zip is already named `RepLine` — don't rename it.

## Compatibility

Built for **TBC Anniversary Classic** (Interface 20505, client 2.5.5). Should also load fine on regular Burning Crusade Classic.

## Bugs and feedback

[Open an issue on GitHub.](https://github.com/gabcinder2004/RepLine/issues) If a faction isn't tracking right, run `/rep debug` in-game first and paste the output into the issue — that tells me what RepLine is seeing for each of your tracked factions.

## Credits

Logo icon: "Network bars" by [Delapouite](https://delapouite.com/), under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/), from [game-icons.net](https://game-icons.net/).

Bundled font: [Inconsolata](https://fonts.google.com/specimen/Inconsolata), SIL Open Font License.

## License

[MIT](LICENSE).

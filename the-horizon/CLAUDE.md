# The Horizon — handoff for Claude Code

Roblox open-world survival game (R6, first person, PC + mobile) by Darya / Quartz Interactive.
Full game overview: `docs/THE_HORIZON_PROJECT_OVERVIEW.txt`. Read it first. It lists what is
designed vs. actually working and the rules for working on this project.

## Where things stand
- **UI exists, gameplay mostly doesn't.** The UI screens were designed earlier. Almost nothing is server-side yet:
  no server inventory, gathering, saving, building, combat or NPC logic.
- **New this session:** the Inventory + Crafting + Hotbar screen, designed as an HTML preview
  and then built in Roblox (`roblox/HorizonInventoryUI.client.lua`).

## Files
| Path | What it is |
| --- | --- |
| `roblox/HorizonInventoryUI.client.lua` | LocalScript (StarterPlayerScripts). The full inventory/crafting/hotbar UI with a LOCAL demo inventory. **The only script for now — the user wants UI only, no server scripts yet.** |
| `roblox/HorizonMotion.module.lua` | ModuleScript named `Motion`, INSIDE the HorizonInventoryUI LocalScript (required, the UI waits for it). Flying items, drag ghost, drop pill, landing pop, hit-testing. |
| `roblox/HorizonUITuner.module.lua` | ModuleScript named `Tuner`, placed INSIDE the HorizonInventoryUI LocalScript. The UI tuner (Pick/Drag/move/size/text/letter spacing, Copy all -> `HZT` line). Loaded only when `CONFIG.Tuner = true`. |
| `design/InventoryCrafting_preview.html` | **Open this in a browser** to see the approved design working (Tab = open/close, 1–8 = hotbar, Craft/All test the queue). Standalone, matches the latest decisions. |
| `design/InventoryCrafting.dc.html` | Source of the approved HTML preview (Claude Design canvas format; needs the canvas runtime to render). Live canvas: https://claude.ai/artifact/THsdwNwjTZUf2NXa1FVNbJ |
| `design/icons/*.svg` | Placeholder item icons used in the preview only. The Roblox script uses the user's real `rbxassetid` images. |
| `docs/old_SurvivalCraftingUI_reference.lua` | The user's OLD crafting UI script. Reference for style, the original `CraftingProgress` element, asset IDs and recipes. Don't run it alongside the new script. |
| `docs/THE_HORIZON_PROJECT_OVERVIEW.txt` | Whole-game design doc + status + rules. |

## Decisions the user made (keep these)
**Colours and font**
- **Accent is yellow** `#E9B949` (RGB 233,185,73). No teal or second accent colour, and no black/white-only theme. The user rejected both.
- **Font is Patrick Hand** (`Enum.Font.PatrickHand`), used for all text.
- **Text sizes are written as the HTML px sizes** and multiplied by `CONFIG.FontScale = 1.354` in the `text()`/`textButton()` helpers.
  Roblox TextSize is the font's line height; Patrick Hand's line height is 1.354 em, so without this all text came out ~26% too small.
- **Equipment slots** use a dashed outline (built from small Frames) and icons from `design/equipment_icons/*.png`
  once the user uploads them and fills `CONFIG.EquipmentIcons`. The PNGs are solid cream #EDE8DC (512px, transparent
  background); the script sets ImageTransparency 0.7 so they look grey like the HTML. Don't bake grey into the PNGs.
  How a slot looks when armour is equipped: **not decided yet** (user: decide later).
- **Item icons:** the coloured rbxassetid pictures are final. The HTML's white line icons were placeholders only.
  Only recipe tiles fade (ImageTransparency 0.55) when an item can't be crafted. Map/Compass show their name until they have art.

**Layout**
- **Panels:** dark semi-transparent, RGB 16,21,19, warm off-white text RGB 237,232,220. The user chose **darker than the HTML**
  for the bright game world: `PanelTransparency = 0.15`, menu dim `DimTransparency = 0.45` (HTML was 0.32 / 0.42 black).
  Two panels side by side: Inventory (464×560) and Crafting (640×560), with a 20px gap.
- **Design screen is 1280×720**, matching the HTML. Everything scales from it so proportions match the preview.
  The menu sits between Roblox's top-left buttons (GuiInset) and the hotbar. It must not be huge.
- **Hotbar:** 8 slots, keys 1–8. It **stays visible when the menu is open**.
- **Inventory button** sits **right next to hotbar slot 8** (backpack icon, "TAB" hint on PC). No separate
  bottom-left button. Tab toggles on PC.

**Menu behaviour**
- **While open:** background blur (BlurEffect) and dim. The mouse is unlocked (Modal button) and mobile touch controls are hidden.
- **Animations are fast and snappy:** the menu opens in about 0.16s with the panels snapping in from the sides and a Back overshoot,
  and closes in about 0.1s. Selected items, tabs and slots do quick bounces.
- **Text must stay sharp.** Don't wrap the menu in CanvasGroups; they made the text blurry on mobile.

**Crafting progress** (based on the old `CraftingProgress` in the old script)
- **Look:** top-right of the screen, no background box. White "Crafting <Item>" text on the left, "x<count>" on the right,
  and a thin 4px **yellow** bar underneath. **No seconds timer** under the bar.
- **Per-item bar:** the bar fills once per item. When one finishes the count drops (100x → 99x) with a small pop,
  and the bar slides back to empty very fast and smoothly (not an instant reset).
- **Finish:** when the batch is done it plays the old sound `rbxassetid://100545760361878`, holds about 0.65s, then slides out to the right.
- **Always on screen** while crafting, whether the menu is open or closed.
- **Rejected versions:** a box widget, a top-centre pill, ARK-style slot tiles, and a ring/card version.

**Crafting rules** (ARK-like)
- **Craft only:** Craft adds 1; clicking it again stacks the same item. The All button was removed (user decision).
- **Materials** are taken when each item **starts**, not when it's queued.
- **Clear queue** clears everything except the item currently being crafted.
- **Queue limit:** up to 8 different entries.

**Recipes** (from the overview doc and the old script)
- **Stone Pickaxe:** 4 Planks, 4 Stone, 2 Rope
- **Stone Axe:** 3 Planks, 4 Stone, 2 Rope
- **Stone Spear:** 3 Planks, 1 Stone, 1 Rope
- **Wooden Club:** 3 Planks, 1 Rope
- **Stone Sword:** 3 Planks, 5 Stone, 2 Rope
- **Torch:** 1 Plank, 4 Leaves, 1 Rope
- **Wooden Shield:** 6 Planks, 2 Rope, 1 Hide
- **Map:** 2 Hide, 2 Fiber
- **Compass:** 3 Scrap, 1 Plastic
- **Rope:** 3 Leaves
- **Nails:** 1 Scrap
- **No recipe yet:** Bow, Stone Arrows, Building Hammer, Clean Water Cup. Ask the user before inventing recipes.

**Placeholders still to replace**
- **Craft times** (`CRAFT_TIME` in the script) were made up and need real values.
- **Item images** for Map and Compass don't exist yet, so those items show their name instead.

## Reference image pass (latest)
The user's target is her reference screenshot (older design iteration), "just like the reference":
- "Ready" is cream (not yellow), category line is just "Tools" (no craft time), short HTML descriptions,
  held item name stays visible above the hotbar while the menu is open (28 design px gap menu to hotbar).
- Dim behind menu: `DimColor` rgb(12,11,6) at `DimTransparency` 0.16; panels 0.32; hotbar and bag button `HotbarTransparency` 0.15.
- Selected outlines are drawn INSIDE slots/tiles (inset ring frame), rows/labels use the reference's taller line boxes
  (equipment y 94, backpack grid y 202, material rows 52 tall, pitch 60).
- Hotbar itself is screen-centred; the bag button hangs to its right.
- **Menu is wider on wide screens:** `applyStretch(k)` widens both panels (k up to `MaxWidthStretch` 1.2) so the menu
  approaches `MenuWidthFraction` of the screen width. Vertical placement is unchanged apart from the gap for the item name.
  Panel children are laid out with scale-relative UDim2s so they follow the panel width.

## Mobile inventory controls (Bedrock-style, client only)
- Data: `bp` (24 backpack slots), `hb` (8 hotbar slots), `worn` (armour by slot name). Each slot is nil or `{ id, n }`.
  `pick = { area = "bp"|"hb", i, n }` (n nil = whole stack). `hold` tracks a finger press. Crafting counts items across bp + hb.
- Menu open: tap = pick whole stack (yellow outline only; the user rejected the lift/shadow and the pop after a move); tap another slot = move / stack / swap; tap same = unpick.
  Hold 0.3s on a stack of 2+ = amount bar (auto counts up, slide sideways to adjust); release keeps the partial pick.
  Partial pick onto empty = new stack, onto same item = add, onto different item = cancelled.
  Tap the dim background = drop the pick (toast "Dropped N Item"). Armour: tap slot with a wearable picked (ITEMS[id].Wear == slot name) = equip; tap worn slot = unequip.
- Menu closed: tap hotbar = select; hold hotbar 0.15s + 0.45s coral bar = throw whole stack.
- Settings at top of script: HOLD_DELAY, HOLD_FILL, SLIDE_PX, SLIDE_MIN, SLIDE_MAX, THROW_DELAY, THROW_TIME, TAP_GUARD.
- **Server hook spots** (no comments allowed in the script, so they are listed here): `moveTo` (move / stack / swap / move part of a stack),
  `dropPicked` (drop), `throwHotbar` (throw), `tapEquip` (equip / unequip), crafting `removeItem` / `addItem`.
  The server must verify the player owns the items and spawn drops in the world.
- No armour items exist yet; equipping works as soon as an item has `Wear = "Helmet"` (etc.) in ITEMS.

## Move animation + drag (Motion module)
- Every move flies the item picture to its new slot (FLY_TIME 0.18, Quint Out, starts at 1.12x). Data changes at once; the destination hides its icon/count (`ui.Hidden`) until landing, stacks keep the old count (`ui.FrozenCount`) until landing.
- Landing pop is tiny on purpose: the user wants 10% of a normal bounce (`POP_SCALE = 0.1`).
- Swap = two flyers at once. Equip/unequip fly to/from the armour icon. Unequip with a full backpack shows the "Backpack is full" toast.
- New move while flying = old flyers snap (`motion:finishAll()`); closing the menu snaps everything and cancels a drag.
- Drag: move > DRAG_START_PX before the hold bar = drag. Ghost follows the finger (36px above on touch), hover target gets the yellow outline, outside the panels shows the coral "Release to drop" pill. Release: slot = move (ghost drops in), matching armour = equip, world = drop (fade + toast), anything else = ghost flies back.
- The drop is where the server must spawn the item (listed here instead of a code comment).

## Next steps
1. **Server side for the inventory — LATER.** The user said UI only for now (one client script). A first server version
   (shared items module, server-owned queue, RemoteEvents) exists in git history (commit 9ddf0dc) if wanted later.
   Look for `SERVER HOOK` in the script. The client must never grant items.
2. **Real equipment slots** (Helmet, Chest, Gloves, Legs, Boots) and drag-and-drop between the backpack and hotbar.
3. **Check this against the user's existing scripts in Roblox Studio** (`SurvivalInventoryUI`, `SurvivalCraftingUI`,
   RemoteEvent names) before wiring anything. The overview's "October 2026 recovery findings" list known mismatches.
4. **Then follow the build order from this session:** inventory server → gathering → crafting server →
   survival stats → saving per world → building → combat → NPCs → world.

## Working with the user
- **Script size limit:** the user pastes scripts into an in-game editor that colour-codes them; the coloured text must stay under Roblox's 200,000-char limit (about 2.7x the raw size). Keep each script under ~70,000 chars; split into ModuleScripts when it grows.
- **IMPORTANT: if anything in a request is unclear, ASK the user before doing it.** Don't guess.
- **NEVER remove or change a value the user tuned with the UI tuner (HZT lines) without asking first.** Later edits must keep them.
- **Tuner values for one repeated item apply to all of its kind** (one material row -> all rows, one recipe tile -> all tiles, one backpack slot -> all slots). Exception: armour/equipment slots are per-slot; never touch them unless asked.
- **NEVER put comments or prints in the user's scripts.** No `--` comments, no `print`/`warn`. Explain things in chat instead.
- **Short, direct messages.** They test on mobile (landscape phone) and send screenshots.
- **Match the approved preview closely.** Don't restyle things they didn't ask about.
- **Keep their existing names, assets and structure** (see the overview's rules section).

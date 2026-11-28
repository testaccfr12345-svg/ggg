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
| `roblox/InventoryModule.module.lua` | ModuleScript named `InventoryModule` (was `Motion`), INSIDE the HorizonInventoryUI LocalScript (required, the UI waits for it). Flying items, drag ghost, drop pill, landing pop, hit-testing. |
| `design/InventoryCrafting_preview.html` | **Open this in a browser** to see the approved design working (Tab = open/close, 1–8 = hotbar, Craft/All test the queue). Standalone, matches the latest decisions. |
| `design/InventoryCrafting.dc.html` | Source of the approved HTML preview (Claude Design canvas format; needs the canvas runtime to render). Live canvas: https://claude.ai/artifact/THsdwNwjTZUf2NXa1FVNbJ |
| `design/icons/*.svg` | Placeholder item icons used in the preview only. The Roblox script uses the user's real `rbxassetid` images. |
| `docs/old_SurvivalCraftingUI_reference.lua` | The user's OLD crafting UI script. Reference for style, the original `CraftingProgress` element, asset IDs and recipes. Don't run it alongside the new script. |
| `docs/THE_HORIZON_PROJECT_OVERVIEW.txt` | Whole-game design doc + status + rules. |

## Build UI (UI only, separate LocalScript)
- `roblox/HorizonBuildUI.client.lua` (+ `txt/HorizonBuildUI.txt`): LocalScript in StarterPlayerScripts. Reference: `design/Horizon_Build_UI.html` (896x414, safe area).
- UI only. Everything it reads/triggers goes through the `BuildHooks` functions at the top (IsHammerEquipped = character holds a Tool named "Building Hammer";
  GetLookedAtPiece returns nil; GetMaterialCount uses PLACEHOLDER_MATERIALS; GetPieceCost uses the HTML structure costs, placeables return nil = Select disabled;
  StartPlacing/RotatePlacing/PlacePiece/CancelPlacing/Upgrade/Repair/Destroy are empty). No comments, so the hook list lives here.
- Icons/pictures: `design/build_icons/*.png` (rendered from the HTML SVGs, cream). IDs go in CONFIG.Icons and CONFIG.PieceImages.
- User said the Jump/Sprint/Crouch buttons in the HTML don't exist in the build script; they live in the user's own `HorizonMobileButtons` script.
  The Build/Rotate mobile buttons copy that script's style and placement (own ScreenGui, real px, placed relative to the native TouchGui JumpButton: Build at +26.5,-131, Rotate at +26.5,-189 from its centre).
- Build menu = a copy of the inventory's Crafting panel (user: "literally use the craft side"): 640x560 inventory design units, widened by the same stretch,
  same scale and vertical centre as the inventory menu, centred horizontally. Same title, close button, tabs (auto-shrink to fit 5 tabs), tiles 90x100,
  preview card, material row, "Recipe not set yet" box and button as crafting. Same dim (rgb 12,11,6 @ 0.16), panel 0.32 and blur 12.
  Open/close animation is an exact copy of the inventory's (fade + text fade, 0.985 -> 1 grow, close shrink to 0.96, same timings and lock).
- Material row and Select button copy the inventory crafting style (row 52 tall, icon 42, Ready = yellow, missing = rgb 244,164,124). `TestPieceImage` (wall) fills every piece with no picture.
- Tiles never show the word "Wooden" (only the preview name does). Tiles are square 100x100, gap 7, no scrollbar. ExtraWidth = 100 (user tuned). Row is 100 tall (no scrollbar gap), preview/side moved up to y 186 and 354 tall. Build button + PC key legend stay visible while the menu is open (button gui DisplayOrder 13, above the dim). Tapping the dim does NOT close the menu. The row sits in a CanvasGroup (user asked) with a UIGradient edge fade (22%):
  right fade while more tiles are to the right, left fade once scrolled; no fades if everything fits (fades tween in/out 0.18s). Detected from first/last tile positions.
- The width tuner was removed (user). `ShowPieceMenuForTesting = true` makes GetLookedAtPiece return a demo Wooden Wall (60/100 hp) so the Upgrade/Repair/Destroy menu always shows (no building system yet).
- Piece menu = the user's mockup: centred, name in spaced caps + thin health bar, then 3 columns (keycap icon/E R X, UPGRADE / REPAIR / DESTROY, cost) with no row boxes,
  interaction-prompt styling (UIShadow, keycap rgb 37,30,24). Own ScreenGui "HorizonBuildPieceMenu"; its bottom sits above the inventory hotbar and the held-item name (same hotbar math), scale like the prompt.
- `ShowWithoutHammer = true` is a test switch (UI shows without the hammer). Place prompt = exact copy of the user's HorizonInteractionPrompt script (own ScreenGui "HorizonBuildPrompt", same settings, UIShadow, haze, fade). Text "PLACE WOODEN WALL"; keycap TAP on mobile, CLICK on PC (box widens to fit CLICK). The cost line under it was dropped to match their prompt.

## Item feed (UI only, separate LocalScript)
- `roblox/HorizonItemFeed.client.lua` (+ txt): top-centre feed of added/removed items (ref 896x414 safe area, 8px from top (user: slightly up)). No panel; 16px icon + Patrick Hand text with UIShadow.
  Added cream, removed rgb 224,122,110 (icon tinted). Newest on top, max 3, rank alpha 1/0.7/0.4, 2s then fade. NO merging: every gain/loss is its own new line (user). Older lines slide down and dim smoothly (0.18s); new line drops in from 10px above; the pushed-out oldest slides one slot down while fading.
- Hook (no comments allowed): other LocalScripts fire the BindableEvent (`shared`/`_G` are blocked in the user's in-game script runner, SLVM)
  `PlayerGui.HorizonItemFeed.ItemFeedAdd:Fire(itemName, amount)` (amount < 0 = removed). The inventory should call it wherever items are added/removed (addItem/removeItem/drop etc.).
- `SHOW_TEST_BUTTONS = true` shows a Frame "TestButtons" (+ Item / - Item) on the left middle. Icons: the user supplies their own IDs in CONFIG.Icons. Do NOT make icons for the user unless asked.

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

## PC controls (Minecraft-style, mouse) - code lives in the Motion module (`Motion:attachPC(api)`)
- Only one ModuleScript inside the LocalScript: InventoryModule (formerly Motion). PC code is in Motion (user did not want a 3rd module).
- Menu open, mouse: left click item = it sticks to the cursor; left click slot = place/stack/swap; right click item = half; right click slot while holding = place 1.
  Holding + drag across empty/same slots: left = split evenly, right = 1 each. Click outside (dim) while holding: left = drop all, right = drop 1.
  Q on hovered slot = drop 1, Ctrl+Q = drop stack. Double-click = gather all of that item. Shift+click = equip/unequip armour ONLY.
- Backpack <-> hotbar stays DRAG ONLY on PC too (press and drag, like mobile). Cursor items never go into the hotbar by click.
- Closing the menu returns the cursor item to the inventory (or drops it if full). Touch/mobile behaviour is unchanged.

## CHECKPOINT: mobile controls finished
- The user approved the mobile inventory as finished. Saved state = git commit `5155fe0` on branch `claude/new-session-wjmhlh`
  (files: roblox/HorizonInventoryUI.client.lua + Motion and Tuner modules; the Tuner was removed later). Next: PC controls (mouse/keyboard), Minecraft-style.
- PC controls must NOT change how mobile works.

## Mobile inventory controls (Bedrock-style, client only)
- Data: `bp` (24 backpack slots), `hb` (8 hotbar slots), `worn` (armour by slot name). Each slot is nil or `{ id, n }`.
  `pick = { area = "bp"|"hb", i, n }` (n nil = whole stack). `hold` tracks a finger press. Crafting counts items across bp + hb.
- Menu open: tap = pick whole stack (yellow outline only; the user rejected the lift/shadow and the pop after a move); tap another slot = move / stack / swap; tap same = unpick.
  Hold 0.3s on a stack of 2+ = amount bar (auto counts up, slide sideways to adjust); release keeps the partial pick.
  Partial pick onto empty = new stack, onto same item = add, onto different item = cancelled.
  Tap the dim background = drop the pick (no message). Armour: tap slot with a wearable picked (ITEMS[id].Wear == slot name) = equip; tap worn slot = unequip.
- Menu closed: tap hotbar = select; hold hotbar 0.15s + 0.45s coral bar = throw whole stack.
- Settings at top of script: HOLD_DELAY, HOLD_FILL, SLIDE_PX, SLIDE_MIN, SLIDE_MAX, THROW_DELAY, THROW_TIME, TAP_GUARD.
- **Server hook spots** (no comments allowed in the script, so they are listed here): `moveTo` (move / stack / swap / move part of a stack),
  `dropPicked` (drop), `throwHotbar` (throw), `tapEquip` (equip / unequip), crafting `removeItem` / `addItem`.
  The server must verify the player owns the items and spawn drops in the world.
- No armour items exist yet; equipping works as soon as an item has `Wear = "Helmet"` (etc.) in ITEMS.

## Hotbar rules while the menu is open (user decision)
- The selected hotbar slot ALWAYS shows its yellow outline (drawn just OUTSIDE the slot, so it doesn't look smaller).
- Tapping hotbar slots does nothing while the menu is open; keys 1-8 are ignored too. No hold-to-pick on the hotbar.
- Moving items between backpack and hotbar is DRAG ONLY (both ways). Tap-to-move works only inside the backpack.
- Held-item name above the hotbar shows for 2 seconds, a bit higher than before.

## Move animation + drag (Motion module)
- Every move flies the item picture to its new slot (FLY_TIME 0.18, Quint Out, starts at 1.12x). Data changes at once; the destination hides its icon/count (`ui.Hidden`) until landing, stacks keep the old count (`ui.FrozenCount`) until landing.
- NO landing pop and NO pop when crafting finishes (user removed them). The crafted slot keeps only the quick yellow outline flash.
- Swap = two flyers at once. Equip/unequip fly to/from the armour icon. Unequip with a full backpack shows the "Backpack is full" toast (toast UI lives in Motion as motion:toast). Drops never show a message.
- Menu open = character can't move or jump (PlayerModule controls Disable) and the camera is locked (CameraType Scriptable, old type restored on close), PC and mobile.
- New move while flying = old flyers snap (`motion:finishAll()`); closing the menu snaps everything and cancels a drag.
- Drag: move > DRAG_START_PX before the hold bar = drag. Ghost follows the finger (36px above on touch), hover target gets the yellow outline, outside the panels shows the coral "Release to drop" pill. Release: slot = move (ghost drops in), matching armour = equip, world = drop (fade, no message), anything else = ghost flies back.
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
- **Menu open animation (user choice):** everything, text included, fades in together (0.2s) with a tiny grow (UIScale 0.985 -> 1). Roblox snaps text sizes while a UIScale animates, so keep the grow tiny; never delay the text fade.
- **Script size limit:** the user pastes scripts into an in-game editor that colour-codes them; the coloured text must stay under Roblox's 200,000-char limit (about 2.7x the raw size). Keep each script under ~70,000 chars; split into ModuleScripts when it grows.
- **IMPORTANT: if anything in a request is unclear, ASK the user before doing it.** Don't guess.
- **NEVER remove or change a value the user tuned with the UI tuner (HZT lines) without asking first.** Later edits must keep them.
- **The UI tuner and the + crosshair were removed (user request).** The tuner is in git history (commit before its removal) if it is ever wanted again.
- **Tuner values for one repeated item apply to all of its kind** (one material row -> all rows, one recipe tile -> all tiles, one backpack slot -> all slots). Exception: armour/equipment slots are per-slot; never touch them unless asked.
- **NEVER put comments or prints in the user's scripts.** No `--` comments, no `print`/`warn`. Explain things in chat instead.
- **Short, direct messages.** They test on mobile (landscape phone) and send screenshots.
- **Match the approved preview closely.** Don't restyle things they didn't ask about.
- **Keep their existing names, assets and structure** (see the overview's rules section).

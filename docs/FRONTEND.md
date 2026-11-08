# FreightIntel AI — Frontend (Flutter)

> Living doc of the mobile frontend. **Update this on every frontend change**
> (see [`../AGENTS.md`](../AGENTS.md) RULE 0). Backend not built; all data is demo.

## Stack
- **Flutter / Dart**, Material 3.
- Fonts: `google_fonts` (Onest, SF-like). Icons: `iconsax_plus` (Bold = filled,
  Linear = outline). Motion: `flutter_animate`. Loading: `skeletonizer`.
- No state-management lib yet; screens use `StatefulWidget` + in-memory repos.

## Run
AVD `expo_review` (Pixel 6 skin → device frame). `flutter run -d emulator-5554`.
Hot reload SIGUSR1, hot restart SIGUSR2 (const-class/asset changes). New
`pubspec.yaml` assets need a full rebuild.

## Folder map (`app/lib`)
```
core/
  theme/app_theme.dart     # tokens: AppColors, AppRadii, AppShadows, numStyle,
                           # labelStyle (sentence case), kEaseOut curve, theme
  illustrations.dart       # Illus.* asset paths + Illus.mode(type) mapping
  widgets/
    app_card.dart          # AppCard, HighlightCard (profit hero), StatTile
                           # (label + value + delta chip + Sparkline)
    app_bottom_nav.dart    # floating capsule nav, 4 tabs, active = filled icon
                           # + green label + underline (icon weight, not a blob)
    pressable.dart         # scale-on-press + Semantics wrapper (all tappables)
    empty_state.dart       # illustration + title + message
    sparkline.dart         # mini trend line w/ grow animation
    logo_mark.dart         # route logo + Wordmark "FreightIntel AI"
features/
  auth/login_screen.dart           # hero illustration + wordmark + demo login
  home/home_shell.dart             # Scaffold: IndexedStack + AppBottomNav, extendBody
  dashboard/dashboard_screen.dart  # greeting+avatar, period chips, profit hero
                                   # (ring + route pattern), 4 stat tiles, bar chart
  shipments/
    shipments_screen.dart          # list (skeleton→data, pagination, empty),
                                   # mode thumbnail + status chip, FAB "+" create
    shipment_detail_screen.dart    # header, P&L, status timeline, revenue/cost
                                   # breakdown, custom fields
    create_shipment_screen.dart    # form: customer/type/origin/dest → new Shipment
    shipment_repository.dart       # Shipment model, demo data, pagination, cache
    status_chip.dart               # StatusChip + statusColors()
  finance/finance_screen.dart      # 4 stat tiles + invoice list + empty
  finance/finance_repository.dart  # Invoice demo data
  insight/insight_screen.dart      # AI hero illustration + "Segera hadir"
```

## Design system (quick)
- Colors: green `#17A55B` (accent/positive), greenSoft `#E7F6EE`, greenInk
  `#0E7A42`; ink/navy `#16365C`, inkSoft `#3A4B66`, muted `#5C6B7D` (AA-safe);
  loss `#E0523D`, warning `#E0A33E`; bg `#F4F6F8`, surface white.
- Radii: card 24, tile 20, input 14, pill 999. Shadow: soft elevation only.
- Type: `numStyle` (tabular, bold, for money/KPI), `labelStyle` (13px w600,
  sentence case — NOT eyebrow caps). Entrance easing `kEaseOut`.
- Illustrations: flat-vector, playful, brand palette, from `assets/illustrations/`
  (Gemini-generated; source raws in `/Asset Generate`, do not delete). Objects
  have no faces; only people (avatar) do.

## Screens: built vs TODO (PRD map)
Built (UI + demo data): Login · Dashboard (FR-DSH partial) · Shipments list
(FR-SHP-03) · Shipment detail + P&L (FR-SHP-04, FR-PRF) · Create shipment
(FR-SHP-01 core) · Finance overview (FR-REV/CST/PRF partial) · Insight placeholder.

Not built yet (priority order, see PRD §13):
1. Add Revenue / Add Cost forms (FR-REV-01, FR-CST-01); Record payment (BR-06);
   Shipment filter & search (FR-SHP-03); Notification center (FR-NOT-05).
2. Financial Report + export (FR-RPT); Customer + analytics (FR-CAN); Vendor +
   analytics (FR-VAN).
3. Company/branch settings (FR-CMP); Users & RBAC (FR-USR); Custom fields (FR-CF).
4. AI Advisor chat (FR-AI); Forecasting (FR-FC); Invoice OCR (FR-OCR).

## Known debt / audit items
- Period chips (Harian/Bulanan/Tahunan) don't change data yet.
- Shipment detail "Edit" button is a stub ("segera").
- Created shipment is in-memory only (lost on restart).
- Create form lacks container & ETD/ETA fields (`shortcut:` comment in file).
- Language EN/ID mix (Revenue/Cost/PAID). Migrate to ID.
- Profit ring vs "+12%" label not semantically linked.
- Insight tab icon is a star/sparkle (generic); consider a chart/bulb icon.

## Changelog
- 2026-11-08 — Shipment detail + P&L + status timeline; tappable cards; status
  chips on list; Create Shipment form + FAB. Illustration system wired (login
  hero, avatar, mode thumbnails, insight hero, empty states, dashboard pattern).
  Stat tiles got sparkline + delta chips. Bottom nav redesigned to floating
  labeled capsule (icon-weight active state). De-slopped labels (sentence case).
  Emulator given Pixel 6 device frame.

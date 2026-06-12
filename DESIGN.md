# Design System: Due

**Project type:** Flutter Android MVP  
**Product:** Minimal exam countdown, review-day tracker, focus timer, school notice monitor, and Android home-screen widget  
**Primary use case:** A student opens the app daily to see urgent exam dates, track review progress, record focus sessions, and monitor admission-related notices.

## 1. Visual Theme & Atmosphere

Due should feel calm, compact, and dependable. The core countdown and settings pages use a restrained academic productivity style: warm white cards, soft green emphasis, thin dividers, and modest rounded corners. The app should avoid marketing-style hero layouts, decorative gradients, oversized empty space, or playful illustrations on utility pages.

The focus timer and study-record pages are allowed to feel more immersive. They currently use a sky-blue concentration mode with soft glassy white surfaces, circular timer controls, and chart-forward dashboards. Keep that branch visually related to the rest of the app through similar radius, typography weight, and compact information hierarchy.

## 2. Color Palette & Roles

| Color | Hex | Role |
| --- | --- | --- |
| Deep Study Green | `#2D6A4F` | Primary actions, selected states, floating action buttons, success-forward status chips |
| Dark Evergreen | `#0F5238` | Strong status text, high-emphasis green labels |
| Muted Sage | `#52796F` | Secondary action color and quieter support accents |
| Warm Alert Clay | `#B75D4A` | Accent for warning-like emphasis, never as the dominant page color |
| Soft App Background | `#F8F9FA` | Default scaffold background for countdown, forms, settings, monitor, and widget pages |
| Low Surface Gray | `#F3F4F5` | Subtle chips, date strips, inactive status backgrounds, empty-state icons |
| Pure Card White | `#FFFFFF` | Cards, form fields, grouped settings, widget previews |
| Ink Black | `#191C1D` | Primary text and high-value numbers |
| Muted Body Green-Gray | `#5E6862` | Secondary text, subtitles, dates, explanatory labels |
| Quiet Metadata Gray | `#87918B` | Low-priority labels, chevrons, timestamps |
| Fine Border | `#E1E6E2` | Card outlines, input outlines, dividers |
| Success Wash | `#E7F3EC` | Positive chips, enabled monitor states, green icon containers |
| Warning Wash | `#F8EEE8` | Soft warning backgrounds |
| Destructive Red | `#BA1A1A` | Delete actions and destructive copy |
| Destructive Wash | `#FFDAD6` | Destructive icon backgrounds and error panels |
| Focus Sky | `#87C9F7` | Top of focus timer gradient |
| Focus Mist | `#BCE7FF` | Middle of focus timer gradient |
| Focus Paper | `#F7FBFF` | Bottom of focus timer gradient |
| Focus Deep Blue | `#1D6C93` | Focus timer primary controls, study-record selected tabs, summary cards |
| Focus Ink | `#153C55` | Main text on focus and study-record screens |
| Chart Sky Blue | `#74BDE8` | Study distribution bars |

Countdown items may use user-selected accent colors:

`#2563EB`, `#F97316`, `#10B981`, `#EF4444`, `#8B5CF6`, `#EC4899`, `#14B8A6`, `#F59E0B`.

Use these as per-item accents only: thin bars, number color, icon tile tint, or widget highlight. Do not let them overpower the primary green system.

## 3. Typography Rules

Use a clean system sans-serif style similar to Flutter Material 3 defaults. Text should be practical and highly scannable.

| Text role | Size | Weight | Use |
| --- | ---: | ---: | --- |
| App bar title | `20` | `700` | Page title, left aligned |
| Page heading | `24` | `700` | Home header and primary page introductions |
| Section title | `16` | `700` | Card group headings and dashboard modules |
| Body | `15` | `400-500` | General labels, dates, subtitles |
| Small label | `13` | `600-700` | Form labels, status metadata, helper text |
| Countdown number | `56-64` | `600-700` | Hero countdown value only |
| Focus timer | `58` | `800` | Timer dial value only |

Letter spacing should stay at `0`. Avoid condensed or negative-tracked display text. Large numbers should be bold but not decorative.

## 4. Shape, Spacing & Elevation

| Token | Value | Design meaning |
| --- | ---: | --- |
| Page padding | `20` | Main mobile horizontal rhythm |
| Standard spacing | `16` | Default gap between cards, controls, and form rows |
| Large spacing | `24` | Section breaks and major card inner padding |
| Extra-large spacing | `32` | Empty-state breathing room and final form spacing |
| Small radius | `4` | Chips, mini bars, segmented selected tabs |
| Default radius | `8` | Cards, buttons, inputs, list tiles, icon tiles |
| Medium radius | `10` | Picker tiles and selected item tiles |
| Large radius | `12` | Empty-state icon containers |
| Widget radius | `16` | Android widget preview only |

Most app surfaces are flat. Default cards should use `0` elevation with a thin `#E1E6E2` outline. Use shadows sparingly: only widget previews, focus timer dial, and study-record summary cards may use soft diffused shadows.

## 5. Core Components

### Buttons

Primary buttons are filled Deep Study Green with white text, radius `8`, vertical padding around `14`, and no heavy shadow. Floating action buttons are green circles with a plus icon. Text buttons use green foregrounds. Destructive text buttons use Destructive Red.

### Cards

Cards are white, flat, outlined, and compact. They should read as grouped information, not decorative panels. Avoid nested cards. Use internal padding `16`; use `24` only for the main countdown overview.

### Inputs

Inputs are filled white with thin borders, radius `8`, and generous internal padding. Focused input outlines switch to Deep Study Green. Form labels are small, semibold, and muted.

### Chips

Status chips are compact rectangles with radius `4`, small icon optional, 12px bold text, and soft background washes. Choice chips should be used for repeat mode, focus duration, source type, and category selection.

### List Rows

List rows use a left icon tile, strong title, muted subtitle, and right chevron or status marker. Dividers should be thin and inset when rows are grouped inside a settings-style card.

### Empty States

Empty states use a centered icon tile, one short message, and an optional outlined action. Keep them functional and quiet; no large illustrations.

## 6. Page Patterns

### Home / Countdown Dashboard

Purpose: show the nearest important date first, then review progress, monitor entry, and all countdowns.

Design requirements:

- Keep `Due` as the app identity in the app bar.
- Use a compact header with title "备考日程" and a short subtitle.
- If review start is set, show a small review-day status chip beside the header.
- The nearest countdown should be the strongest visual block: white outlined container, colored vertical accent bar, title, giant day count, target date strip.
- Countdown cards should remain list-friendly: icon/accent tile on left, title/date in the middle, day number on the right.
- The school-monitor entry should look like a navigational card, not a banner.
- Empty state should encourage adding the first important date.

### Add / Edit Countdown

Purpose: create or update an exam/date countdown quickly.

Design requirements:

- Use a single-column form with title, target date, repeat mode, color picker, icon picker, and full-width save button.
- Target date should be a tappable outlined row with calendar icon.
- Repeat mode should use a segmented control: once / yearly.
- Color picker should use circular swatches; selected swatch has a dark outline.
- Icon picker should use square rounded tiles with selected green tint.
- Edit page includes a destructive delete icon in the app bar.

### Settings

Purpose: route to app-level configuration and data management.

Design requirements:

- Use grouped cards under section headings.
- Each row has a soft icon tile, bold title, muted subtitle, and chevron.
- Destructive rows use red icon/text and red soft background.
- Settings should feel administrative and dense, not editorial.

### Review Start Date

Purpose: set the first day of review.

Design requirements:

- Keep a quiet prompt near the top.
- Use one date picker row as the central control.
- Place the full-width save button at the bottom.
- Do not add charts or motivational copy here.

### Android Widget Preview

Purpose: choose which countdown appears on the home-screen widget and sync it.

Design requirements:

- Start with a label "预览" and a fixed-height widget mock.
- Widget mock should be 120px tall, radius `16`, white surface, thin border, optional soft shadow.
- Use a narrow vertical accent strip, title/date block, and large day number.
- Countdown selection list uses left accent/icon tile, title, date, and green check for selected item.
- Sync action is a full-width primary button fixed near the bottom of the page content.

### School Monitor List

Purpose: manage monitored school notice sources.

Design requirements:

- Use flat outlined source cards.
- Header row: source-type icon tile, school name, compact status chip.
- Secondary line: source name or URL.
- Body line: last check time and watched keywords.
- Keyword chips are small low-surface tags.
- Bottom toolbar has refresh and hit-record text buttons, plus edit/delete icon buttons.
- Failure states use Destructive Red and Destructive Wash.

### Monitor Source Edit

Purpose: add or edit RSS/webpage notice source.

Design requirements:

- Single-column form with school name, source name, URL, keywords, source type, enabled switch, and save.
- Source type uses segmented RSS / webpage control.
- Enabled state uses a switch row.
- Validation errors should be concise and inline.

### Monitor Hits

Purpose: review matched admissions notices.

Design requirements:

- Top section contains title, short subtitle, and search field with search icon.
- Hit cards show a small "new notice" chip, optional date, bold title, matched keyword line, summary box, and right-aligned "open original" text button.
- Summary boxes use Low Surface Gray with border and max three lines.
- Empty and no-match states should be short and centered.

### Focus Timer

Purpose: run a focused study session.

Design requirements:

- This page may use the sky gradient background from `#87C9F7` to `#F7FBFF`.
- Header title is "沉浸专注"; right action opens study records with a filled-tonal chart icon.
- Main timer is a large circular white translucent dial with thick white ring and soft blue shadow.
- Timer value is the only display-scale text on the page.
- Duration selection uses centered choice chips.
- Notes and category selector live in a translucent white panel.
- Controls are circular icon buttons: reset, play/pause, stop. Primary play/pause button is larger.
- Today stats sit in a translucent white panel with two metrics separated by a vertical divider.

### Study Records

Purpose: inspect focus-session history and distribution.

Design requirements:

- Use a pale blue background `#F3F8FB`, not the default green-gray background.
- Top range selector is a segmented row: day / week / month / year.
- Date range row uses a calendar icon and bold blue-gray text.
- Summary card is solid Focus Deep Blue with three metrics in white.
- Distribution chart uses compact vertical bars in Chart Sky Blue.
- Category chart uses horizontal progress bars and percentage labels.
- Record list uses white outlined rows with small book icon tiles.

## 7. Navigation & Information Hierarchy

Primary flows:

1. Home -> Add countdown -> Home
2. Home -> Edit countdown -> Home
3. Home -> Settings -> Review start / Widget preview / Monitor
4. Home -> Monitor -> Monitor hits / Monitor source edit
5. Focus timer -> Study records

The app should always show the next obvious action without explaining the whole feature. Use app bars, icon buttons, and list rows for navigation. Avoid onboarding text unless the state is empty.

## 8. Stitch Redesign Guidance

When redesigning in Google Stitch:

- Preserve the app as a mobile-first Android productivity app.
- Redesign all major pages as a coherent system, not just the home page.
- Keep the core countdown pages green, white, and quiet.
- Keep focus and study analytics as a related but distinct sky-blue mode.
- Prefer dense, readable utility layouts over decorative marketing screens.
- Use actual UI controls: segmented controls, chips, switches, icon buttons, search fields, forms, charts, and list cards.
- Do not introduce oversized hero imagery, gradient blobs, glassmorphism outside the focus mode, nested cards, or excessive rounded pills.
- Keep every screen usable with Chinese labels and exam-prep context.

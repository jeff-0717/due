# Due UI Polish Design

## Scope

Optimize the Flutter UI for the existing Due app on the `UI-polish` branch. The priority surfaces are home, school information monitoring, hit records, and settings. The work keeps existing routes, data models, and core behavior intact.

## Stitch MCP Evidence

- Project: `projects/7909151045756809397`
- Generated screen: `projects/7909151045756809397/screens/d0702b4ef7114c338acdac1ef417c297`
- Design system: `assets/5a43c7942f784f0cb9784f9bcd55cb5e`
- Direction: Productive Serenity, a calm minimal interface for Chinese exam-prep users.

## Design Contract

| Area | Decision |
| --- | --- |
| Palette | Off-white background, white surfaces, deep sage green primary, muted teal secondary, red only for destructive/error states |
| Shape | 8px default radius, 4px chips, no decorative large rounded cards |
| Depth | Thin borders and tonal separation instead of heavy shadows |
| Typography | Clear Chinese labels, prominent but controlled countdown numerals, no viewport-scaled type |
| Density | Compact list rows with enough touch space; no nested cards |
| Motion | Keep existing Flutter defaults; no decorative animation |

## Page Direction

| Page | UI Outcome |
| --- | --- |
| Home | Calm study dashboard with nearest countdown, review days, monitoring entry, sorted countdown list |
| Monitoring | Source cards with keywords, last check status, compact status chip, refresh/hits/edit/delete actions |
| Hit records | Search-first notice feed with keyword chips, date, concise summary, original-link action |
| Settings | Grouped utility sections with clear rows and a restrained destructive area |

## Acceptance

- Existing functional tests for home, monitor, hits, and settings continue to pass.
- `dart analyze`, `flutter test`, and `flutter build apk` pass or document a concrete external blocker.
- UI changes remain scoped to app frontend and loop documentation.

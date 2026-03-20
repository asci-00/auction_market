# Auction Market Design System

## Design Goal
- Build a premium resale market interface with auction urgency.
- The app should feel curated, modern, and calm.
- Avoid default Material look.
- Avoid bright blue or purple-heavy palettes.

## Visual Direction
- Base mood: warm neutral paper and soft stone.
- Contrast mood: charcoal panels for important price and action areas.
- Accent mood: copper for primary action, coral for urgent status, muted sage for success and confirmation.
- Composition mood: editorial luxury marketplace with large headlines, breathing room, and image-first cards.
- Reference direction:
  - [Dribbble auction app search](https://dribbble.com/search/auction%20app)
  - [Dribbble marketplace app search](https://dribbble.com/search/marketplace%20mobile%20app)

## Typography
- Display font: `Cormorant Garamond`
- UI font: `Manrope`
- Use display font only for hero titles, major price headers, and editorial banners.
- Use UI font for lists, forms, tabs, buttons, badges, and metadata.

## Color Tokens
- `bg.base`: `#F6F1EA`
- `bg.surface`: `#FFFDF9`
- `bg.panel`: `#1E1C1A`
- `text.primary`: `#201D19`
- `text.secondary`: `#6E665F`
- `text.inverse`: `#F8F4EE`
- `accent.primary`: `#B86A3B`
- `accent.urgent`: `#D85B45`
- `accent.success`: `#6D8A74`
- `border.soft`: `#E5D9CC`
- `shadow.color`: `#201D19` at low opacity

## Layout Tokens
- Grid: 4pt base unit.
- Screen horizontal padding: 20.
- Card radius: 24.
- Sheet radius: 28.
- Input height: 56.
- Primary button height: 56.
- Sticky bottom action area height: 88 including safe area padding.

## Motion Rules
- Page entrance: fade plus 12px rise, 260ms.
- List stagger: 30ms per item, max 6 visible items.
- Bottom sheet: spring, no bounce overshoot.
- Countdown updates: text-only animation, no full card rebuild flash.
- Use motion to guide action, not to decorate idle screens.

## Component Rules

### App Bar
- Use transparent or low-contrast surface.
- Large title on home and detail screens.
- Keep icons inside soft rounded containers on light backgrounds.
- Use subtitle support sparingly to anchor the editorial tone rather than repeat the title.

### Auction Card
- Large image with 4:5 ratio.
- Price block sits on the card, not below it.
- Show `LIVE`, `ENDING SOON`, or `BUY NOW` badge in the image corner.
- Countdown stays visible without entering the detail screen.
- Support fallback artwork gradients when the listing image is unavailable, but never inject fake product data.

### Buttons
- Primary action uses copper fill on light surfaces.
- Urgent action uses coral only for destructive or expiring states.
- Secondary action uses outline or tonal surface.
- Do not disable the primary button silently. Show a reason when action is unavailable.

### Tabs And Navigation
- Bottom navigation uses rounded indicator and heavy label contrast.
- Active tab should look anchored, not just tinted.
- Keep tab count at 5 as already defined.
- Navigation should sit on a dark floating plate rather than default Material chrome.

### Empty, Loading, And Error States
- Empty and unavailable states should look premium and intentional, not like debug scaffolds.
- Use localized product copy only. Never mention phases, Firestore, callables, or documentation files in release-facing UI.
- Pair every quiet state with either a real read path, a navigation recovery action, or a clear informational explanation.

### Form Inputs
- Use full-width fields with strong label and helper text.
- Image upload area uses a card with visible progress and failure retry.
- Step forms must show progress and draft-save status.

### Status Badges
- `LIVE`: charcoal background with inverse text.
- `ENDING SOON`: coral background with inverse text.
- `PAID` and `SETTLED`: sage background with dark text.
- `PENDING`: warm sand background with dark text.

## Screen Rules

### Login
- Hero image or abstract texture at top.
- One primary sign-in action per provider.
- Short trust message below actions.
- Do not show unsupported providers.

### Home
- Sections:
  - ending soon
  - hot auctions
  - curated category rows
- Use strong editorial header and dense card layout.
- Notification entry point stays visible.

### Search
- Sticky search field.
- Filter chips for category, price, end time, and buy now.
- Results can switch between large cards and compact list if needed.

### Auction Detail
- Image gallery at top.
- Sticky bottom action bar with bid and buy-now affordance area or a clearly explained browse fallback when the live action contract is unavailable.
- Price history chart uses restrained lines and no unnecessary chrome.
- Bid history should feel trustworthy and readable.
- Show seller summary and verification state above item description.

### Sell
- Multi-step flow:
  - category
  - item details
  - price and schedule
  - image upload
  - preview and publish
- Draft save must be visible and reliable.
- Validation errors appear inline and in a summary near submit.

### Activity And Orders
- Separate buyer and seller states clearly.
- Order cards show current status, next action, and deadline.
- Payment due cards must display countdown and amount together.

### Notifications
- Inbox rows show title, body, time, and next destination.
- Unread state should be visible without bright blue dots.

### My
- Show profile, verification states, seller grade summary, and settings.
- Keep settings secondary. Surface trust and selling readiness first.

## Accessibility Rules
- Maintain text contrast that meets accessibility guidelines.
- Support dynamic text without clipped buttons or broken cards.
- Touch targets stay at or above 44pt.
- Do not encode meaning with color alone. Pair color with label or icon.

# Auction Market Notification Specification

## Purpose
- Define the Android and iOS push-notification scope for the current app.
- Keep push delivery, Firestore inbox records, deep links, and user preferences aligned.
- Give agents one document to follow when implementing notification delivery and settings.

## Scope
- Platform push delivery uses Firebase Messaging for Android and iOS.
- Every supported push event must also create a Firestore inbox document under `notifications/{uid}/inbox/{notificationId}`.
- Push notifications are product events only. Marketing campaigns, bulk promotions, and silent sync jobs are out of scope for v1.

## Current App Flows Covered
- Auction browse, search, detail, bidding, auto-bid, and buy now.
- Order payment, shipment update, and receipt confirmation.
- Activity summary cards and inbox deep links.
- My and settings surfaces that will own notification preferences in Phase 4.

## Current Implementation Status
- Implemented now:
  - in-app notification preferences
  - OS permission visibility and permission request flow
  - device-token register, refresh, and deactivate lifecycle
  - backend persistence of active device tokens
  - Firestore inbox creation for supported product events
  - backend Firebase Admin Messaging dispatch for the product events that already create inbox entries
  - auto-bid ceiling reached inbox plus push event
  - buy-now completion and payment-failed-or-expired inbox plus push events
  - payment-due, shipment-reminder, and receipt-reminder inbox plus push events with deterministic reminder inbox ids
  - debug-only push probe trigger in both Firebase callable and Render dev HTTP
  - reminder candidate windows: payment due within 1 hour, shipment pending for 24 hours, and receipt pending for 24 hours, with bounded lookback reads
  - Android default notification-channel declaration and channel creation
  - foreground surfaced push handling through `onMessage`
  - push tap routing through `getInitialMessage` and `onMessageOpenedApp`
- Implemented for Android real-device dev testing:
  - real Firebase dev project connection
  - FCM registration-token retrieval and backend registration
  - Render dev backend path for token registration without emulator networking
- Not implemented yet:
  - final real-device verification of Android foreground, background, and terminated delivery behavior
- Deferred debt:
  - iOS APNs auth setup in Firebase
  - final iOS real-device push verification after APNs setup

## Delivery Preconditions
- Firebase Cloud Messaging is enabled for the active Firebase project.
- Android notification channels, default small icon, and app-level permission behavior are configured for the final package.
- iOS push capability, remote-notification capability, and APNs auth setup are configured for the final bundle.
- These project-level steps do not block planning, settings UI, token registration, backend event generation, or local foreground handling.
- Final real-device delivery verification is blocked until the project-level setup above is available.
- Current repo status:
  - Android permission request and token registration are wired.
  - iOS client-side token lifecycle code is wired, but real delivery remains blocked by APNs project setup.
  - Backend FCM fan-out is wired for inbox-backed product events, but final product-push behavior still depends on real device-token availability plus client presentation and tap-routing work.

## Supported Categories
- `auctionActivity`
  - Outbid.
  - Auto-bid ceiling reached and the user is no longer leading.
  - Auction won or buy-now order created.
- `orderPayment`
  - Payment due.
  - Payment reminder before expiry.
  - Payment confirmed.
  - Payment failed, cancelled, or expired.
- `shippingAndReceipt`
  - Shipment registered by seller.
  - Receipt confirmation reminder for buyer.
  - Receipt confirmed.
  - Settlement completed for seller.
- `system`
  - Account, policy, release-critical, or support notices that are not marketing.
  - Debug push probe for real-device delivery verification in `dev` only.

## Events To Support

### Buyer Events
- Outbid
  - Trigger: buyer loses highest-bidder status on a live auction.
  - Category: `auctionActivity`
  - Deep link: `app://auction/{auctionId}`
- Auto-bid ceiling reached
  - Trigger: buyer has an active auto-bid cap, is no longer leading, and would need to raise the ceiling to continue.
  - Category: `auctionActivity`
  - Deep link: `app://auction/{auctionId}`
- Auction won
  - Trigger: a live auction ends with the buyer as winner and an order enters `AWAITING_PAYMENT`.
  - Category: `orderPayment`
  - Deep link: `app://orders/{orderId}`
- Buy now completed
  - Trigger: buyer uses buy now and the order is created.
  - Category: `orderPayment`
  - Deep link: `app://orders/{orderId}`
- Payment reminder
  - Trigger: order remains `AWAITING_PAYMENT` and the payment deadline is approaching.
  - Category: `orderPayment`
  - Deep link: `app://orders/{orderId}`
- Payment failed or expired
  - Trigger: payment confirmation fails, the buyer cancels, or the unpaid-expiry scheduler closes the order.
  - Category: `orderPayment`
  - Deep link: `app://orders/{orderId}`
- Shipment registered
  - Trigger: seller records carrier and tracking information.
  - Category: `shippingAndReceipt`
  - Deep link: `app://orders/{orderId}`
- Receipt reminder
  - Trigger: order is `SHIPPED` and the buyer still needs to confirm receipt.
  - Category: `shippingAndReceipt`
  - Deep link: `app://orders/{orderId}`

### Seller Events
- New order awaiting payment
  - Trigger: auction ends with a winner or buy now creates an order.
  - Category: `orderPayment`
  - Deep link: `app://orders/{orderId}`
- Payment confirmed
  - Trigger: order moves to `PAID_ESCROW_HOLD`.
  - Category: `orderPayment`
  - Deep link: `app://orders/{orderId}`
- Shipment reminder
  - Trigger: order remains `PAID_ESCROW_HOLD` and the seller still needs to register shipment.
  - Category: `shippingAndReceipt`
  - Deep link: `app://orders/{orderId}`
- Receipt confirmed
  - Trigger: buyer confirms receipt.
  - Category: `shippingAndReceipt`
  - Deep link: `app://orders/{orderId}`
- Settlement completed
  - Trigger: order moves to `SETTLED`.
  - Category: `shippingAndReceipt`
  - Deep link: `app://orders/{orderId}`

### Debug Verification Event

- Debug push probe (dev only)
  - Trigger: authenticated caller invokes `sendDebugPushProbe` callable or `POST /api/notifications/debug/push-probe`.
  - Guard: only allowed when backend runtime `APP_ENV=dev`.
  - Category: `system`
  - Type: `SYSTEM_TEST`
  - Deep link: `app://notifications`

## Events Not In Scope For v1
- Marketing or promotion pushes.
- Seller alerts for every new bid while the auction is still active.
- Price-watch or saved-search alerts.
- Chat or social notifications.
- Silent push used only for cache refresh without user-visible inbox entries.

## Preference Model
- Global switch
  - One master on or off control for all app notifications.
- Category switches
  - `auctionActivity`
  - `orderPayment`
  - `shippingAndReceipt`
  - `system`
- Delivery rule
  - A push notification may be sent only when:
    - the OS permission is granted
    - the user has at least one active device token
    - the master switch is on
    - the relevant category switch is on
- Inbox rule
  - Inbox documents are still written even when push delivery is disabled, unless the product later defines a separate inbox mute rule.

## Settings Requirements
- Provide a settings screen reachable from the app bar and from the `My` area as a persistent fallback.
- Show the current OS push-permission state.
- When OS permission is denied, show a clear explanation and a way to open system settings.
- Expose:
  - master push switch
  - category switches
  - theme mode
  - system-language behavior
  - open-source licenses
  - app version
  - debug-only developer settings

## Payload Contract
- Current inbox documents written by backend Functions include:
  - `type`
  - `category`
  - `title`
  - `body`
  - `deeplink`
  - `entityType`
  - `entityId`
  - `isRead`
  - `createdAt`
- Current Phase 4 push payloads include:
  - `notificationId`
  - `type`
  - `category`
  - `deeplink`
  - `timestamp`
  - `entityType`
  - `entityId`
- Client routing must use the existing deep-link resolver and must not add a separate push-only routing format.

## Localization Contract
- Notification copy is centralized by event type with `ko` and `en` templates.
- Render dev server and Firebase Functions must both resolve inbox-backed event copy through those centralized templates instead of route-level hardcoded strings.
- Locale resolution priority is:
  - `users/{uid}.preferences.languageCode` when normalized to `ko` or `en`
  - device-token locale metadata under `users/{uid}/deviceTokens/{tokenId}` (latest active token first)
  - fallback `ko`
- Debug push-probe must reuse the same localized `title` and `body` generated for inbox writes so push and inbox copy stay aligned for the same event.

## Client Behavior
- Foreground
  - Show an in-app banner or surfaced message for supported push events.
  - Refresh the affected screen state if the current route already matches the pushed entity.
- Background or terminated
  - Open the app through the payload deep link.
  - Mark the related inbox item as read only after the user opens or explicitly consumes the message.
- Failure handling
  - If a push payload is missing a valid deep link, route to `/notifications` instead of failing.
- Current implementation note:
  - The current app now implements foreground surfaced messages plus open routing through `getInitialMessage` and `onMessageOpenedApp`.
  - Missing or unsupported push deeplinks fall back to `/notifications`.
  - Real-device verification is still required before treating this as final delivery behavior.

## Token Lifecycle
- Register the device token only after sign-in and permission grant.
- Refresh the stored token when Firebase Messaging rotates it.
- Mark the active token record inactive before sign-out completes.
- Keep token records scoped per signed-in user and per app installation.
- Store token records under `users/{uid}/deviceTokens/{tokenId}` as documented in `Documentation.md`.
- The mobile app must manage token lifecycle through backend callables instead of direct Firestore writes.
- Token records should capture at least:
  - `token: string`
  - `platform: "ANDROID" | "IOS"`
  - `appVersion: string`
  - `locale: string`
  - `timezone: string`
  - `permissionStatus: "AUTHORIZED" | "DENIED" | "PROVISIONAL" | "NOT_DETERMINED"`
  - `isActive: boolean`
  - `lastSeenAt: Timestamp`
  - `createdAt: Timestamp`
  - `updatedAt: Timestamp`

## Copy And UX Rules
- Titles and bodies must be short, actionable, and user-facing.
- Push copy and inbox copy may differ slightly, but both must describe the same event and next action.
- Notification copy must be localized for `ko` and `en`.
- Debug-only text such as raw event names, token ids, or payload dumps must never appear in release pushes.

## Testing Matrix
- Android foreground notification handling.
- Android background tap deep-link routing.
- iOS foreground presentation behavior.
- iOS background tap deep-link routing.
- Permission denied, provisional, and granted paths where the platform supports them.
- Global notification off.
- Category-specific off.
- Duplicate event protection between push delivery and inbox rendering.
- Missing or stale deep-link fallback to `/notifications`.

## Next Slice
- Run Android real-device verification for foreground, background, and terminated notification behavior using the current client routing and channel setup.
- Keep the client handling iOS-compatible so APNs setup later only unlocks delivery instead of requiring another app-architecture change.

## Implementation Notes For Agents
- Use this file together with `Plan.md`, `Documentation.md`, and `docs/Environment.md`.
- Do not add unsupported push categories or event types without updating this file first.
- Keep notification delivery provider-neutral at the product level. Firebase Messaging is the mobile delivery transport, but event semantics belong to this document.
- If project-level APNs or Firebase Messaging setup is still missing, finish the in-app settings, token lifecycle, inbox alignment, and backend event generation first, then record the remaining delivery-verification blocker.

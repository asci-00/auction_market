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

## Delivery Preconditions
- Firebase Cloud Messaging is enabled for the active Firebase project.
- Android notification channels, default small icon, and app-level permission behavior are configured for the final package.
- iOS push capability, remote-notification capability, and APNs auth setup are configured for the final bundle.
- These project-level steps do not block planning, settings UI, token registration, backend event generation, or local foreground handling.
- Final real-device delivery verification is blocked until the project-level setup above is available.

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
  - language
  - open-source licenses
  - app version
  - debug-only developer settings

## Payload Contract
- Each push payload must include:
  - `notificationId`
  - `category`
  - `deeplink`
  - `title`
  - `body`
  - `timestamp`
  - one related entity id such as `auctionId` or `orderId`
- Each inbox document must keep the same logical event identity as the push payload.
- Client routing must use the existing deep-link resolver and must not add a separate push-only routing format.

## Client Behavior
- Foreground
  - Show an in-app banner or surfaced message for supported push events.
  - Refresh the affected screen state if the current route already matches the pushed entity.
- Background or terminated
  - Open the app through the payload deep link.
  - Mark the related inbox item as read only after the user opens or explicitly consumes the message.
- Failure handling
  - If a push payload is missing a valid deep link, route to `/notifications` instead of failing.

## Token Lifecycle
- Register the device token only after sign-in and permission grant.
- Refresh the stored token when Firebase Messaging rotates it.
- Remove or deactivate the token on sign-out.
- Keep token records scoped per signed-in user and per app installation.
- Store token records under `users/{uid}/deviceTokens/{tokenId}` as documented in `Documentation.md`.
- Token records should capture at least:
  - user id
  - platform
  - token
  - app version
  - locale
  - timezone
  - last seen timestamp

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

## Implementation Notes For Agents
- Use this file together with `Plan.md`, `Documentation.md`, and `docs/Environment.md`.
- Do not add unsupported push categories or event types without updating this file first.
- Keep notification delivery provider-neutral at the product level. Firebase Messaging is the mobile delivery transport, but event semantics belong to this document.
- If project-level APNs or Firebase Messaging setup is still missing, finish the in-app settings, token lifecycle, inbox alignment, and backend event generation first, then record the remaining delivery-verification blocker.

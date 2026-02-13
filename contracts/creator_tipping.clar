(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-percentage (err u101))
(define-constant err-creator-not-found (err u102))
(define-constant err-no-recipients (err u103))
(define-constant err-insufficient-amount (err u104))
(define-constant err-transfer-failed (err u105))
(define-constant err-already-exists (err u106))
(define-constant err-unauthorized (err u107))
(define-constant err-recipient-limit (err u108))

(define-map creators
  principal
  {
    total-received: uint,
    tip-count: uint,
    active: bool
  }
)

(define-map creator-recipients
  { creator: principal, recipient-id: uint }
  {
    recipient: principal,
    percentage: uint,
    total-received: uint
  }
)

(define-map creator-recipient-count
  principal
  uint
)

(define-data-var platform-fee-percentage uint u5)
(define-data-var platform-fee-recipient principal contract-owner)
(define-data-var total-platform-fees uint u0)

(define-read-only (get-creator-info (creator principal))
  (ok (map-get? creators creator))
)

(define-read-only (get-recipient-info (creator principal) (recipient-id uint))
  (ok (map-get? creator-recipients { creator: creator, recipient-id: recipient-id }))
)

(define-read-only (get-recipient-count (creator principal))
  (ok (default-to u0 (map-get? creator-recipient-count creator)))
)

(define-read-only (get-platform-fee-percentage)
  (ok (var-get platform-fee-percentage))
)

(define-read-only (get-platform-fee-recipient)
  (ok (var-get platform-fee-recipient))
)

(define-read-only (get-total-platform-fees)
  (ok (var-get total-platform-fees))
)

(define-public (register-creator)
  (let
    (
      (existing-creator (map-get? creators tx-sender))
    )
    (asserts! (is-none existing-creator) err-already-exists)
    (ok (map-set creators tx-sender {
      total-received: u0,
      tip-count: u0,
      active: true
    }))
  )
)

(define-public (add-recipient (recipient principal) (percentage uint))
  (let
    (
      (creator-data (unwrap! (map-get? creators tx-sender) err-creator-not-found))
      (current-count (default-to u0 (map-get? creator-recipient-count tx-sender)))
      (new-count (+ current-count u1))
    )
    (asserts! (get active creator-data) err-unauthorized)
    (asserts! (< current-count u10) err-recipient-limit)
    (asserts! (and (> percentage u0) (<= percentage u100)) err-invalid-percentage)
    (map-set creator-recipients
      { creator: tx-sender, recipient-id: current-count }
      {
        recipient: recipient,
        percentage: percentage,
        total-received: u0
      }
    )
    (map-set creator-recipient-count tx-sender new-count)
    (ok new-count)
  )
)

(define-public (update-recipient-percentage (recipient-id uint) (new-percentage uint))
  (let
    (
      (creator-data (unwrap! (map-get? creators tx-sender) err-creator-not-found))
      (recipient-data (unwrap! (map-get? creator-recipients { creator: tx-sender, recipient-id: recipient-id }) err-creator-not-found))
    )
    (asserts! (get active creator-data) err-unauthorized)
    (asserts! (and (> new-percentage u0) (<= new-percentage u100)) err-invalid-percentage)
    (ok (map-set creator-recipients
      { creator: tx-sender, recipient-id: recipient-id }
      (merge recipient-data { percentage: new-percentage })
    ))
  )
)

(define-private (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee-percentage)) u100)
)

(define-private (distribute-to-recipient (creator principal) (recipient-id uint) (amount uint))
  (let
    (
      (recipient-data (unwrap! (map-get? creator-recipients { creator: creator, recipient-id: recipient-id }) err-creator-not-found))
      (recipient-address (get recipient recipient-data))
      (recipient-percentage (get percentage recipient-data))
      (recipient-amount (/ (* amount recipient-percentage) u100))
    )
    (if (> recipient-amount u0)
      (begin
        (unwrap! (stx-transfer? recipient-amount tx-sender recipient-address) err-transfer-failed)
        (map-set creator-recipients
          { creator: creator, recipient-id: recipient-id }
          (merge recipient-data { total-received: (+ (get total-received recipient-data) recipient-amount) })
        )
        (ok recipient-amount)
      )
      (ok u0)
    )
  )
)

(define-private (distribute-tips-internal (creator principal) (amount uint) (recipient-count uint))
  (let
    (
      (platform-fee (calculate-platform-fee amount))
      (distributable-amount (- amount platform-fee))
    )
    (if (> platform-fee u0)
      (unwrap! (stx-transfer? platform-fee tx-sender (var-get platform-fee-recipient)) err-transfer-failed)
      true
    )
    (var-set total-platform-fees (+ (var-get total-platform-fees) platform-fee))
    (fold distribute-recipient-fold
      (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9)
      { creator: creator, amount: distributable-amount, count: recipient-count, index: u0 }
    )
    (ok distributable-amount)
  )
)

(define-private (distribute-recipient-fold (recipient-id uint) (state { creator: principal, amount: uint, count: uint, index: uint }))
  (if (< (get index state) (get count state))
    (match (distribute-to-recipient (get creator state) recipient-id (get amount state))
      success (merge state { index: (+ (get index state) u1) })
      error state
    )
    state
  )
)

(define-public (send-tip (creator principal) (amount uint))
  (let
    (
      (creator-data (unwrap! (map-get? creators creator) err-creator-not-found))
      (recipient-count (default-to u0 (map-get? creator-recipient-count creator)))
    )
    (asserts! (get active creator-data) err-unauthorized)
    (asserts! (> recipient-count u0) err-no-recipients)
    (asserts! (> amount u0) err-insufficient-amount)
    (unwrap! (distribute-tips-internal creator amount recipient-count) err-transfer-failed)
    (map-set creators creator {
      total-received: (+ (get total-received creator-data) amount),
      tip-count: (+ (get tip-count creator-data) u1),
      active: true
    })
    (ok amount)
  )
)

(define-public (deactivate-creator)
  (let
    (
      (creator-data (unwrap! (map-get? creators tx-sender) err-creator-not-found))
    )
    (ok (map-set creators tx-sender
      (merge creator-data { active: false })
    ))
  )
)

(define-public (reactivate-creator)
  (let
    (
      (creator-data (unwrap! (map-get? creators tx-sender) err-creator-not-found))
    )
    (ok (map-set creators tx-sender
      (merge creator-data { active: true })
    ))
  )
)

(define-public (set-platform-fee-percentage (new-percentage uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-percentage u20) err-invalid-percentage)
    (ok (var-set platform-fee-percentage new-percentage))
  )
)

(define-public (set-platform-fee-recipient (new-recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set platform-fee-recipient new-recipient))
  )
)
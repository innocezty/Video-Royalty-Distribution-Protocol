(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-percentage (err u103))
(define-constant err-unauthorized (err u104))
(define-constant err-invalid-amount (err u105))
(define-constant err-transfer-failed (err u106))
(define-constant err-invalid-collaborators (err u107))
(define-constant err-no-balance (err u108))

(define-data-var video-nonce uint u0)

(define-map videos
  { video-id: uint }
  {
    creator: principal,
    title: (string-ascii 100),
    total-earned: uint,
    created-at: uint,
    active: bool
  }
)

(define-map collaborators
  { video-id: uint, collaborator: principal }
  {
    percentage: uint,
    total-withdrawn: uint
  }
)

(define-map video-balances
  { video-id: uint }
  { balance: uint }
)

(define-map video-collaborator-list
  { video-id: uint }
  { collaborator-count: uint }
)

(define-read-only (get-video (video-id uint))
  (map-get? videos { video-id: video-id })
)

(define-read-only (get-collaborator (video-id uint) (collaborator principal))
  (map-get? collaborators { video-id: video-id, collaborator: collaborator })
)

(define-read-only (get-video-balance (video-id uint))
  (default-to { balance: u0 } (map-get? video-balances { video-id: video-id }))
)

(define-read-only (get-pending-earnings (video-id uint) (collaborator principal))
  (let
    (
      (collab-data (unwrap! (get-collaborator video-id collaborator) (err err-not-found)))
      (video-bal (get balance (get-video-balance video-id)))
      (percentage (get percentage collab-data))
    )
    (ok (/ (* video-bal percentage) u10000))
  )
)

(define-read-only (get-video-nonce)
  (ok (var-get video-nonce))
)

(define-public (register-video
  (title (string-ascii 100))
  (collaborator-list (list 20 { addr: principal, pct: uint }))
)
  (let
    (
      (video-id (+ (var-get video-nonce) u1))
      (total-pct (fold + (map get-pct collaborator-list) u0))
    )
    (asserts! (is-eq total-pct u10000) err-invalid-percentage)
    (asserts! (> (len collaborator-list) u0) err-invalid-collaborators)
    
    (map-set videos
      { video-id: video-id }
      {
        creator: tx-sender,
        title: title,
        total-earned: u0,
        created-at: stacks-block-height,
        active: true
      }
    )
    
    (map-set video-balances
      { video-id: video-id }
      { balance: u0 }
    )
    
    (map-set video-collaborator-list
      { video-id: video-id }
      { collaborator-count: (len collaborator-list) }
    )
    
    (begin
      (fold register-collab-fold collaborator-list video-id)
      (var-set video-nonce video-id)
      (ok video-id)
    )
  )
)

(define-private (get-pct (collab { addr: principal, pct: uint }))
  (get pct collab)
)

(define-private (register-collab-fold (collab { addr: principal, pct: uint }) (vid uint))
  (begin
    (map-set collaborators
      { video-id: vid, collaborator: (get addr collab) }
      {
        percentage: (get pct collab),
        total-withdrawn: u0
      }
    )
    vid
  )
)

(define-public (deposit-streaming-revenue (video-id uint) (amount uint))
  (let
    (
      (video (unwrap! (get-video video-id) err-not-found))
      (current-balance (get balance (get-video-balance video-id)))
    )
    (asserts! (get active video) err-not-found)
    (asserts! (> amount u0) err-invalid-amount)
    
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    (map-set video-balances
      { video-id: video-id }
      { balance: (+ current-balance amount) }
    )
    
    (map-set videos
      { video-id: video-id }
      (merge video { total-earned: (+ (get total-earned video) amount) })
    )
    
    (ok true)
  )
)

(define-public (withdraw-earnings (video-id uint))
  (let
    (
      (collab-data (unwrap! (get-collaborator video-id tx-sender) err-unauthorized))
      (video-bal (get balance (get-video-balance video-id)))
      (percentage (get percentage collab-data))
      (earnings (/ (* video-bal percentage) u10000))
      (new-balance (- video-bal earnings))
      (recipient tx-sender)
    )
    (asserts! (> earnings u0) err-no-balance)
    
    (try! (as-contract (stx-transfer? earnings tx-sender recipient)))
    
    (map-set video-balances
      { video-id: video-id }
      { balance: new-balance }
    )
    
    (map-set collaborators
      { video-id: video-id, collaborator: recipient }
      (merge collab-data { total-withdrawn: (+ (get total-withdrawn collab-data) earnings) })
    )
    
    (ok earnings)
  )
)

(define-public (update-video-status (video-id uint) (status bool))
  (let
    (
      (video (unwrap! (get-video video-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get creator video)) err-unauthorized)
    
    (map-set videos
      { video-id: video-id }
      (merge video { active: status })
    )
    
    (ok true)
  )
)

(define-public (update-collaborator-percentage
  (video-id uint)
  (collaborator principal)
  (new-percentage uint)
)
  (let
    (
      (video (unwrap! (get-video video-id) err-not-found))
      (collab-data (unwrap! (get-collaborator video-id collaborator) err-not-found))
    )
    (asserts! (is-eq tx-sender (get creator video)) err-unauthorized)
    (asserts! (<= new-percentage u10000) err-invalid-percentage)
    
    (map-set collaborators
      { video-id: video-id, collaborator: collaborator }
      (merge collab-data { percentage: new-percentage })
    )
    
    (ok true)
  )
)

(define-read-only (get-total-earnings (video-id uint) (collaborator principal))
  (match (get-collaborator video-id collaborator)
    collab-data (ok (get total-withdrawn collab-data))
    err-not-found
  )
)

(define-read-only (get-video-stats (video-id uint))
  (match (get-video video-id)
    video (ok {
      total-earned: (get total-earned video),
      current-balance: (get balance (get-video-balance video-id)),
      active: (get active video),
      created-at: (get created-at video)
    })
    err-not-found
  )
)

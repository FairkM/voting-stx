;; ------------------------------------------------------------
;; voting-stx.clar
;; A lightweight STX-weighted voting system
;; Features:
;; - Submit proposals
;; - Vote with STX balance (1 STX = 1 vote)
;; - Track results (for, against, abstain)
;; ------------------------------------------------------------

(define-constant ERR_ALREADY_VOTED (err u100))
(define-constant ERR_VOTING_CLOSED (err u101))
(define-constant ERR_NO_SUCH_PROPOSAL (err u102))

(define-data-var proposal-count uint u0)

;; Proposal structure
(define-map proposals
  uint
  {
    proposer: principal,
    description: (string-ascii 200),
    start-block: uint,
    end-block: uint,
    for-votes: uint,
    against-votes: uint,
    abstain-votes: uint
  }
)

;; Track voters
(define-map votes
  {proposal-id: uint, voter: principal}
  bool
)

;; Parameters
(define-constant VOTING_PERIOD u50) ;; ~50 blocks

;; ----------------------------------
;; Submit a proposal
;; ----------------------------------
(define-public (submit-proposal (description (string-ascii 200)))
  (begin
    (asserts! (is-eq (len description) u200) (err u104))
    (let
      (
        (id (+ (var-get proposal-count) u1))
        (start u0)
        (end (+ u0 VOTING_PERIOD))
      )
      (var-set proposal-count id)
      (ok (map-set proposals id {
        proposer: tx-sender,
        description: description,
        start-block: start,
        end-block: end,
        for-votes: u0,
        against-votes: u0,
        abstain-votes: u0
      }))
    )
  )
)

;; ----------------------------------
;; Vote on a proposal
;; choice: 0 = against, 1 = for, 2 = abstain
;; ----------------------------------
(define-public (vote (proposal-id uint) (choice uint))
  (let
    (
      (proposal (unwrap! (map-get? proposals proposal-id) ERR_NO_SUCH_PROPOSAL))
      (weight (stx-get-balance tx-sender))
    )
    (asserts! (< u0 (get start-block proposal)) ERR_VOTING_CLOSED)
    (asserts! (> u0 (get end-block proposal)) ERR_VOTING_CLOSED)
    (asserts! (is-none (map-get? votes {proposal-id: proposal-id, voter: tx-sender})) ERR_ALREADY_VOTED)
    
    (map-set votes {proposal-id: proposal-id, voter: tx-sender} true)
    
    (ok 
      (if (is-eq choice u1)
          (map-set proposals proposal-id 
              (merge proposal {for-votes: (+ (get for-votes proposal) weight)}))
          (if (is-eq choice u0)
              (map-set proposals proposal-id 
                  (merge proposal {against-votes: (+ (get against-votes proposal) weight)}))
              (map-set proposals proposal-id 
                  (merge proposal {abstain-votes: (+ (get abstain-votes proposal) weight)}))
          )
      )
    )
  )
)

;; ----------------------------------
;; Read-only helpers
;; ----------------------------------

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-read-only (get-voted (proposal-id uint) (who principal))
  (map-get? votes {proposal-id: proposal-id, voter: who})
)

(define-read-only (get-proposal-count)
  (var-get proposal-count)
)

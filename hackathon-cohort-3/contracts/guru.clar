;; Guru
;; Smart Contract 
;;     Should register someone as a guru. 

;; constants
(define-constant ERR-GENERIC (err u100))
(define-constant ERR-PERMISSION-DENIED (err u101))
(define-constant ERR-GURU-NOT-REGISTERED (err u120))
(define-constant ERR-GURU-ALREADY-REGISTERED (err u121))

;; data maps and vars
(define-data-var guruIdNonce uint u10001)

(define-map guruByPrincipal
  principal
  uint
)

;; private functions
(define-private (get-or-create-guru-id (guru principal))

  (match (map-get? guruByPrincipal guru) 
          value 
          value  (let ((guruId (var-get guruIdNonce)))  
                      (map-set guruByPrincipal guru guruId)
                      (var-set guruIdNonce (+ u1 guruId))
                      guruId
                  )
  )
)

;; read-only functions
(define-read-only (get-guru-id (guru principal))

  (map-get? guruByPrincipal guru)
)

(define-read-only (get-next-guru-id)    

  (var-get guruIdNonce)
)

;; public functions
(define-public (register (guru principal))

  (begin 
            
      (asserts! (is-eq tx-sender guru) 
          ERR-PERMISSION-DENIED
      )

      (asserts! (is-none (map-get? guruByPrincipal guru)) ERR-GURU-ALREADY-REGISTERED)
      
      (ok (let ((guruId (get-or-create-guru-id guru)))
            guruId
      ))
  )
)


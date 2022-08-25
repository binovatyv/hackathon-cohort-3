;; Student
;; Smart Contract 
;;     Should register someone as a student. 

;; constants
(define-constant ERR-GENERIC (err u100))
(define-constant ERR-PERMISSION-DENIED (err u101))
(define-constant ERR-STUDENT-NOT-REGISTERED (err u120))
(define-constant ERR-STUDENT-ALREADY-REGISTERED (err u121))

;; data maps and vars
(define-data-var studentIdNonce uint u10001)

(define-map studentByPrincipal
  principal
  uint
)

;; private functions
(define-private (get-or-create-student-id (student principal))

  (match (map-get? studentByPrincipal student) 
          value 
          value  (let ((studentId (var-get studentIdNonce)))  
                      (map-set studentByPrincipal student studentId)
                      (var-set studentIdNonce (+ u1 studentId))
                      studentId
                  )
  )
)

;; read-only functions
(define-read-only (get-student-id (student principal))

  (map-get? studentByPrincipal student)
)

(define-read-only (get-next-student-id)    

  (var-get studentIdNonce)
)

;; public functions
(define-public (register (student principal))

  (begin 
            
      (asserts! (is-eq tx-sender student) 
          ERR-PERMISSION-DENIED
      )

      (asserts! (is-none (map-get? studentByPrincipal student)) ERR-STUDENT-ALREADY-REGISTERED)
      
      
      (ok (let ((studentId (get-or-create-student-id student)))
            studentId
      ))
  )
)

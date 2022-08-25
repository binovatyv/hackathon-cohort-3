;; Timely Support
;; Smart Contract      
;;     Should initialize a contract by student and escrow an amount.
;;     Should enable/cancel the transfer on success/failure of the support. 

;; constants
;;
(define-constant ERR-GENERIC (err u100))
(define-constant ERR-PERMISSION-DENIED (err u101))
(define-constant ERR-STUDENT-NOT-REGISTERED (err u120))
(define-constant ERR-GURU-NOT-REGISTERED (err u121))
(define-constant ERR-STATE (err u122))

(define-constant STATE-APPROVED u200)
(define-constant STATE-SUCCESS u201)
(define-constant STATE-FAILED u500)
(define-constant STATE-EXPIRED u501)

;; data maps and vars
;;
(define-data-var opportunityIdNonce uint u10001)

(define-map opportunity {id: uint} 
  {    
    student: principal,
    guru: principal,    
    honorarium: uint,    
    state: uint
  }
)

;; private functions
;;
(define-private (get-opportunity-id)
   (let ((opportunityId (var-get opportunityIdNonce)))  
                        (var-set opportunityIdNonce (+ u1 opportunityId)
        )
        opportunityId
   )  
)

(define-read-only (get-opportunity (id uint))
 
    (map-get? opportunity { id: id})
)

;; public functions
;;

(define-public (initialize (student principal) 
                           (guru principal) 
                           (honorarium uint)
               )
  (begin 

      (asserts! (> honorarium u0)
        ERR-GENERIC
      ) 

      (let ((studentId (contract-call? .student get-student-id student) ))

        (asserts! (not (is-none studentId)) 
          ERR-STUDENT-NOT-REGISTERED 
        )
        
        (asserts! (is-eq tx-sender student) 
          ERR-PERMISSION-DENIED
        )
      )

      (let ((guruId (contract-call? .guru get-guru-id guru) ))
          (asserts! (not (is-none guruId)) 
            ERR-GURU-NOT-REGISTERED 
          )
      )

      (ok (let ((opportunityId (get-opportunity-id)))
            (map-insert opportunity {id: opportunityId} 
                                    {student: student,
                                     guru: guru,
                                     honorarium: honorarium,     
                                     state: STATE-APPROVED    
                                    })      

            ;; escrow the honorarium
            (try! (stx-transfer? honorarium tx-sender (as-contract tx-sender)))         
            opportunityId
          ))
  )
)

(define-public (update-failed-opportunity (opportunityId uint))
  (begin 

    (asserts! (> opportunityId u0)
      ERR-GENERIC
    )

    (let ((optStudent (get student (map-get? opportunity {id: opportunityId}))))        
            (let (( student (unwrap-panic optStudent) ))
              (asserts! (is-eq tx-sender student) 
                ERR-PERMISSION-DENIED
              )
            )
    )

    (ok                 
      (let ((currentOpporutnity (unwrap-panic (map-get? opportunity {id: opportunityId} )) ))          
        (map-set opportunity {id: opportunityId} 
          (merge currentOpporutnity { state: STATE-FAILED})
        )   
      )  
    )
  )
)

(define-public (update-expired-opportunity (opportunityId uint))
  
  (begin 
    
    (asserts! (> opportunityId u0)
      ERR-GENERIC
    )

    (let ((optStudent (get student (map-get? opportunity {id: opportunityId}))))        
            (let (( student (unwrap-panic optStudent) ))
              (asserts! (is-eq tx-sender student) 
                ERR-PERMISSION-DENIED
              )
            )
    )

    (ok                 
      (let ((currentOpporutnity (unwrap-panic (map-get? opportunity {id: opportunityId} )) ))          
        (map-set opportunity {id: opportunityId} 
          (merge currentOpporutnity { state: STATE-EXPIRED})
        )   
      )  
    )
  )
)


(define-public (honor-my-teacher (opportunityId uint))
  (begin 
     
    (let ((optState (get state (map-get? opportunity {id: opportunityId} )) ))            
      (let (( state (unwrap-panic optState) ))
        (asserts! (is-eq state STATE-APPROVED) ERR-STATE )
      )          
    )

    (asserts! (> opportunityId u0)
      ERR-GENERIC
    ) 

    (ok       
      (let ((optGuru (get guru (map-get? opportunity {id: opportunityId}))))        
        (let ((optHonorarium (get honorarium (map-get? opportunity {id: opportunityId}))))
          (let (( guru (unwrap-panic optGuru) ))
            (let (( honorarium (unwrap-panic optHonorarium) ))

              (let ((optStudent (get student (map-get? opportunity {id: opportunityId}))))        
                (let (( student (unwrap-panic optStudent) ))
                  (asserts! (is-eq tx-sender student) 
                        ERR-PERMISSION-DENIED
                  )
                )
              )
              
              (try! (as-contract (stx-transfer? honorarium tx-sender guru)))         

              (let ((currentOpporutnity (unwrap-panic (map-get? opportunity {id: opportunityId} )) ))          
                (map-set opportunity {id: opportunityId} 
                  (merge currentOpporutnity { state: STATE-SUCCESS})
                )   
              )
            )
          )           
        )
      )                                
    )

  )
)
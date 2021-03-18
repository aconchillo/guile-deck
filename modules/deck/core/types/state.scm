(define-module (deck core types state)
  #:use-module (oop goops)
  #:use-module (deck core types matrix-id)
  #:export (<state>
            state?
            state-account-data
            state-device-lists
            state-device-one-time-keys-count
            state-next-batch
            state-presense
            state-presense-events
            state-presense-events-available?
            state-rooms
            state-rooms-invite
            state-rooms-invite-available?
            state-rooms-join
            state-rooms-join-available?
            state-rooms-leave
            state-rooms-leave-available?
            state-rooms-any-available?
            alist->state

            <room-update>
            list->room-update
            room-update-id
            room-update-content))


;; See <https://matrix.org/docs/api/client-server/#!/Room32participation/sync>
(define-class <state> ()
  ;; The global private data created by this user.
  ;;
  ;; <list> of <matrix-event>
  (account-data
   #:init-keyword #:account-data
   #:getter       state-account-data)

  ;; Information on end-to-end device updates.
  (device-lists
   #:init-keyword #:device-lists
   #:getter       state-device-lists)

  ;; Information on end-to-end encryption keys.
  (device-one-time-keys-count
   #:init-keyword #:device-one-time-keys-count
   #:getter        state-device-one-time-keys-count)

  ;; REQUIRED. The batch token to supply in the since param of the next /sync
  ;; request.
  ;;
  ;; <string>
  (next-batch
   #:init-keyword  #:next-batch
   #:getter        state-next-batch)

  ;; The updates to the presence status of other users.
  ;;
  ;; <list> of <matrix-event>
  (presense
   #:init-keyword  #:presense
   #:getter        state-presense)

  ;; Updates to rooms.
  (rooms
   #:init-keyword  #:rooms
   #:getter        state-rooms)

   ;; Information on the send-to-device messages for the client device.
  (to-device
   #:init-keyword #:to-device
   #:getter       state-to-device))



;; This class describes an update to a room.
(define-class <room-update> ()
  ;; ID of the room.
  ;;
  ;; <matrix-id>
  (id
   #:init-keyword #:id
   #:getter       room-update-id)

  ;; The content of the update.
  ;;
  ;; <list>
  (content
   #:init-keyword #:content
   #:getter       room-update-content))

(define-method (display (update <room-update>) (port <port>))
  (format port "#<room-update ~a ~a>"
          (room-update-id update)
          (number->string (object-address pipe) 16)))

(define-method (write (update <room-update>) (port <port>))
  (display update port))

(define-method (display (update <room-update>))
  (next-method)
  (display update (current-output-port)))

(define-method (write (update <room-update>))
  (next-method)
  (display update (current-output-port)))

;; Convert a list LST from a "sync" response to a room update.
(define-method (list->room-update (lst <list>))
  (make <room-update>
    #:id      (string->matrix-id (car lst))
    #:content (cdr lst)))

(define-method (equal? (obj1 <room-update>) (obj2 <room-update>))
  (and (equal? (room-update-id obj1) (room-update-id obj2))
       (equal? (room-update-content obj1) (room-update-content obj2))))



(define-method (state? object)
  (is-a? <state> object))



(define-method (display (state <state>) (port <port>))
  (format port "#<state next-batch: ~a ~a>"
          (state-next-batch state)
          (number->string (object-address pipe) 16)))

(define-method (write (state <state>) (port <port>))
  (display state port))

(define-method (display (state <state>))
  (next-method)
  (display state (current-output-port)))

(define-method (write (state <state>))
  (next-method)
  (display state (current-output-port)))



(define-method (equal? (s1 <state>) (s2 <state>))
  (and (equal? (state-account-data               s1) (state-account-data s2))
       (equal? (state-device-lists               s1) (state-device-lists s2))
       (equal? (state-device-one-time-keys-count s1)
               (state-device-one-time-keys-count s2))
       (equal? (state-next-batch                 s1) (state-next-batch s2))
       (equal? (state-presense                   s1) (state-presense s2))
       (equal? (state-rooms                      s1) (state-rooms s2))
       (equal? (state-to-device                  s1) (state-to-device s2))))



(define-method (state-rooms-invite (state <state>))
  (assoc-ref (state-rooms state) "invite"))

(define-method (state-rooms-invite-available? (state <state>))
  (> (length (state-rooms-invite state)) 0))

(define-method (state-rooms-join (state <state>))
  (assoc-ref (state-rooms state) "join"))

(define-method (state-rooms-join-available? (state <state>))
  (> (length (state-rooms-join state)) 0))

(define-method (state-rooms-leave (state <state>))
  (assoc-ref (state-rooms state) "leave"))

(define-method (state-rooms-leave-available? (state <state>))
  (> (length (state-rooms-leave state)) 0))

(define-method (state-rooms-any-available? (state <state>))
  (or (state-rooms-invite-available? state)
      (state-rooms-join-available? state)
      (state-rooms-leave-available? state)))

(define-method (state-presense-events (state <state>))
  (assoc-ref (state-presense state) "events"))

(define-method (state-presense-events-available? (state <state>))
  (> (vector-length (state-presense-events state)) 0))



(define-method (alist->state (alist <list>))
  (let* ((rooms-updates (assoc-ref alist "rooms"))
         (invite        (assoc-ref rooms-updates "invite"))
         (join          (assoc-ref rooms-updates "join"))
         (leave         (assoc-ref rooms-updates "leave")))
    (make <state>
      #:account-data (assoc-ref alist "account_data")
      #:device-lists (assoc-ref alist "device_lists")
      #:device-one-time-keys-count (assoc-ref alist "device_one_time_keys_count")
      #:next-batch   (assoc-ref alist "next_batch")
      #:presense     (assoc-ref alist "presence")
      #:rooms        `(,(if (null? invite)
                            (cons "invite" '())
                            (cons "invite" (map list->room-update invite)))
                       ,(if (null? join)
                            (cons "join" '())
                            (cons "join" (map list->room-update join)))
                       ,(if (null? leave)
                            (cons "leave" '())
                            (cons "leave" (map list->room-update leave))))
      #:to-device    (assoc-ref alist "to_device"))))


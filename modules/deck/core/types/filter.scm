;; Description:
;;   <https://matrix.org/docs/api/client-server/#!/Room32participation/defineFilter>

(define-module (deck core types filter)
  #:use-module (oop goops)
  #:export (<filter>
            filter?
            ;; alist->filter

            <event-filter>
            event-filter?
            event-filter->alist
            ;; alist->event-filter

            <room-filter>
            room-filter?
            room-filter->alist
            ;; alist->room-filter

            <state-filter>
            state-filter?
            ))

(define-syntax cons-or-null
  (syntax-rules ()
    ((_ key value)
     (if value
         (cons key value)
         '()))
    ((_ key value converter)
     (if value
         (cons key (converter value))
         '()))))

(define (make-sieved-list . elements)
  (delete '() elements))


(define-class <event-filter> ()
  ;; <number>
  (limit
   #:init-value   #f
   #:init-keyword #:limit
   #:getter       event-filter-limit)

  ;; <list> of <string>
  (not-senders
   #:init-value   #f
   #:init-keyword #:not-senders
   #:getter       event-filter-not-senders)

  ;; <list> of <string>
  (not-types
   #:init-value   #f
   #:init-keyword #:not-types
   #:getter       event-filter-not-types)

  ;; <list> of <string>
  (senders
   #:init-value   #f
   #:init-keyword #:senders
   #:getter       event-filter-senders)

  ;; <list> of <string>
  (types
   #:init-value   #f
   #:init-keyword #:types
   #:getter       event-filter-types))

(define-method (event-filter? object)
  (is-a? object <event-filter>))

;; Convert a FILTER instance to an association list suitable for using with
;; the Matrix API.
(define-method (event-filter->alist (filter <event-filter>))
  (make-sieved-list
   (cons-or-null "limit"       (event-filter-limit filter))
   (cons-or-null "not_senders" (event-filter-not-senders filter) list->vector)
   (cons-or-null "not_types"   (event-filter-not-types   filter) list->vector)
   (cons-or-null "senders"     (event-filter-senders     filter) list->vector)
   (cons-or-null "types"       (event-filter-types       filter) list->vector)))


(define-class <room-filter> ()
  ;; <event-filter>
  (account-data
   #:init-value   #f
   #:init-keyword #:account-data
   #:getter       room-filter-account-data)

  ;; <event-filter>
  (ephemeral
   #:init-value   #f
   #:init-keyword #:ephemeral
   #:getter       room-filter-ephemeral)

  ;; <boolean>
  (include-leave?
   #:init-value   #f
   #:init-keyword #:include-leave?
   #:getter       room-filter-include-leave?)

  ;; <list> of <string>
  (not-rooms
   #:init-value   #f
   #:init-keyword #:not-rooms
   #:getter       room-filter-not-rooms)

  (rooms
   #:init-value   #f
   #:init-keyword #:rooms
   #:getter       room-filter-rooms)

  ;; <state-filter>
  (state
   #:init-value   #f
   #:init-keyword #:state
   #:getter       room-filter-state)

  (timeline
   #:init-value   #f
   #:init-keyword #:state
   #:getter       room-filter-timeline))

(define-method (room-filter? object)
  (is-a? object <room-filter>))

;; Convert a ROOM-FILTER instance to an association list suitable for using
;; with the Matrix API.
(define-method (room-filter->alist (room-filter <room-filter>))
  (make-sieved-list
   (cons-or-null "account_data" (room-filter-account-data room-filter)
                 event-filter->alist)
   (cons-or-null "ephemeral" (room-filter-ephemeral room-filter)
                 event-filter->alist)
   (cons-or-null "include_leave" (room-filter-include-leave? room-filter))
   (cons-or-null "not_rooms" (room-filter-not-rooms room-filter)
                 list->vector)
   (cons-or-null "rooms" (room-filter-rooms room-filter)
                 list->vector)
   ;; TODO:
   ;; (cons-or-null "state" (room-filter-state room-filter)
   ;;               state-filter->alist)
   (cons-or-null "timeline" (room-filter-timeline room-filter)
                 event-filter->alist)))



(define-class <state-filter> ()
  ;; <number>
  (limit
   #:init-value   #f
   #:init-keyword #:limit
   #:getter       state-filter-limit)

  ;; <list> of <string>
  (not-senders
   #:init-value   #f
   #:init-keyword #:not-senders
   #:getter       state-filter-not-senders)

  ;; <list> of <string>
  (not-types
   #:init-value   #f
   #:init-keyword #:not-types
   #:getter       state-filter-not-types)

  ;; <list> of <string>
  (senders
   #:init-value   #f
   #:init-keyword #:senders
   #:getter       state-filter-senders)

  ;; <list> of <string>
  (types
   #:init-value   #f
   #:init-keyword #:types
   #:getter       state-filter-types)

  ;; <boolean>
  (contains-url?
   #:init-value   #f
   #:init-keyword #:contains-url
   #:getter       state-filter-contains-url?)

  ;; <boolean>
  (include-redundant-members?
   #:init-value   #f
   #:init-keyword #:include-redundant-members?
   #:getter       state-filter-include-redundant-members?)

  ;; <boolean>
  (lazy-load-members?
   #:init-value   #f
   #:init-keyword #:lazy-load-members?
   #:getter       state-filter-lazy-load-members?)

  ;; <list> of <string>
  (not-rooms
   #:init-value   #f
   #:init-keyword #:not-rooms
   #:getter       state-filter-not-rooms)

  (rooms
   #:init-value   #f
   #:init-keyword #:rooms
   #:getter       state-filter-rooms))

(define-method (state-filter? object)
  (is-a? object <state-filter>))


(define-class <filter> ()
  ;; The user account data that isn't associated with rooms to include.
  ;;
  ;; <event-filter>
  (account-data
   #:init-value   #f
   #:init-keyword #:account-data
   #:getter       filter-account-data)

  ;; List of event fields to include. If this list is absent then all fields
  ;; are included. The entries may include '.' characters to indicate
  ;; sub-fields. So ['content.body'] will include the 'body' field of the
  ;; 'content' object. A literal '.' character in a field name may be escaped
  ;; using a '\'. A server may include more fields than were requested.
  ;;
  ;; <list> of <string>
  (event-fields
   #:init-value   #f
   #:init-keyword #:event-fields
   #:getter       filter-event-fields)

  ;; The format to use for events. 'client' will return the events in a format
  ;; suitable for clients. 'federation' will return the raw event as received
  ;; over federation. The default is 'client'. = ['client', 'federation'],
  ;;
  ;; <symbol>
  (event-format
   #:init-value   #f
   #:init-keyword #:event-format
   #:getter       filter-event-format)

  ;; The presence updates to include.
  ;;
  ;; <event-filter>
  (presence
   #:init-value   #f
   #:init-keyword #:presense
   #:getter       filter-presence)

  ;; Filters to be applied to room data.
  ;;
  ;; <room-filter>
  (room
   #:init-value   #f
   #:init-keyword #:room
   #:getter       filter-room))



(define-method (filter? object)
  (is-a? object <filter>))



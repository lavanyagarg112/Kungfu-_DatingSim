extensions [table]

turtles-own
[
  partner   ;;  the turtle that is our partner, or "nobody" if we don't have one
  meet-table
]

;;  This procedure will setup 150 turtles, by randomly placing them around the world.
to setup
  clear-all
  create-turtles 100
  [
    ;;  turtles get random coordinates, and they are
    ;;  light gray (to show they don't have partners yet).
    setxy random-xcor random-ycor
    set color gray + 2
    set partner nobody
    set meet-table table:make ;; each turtle is initialized with its own table
  ]
  reset-ticks
end

to update-memory
  let nearby-turtles other turtles-here
  foreach (sort nearby-turtles) [ other-turtle ->
    let other-id [who] of other-turtle  ;; Get the ID of the other turtle

    ;; Check if we already met this turtle, else initialize with 0
    if not table:has-key? meet-table other-id [
      table:put meet-table other-id 0
    ]

    ;; Increment the count for this specific turtle
    table:put meet-table other-id (table:get meet-table other-id + 1)
  ]
end


to find-partners
  let singles turtles with [partner = nobody]
  if not any? singles [ stop ]
  
  ;; Only turtles without a partner move
  ask singles [
    lt random 40
    rt random 40
    fd 1
  ]
  
  ask turtles [
    update-memory
    let my-meet-table meet-table
    if (partner = nobody) and (any? other turtles-here with [
          partner = nobody and 
          (ifelse-value table:has-key? my-meet-table [who] of self
             [ table:get my-meet-table [who] of self ]
             [ 0 ]) >= meet-threshold
    ]) [
      let candidate one-of other turtles-here with [
          partner = nobody and 
          (ifelse-value table:has-key? my-meet-table [who] of self
             [ table:get my-meet-table [who] of self ]
             [ 0 ]) >= 3
      ]
      set partner candidate
      set color red
      update-memory
      ask candidate [
        set partner myself
        set color red
      ]
    ]
  ]
  
  if any? turtles with [partner != nobody and [partner] of partner != self] [
    ask one-of turtles with [[partner] of partner != self] [
      user-message (word "Oops! Partner mismatch: " self " is not partnered to " myself)
    ]
    stop
  ]
  tick
end



; Public Domain:
; To the extent possible under law, Uri Wilensky has waived all
; copyright and related or neighboring rights to this model.
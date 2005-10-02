! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: arrays generic hashtables kernel lists math
namespaces sequences styles ;

SYMBOL: origin

@{ 0 0 0 }@ origin global set-hash

TUPLE: rect loc dim ;

M: array rect-loc ;

M: array rect-dim drop @{ 0 0 0 }@ ;

: rect-bounds ( rect -- loc dim ) dup rect-loc swap rect-dim ;

: rect-extent ( rect -- loc dim ) rect-bounds over v+ ;

: >absolute ( rect -- rect )
    rect-bounds >r origin get v+ r> <rect> ;

: |v-| ( vec vec -- vec ) v- [ 0 max ] map ;

: (intersect) ( rect rect -- array array )
    [ rect-extent ] 2apply swapd vmin >r vmax r> ;

: intersect ( rect rect -- rect )
    (intersect) dupd swap |v-| <rect> ;

: intersects? ( rect/point rect -- ? )
    (intersect) v- [ 0 <= ] all? ;

! A gadget is a rectangle, a paint, a mapping of gestures to
! actions, and a reference to the gadget's parent.
TUPLE: gadget
    paint gestures visible? relayout? root?
    parent children ;

: show-gadget t swap set-gadget-visible? ;

: hide-gadget f swap set-gadget-visible? ;

M: gadget = eq? ;

: gadget-child gadget-children first ;

C: gadget ( -- gadget )
    @{ 0 0 0 }@ dup <rect> over set-delegate dup show-gadget ;

: gadget-delegate ( tuple -- ) <gadget> swap set-delegate ;

GENERIC: user-input* ( ch gadget -- ? )

M: gadget user-input* 2drop t ;

: invalidate ( gadget -- ) t swap set-gadget-relayout? ;

DEFER: add-invalid

GENERIC: children-on ( rect/point gadget -- list )

M: gadget children-on ( rect/point gadget -- list )
    nip gadget-children ;

: inside? ( bounds gadget -- ? )
    dup gadget-visible?
    [ >absolute intersects? ] [ 2drop f ] if ;

: pick-up-list ( rect/point gadget -- gadget/f )
    dupd children-on reverse-slice [ inside? ] find-with nip ;

: translate ( rect/point -- )
    rect-loc origin [ v+ ] change ;

: (pick-up) ( rect/point gadget -- gadget )
    2dup inside? [
        dup translate 2dup pick-up-list dup
        [ nip (pick-up) ] [ rot 2drop ] if
    ] [ 2drop f ] if ;

: pick-up ( rect/point gadget -- gadget )
    [ (pick-up) ] with-scope ;

: max-dim ( dims -- dim ) @{ 0 0 0 }@ [ vmax ] reduce ;

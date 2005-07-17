! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel kernel-internals lists math strings
vectors ;

! A reversal of an underlying sequence.
TUPLE: reversed ;
C: reversed [ set-delegate ] keep ;
: reversed@ delegate [ length swap - 1 - ] keep ;
M: reversed nth ( n seq -- elt ) reversed@ nth ;
M: reversed set-nth ( elt n seq -- ) reversed@ set-nth ;

! A repeated sequence is the same element n times.
TUPLE: repeated length object ;
M: repeated length repeated-length ;
M: repeated nth nip repeated-object ;

! Combinators
M: object each ( seq quot -- )
    swap dup length [
        [ swap nth swap call ] 3keep
    ] repeat 2drop ;

: change-nth ( seq i quot -- )
    pick pick >r >r >r swap nth r> call r> r> swap set-nth ;
    inline

: (nmap) ( seq i quot -- )
    pick length pick <= [
        3drop
    ] [
        [ change-nth ] 3keep >r 1 + r> (nmap)
    ] ifte ; inline

: nmap ( seq quot -- | quot: elt -- elt )
    #! Destructive on seq.
    0 swap (nmap) ; inline

M: object map ( seq quot -- seq | quot: elt -- elt )
    swap [ swap nmap ] immutable ;

: (2nmap) ( seq1 seq2 i quot -- elt3 )
    pick pick >r >r >r 2nth r> call r> r> swap set-nth ; inline

: 2nmap ( seq1 seq2 quot -- | quot: elt1 elt2 -- elt3 )
    #! Destructive on seq2.
    over length [
        [ >r 3dup r> swap (2nmap) ] keep
    ] repeat 3drop ; inline

M: object 2map ( seq1 seq2 quot -- seq | quot: elt1 elt2 -- elt3 )
    swap [ swap 2nmap ] immutable ;

M: object find* ( i seq quot -- i elt  )
    pick pick length >= [
        3drop -1 f
    ] [
        3dup >r >r >r >r nth r> call [
            r> dup r> nth r> drop
        ] [
            r> 1 + r> r> find*
        ] ifte
    ] ifte ;

M: object find ( seq quot -- i elt )
    0 -rot find* ;

: contains? ( seq quot -- ? )
    find drop -1 > ; inline

: contains-with? ( obj seq quot -- ? )
    find-with drop -1 > ; inline

: all? ( seq quot -- ? )
    #! ForAll(P in X) <==> !Exists(!P in X)
    swap [ swap call not ] contains-with? not ; inline

: all-with? ( obj list pred -- ? )
    swap [ with rot ] all? 2nip ; inline

: subset ( seq quot -- seq | quot: elt -- ? )
    #! all elements for which the quotation returned a value
    #! other than f are collected in a new list.
    swap [
        dup length <vector> -rot [
            rot >r 2dup >r >r swap call [
                r> r> r> [ push ] keep swap
            ] [
                r> r> drop r> swap
            ] ifte
        ] each drop
    ] keep like ; inline

: subset-with ( obj list quot -- list )
    swap [ with rot ] subset 2nip ; inline

: fiber? ( seq quot -- ? | quot: elt elt -- ? )
    #! Tests if all elements are equivalent under the relation.
    over empty?
    [ >r [ first ] keep r> all-with? ] [ 2drop t ] ifte ; inline

! Operations
M: object thaw clone ;

M: object like drop ;

M: object empty? ( seq -- ? ) length 0 = ;

: (>list) ( n i seq -- list )
    pick pick <= [
        3drop [ ]
    ] [
        2dup nth >r >r 1 + r> (>list) r> swons
    ] ifte ;

M: object >list ( seq -- list ) dup length 0 rot (>list) ;

: index* ( obj i seq -- n )
    #! The index of the object in the sequence, starting from i.
    [ = ] find-with* drop ;

: index ( obj seq -- n )
    #! The index of the object in the sequence.
    [ = ] find-with drop ;

: member? ( obj seq -- ? )
    #! Tests for membership using =.
    [ = ] contains-with? ;

: memq? ( obj seq -- ? )
    #! Tests for membership using eq?
    [ eq? ] contains-with? ;

: remove ( obj list -- list )
    #! Remove all occurrences of objects equal to this one from
    #! the list.
    [ = not ] subset-with ;

: remq ( obj list -- list )
    #! Remove all occurrences of the object from the list.
    [ eq? not ] subset-with ;

: nappend ( s1 s2 -- )
    #! Destructively append s2 to s1.
    [ over push ] each drop ;

: append ( s1 s2 -- s1+s2 )
    #! Outputs a new sequence of the same type as s1.
    swap [ swap nappend ] immutable ;

: add ( seq elt -- seq )
    #! Outputs a new sequence of the same type as seq.
    unit append ;

: append3 ( s1 s2 s3 -- s1+s2+s3 )
    #! Return a new sequence of the same type as s1.
    rot [ [ rot nappend ] keep swap nappend ] immutable ;

M: f concat ;

M: cons concat
    unswons [ swap [ nappend ] each-with ] immutable ;

M: object concat
    >list concat ;

M: object peek ( sequence -- element )
    #! Get value at end of sequence.
    dup length 1 - swap nth ;

: pop ( sequence -- element )
    #! Get value at end of sequence and remove it.
    dup peek >r dup length 1 - swap set-length r> ;

: push-new ( elt seq -- )
    2dup member? [ 2drop ] [ push ] ifte ;

: prune ( seq -- seq )
    [
        dup length <vector> swap [ over push-new ] each
    ] keep like ;

: >pop> ( stack -- stack ) dup pop drop ;

M: object reverse ( seq -- seq ) [ <reversed> ] keep like ;

! Set theoretic operations
: seq-intersect ( seq seq -- seq )
    #! Make a list of elements that occur in both lists.
    [ swap member? ] subset-with ;

: seq-diff ( list1 list2 -- list )
    #! Make a list of elements that occur in list2 but not
    #! list1.
    [ swap member? not ] subset-with ;

: seq-diffq ( list1 list2 -- list )
    #! Make a list of elements that occur in list2 but not
    #! list1.
    [ swap memq? not ] subset-with ;

: contained? ( list1 list2 -- ? )
    #! Is every element of list1 in list2?
    swap [ swap member? ] all-with? ;

IN: kernel

: depth ( -- n )
    #! Push the number of elements on the datastack.
    datastack length ;

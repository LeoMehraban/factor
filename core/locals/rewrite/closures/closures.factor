! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel locals.rewrite.point-free
locals.rewrite.sugar locals.types macros.expander make
quotations sequences sets words ;
IN: locals.rewrite.closures

! Step 2: identify free variables and make them into explicit
! parameters of lambdas which are curried on

GENERIC: rewrite-closures* ( obj -- )

: (rewrite-closures) ( form -- form' )
    [ [ rewrite-closures* ] each ] [ ] make ;

: rewrite-closures ( form -- form' )
    expand-macros rewrite-sugar (rewrite-closures) point-free ;

GENERIC: defs-vars* ( seq form -- seq' )

: defs-vars ( form -- vars ) { } [ defs-vars* ] reduce members ;

M: def defs-vars* local>> unquote suffix ;

M: quotation defs-vars* [ defs-vars* ] each ;

M: fryable defs-vars* quot>> defs-vars* ;

M: object defs-vars* drop ;

GENERIC: uses-vars* ( seq form -- seq' )

: uses-vars ( form -- vars ) { } [ uses-vars* ] reduce members ;

M: local-writer uses-vars* "local-reader" word-prop suffix ;

M: lexical uses-vars* suffix ;

M: quote uses-vars* local>> uses-vars* ;

M: object uses-vars* drop ;

M: quotation uses-vars* [ uses-vars* ] each ;

M: fryable uses-vars* quot>> uses-vars* ;

: free-vars ( form -- seq )
    [ uses-vars ] [ defs-vars ] bi diff ;

M: callable rewrite-closures*
    ! Turn free variables into bound variables, curry them
    ! onto the body
    dup free-vars [ <quote> ] map
    [ % ]
    [ var-defs prepend (rewrite-closures) point-free , ]
    [ length \ curry <repetition> % ]
    tri ;

! almost good
M: fryable rewrite-closures* quot>> fry rewrite-closures* \ call , ;

! M: fryable rewrite-closures* B quot>> fry (rewrite-closures) % ;

! M: fryable rewrite-closures* B quot>> fry rewrite-closures* ;

![[
M: fryable rewrite-closures*
    B
    quot>> [
        dup array? [ fry-to-lambda ] when
    ] map
    fry rewrite-closures* ;
    ! dup array? [ fry-to-lambda ] [ fry ] if rewrite-closures* ;
! M: fryable rewrite-closures* quot>> fry % \ call , ;
]]

M: object rewrite-closures* , ;

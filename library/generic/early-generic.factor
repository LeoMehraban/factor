! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors kernel kernel-internals ;

DEFER: standard-combination

DEFER: math-combination

: delegate ( object -- delegate )
    dup tuple? [ 3 slot ] [ drop f ] if ;

GENERIC: set-delegate ( delegate obj -- )
M: tuple set-delegate 3 set-slot ;

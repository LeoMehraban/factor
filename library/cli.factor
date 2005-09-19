! Copyright (C) 2003, 2004 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: command-line
USING: errors io kernel kernel-internals lists namespaces parser
sequences strings ;

! This file is run as the last stage of boot.factor; it relies
! on all other words already being defined.

: ?run-file ( file -- )
    dup exists? [ [ dup run-file ] try drop ] [ drop ] ifte ;

: run-user-init ( -- )
    #! Run user init file if it exists
    "user-init" get
    [ "~" get "/.factor-rc" append ?run-file ] when ;

: set-path ( value list -- )
    unswons over [ nest [ set-path ] bind ] [ nip set ] ifte ;

: cli-var-param ( name value -- ) swap ":" split set-path ;

: cli-bool-param ( name -- ) "no-" ?head not swap set ;

: cli-param ( param -- )
    #! Handle a command-line argument starting with '-' by
    #! setting that variable to t, or if the argument is
    #! prefixed with 'no-', setting the variable to f.
    #!
    #! Arguments containing = are handled differently; they
    #! set the object path.
    "=" split1 [ cli-var-param ] [ cli-bool-param ] ifte* ;

: cli-arg ( argument -- argument )
    #! Handle a command-line argument. If the argument was
    #! consumed, returns f. Otherwise returns the argument.
    #! Parameters that start with + are runtime parameters.
    dup empty? [
        "-" ?head [ cli-param f ] when
        dup [ "+" ?head [ drop f ] when ] when
    ] unless ;

: parse-switches ( args -- args )
    [ cli-arg ] map ;

: run-files ( args -- )
    [ [ run-file ] when* ] each ;

: cli-args ( -- args ) 10 getenv ;

: default-cli-args
    #! Some flags are *on* by default, unless user specifies
    #! -no-<flag> CLI switch
    "user-init" on
    "compile" on
    "null-stdio" off
    os "win32" = "ui" "tty" ? "shell" set ;

: parse-command-line ( -- )
    #! Parse command line arguments.
    #! The first CLI arg is the image name.
    cli-args unswons "image" set parse-switches run-files ;

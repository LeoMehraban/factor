! Copyright (C) 2022-2023 nomennescio
! See https://factorcode.org/license.txt for BSD license.
! can be run as : factor -run=binary.image.factor.compressor

USING: accessors classes.struct byte-arrays compression.zstd io io.encodings.binary io.files kernel kernel.private locals math sequences system tools.image-analyzer tools.image-analyzer.vm vm ;
IN: binary.image.factor.compressor

TUPLE: image
  { header image-header }
  { data byte-array }
  { code byte-array } ;

! converts to compression compatible header if needed
: >compression-header ( headerv4 -- headerv4+ )
  dup data-size>> zero?
  [ dup data-size>> [ >>escaped-data-size ] [ >>compressed-data-size ] 2bi
    code-size>> >>compressed-code-size 0 >>data-size
  ] unless
;

: sync-header ( image -- image' )
  dup data>> length over header>> compressed-data-size<<
  dup code>> length over header>> compressed-code-size<<
;

! load factor image
: load-factor-image ( filename -- image )
  binary [
    image-header read-struct >compression-header dup
    [ compressed-data-size>> read ]
    [ compressed-code-size>> read ] bi
  ] with-file-reader image boa
;

! save factor image
: save-factor-image ( image filename -- )
  binary [
   [ header>> ] [ data>> ] [ code>> ] tri [ write ] tri@
  ] with-file-writer
;

: compress ( byte-array -- compressed ) 12 zstd-compress-level ; ! level 12 seems the right balance between compression factor and compression speed
: compress-data ( image -- image' ) dup header>> [ escaped-data-size>> ] [ compressed-data-size>> ] bi = [ dup data>> compress >>data ] when ; ! only compress uncompressed data
: compress-code ( image -- image' ) dup header>> [ code-size>> ]         [ compressed-code-size>> ] bi = [ dup code>> compress >>code ] when ; ! only compress uncompressed code

! compress factor image
: compress-factor-image ( filename -- )
  [ load-factor-image compress-data compress-code sync-header ] keep
  ".compressed" append save-factor-image
;

: compress-current-image ( -- ) image-path compress-factor-image ;
MAIN: compress-current-image

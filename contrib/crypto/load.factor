IN: scratchpad
USING: kernel parser sequences words compiler ;
"contrib/math/load.factor" run-file

{ "common" "md5" "sha1" }
[ "contrib/crypto/" swap ".factor" append3 run-file ] each

"crypto" words [ try-compile ] each

IN: scratchpad
USING: words kernel parser sequences io compiler ;
"contrib/httpd/load.factor" run-file
"contrib/parser-combinators/load.factor" run-file

{ "cont-examples" "cont-numbers-game" "todo" "todo-example" "live-updater" "eval-responder" "live-updater-responder" "cont-testing" }
[ "contrib/cont-responder/" swap ".factor" append3 run-file ] each

{ "cont-examples" "numbers-game" "cont-responder" "eval-responder" "live-updater-responder" "live-updater" "todo-example" "todo" }
[ words [ try-compile ] each ] each


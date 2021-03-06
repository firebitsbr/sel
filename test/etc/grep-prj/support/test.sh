#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROG=$1
CASE=$2
shift 2
WRAPPER=$@

run_it() {
    ${WRAPPER} ${PROG} $@; }

case ${CASE} in
    0) run_it -v ;;
    1) run_it -0 12345 $BASEDIR/inputs/grep1.dat ;;
    2) run_it -1 12345 $BASEDIR/inputs/grep1.dat ;;
    3) run_it -2 12345 $BASEDIR/inputs/grep1.dat ;;
    4) run_it -3 12345 $BASEDIR/inputs/grep1.dat ;;
    5) run_it -4 12345 $BASEDIR/inputs/grep1.dat ;;
    6) run_it -5 12345 $BASEDIR/inputs/grep1.dat ;;
    7) run_it -6 12345 $BASEDIR/inputs/grep1.dat ;;
    8) run_it -7 12345 $BASEDIR/inputs/grep1.dat ;;
    9) run_it -8 12345 $BASEDIR/inputs/grep1.dat ;;
    10) run_it -9 12345 $BASEDIR/inputs/grep1.dat ;;
    11) run_it -f 12345 $BASEDIR/inputs/grep1.dat ;;
    12) run_it -i 12345 $BASEDIR/inputs/grep1.dat ;;
    13) run_it -Y 12345 $BASEDIR/inputs/grep1.dat ;;
    14) run_it -A -12345 $BASEDIR/inputs/grep1.dat ;;
    15) run_it -B -12345 $BASEDIR/inputs/grep1.dat ;;
    16) run_it -F -E 12345 $BASEDIR/inputs/grep1.dat ;;
    17) run_it -E -F 12345 $BASEDIR/inputs/grep1.dat ;;
    18) run_it -E -G 12345 $BASEDIR/inputs/grep1.dat ;;
    19) run_it -G -X 12345 ;;
    20) run_it -f nosuchfile $BASEDIR/inputs/grep1.dat ;;
    21) run_it -f $BASEDIR/inputs/grep1.dat $BASEDIR/inputs/grep1.dat ;;
    22) run_it -c 12345a < $BASEDIR/inputs/grep1.dat ;;
    23) run_it 12345a < $BASEDIR/inputs/grep1.dat ;;
    24) run_it -c include < $BASEDIR/inputs/grep1.dat ;;
    25) run_it include < $BASEDIR/inputs/grep1.dat ;;
    26) run_it include $BASEDIR/inputs/grep1.dat ;;
    27) run_it -l include < $BASEDIR/inputs/../$BASEDIR/inputs/grep1.dat ;;
    28) run_it -L 12345a < $BASEDIR/inputs/../$BASEDIR/inputs/grep1.dat ;;
    29) run_it 12345a < $BASEDIR/inputs/../$BASEDIR/inputs/grep1.dat ;;
    30) run_it "--" 12345 $BASEDIR/inputs/grep1.dat ;;
    31) run_it - -- 12345 $BASEDIR/inputs/grep1.dat ;;
    32) run_it "[z-a]" $BASEDIR/inputs/grep1.dat ;;
    33) run_it "[5-1]" $BASEDIR/inputs/grep1.dat ;;
    34) run_it "[F-A]" $BASEDIR/inputs/grep1.dat ;;
    35) run_it -ff ;;
    36) run_it -f ;;
    37) run_it 'a$a' $BASEDIR/inputs/grep1.dat ;;
    38) run_it 'if$' $BASEDIR/inputs/grep1.dat ;;
    39) run_it 'switch$|else' $BASEDIR/inputs/grep1.dat ;;
    40) run_it "1\+\+" $BASEDIR/inputs/grep1.dat ;;
    41) run_it "1\?\+" $BASEDIR/inputs/grep1.dat ;;
    42) run_it "1\+\?" $BASEDIR/inputs/grep1.dat ;;
    43) run_it "[" $BASEDIR/inputs/grep1.dat ;;
    44) run_it "a[" $BASEDIR/inputs/grep1.dat ;;
    45) run_it "a*[" $BASEDIR/inputs/grep1.dat ;;
    46) run_it "[a" $BASEDIR/inputs/grep1.dat ;;
    47) run_it "[1" $BASEDIR/inputs/grep1.dat ;;
    48) run_it "[1-9" $BASEDIR/inputs/grep1.dat ;;
    49) run_it "[1-]" $BASEDIR/inputs/grep1.dat ;;
    50) run_it "[a-]" $BASEDIR/inputs/grep1.dat ;;
    51) run_it "[1a-]" $BASEDIR/inputs/grep1.dat ;;
    52) run_it "[[:alpha:]-5]" $BASEDIR/inputs/grep1.dat ;;
    53) run_it "[z[:digit:]-f]" $BASEDIR/inputs/grep1.dat ;;
    54) run_it "[[:alnum:]-9]" $BASEDIR/inputs/grep1.dat ;;
    55) run_it "[1-2-9]" $BASEDIR/inputs/grep1.dat ;;
    56) run_it "[a-c-z]" $BASEDIR/inputs/grep1.dat ;;
    57) run_it "[1A-Z-A]" $BASEDIR/inputs/grep1.dat ;;
    58) run_it "[[:digit:]-1-9]" $BASEDIR/inputs/grep1.dat ;;
    59) run_it "[[:digit:]-A-Z]" $BASEDIR/inputs/grep1.dat ;;
    60) run_it "[[:digit:]-a-z]" $BASEDIR/inputs/grep1.dat ;;
    61) run_it "[1-2-" $BASEDIR/inputs/grep1.dat ;;
    62) run_it "[1A-Z-" $BASEDIR/inputs/grep1.dat ;;
    63) run_it "[Aa-z-" $BASEDIR/inputs/grep1.dat ;;
    64) run_it "[1-" $BASEDIR/inputs/grep1.dat ;;
    65) run_it "[1A-" $BASEDIR/inputs/grep1.dat ;;
    66) run_it "[Aa-" $BASEDIR/inputs/grep1.dat ;;
    67) run_it "[[:" $BASEDIR/inputs/grep1.dat ;;
    68) run_it "a[[:" $BASEDIR/inputs/grep1.dat ;;
    69) run_it "1-9[[:" $BASEDIR/inputs/grep1.dat ;;
    70) run_it "[[:a:]]" $BASEDIR/inputs/grep1.dat ;;
    71) run_it "[[:1:]]" $BASEDIR/inputs/grep1.dat ;;
    72) run_it "[[:abcdefg:]]" $BASEDIR/inputs/grep1.dat ;;
    73) run_it "[[:alpha:]" $BASEDIR/inputs/grep1.dat ;;
    74) run_it "[a[:digit:]" $BASEDIR/inputs/grep1.dat ;;
    75) run_it "[[:alnum:]" $BASEDIR/inputs/grep1.dat ;;
    76) run_it "\\" $BASEDIR/inputs/grep1.dat ;;
    77) run_it "if\\" $BASEDIR/inputs/grep1.dat ;;
    78) run_it "else\\" $BASEDIR/inputs/grep1.dat ;;
    79) run_it '\`' $BASEDIR/inputs/grep1.dat ;;
    80) run_it 'if\`' $BASEDIR/inputs/grep1.dat ;;
    81) run_it '\`else' $BASEDIR/inputs/grep1.dat ;;
    82) run_it "\'" $BASEDIR/inputs/grep1.dat ;;
    83) run_it "if\'" $BASEDIR/inputs/grep1.dat ;;
    84) run_it "\'else" $BASEDIR/inputs/grep1.dat ;;
    85) run_it "\1" $BASEDIR/inputs/grep1.dat ;;
    86) run_it "\2" $BASEDIR/inputs/grep1.dat ;;
    87) run_it "\3" $BASEDIR/inputs/grep1.dat ;;
    88) run_it "\4" $BASEDIR/inputs/grep1.dat ;;
    89) run_it "\5" $BASEDIR/inputs/grep1.dat ;;
    90) run_it "\6" $BASEDIR/inputs/grep1.dat ;;
    91) run_it "\7" $BASEDIR/inputs/grep1.dat ;;
    92) run_it "\8" $BASEDIR/inputs/grep1.dat ;;
    93) run_it "\9" $BASEDIR/inputs/grep1.dat ;;
    94) run_it "\)" $BASEDIR/inputs/grep1.dat ;;
    95) run_it "if\)" $BASEDIR/inputs/grep1.dat ;;
    96) run_it "[a-z]\)" $BASEDIR/inputs/grep1.dat ;;
    97) run_it "\{" $BASEDIR/inputs/grep1.dat ;;
    98) run_it "a\{" $BASEDIR/inputs/grep1.dat ;;
    99) run_it "[1-9]\{" $BASEDIR/inputs/grep1.dat ;;
    100) run_it "\{2,1}" $BASEDIR/inputs/grep1.dat ;;
    101) run_it "a\{2,1}" $BASEDIR/inputs/grep1.dat ;;
    102) run_it "\{1" $BASEDIR/inputs/grep1.dat ;;
    103) run_it "\{1,2" $BASEDIR/inputs/grep1.dat ;;
    104) run_it "a\{1" $BASEDIR/inputs/grep1.dat ;;
    105) run_it "\{1\{" $BASEDIR/inputs/grep1.dat ;;
    106) run_it "\{1,2\{" $BASEDIR/inputs/grep1.dat ;;
    107) run_it "[a-z]\{1,2\{" $BASEDIR/inputs/grep1.dat ;;
    108) run_it "a\{1,2\}" $BASEDIR/inputs/grep1.dat ;;
    109) run_it "[1-9]\{1,2\}" $BASEDIR/inputs/grep1.dat ;;
    110) run_it "A\{1,2\}" $BASEDIR/inputs/grep1.dat ;;
    111) run_it "A\{0\}" $BASEDIR/inputs/grep1.dat ;;
    112) run_it "1\{0\}" $BASEDIR/inputs/grep1.dat ;;
    113) run_it "[a-z]\{0\}" $BASEDIR/inputs/grep1.dat ;;
    114) run_it "\(" $BASEDIR/inputs/grep1.dat ;;
    115) run_it "a\(" $BASEDIR/inputs/grep1.dat ;;
    116) run_it "a\(a" $BASEDIR/inputs/grep1.dat ;;
    117) run_it "\|\(a\|b\)1*2\?3\+" $BASEDIR/inputs/grep1.dat ;;
    118) run_it "\|\(if\|else\)1*2\?3\+" $BASEDIR/inputs/grep1.dat ;;
    119) run_it "\|\(for\|12345\)a*b\?c\+" $BASEDIR/inputs/grep1.dat ;;
    120) run_it "a" $BASEDIR/inputs/biginput.dat ;;
    121) run_it "[a-z]" $BASEDIR/inputs/biginput.dat ;;
    122) run_it "5\|7" $BASEDIR/inputs/biginput.dat ;;
    123) run_it -5 if $BASEDIR/inputs/grep1.dat ;;
    124) run_it -7 else $BASEDIR/inputs/grep1.dat ;;
    125) run_it -4 12345 $BASEDIR/inputs/grep1.dat ;;
    126) run_it "[[:alnum:]]" $BASEDIR/inputs/grep1.dat ;;
    127) run_it "1[[:alnum:]]" $BASEDIR/inputs/grep1.dat ;;
    128) run_it "a*[[:alnum:]]" $BASEDIR/inputs/grep1.dat ;;
    129) run_it -f $BASEDIR/inputs/biginput.dat $BASEDIR/inputs/grep1.dat ;;
    130) run_it -f $BASEDIR/inputs/biginput2.dat $BASEDIR/inputs/grep1.dat ;;
    131) run_it -f $BASEDIR/inputs/input_enter1 $BASEDIR/inputs/grep1.dat ;;
    132) run_it -f $BASEDIR/inputs/input_enter2 $BASEDIR/inputs/grep1.dat ;;
    133) run_it -f $BASEDIR/inputs/input_enter3 $BASEDIR/inputs/grep1.dat ;;
    134) run_it "\\" $BASEDIR/inputs/grep1.dat ;;
    135) run_it "1\\" $BASEDIR/inputs/grep1.dat ;;
    136) run_it "a\\" $BASEDIR/inputs/grep1.dat ;;
    137) run_it "\^" $BASEDIR/inputs/grep1.dat ;;
    138) run_it "1\^" $BASEDIR/inputs/grep1.dat ;;
    139) run_it "a\^" $BASEDIR/inputs/grep1.dat ;;
    140) run_it "1\|^" $BASEDIR/inputs/grep1.dat ;;
    141) run_it "a\|^" $BASEDIR/inputs/grep1.dat ;;
    142) run_it "\(1\)^" $BASEDIR/inputs/grep1.dat ;;
    143) run_it '\$' $BASEDIR/inputs/grep1.dat ;;
    144) run_it 'if\$' $BASEDIR/inputs/grep1.dat ;;
    145) run_it 'main\$' $BASEDIR/inputs/grep1.dat ;;
    146) run_it '$' $BASEDIR/inputs/grep1.dat ;;
    147) run_it 'if$' $BASEDIR/inputs/grep1.dat ;;
    148) run_it 'main$' $BASEDIR/inputs/grep1.dat ;;
    149) run_it '$if' $BASEDIR/inputs/grep1.dat ;;
    150) run_it 'if$if' $BASEDIR/inputs/grep1.dat ;;
    151) run_it 'if$else' $BASEDIR/inputs/grep1.dat ;;
    152) run_it ">" $BASEDIR/inputs/grep1.dat ;;
    153) run_it "1>" $BASEDIR/inputs/grep1.dat ;;
    154) run_it "1>a" $BASEDIR/inputs/grep1.dat ;;
    155) run_it "B" $BASEDIR/inputs/grep1.dat ;;
    156) run_it "ABCDE" $BASEDIR/inputs/grep1.dat ;;
    157) run_it "[A-B]" $BASEDIR/inputs/grep1.dat ;;
    158) run_it "*" $BASEDIR/inputs/grep1.dat ;;
    159) run_it "*a" $BASEDIR/inputs/grep1.dat ;;
    160) run_it "*\(abcde\)" $BASEDIR/inputs/grep1.dat ;;
    161) run_it "\+" $BASEDIR/inputs/grep1.dat ;;
    162) run_it "1\+" $BASEDIR/inputs/grep1.dat ;;
    163) run_it "if\+" $BASEDIR/inputs/grep1.dat ;;
    164) run_it "+" $BASEDIR/inputs/grep1.dat ;;
    165) run_it "+if" $BASEDIR/inputs/grep1.dat ;;
    166) run_it "+else" $BASEDIR/inputs/grep1.dat ;;
    167) run_it "{" $BASEDIR/inputs/grep1.dat ;;
    168) run_it "if{" $BASEDIR/inputs/grep1.dat ;;
    169) run_it "else{" $BASEDIR/inputs/grep1.dat ;;
    170) run_it "1\{10,11\}2" $BASEDIR/inputs/grep1.dat ;;
    171) run_it "a\{10,11\}b" $BASEDIR/inputs/grep1.dat ;;
    172) run_it "if\{10,11\}else" $BASEDIR/inputs/grep1.dat ;;
    173) run_it "\." $BASEDIR/inputs/grep1.dat ;;
    174) run_it "1\.a" $BASEDIR/inputs/grep1.dat ;;
    175) run_it "if\.else" $BASEDIR/inputs/grep1.dat ;;
    176) run_it "\[" $BASEDIR/inputs/grep1.dat ;;
    177) run_it "if\[" $BASEDIR/inputs/grep1.dat ;;
    178) run_it "if\[else" $BASEDIR/inputs/grep1.dat ;;
    179) run_it -i "[A-z1]" $BASEDIR/inputs/grep1.dat ;;
    180) run_it -i "[C-x2]" $BASEDIR/inputs/grep1.dat ;;
    181) run_it -i "if[Xx5]" $BASEDIR/inputs/grep1.dat ;;
    182) run_it -X grep 12345 $BASEDIR/inputs/grep1.dat ;;
    183) run_it -X grep abcde $BASEDIR/inputs/grep1.dat ;;
    184) run_it -X grep if $BASEDIR/inputs/grep1.dat ;;
    185) run_it -e 1 -e 2 $BASEDIR/inputs/grep1.dat ;;
    186) run_it -e a -e b $BASEDIR/inputs/grep1.dat ;;
    187) run_it -e if -e else $BASEDIR/inputs/grep1.dat ;;
    188) run_it -e 12345 -e abcde -f $BASEDIR/inputs/input_1.dat $BASEDIR/inputs/grep1.dat ;;
    189) run_it -e if -e else -f $BASEDIR/inputs/input_1.dat $BASEDIR/inputs/grep1.dat ;;
    190) run_it -e 1 -e 2 -e 3 -e 4 -e 5 -e 12345 -f $BASEDIR/inputs/input_1.dat $BASEDIR/inputs/grep1.dat ;;
    191) run_it -f $BASEDIR/inputs/input_2.dat $BASEDIR/inputs/grep1.dat  ;;
    192) run_it -i -f $BASEDIR/inputs/input_2.dat $BASEDIR/inputs/grep1.dat ;;
    193) run_it -v -f $BASEDIR/inputs/input_2.dat $BASEDIR/inputs/grep1.dat ;;
    194) run_it "\(\b\)*" $BASEDIR/inputs/grep1.dat ;;
    195) run_it "if\(\b\)*" $BASEDIR/inputs/grep1.dat ;;
    196) run_it "\(\b\)\+" $BASEDIR/inputs/grep1.dat ;;
    197) run_it "\(\a|b*\|c\?|d\+\)\{1\}" $BASEDIR/inputs/grep1.dat ;;
    198) run_it "\(\if|else*\|for\?|while\+\)\{1\}" $BASEDIR/inputs/grep1.dat ;;
    199) run_it "\(\do|12345*\|main\?|A\+\)\{1\}" $BASEDIR/inputs/grep1.dat ;;
esac
exit 1

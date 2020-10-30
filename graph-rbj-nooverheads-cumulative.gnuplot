# vim: set et ft=gnuplot sw=4 :

set terminal tikz standalone color size 3.0in,2.6in
set output "gen-" . ARG0[:(strlen(ARG0)-strlen(".gnuplot"))] . ".tex"

set xlabel "Runtime (ms)"
set ylabel "Instances Solved"
set border 3
set grid
set xtics nomirror
set ytics nomirror
set key off
set xrange [1:1e6]
set yrange [0:14621]
set logscale x
set format x '$10^{%T}$'
set ytics add ('$14621$' 14621) add ('' 14000)

cx(s,m)=stringcolumn(s)eq"NaN"?1e6:column(s)*m>=1e6?1e6:column(s)*m
cy(s,m)=stringcolumn(s)eq"NaN"?1e-10:column(s)*m>=1e6?1e-10:1

plot \
    "overheads.data" u (cx("glasgow",1)):(cy("glasgow",1)) smooth cum w l lw 2 dt ".", \
    "runtimes.data" u (cx("hybrid-rbj",1000)):(cy("hybrid-rbj",1000)) smooth cum w l lw 2 lc 6 dt ".", \
    "overheads.data" u (cx("hybrid-rbj",1)):(cy("hybrid-rbj",1)) smooth cum w l lw 2 lc 7 ti 'No Overheads' at end


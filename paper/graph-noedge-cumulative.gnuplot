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
set logscale x
set format x '$10^{%T}$'

cx(s,m)=stringcolumn(s)eq"NaN"?1e6:column(s)*m>=1e6?1e6:column(s)*m
cy(s,m)=stringcolumn(s)eq"NaN"?1e-10:column(s)*m>=1e6?1e-10:1

plot \
    "runtimes.data" u (cx("glasgow",1)):(cy("glasgow",1)) smooth cum w l lw 2 dt ".", \
    "runtimes.data" u (cx("hybrid-rbj",1000)):(cy("hybrid-rbj",1000)) smooth cum w l lw 2 lc 6 dt ".", \
    "runtimes.data" u (cx("hybrid-noedge-rbj",1000)):(cy("hybrid-noedge-rbj",1000)) smooth cum w l lw 2 lc 8 ti 'No Table' at end


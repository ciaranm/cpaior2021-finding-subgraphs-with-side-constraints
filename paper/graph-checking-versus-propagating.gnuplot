# vim: set et ft=gnuplot sw=4 :

set terminal tikz standalone color size 2.6in,2.6in
set output "gen-" . ARG0[:(strlen(ARG0)-strlen(".gnuplot"))] . ".tex"

set xlabel "Propagating (ms)"
set ylabel "Checking (ms)"
set border 3
set grid
set xtics nomirror
set ytics nomirror
set key off
set xrange [1e3:2e6]
set yrange [1e3:2e6]
set logscale xy
set format x '$10^{%T}$'
set format y '$10^{%T}$'
set size square

sx(s,m)=stringcolumn(s)eq"NaN"?2e6:column(s)*m>=1e6?2e6:column(s)*m<1e3?1e3:column(s)*m

plot \
    "<head -n1 runtimes.data ; sed -e 1d runtimes.data | shuf" u (sx("hybrid-always",1000)):(sx("hybrid-checking",1000)):(column("family")==14?10:column("family")) w p pt var lc var, \
    x w l notitle ls 0


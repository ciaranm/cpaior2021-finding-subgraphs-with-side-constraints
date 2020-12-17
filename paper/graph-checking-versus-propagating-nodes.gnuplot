# vim: set et ft=gnuplot sw=4 :

set terminal tikz standalone color size 2.6in,2.6in
set output "gen-" . ARG0[:(strlen(ARG0)-strlen(".gnuplot"))] . ".tex"

set xlabel "Checking (nodes)"
set ylabel "Propagating (nodes)"
set border 3
set grid
set xtics nomirror
set ytics nomirror
set key off
set xrange [1:2e7]
set yrange [1:2e7]
set logscale xy
set format x '$10^{%T}$'
set format y '$10^{%T}$'
set size square

sx(s,m)=stringcolumn(s)eq"NaN"?2e7:column(s)*m>=1e7?2e7:column(s)*m<1?1:column(s)*m

plot \
    "<head -n1 nodes.data ; sed -e 1d nodes.data | shuf" u (sx("hybrid-checking",1)):(sx("hybrid-always",1)):(column("family")==14?10:column("family")) w p pt var lc var, \
    x w l notitle ls 0


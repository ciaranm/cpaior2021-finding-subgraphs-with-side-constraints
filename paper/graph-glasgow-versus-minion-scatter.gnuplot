# vim: set et ft=gnuplot sw=4 :

set terminal tikz standalone color size 2.6in,2.6in font '\scriptsize' preamble '\input{gnuplot-preamble}'
set output "gen-" . ARG0[:(strlen(ARG0)-strlen(".gnuplot"))] . ".tex"

load "viridis.pal"

set xlabel "Essence (ms)"
set ylabel "Glasgow (ms)" offset character 0.5
set border 3
set grid
set xtics nomirror
set ytics nomirror
set key off
set xrange [1:4e6]
set yrange [1:4e6]
set logscale xy
set format x '$10^{%T}$'
set format y '$10^{%T}$'
set size square

sx(s,m)=stringcolumn(s)eq"NaN"?4e6:column(s)*m>=3600e3?4e6:column(s)<1e-3?1e-3:column(s)*m

plot \
    "<head -n1 runtimes.data ; sed -e 1d runtimes.data | shuf" u (sx("si-noninduced-minion-preprocess-gac-20201208",1000)):(sx("si-noninduced-gss-20201208",1000)) w p ls 2 ps 0.3, \
    x  w l notitle ls 0


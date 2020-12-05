# vim: set et ft=gnuplot sw=4 :

set terminal tikz standalone color size 2.2in,2.6in font '\scriptsize' preamble '\input{gnuplot-preamble}'
set output "gen-" . ARG0[:(strlen(ARG0)-strlen(".gnuplot"))] . ".tex"

load "inferno.pal"

set xlabel "Runtime (ms)"
set ylabel "Instances Solved" offset character 1.5
set border 3
set grid
set xtics nomirror
set ytics nomirror
set key off
set xrange [1e4:1e6]
set yrange [12500:14500]
set logscale x
set format x '$10^{%T}$'

cx(s,m)=stringcolumn(s)eq"NaN"?1e6:column(s)*m>=1e6?1e6:column(s)*m
cy(s,m)=stringcolumn(s)eq"NaN"?1e-10:column(s)*m>=1e6?1e-10:1

# ygapsize=60
# lowerygap=13340
# upperygap=13700
# ygap(i)=(i<=lowerygap)?i:(i<upperygap)?NaN:(i-upperygap+lowerygap+ygapsize)
# yinvgap(i)=(i<=lowerygap)?i:(i<lowerygap+ygapsize)?NaN:(i+upperygap-lowerygap-ygapsize)
# 
# set nonlinear y via ygap(y) inverse yinvgap(y)
# 
# set object 500 rect from graph 0, first lowerygap to graph 1, first upperygap fs solid noborder fc bgnd front
# set arrow 501 from graph 0, first lowerygap to graph 0, first upperygap lw 2 lc bgnd nohead front
# set arrow 502 from graph 1, first lowerygap to graph 1, first upperygap lw 2 lc bgnd nohead front
# set arrow 503 from graph 0, first lowerygap length graph  .03 angle 15 nohead lw 2 front
# set arrow 504 from graph 0, first lowerygap length graph -.03 angle 15 nohead lw 2 front
# set arrow 505 from graph 0, first upperygap length graph  .03 angle 15 nohead lw 2 front
# set arrow 506 from graph 0, first upperygap length graph -.03 angle 15 nohead lw 2 front

set title "Odd to odd, even to even"

plot \
    "runtimes.data" u (cx("si-parity-gss-20201201",1000)):(cy("si-parity-gss-20201201",1000)) smooth cum w l ls 1 ti '\raisebox{1mm}{Glasgow}' at end, \
    "runtimes.data" u (cx("si-parity-minion-preprocess-gac-20201201",1000)):(cy("si-parity-minion-preprocess-gac-20201201",1000)) smooth cum w l ls 3 ti '\raisebox{-0.5mm}{Minion}' at end, \
    "runtimes.data" u (cx("si-parityoz-minion-preprocess-gac-20201203",1000)):(cy("si-parityoz-minion-preprocess-gac-20201203",1000)) smooth cum w l ls 3 dt ".", \
    "runtimes.data" u (cx("si-parity-hybrid-preprocess-gac-comm-checker-20201201",1000)):(cy("si-parity-hybrid-preprocess-gac-comm-checker-20201201",1000)) smooth cum w l ls 5 ti '\raisebox{0.5mm}{Checking}' at end, \
    "runtimes.data" u (cx("si-parityoz-hybrid-preprocess-gac-comm-checker-20201203",1000)):(cy("si-parityoz-hybrid-preprocess-gac-comm-checker-20201203",1000)) smooth cum w l ls 5 dt ".", \
    "runtimes.data" u (cx("si-parity-hybrid-preprocess-gac-comm-propagate-20201201",1000)):(cy("si-parity-hybrid-preprocess-gac-comm-propagate-20201201",1000)) smooth cum w l ls 6 ti 'Propagating' at end, \
    "runtimes.data" u (cx("si-parityoz-hybrid-preprocess-gac-comm-propagate-20201203",1000)):(cy("si-parityoz-hybrid-preprocess-gac-comm-propagate-20201203",1000)) smooth cum w l ls 6 dt ".", \
    "runtimes.data" u (cx("si-parity-hybrid-preprocess-gac-comm-rollback-20201201",1000)):(cy("si-parity-hybrid-preprocess-gac-comm-rollback-20201201",1000)) smooth cum w l ls 8 ti '\raisebox{-0.5mm}{Rollback}' at end, \
    "runtimes.data" u (cx("si-parityoz-hybrid-preprocess-gac-comm-rollback-20201203",1000)):(cy("si-parityoz-hybrid-preprocess-gac-comm-rollback-20201203",1000)) smooth cum w l ls 8 dt "."


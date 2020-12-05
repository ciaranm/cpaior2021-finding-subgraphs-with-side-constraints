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
set xrange [1e0:1e6]
set yrange [0:14621] noextend
set logscale x
set format x '$10^{%T}$'
set ytics add ('$14621$' 14621) add ('' 14500)

ygapsize=60
lowerygap=1000
upperygap=12060
lowerygap2=12500
upperygap2=13860

# ygap(i)= \
#     (i<=lowerygap) ? \
#         i : \
#         (i<upperygap) ? \
#             NaN : \
#             (i<=lowerygap2) ? \
#                 (i-upperygap+lowerygap+ygapsize) : \
#                 (i<upperygap2) ? \
#                     NaN : \
#                     (i-upperygap+lowerygap-upperygap2+lowerygap2+ygapsize+ygapsize)
# 
# yinvgap(i)= \
#     (i<=lowerygap) ? \
#         i : \
#         (i<lowerygap+ygapsize) ? \
#             NaN : \
#             (i+upperygap-lowerygap-ygapsize)
# 
# print yinvgap(ygap(15000))

ygap(i)=(i<=lowerygap)?i:(i<upperygap)?NaN:(i-upperygap+lowerygap+ygapsize)
yinvgap(i)=(i<=lowerygap)?i:(i<lowerygap+ygapsize)?NaN:(i+upperygap-lowerygap-ygapsize)

set nonlinear y via ygap(y) inverse yinvgap(y)

set object 500 rect from graph 0, first lowerygap to graph 1, first upperygap fs solid noborder fc bgnd front
set arrow 501 from graph 0, first lowerygap to graph 0, first upperygap lw 2 lc bgnd nohead front
set arrow 502 from graph 1, first lowerygap to graph 1, first upperygap lw 2 lc bgnd nohead front
set arrow 503 from graph 0, first lowerygap length graph  .03 angle 15 nohead lw 2 front
set arrow 504 from graph 0, first lowerygap length graph -.03 angle 15 nohead lw 2 front
set arrow 505 from graph 0, first upperygap length graph  .03 angle 15 nohead lw 2 front
set arrow 506 from graph 0, first upperygap length graph -.03 angle 15 nohead lw 2 front

cx(s,m)=stringcolumn(s)eq"NaN"?1e6:column(s)*m>=1e6?1e6:column(s)*m
cy(s,m)=stringcolumn(s)eq"NaN"?1e-10:column(s)*m>=1e6?1e-10:1

set title "No side constraints"

plot \
    "runtimes.data" u (cx("si-noninduced-gss-20201201",1000)):(cy("si-noninduced-gss-20201201",1000)) smooth cum w l ls 1 ti "Glasgow" at end, \
    "runtimes.data" u (cx("si-noninduced-minion-preprocess-gac-20201201",1000)):(cy("si-noninduced-minion-preprocess-gac-20201201",1000)) smooth cum w l ls 3 ti "Minion" at end, \
    "runtimes.data" u (cx("si-noninducedoz-minion-preprocess-gac-20201203",1000)):(cy("si-noninducedoz-minion-preprocess-gac-20201203",1000)) smooth cum w l ls 3 dt ".", \
    "runtimes.data" u (cx("si-noninduced-hybrid-preprocess-gac-comm-checker-20201201",1000)):(cy("si-noninduced-hybrid-preprocess-gac-comm-checker-20201201",1000)) smooth cum w l ls 5 ti "Checking" at end, \
    "runtimes.data" u (cx("si-noninducedoz-hybrid-preprocess-gac-comm-checker-20201203",1000)):(cy("si-noninducedoz-hybrid-preprocess-gac-comm-checker-20201203",1000)) smooth cum w l ls 5 dt ".", \
    "runtimes.data" u (cx("si-noninduced-hybrid-preprocess-gac-comm-propagate-20201201",1000)):(cy("si-noninduced-hybrid-preprocess-gac-comm-propagate-20201201",1000)) smooth cum w l ls 6 ti '\raisebox{-1mm}{Propagating}' at end, \
    "runtimes.data" u (cx("si-noninducedoz-hybrid-preprocess-gac-comm-propagate-20201203",1000)):(cy("si-noninducedoz-hybrid-preprocess-gac-comm-propagate-20201203",1000)) smooth cum w l ls 6 dt ".", \
    "runtimes.data" u (cx("si-noninduced-hybrid-preprocess-gac-comm-rollback-20201201",1000)):(cy("si-noninduced-hybrid-preprocess-gac-comm-rollback-20201201",1000)) smooth cum w l ls 8 ti '\raisebox{1mm}{Rollback}' at end, \
    "runtimes.data" u (cx("si-noninducedoz-hybrid-preprocess-gac-comm-rollback-20201203",1000)):(cy("si-noninducedoz-hybrid-preprocess-gac-comm-rollback-20201203",1000)) smooth cum w l ls 8 dt "."


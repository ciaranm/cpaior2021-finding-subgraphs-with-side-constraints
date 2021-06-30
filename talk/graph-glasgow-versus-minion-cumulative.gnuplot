# vim: set et ft=gnuplot sw=4 :

set terminal tikz standalone color size 10.5cm,6.5cm preamble '\RequirePackage[tt=false, type1=true]{libertine} \RequirePackage[varqu]{zi4} \RequirePackage[libertine]{newtxmath} \RequirePackage[T1]{fontenc}'
set output "gen-" . ARG0[:(strlen(ARG0)-strlen(".gnuplot"))] . ".tex"

load "viridis.pal"

set xlabel "Runtime (ms)"
set ylabel "Instances Solved"
set border 3
set grid
set xtics nomirror
set ytics nomirror
set key off
set xrange [1:3600e3]
set yrange [0:14621] noextend
set logscale x
set format x '$10^{%T}$'
set xtics add ('~~1h' 3600e3)
set rmargin 10

ygapsize=300
lowerygap=1350
upperygap=10650
ygap(i)=(i<=lowerygap)?i:(i<upperygap)?NaN:(i-upperygap+lowerygap+ygapsize)
yinvgap(i)=(i<=lowerygap)?i:(i<lowerygap+ygapsize)?NaN:(i+upperygap-lowerygap-ygapsize)

set nonlinear y via ygap(y) inverse yinvgap(y)

set ytics add ('$14621$' 14621) add ('' 14500) add ('$12000$' 12000)

set object 500 rect from graph 0, first lowerygap to graph 1, first upperygap fs solid noborder fc bgnd front
set arrow 501 from graph 0, first lowerygap to graph 0, first upperygap lw 2 lc bgnd nohead front
set arrow 502 from graph 1, first lowerygap to graph 1, first upperygap lw 2 lc bgnd nohead front
set arrow 503 from graph 0, first lowerygap length graph  .03 angle 15 nohead lw 2 front
set arrow 504 from graph 0, first lowerygap length graph -.03 angle 15 nohead lw 2 front
set arrow 505 from graph 0, first upperygap length graph  .03 angle 15 nohead lw 2 front
set arrow 506 from graph 0, first upperygap length graph -.03 angle 15 nohead lw 2 front

cx(s,m)=stringcolumn(s)eq"NaN"?3600e3:column(s)*m>=3600e3?3600e3:column(s)*m
cy(s,m)=stringcolumn(s)eq"NaN"?1e-10:column(s)*m>=3600e3?1e-10:1

plot \
    "../paper/runtimes.data" u (cx("si-noninduced-gss-20201208",1000)):(cy("si-noninduced-gss-20201208",1000)) smooth cum w l ls 1 ti '\raisebox{1mm}{Glasgow}' at end, \
    "../paper/runtimes.data" u (cx("si-noninduced-minion-preprocess-gac-20201208",1000)):(cy("si-noninduced-minion-preprocess-gac-20201208",1000)) smooth cum w l ls 3 ti "Essence" at end, \
    "../paper/runtimes.data" u (cx("si-noninduced-vf2-20201208",1000)):(cy("si-noninduced-vf2-20201208",1000)) smooth cum w l ls 5 ti '\raisebox{0mm}{VF2}' at end, \
    "../paper/runtimes.data" u (cx("si-noninduced-ri-20201208",1000)):(cy("si-noninduced-ri-20201208",1000)) smooth cum w l ls 6 ti "RI" at end, \
    "../paper/runtimes.data" u (cx("si-noninduced-pathlad-20201208",1000)):(cy("si-noninduced-pathlad-20201208",1000)) smooth cum w l ls 8 ti '\raisebox{-1mm}{PathLAD}' at end, \


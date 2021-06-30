all : tables graphs
	latexmk -pdf -pdflatex='pdflatex -interaction=nonstopmode %O %S' talk

TABLES =

GRAPHS = \
	gen-graph-glasgow-versus-minion-cumulative.pdf \
	gen-graph-glasgow-versus-minion-scatter.pdf \
	gen-graph-nosideconstraints.pdf \
	gen-graph-oddeven.pdf \
	gen-graph-mostlyodd.pdf \
	gen-graph-parity.pdf

tables : $(TABLES)

graphs : $(GRAPHS)

gen-graph-%.tex : graph-%.gnuplot
	gnuplot $<

gen-graph-%.pdf : graph-%.gnuplot $(DATA)
	gnuplot $<
	sed -i -e '5,20s/^\(\\path.*\)/\% \1/' gen-graph-$*.tex # epic haxx
	latexmk -pdf gen-graph-$*

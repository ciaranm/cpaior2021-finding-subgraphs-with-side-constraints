all : tables graphs
	latexmk -pdf -pdflatex='pdflatex -interaction=nonstopmode %O %S' -shell-escape paper

TABLES =

GRAPHS = \
	 gen-graph-glasgow-versus-minion-cumulative.pdf \
	 gen-graph-glasgow-versus-minion-scatter.pdf \
	 gen-graph-nosideconstraints.pdf \
	 gen-graph-oddeven.pdf \
	 gen-graph-parity.pdf \
	 gen-graph-mostlyodd.pdf \
	 gen-graph-testing-versus-propagating.pdf

tables : $(TABLES)

graphs : $(GRAPHS)

gen-graph-%.pdf : graph-%.gnuplot
	gnuplot $<
	sed -i -e '19,20s/^\(\\path.*\)/\% \1/' gen-graph-$*.tex # epic haxx
	latexmk -pdf gen-graph-$*

clean :
	rm *.aux *.bbl *.blg *.fdb_latexmk *.fls *.log *.pdf *.data.adjusted gen-graph*


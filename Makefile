DOCUMENT = dossier.pdf
BIBLIOGRAPHY = cited.bib
SOURCES = summary.tex introduction.tex origin.tex context.tex perspectives.tex conclusion.tex constats.tex contacts.tex advancing-lcm.tex
TEMPLATES = layout.tex

OPEN_COMMAND = open
REMOVE_COMMAND = rm -f

default: $(DOCUMENT)

%.pdf: %.tex $(TEMPLATES) $(SOURCES) $(BIBLIOGRAPHY)
	texexec --pdf --color $<
	[ -f $@ ] && $(OPEN_COMMAND) $@

clean:
	@echo Cleaning temporary files
	@$(REMOVE_COMMAND) *-mpgraph.*
	@$(REMOVE_COMMAND) *.aux
	@$(REMOVE_COMMAND) *.log
	@$(REMOVE_COMMAND) *.bbl
	@$(REMOVE_COMMAND) *.blg
	@$(REMOVE_COMMAND) *.tmp
	@$(REMOVE_COMMAND) *.tuo
	@$(REMOVE_COMMAND) *.tui
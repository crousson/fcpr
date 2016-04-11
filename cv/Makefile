DOCUMENT = FCPR_CV.pdf
TARGET = ../pdf/cv.pdf
REMOVE_COMMAND = rm -f

default: $(TARGET)

$(TARGET): $(DOCUMENT)
	cp $(DOCUMENT) $@

%.pdf: %.tex
	pdflatex $<

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
	@$(REMOVE_COMMAND) *.tuc
	@$(REMOVE_COMMAND) *.out

clean-all: clean
	@echo Cleaning output files
	@$(REMOVE_COMMAND) *.pdf
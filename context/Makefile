DOCUMENTS = dossier.pdf projet.pdf
BIBLIOGRAPHY = cited.bib
SOURCES = metadata.tex summary.tex acronyms.tex \
          contexte.tex enjeux.tex probleme_et_verrous.tex cadre_analyse.tex apports_modelisation.tex \
          approches_theoriques.tex theorie_organisation_urbaine.tex cadre_analyse.tex hypotheses_theoriques.tex \
          hypotheses_thematiques.tex  questions_et_terrains.tex \
          choix_methodo.tex activites.tex environnement.tex \
          perspectives.tex conclusion.tex \
          constats.tex contacts.tex advancing-lcm.tex annexe_contexte.tex

TEMPLATES = layout.tex

OPEN_COMMAND = evince
REMOVE_COMMAND = rm -f

default: $(DOCUMENTS)

%.pdf: %.tex $(TEMPLATES) $(SOURCES) $(BIBLIOGRAPHY)
	context --pdf --color $<

view: $(DOCUMENTS)
	$(OPEN_COMMAND) $(DOCUMENTS) &

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

clean-all: clean
	@echo Cleaning output files
	@$(REMOVE_COMMAND) *.pdf

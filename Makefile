# Make file to facilitate the transform of SVG graphics into a Latex native
# form for document compilation.

# Paths
GRAPHICS_DIR=graphics

# Veriable to make the makefile simpler.
SRC=document.tex
DOC_TYPE=pdf
DOC=$(patsubst %.tex,%.$(DOC_TYPE),$(SRC))
TEX_FLAGS=-file-line-error -output-format=$(DOC_TYPE) -interaction=nonstopmode
SVG_SRC=$(filter-out %.ti.svg,$(wildcard $(GRAPHICS_DIR)/*.svg))
SVG_TEX=$(patsubst %.svg,%.pdf_tex,$(SVG_SRC))
SVG_PDF=$(patsubst %.svg,%.pdf,$(SVG_SRC))

.PHONY: all clean typeset vars

all: $(DOC)

# CUSTOM BUILD RULES

# In case you didn't know, '$@' is a variable holding the name of the target,
# and '$<' is a variable holding the (first) dependency of a rule.
# "raw2tex" and "dat2tex" are just placeholders for whatever custom steps
# you might have.

#%.tex: %.raw
#	./raw2tex $< > $@

#%.tex: %.dat
#	./dat2tex $< > $@

$(GRAPHICS_DIR)/%.pdf_tex $(GRAPHICS_DIR)/%.pdf: $(GRAPHICS_DIR)/%.svg
	python ./Oni-svg2tex-0717fdc/svg2tex.py -i "$(subst .svg,,$<)" -t "$(subst .svg,,$<).ti.svg" $< $@
	inkscape --export-pdf="$(subst .svg,,$<).pdf" "$(subst .svg,,$<).ti.svg"

# MAIN LATEXMK RULE

# -pdf tells latexmk to generate PDF directly (instead of DVI).
# -pdflatex="" tells latexmk to call a specific backend with specific options.
# -use-make tells latexmk to call make for generating missing files.

# -interaction=nonstopmode keeps the pdflatex backend from stopping at a
# missing file reference and interactively asking you for an alternative.

$(DOC): $(SRC) $(SVG_TEX) $(SVG_PDF)
	latex $(TEX_FLAGS)  $<
	#latexmk -$(DOC_TYPE) -pdflatex="latex $(FLAGS)" -use-make $<

vars:
	@echo "GRAPHICS_DIR: $(GRAPHICS_DIR)"
	@echo "SRC: $(SRC)"
	@echo "DOC_TYPE: $(DOC_TYPE)"
	@echo "DOC: $(DOC)"
	@echo "TEX_FLAGS: $(TEX_FLAGS)"
	@echo "SVG_SRC: $(SVG_SRC)"
	@echo "SVG_TEX: $(SVG_TEX)"
	@echo "SVG_PDF: $(SVG_PDF)"

clean:
	rm $(SVG_TEX) $(SVG_PDF) $(wildcard $(GRAPHICS_DIR)/*.ti.svg)

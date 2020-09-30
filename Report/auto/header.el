(TeX-add-style-hook
 "header"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "margin=0.8in") ("ntheorem" "thmmarks" "thref" "amsmath")))
   (TeX-run-style-hooks
    "pdfpages"
    "graphicx"
    "amsmath"
    "mathtools"
    "amsfonts"
    "array"
    "helvet"
    "color"
    "empheq"
    "tkz-euclide"
    "caption"
    "geometry"
    "pgfplots"
    "ntheorem")
   (TeX-add-symbols
    '("ro" 1)
    '("widefbox" 1)
    "mybluebox")
   (LaTeX-add-environments
    '("amatrix" 1))
   (LaTeX-add-lengths
    "mytemplen"
    "rowidth")
   (LaTeX-add-saveboxes
    "mytempbox")
   (LaTeX-add-color-definecolors
    "myblue")
   (LaTeX-add-ntheorem-newtheorems
    "thm"
    "case"
    "proof"))
 :latex)


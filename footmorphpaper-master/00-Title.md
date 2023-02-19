---
els-options: preprint
title: "Dynamic foot morphology explained through 4D scanning and shape modeling"
journal: Journal of Biomechanics
author:
- name: Abhishektha Boppana
  email: abhishektha@colorado.edu
  group: CUAero
  corref: cor1
  cortext: Corresponding Author
- name: Allison P. Anderson
  group: CUAero
author-group:
- name: CUAero
  address: Ann and H.J. Smead Department of Aerospace Engineering Sciences, University of Colorado Boulder, USA
bibliography: references


keywords: foot morphology, dynamic scanning, gait biomechanics, shape modeling

acknowledgements: The authors would like to thank Rodger Kram for providing the laboratory space and treadmill used in the study, Wouter Hoogkamer for assistance with equipment setup, and Steven Priddy for assistance isolating the right foot from the 4D scans. The authors would also like to thank Brian Corner and Matthew Reed for providing a high-quality averaged foot-scan to be used as the template for registration. This project was supported with a National Science Foundation Graduate Research Fellowship Grant DGE 1650115.


header-includes:
- \linenumbers
- \usepackage{longtable}
- \usepackage{booktabs}

figPrefix:
  - "Fig."
  - "Figs."
secPrefix:
  - "Section"
  - "Sections"

abstract: A detailed understanding of foot morphology can enable the design of more comfortable and better fitting footwear. However, foot morphology varies widely within the population, and changes dynamically during the loading of stance phase. This study presents a parametric statistical shape model from 4D foot scans to capture both the inter- and intra-individual variability in foot morphology. Thirty subjects walked on a treadmill while 4D scans of their right foot were taken at 90 frames-per-second during stance phase. Each subject's height, weight, foot length, foot width, arch length, and sex were also recorded. The 4D scans were all registered to a common high-quality foot scan, and a principal component analysis was done on all processed 4D scans. Elastic-net linear regression models were built to predict the principal component scores, which were then inverse transformed into 4D scans. The best performing model was selected with leave-one-out cross-validation. The chosen model was predicts foot morphology across stance phase with a root-mean squared error of 5.2 $\pm$ 2.0 mm. This study shows that statistical shape modeling can be used to predict dynamic changes in foot morphology across the population. The model can be used to investigate and improve foot-footwear interaction, allowing for better fitting and more comfortable footwear. 
---


\newpage


# Figures and Tables {-}

All tables, figures, and respective captions are listed below


| Sex    | 5th-35th percentile Height | 35th-65th percentile Height | 65th-95th percentile Height |
| ------ | -------------------------- | --------------------------- | --------------------------- |
| Female | 4'11"-5'3"                 | 5'3"-5'5"                   | 5'5"-5'8"                   |
| Male   | 5'4"-5'8"                  | 5'8"-5'11"                  | 5'11"-6'2"                  |

: Enrollment groups based on reported height. 5 subjects were enrolled in each group {#tbl:groups}

\newpage
![Capture setup of 6 Intel RealSense D415 Depth Cameras (circled in red) placed around a treadmill. The checkerboard shown was used to calibrate the cameras using the DynaMo package.](fig/capturesetup.png){#fig:testSetup width=100%}

\newpage
![Flowchart of processing steps for statistical shape model creation](fig/footProcessing.png){#fig:dataflow width=100%}

\newpage
![Processed and registered scans of one subject during heel-off, shown 10 frames (.11 seconds) apart](fig/scans.png){#fig:scans width=100%}

\newpage
![Distribution of errors across the various prediction models leave-subject-out cross-validation results. Model RMSE mean and standard deviation are shown above each distribution](fig/modelPerformance.png){#fig:modelperf width=100%}

\newpage
![Each graph represents the predictor's effects on the shape mode by visualizing the model's normalized coefficients. Larger absolute values indicate a larger effect from the predictor on the shape mode.](fig/coefs.png){#fig:coefs width=100%}

\newpage
![Each shape mode's principal axis represented as a heatmap overlaid on the mean foot and shown from 4 different point-of-views. The darker regions represent vertices which are most correlated with the shape mode's principal axis, and therefore see deformations in the shape mode.](fig/PCQuad.png){#fig:pca_quad width=100%}

\newpage
![Foot shape deformation at +2 and -2 standard deviations along each shape mode's principal axis, overlaid on the mean foot. The point-of-view is set to highlight the major variance along each shape mode's axis.](fig/PCVAR.png){#fig:pca_overlay width=100%}
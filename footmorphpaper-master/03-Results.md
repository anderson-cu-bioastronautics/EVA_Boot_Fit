# Results

A total of 1771 scans were analyzed across all 30 subjects. 
Each subject's stance phase ranged from 52-69 scans (mean=59). 
([Fig. @fig:scans]) shows a set of raw and registered scans from one subject.
All processed scans were registered to the template with a median registration accuracy of 1.0 $\pm$ 0.6 mm.

The PCA analysis of all registered scans found the first 8 PCs to represent approximately 95% of the variance, the first 27 PCs to represent approximately 98% of the variance, and the first 105 PCs to represent approximately 99.7% of the variance. 
([Fig. @fig:modelperf]) shows the distribution of cross-validation RMSEs for each of the six elastic net regression models tested. 
RMSE distributions did not meet assumptions for normality, but RMANOVA was still used to compare models due to its resiliency to deviations from normality. 
A significant difference was found between predicting different numbers of PCs (F=1595.0, p<0.001), predicting between the two variable sets (F=81.6, p<0.001), and the interaction between both factors (F=213.7, p<0.001). 
Significant differences were found between all three levels of the predicted number of PCs (p-adj<0.001) with a Tukey post-hoc HSD test.
No significant difference was found between the two variable sets (p-adj=0.42).
Therefore, the model predicting 8 PCs with the selected variable set was chosen for its simplicity and performance. 

Each retained PC is a shape mode in the model. ([Fig. @fig:coefs]) shows the chosen model's normalized regression coefficient values for each shape mode. 
The coefficients for the sex predictor are not shown as they were calculated to be zero for every shape mode.

([Fig. @fig:pca_quad]) shows each shape mode's axis represented on the mean foot, highlighting which areas of the foot are affected by deformations in each shape mode. 
([Fig. @fig:pca_overlay]) shows the $\pm$ 2 standard deviations of deformation along each shape mode overlaid on the mean foot. 
Supplementary information includes correlation between figures, ratio of total variance each retained PC accounts for, and a video showing the predictive capability of the model. 




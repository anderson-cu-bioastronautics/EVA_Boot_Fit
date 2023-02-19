# Modeling Dynamic Changes in Foot Morphology During Gait
## Where to Publish?
| Journal | Impact Factor | Turnaround | Notes |
|-|-|-|
| Journal of Biomechanics | 2.576 | Unpublished | Very prestigious but more about general biomechanics |
| Gait & Posture | 2.414 | 4 Months (to 1st rev) | More specific to lower body, many gait but not many foot specific articles |
| Applied Biomechanics | 1.392 | Unpublished | Applied seems to refer to methods, seems to be whole body, very experimental |
| Footwear Science | 0.32 | 6 months (to accepted) | Very footwear focused, community is from the FBS conference, quite a good mix of modeling vs. experimental |
| Computer Methods in Biomechanics and Biomedical Engineering | 1.2 | 7 months (to accepted)| Seems more towards biomed side, not as much biomechanics but very modeling focused |

## Outline

### Introduction
1. Digital human modelling background
	i. Motivation: to understand how differently sized humans interact with the world around them. Traditionally we characterize humans with linear dimensions, but need to understand how humans are sized, and how this translates into 3D shape since the world is in 3D.  For this application, specifically with shoes. Can influence shoe design and fit to accommodate a wider variety of individuals
	i. Whole body: Reed, Park B. 
	ii. Foot: Conrad, Jurca, Stankovic, Barisch-Fritz 2014
2. Evidence of dynamic changes in foot morphology
	i. Barisch-fritz to show changes in linear dimensions
	ii. Kuochi 2009 to show changes in cross-section
3. Technology Limitations for dynamic scanning
	i.  Frame-rate vs. quality trade-off
	ii. Want whole foot structure
	iii. Dynamo
4. Hypothesis: Is dynamic foot morphology different during gait for different individuals?
### Methods
1. Subject demographics
	i. N = 30 (15/15 m/f)
	ii. Selectively recruited
		a. 5-35, 35-65, 65-95 percentiles of height, as height correlates to foot length and we can’t trust people’s measure of foot-length
		b. 5ppl per sex in percentile grouping
	iii. Anthropometric data recorded during experiment
		a. Height
		b. Weight
		c. Brannock: foot length, foot width, arch length
		d. BMI (Calculated from weight, height)
2. *Figure 1: Subject Demographics* 
3. Subject Procedures
	i. Walk on treadmill for 1 min warm-up at 1.4 m/s (cite)
	ii. Cameras capture for 10s -> reviewed by operator to ensure subject was in frame while subject continues to walk -> repeat if necessary 
4. *Figure 2: Test Setup Picture*
5. *Figure 3: Data flowchart*
6. Subject Foot Isolation
	i. All 10s of data manually analyzed to isolate a single heel-strike to toe-off event
	ii. Data from step: RANSAC to detect and delete treadmill floor, then Euclidean cluster detection to detect both feet, then foot with higher RGB value detected as right foot
7. Subject Foot Registration:
	i. Preprocessing: marching cubes algorithm to build mesh from foot scan
	ii. ICP alignment of template foot to scan mesh
	iii. Delete any points on scan that are left over from the isolation by looking at what points are within a radius from the aligned template
	iv. Rough RBF alignment of template to scan point cloud, 2 iterations
	v. Fine alignment of downsampled RBF aligned template to scan mesh, 1 iteration
	vi. Registration done iterative forwards and backwards from seed-scan manually chosen at midpoint 
8. PCA Decomposition and PCR Model
	i. PCA scores explain the variance between scans of all subjects
	ii. Linear regression to predict the PC scores of each scan based on anthropometrics and where in the gait cycle 
### Results
1. *Figure 4: PC score variance in scans*
2. *Figure 5: Model cross-validation accuracy*
### Discussion
1. Which PC scores correspond to which parts of the foot?
2. How accurate was the model?
3. If there are any deficiencies, where can they come from?
### Conclusion
1. Uses of this model
2. Extensions of this model
### Appendix?
1. Registration accuracy as plots/heat maps?
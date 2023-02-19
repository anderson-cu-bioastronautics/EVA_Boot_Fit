# Methods 

## Subjects

A total of 30 healthy subjects (15 men and 15 women, ages 23.1 $\pm$ 3.7) participated in this study.
Subjects were recruited in a stratified sample into one of six groups (5 subjects per group) to maximize variance in population foot length. 
Height was used as the grouping factor since height is well correlated to foot length [@Giles1991]. The general population may not know offhand their exact foot length, and shoe size varies by manufacturer and does not correspond directly to foot length [@Jurca2013; @Wannop2019]. Groups consisted of 5th-35th, 35th-65th, and 65th-95th height percentiles for each sex. 
Height percentile values were taken from the ANSUR II survey [@Gordon2014] and converted to imperial units as it was expected most subjects would report their height in imperial units. 
Population recruitment groups are summarized in [@tbl:groups].  

Prior to recruitment, subjects completed a prescreening survey to ensure they were adequately healthy by the American College of Sports Medicine guidelines[@Riebe2015], and between the ages of 18-65.
Subjects provided their sex and height, and were only enrolled in the study if their population group was not fully enrolled. 

## Experimental Procedures

The experimental protocol was approved by the University of Colorado Institutional Review Board.
Procedures were explained to each subject and written consent was obtained prior to participation. 
Subjects’ height and weight were recorded with a tape measure and scale, respectively. 
Subjects’ foot length, foot width, and arch length were measured with a Brannock device (The Brannock Device Company, Liverpool, NY) [@ASTM2017].
Both foot length and arch length were measured in centimeters.
Foot width was measured as an ordinal size (e.g. A, B, C, D, E), and then converted to a linear measurement in centimeters (The Brannock Device Company, Liverpool, NY).

Six Intel RealSense D415 Depth Cameras (Intel, Santa Clara, CA) were placed and calibrated around a custom-built level treadmill in the University of Colorado Boulder Locomotion Laboratory, as shown in [@fig:testSetup].
The DynaMo software package was used to capture depth images of the right foot at 90 frames-per-second while subjects walked on the treadmill, and convert each frame's depth images to a single point cloud [@Boppana2019].

The treadmill was set to an average walking pace of 1.4 m/s [@Browning2006].
Reflective markers were placed on the subject's right foot and a black sock over their left foot to aid in right foot identification.
Subjects first walked for one minute to warm-up and fall into a natural cadence. 
The operator then collected 10 seconds of data to capture approximately 10 steps.
The data were reviewed to ensure the subject stayed in frame from heel-strike to toe-off during capture. If needed, the subject’s placement was shifted and data was collected again, up to two times.

## Data Processing

([Fig. @fig:dataflow]) provides an overview of the data processing workflow.
The following paragraphs summarize the workflow, while more detail is provided in supplementary methods.

For each subject, a candidate heel-strike to toe-off event was manually identified across all captures by taking into account point cloud quality due to the high computational power required to process all heel-strike to toe-off events. 
The depth images captured by each depth camera were processed into point clouds using the DynaMo package [@Boppana2019].
From each point cloud, the right foot was isolated and transformed into a triangle mesh [@Rusu2011; @Fischler1981;@Bernardini1999;@Zhou2018].
Since every depth image was captured independently by the cameras, the amount and location of points which represented the foot were not consistent. 
In addition, the captured data may have holes in the surface representing the foot. 
Registration of all scans to a common template represents every scan by an equal number of points, and ensures any missing points are properly interpolated. 
The right foot meshes were then iteratively registered using a three-step fitting process to an averaged high-quality static template scan from a previous study [@Reed2013].
First scans were roughly aligned using a point-to-plane iterative-closest-point algorithm [@Chen1992], implemented in Open3D [@Zhou2018].
Next, the radial-basis function fitting algorithm from the GIAS2 software package [@Zhang2016] was run twice using a thin-plate spline to approximate the foot surface [@Park2015a; @KIM2016]. 
The mid-stance scan from each subject was registered first to the template, and then the registration process was run both forwards towards toe-off and backwards towards heel-strike, on a scan-by-scan basis, using the previously registered scan as a template for the next scan. 
Accuracy was checked by comparing registered scans with the processed scans by finding corresponding points between both, and calculating the root-mean-squared error (RMSE) between the corresponding points. 

Anatomical landmarks can be reliably approximated from the registered scans [@VandenHerrewegen2014b]. 
The first metatarsal head, fifth metatarsal head, and second toe landmarks were used to align all scans to be centered at the second metatarsal head, with the forward axis pointing towards the second toe.
Landmarks around the metatarsal-phalangeal (MTP) joint and ankle joint were used to calculate ankle, MTP, and foot kinematics for each subject's scans with respect to the joint angles at the subject's mid-stance scan.
Relevant joint angles include dorsi/plantarflexion, ankle inversion/eversion, ankle internal/external rotation,  MTP dorsi/plantarflexion, foot inversion/eversion, and foot internal/external rotation angles  

## Model Construction

Principal component (PC) analysis is a dimensionality-reduction method commonly in constructing SSMs [@Reed2008; @Park2015a; @Conrad2019; @Stankovic2020].
The first PC represents an axis containing the largest variance in the dataset, and each subsequent PC describes the largest variance orthogonal to the previous component's axis. 
Therefore, PCs allow for a new, smaller set of orthogonal variables to be defined which represent the variance in the dataset.

Let $N$ equal the number of total scans in the dataset, and $n=29873$ equal the number of vertices in each registered scan. The scikit-learn module [@JMLR:v12:pedregosa11a] was used to incrementally calculate the maximum $N$ PCs which represent the dataset.
Each scan in the dataset is represented in the PC model with $N$ PC scores. 
All PC scores are centered around 0, which represents the mean foot scan of the dataset containing all subjects. 
Each PC represents a shape mode in the SSM, where each score represents a deviation from the mean foot along the shape mode axis. The resultant PC model can be used to inverse transform a vector of length $N$ PC scores into a $29873\times 3$ vector, which represents the location of the vertices in the foot shape. Not all PCs were retained in the model since the first few PCs explain a majority of the variance, while additional PCs may be accounting for noise.

Subject demographic data and calculated joint angles were incorporated into the SSM by developing multivariate linear regression models based on these features. 
This was used to predict each PC score, which can then be inverse-transformed into a foot shape.
Subject demographic data and joint angles were normalized and power-transformed to aid in regression development [@Yeo2000].
An elastic net regularization algorithm [@Zou2005] was run for each multivariate regression to calculate normalized feature coefficients for each PC score's regression. 
Two different sets of predictors were created, one with all subject demographic data and calculated joint angles, and one with the highly cross-correlated predictors of arch length, body-mass index, and height were removed (see Supplementary Figures). 
Six potential models were built as combinations between the number of PCs predicted which explained 95%, 98%, and 99.7% of the variance, and the two predictor sets. 


## Model Validation

All six models were validated for performance using leave-one-out cross-validation, where scans from each subject were set as the validation set, and models were trained on the remaining dataset. 
Model performance during validation was quantified with the root mean squared error (RMSE) of the predicted foot shape to the corresponding registered scan. 
A two-way RMANOVA analysis was run on the error distributions to test the effect of constructing a predictor with the different number of PCs, and between using the two variable sets. 
The chosen model was retrained on the whole dataset before being analyzed. 
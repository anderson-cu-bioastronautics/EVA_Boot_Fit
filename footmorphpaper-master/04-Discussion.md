# Discussion 

This study was designed to construct and evaluate a parametric SSM in  explaining and predicting dynamic foot morphology changes across the subject population. 
The model was able to predict dynamic foot shape across the subject population with an average RMSE of 5.2 $\pm$ 2.0 mm. For context, if all possible prediction error was accumulated to only affect length and width, it would be higher than the half-size step of the American shoe sizing system [@Luximon2013], but less than inter-brand variability of shoe length and shoe width [@Wannop2019].
Further, this error is lower than the RMSEs of other parametric SSMs that predicted static standing child body shape (mean=10.4mm) [@Park2015a], dynamic shoulder deformation (mean=11.98mm) [@KIM2016] and child torso shape (mean=9.5mm) [@Park2017]. Note though, that the presented model may have lower prediction errors due to the foot being a relatively smaller section of the body to model. Grant et al's model reconstructed internal foot bones with much lower RMSEs from sparse anatomical landmarks (1.21-1.66 mm for various foot segments) [@Grant2020] but was trained with higher resolution MRI images. Other efforts to create statistical foot shape models did not incorporate parametric prediction of foot shape [@Conrad2019; @Stankovic2020]. 

The first, second, and fourth shape modes, accounting for a total of 86.7% of total variance, capture gross foot motion.
Foot motion during stance is dominated by MTP and ankle dorsi/plantarflexion [@Leardini2007], which is captured in the first shape mode ([@fig:pca_overlay]).
The second and fourth shape modes capture gross changes in foot rotation from frontal and transverse plane movements at the MTP and ankle joints, respectively ([@fig:pca_overlay]). 
The second shape mode is most affected by foot inversion/everison around the MTP joint. 
The second shape mode also captures girth scaling at the ankle joint, as seen in ([@fig:pca_overlay]) by how the ankle girth decreases along the axis, and is affected by weight ([@fig:coefs]).
The fourth shape mode is affected by ankle inversion/eversion and internal/external rotation. 
Foot inversion/eversion, ankle inversion/eversion, and ankle internal/external rotation are expected to vary across the stance phase ([@Leardini2007]), which leads to the observed changes in gross movement. 
However, the second and fourth shape modes are slightly affected by foot length, which may suggest inter-individual effects in foot inversion/eversion, ankle inversion/eversion, and internal/external rotation during gait.
There is a slight correlation between these angles and foot length (see supplementary figures), which may be due to differences in cadence when walking at the treadmill's set speed.
Individuals were given time to acclimate to the treadmill's set speed, but the speed may not have been their preferred walking speed. 

The third shape mode captures foot shape scaling at the rearfoot, as highlighted in ([@fig:pca_quad]).
Foot length shrinks when moving positively along the third shape mode ([@fig:pca_overlay]), and thus has a negative effect from foot length.
There are also negative effects from foot width and weight, which may be due to their correlation to foot length (see supplementary figures).
Rearfoot morphology along this shape mode has a more rounded shape in the negative direction, and a sharper shape in the positive direction ([@fig:pca_overlay]).
There is also a negative effect from foot inversion/eversion ([@fig:coefs]), indicating that with foot eversion, a sharper rearfoot shape is expected.
This may be due to foot eversion at heel-off [@Leardini2007], where the foot unloads from a rounder weight-bearing rearfoot to a sharper non-weight bearing  rearfoot shape. 

Midfoot girth increases and the rearfoot is rounder along the fifth shape mode's axis ([@fig:pca_overlay]).
The fifth shape mode is positively affected by foot length and negatively by MTP dorsi/plantarflexion ([@fig:coefs]). 
This suggests that static midfoot girth increases with foot length, and decreases through heel-off as the MTP dorsiflexes.
Rearfoot morphology is rounder for longer foot lengths but gets sharper through heel-off with MTP dorsiflexion, much like in the third shape mode.
Midfoot girth was previously found to decrease during stance phase compared to statically standing [@Grau2018], most likely due to intrinsic and extrinsic foot muscle contraction [@Scott1993; @Gefen2000]. 
However, it was not noted where during stance phase midfoot girth decreases, but it can now be assumed it occurs during heel-off. 

The sixth shape mode captures girth changes at the ankle, midfoot, and the medial MTP joint region ([@fig:pca_quad]), with girth increasing along the axis. 
There are positive effects from ankle internal/external rotation and weight, while there is a negative effect from ankle inversion/eversion ([fig:coefs]). 
Static MTP, midfoot, and ankle girth may therefore increase with subject weight.
Dynamic girth changes in these regions may occur as the ankle everts and internally rotates just prior to toe-off,  where muscle activation is needed to push the foot off the ground. 
The foot is stiffened through tension in the MTP joints in order to prepare for toe-off [@Hicks1954], and the MTP joints are known to move relatively within the foot during gait [@Wolf2008; @Lundgren2008] which may be resulting in the increased girth at the MTP joint. 
A similar mechanism may be occuring at the ankle joint during ankle inversion and internal rotation, where tension from muscle activation prior to toe-off may cause increased girth. 

The seventh and eight shape modes, accounting for 1.3% of total variance, capture girth increases near the medial malleolus along their axes ([@fig:pca_quad]).
They are both positively affected by ankle inversion/eversion ([@fig:coefs]), and the eight shape mode is further negatively affected by ankle internal/external rotation. 
This may suggest that the girth around the medial malleolus decreases prior to push-off, as the ankle everts and internally rotates. 

Observed girth changes at the ankle joint, medial malleolus, midfoot, and MTP joint can be directly mapped to footwear design recommendations for increased fit and comfort. Midfoot girth decreased as the MTP joint is dorsiflexing after heel-off.
Midfoot, ankle, and MTP joint girth increased and medial malleolus girth decreased through ankle eversion and external rotation just prior to toe-off. 
Footwear should be designed to follow these volume changes as the footwear itself goes through the same motions, to ensure proper support for the foot to drive the footwear through the stance phase and toe-off. 
For example, footwear may be designed to first contract as the MTP joint dorsiflexes, then subsequently expand around the midfoot, ankle and MTP joints while contracting around the medial malleolus as the ankle everts and externally rotates. 

A number of limitations in this study should be noted. 
The elastic-net method is able to retain cross-correlated predictors, but still requires some bias in the dataset to predict scenarios where cross-correlated predictors are independent  [@Zou2005].
Therefore, the presented model may not be valid for predicting changes in morphology due to independent changes in joint angles outside of stance phase, or for variance in foot width or weight compared to foot length not captured in the subject population. 

The model did not capture differences between male and female feet. 
Studies found that sex differences in foot shape after scaling for foot length were not significant [@Kouchi2009; @Barisch-Fritz2014a; @Conrad2019], or were small in magnitude [@Wunderlich2001;@Krauss2008].
No subject demographic data was collected to account for differences in foot shape due to ethnicity [@Jurca2019].
No data was captured on the foot's plantar surface due to limitations with the scanning system; therefore foot arch changes were not captured. 
Data captured around the toes had high noise, which necessitated smoothing the toes in the template to ease fitting.
Future advances in 4D scanning may alleviate some of these concerns, and also allow for expansion of this model to higher frequency foot motions, such as running. 


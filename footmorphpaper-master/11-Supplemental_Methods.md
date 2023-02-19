
# Appendix I : Supplemental Methods {-}

Following is more details on the mesh construction, template registration, and joint angle calculation methods. 

## Mesh Construction

The C++ implementation of the PointCloud Library [@Rusu2011] was used to identify and isolate the right foot from the point set. 
First, the point clouds were downsampled with a voxel size of 3 mm to reduce required computing power. 
A RANSAC algorithm [@Fischler1981] was used to identify the flat treadmill floor with a plane model, and remove it from the point cloud. 
Euclidean cluster extraction was then used to detect the point clusters that make up each foot.
The total color value of each point cluster was used to identify the right foot from the left foot, as the left foot had a lower total color value due to the black sock. 
The left foot was then removed from the point cloud, leaving only the right foot for processing. 

Poisson surface reconstruction was done using Open3D [@Zhou2018]; this adds a topological layer interpreted from the pointcloud.
Point normals were calculated for the point cloud using the 10 nearest neighbors. 
A ball-pivoting algorithm [@Bernardini1999] is then used with the point normals to estimate the surface from the point cloud and construct the foot scan mesh. 

## Foot Template Registration

From the provided template, the toes were smoothed into a single structure and parts of the upper shank removed to be better fit to the captured data, with a finalized structure of 29873 points. 
The overall registration process follows a three-step process: a rough alignment followed by two radial-basis function (RBF) fine alignment steps

The registration process was first completed for each subject's data with a foot scan mesh manually identified near mid-stance. 
A point-to-plane iterative-closest-point (ICP) algorithm [@Chen1992] was used to roughly align the template foot to the scan mesh with the Open3D library [@Zhou2018]. 

Corresponding points between both the scan mesh and the ICP-aligned template were found using a radial-search KD-Tree implemented in the Open3D library [@Zhou2018]. 
Any points on the scan mesh which were not within 1 cm of a corresponding point on the aligned template were deleted; these points represented parts of the treadmill floor which were missed in the RANSAC identification and parts of the upper shank. 
Similarly, any points on the template not within 1cm of a corresponding point on the scan mesh were temporarily set aside from the template; these points correspond to those near holes in the scan mesh which would be refilled in later processing

Thin-plate spline RBFs have been used to surface fit templates to scanned body shapes [@Park2015a], and so were used in two stages in this research. 
A first-pass RBF registration, using a thin-plate spline for interpolation, was done between the template and the scan using the GIAS2 package [@Zhang2016]
To prevent overfitting of the RBF to the noise on the edges of the captured pointcloud, a maximum of five iterations were done on the first-pass RBF registration process. 
The first-pass registered RBF template was then appended with the points previously removed from the template. 
This intermediate template represents the template fitted to the known scan data, with any unknown sections (e.g. holes in the scan data), taking the value of the template. 
However, the disparity between the known and unknown sections created major discrepencies in the morphed template not representative of the scan data. 

A second-pass RBF registration was done from the ICP-aligned template to the intermediate template with the same parameters as the first-pass registration.
This smooths out the unknown sections representing holes in the scan data with the surrounding known sections. 
The second-pass registered template was saved as the final registered template. 

Following the registration of the mid-stance scan, the process was repeated both forwards towards toe-off and backwards toward heel-strike on a scan-by-scan basis.
In this iterative fashion, the previous scan’s registered template was used as the template for the following scan. 
During the iterative registration process, the RBF alignment was only conducted for one iteration for both the first-pass and second-pass to prevent over-fitting.

## Joint Angle Calculation

The original template identified the lateral malleolus, medial malleolus, 1st metatarsal head, 5th metatarsal head, and 2nd toe landmarks as certain vertices. 
New landmark vertices for the lateral shank and medial shank were manually picked on the template. 

Post-registration scans were aligned to a common coordinate frame based around the toes.
The origin was defined as the point along the vector from the 1st metatarsal head landmark to the 5th metatarsal head landmark which is orthogonal to the second phalange. 
From the origin, the x-axis, was defined as pointing towards the 2nd toe.
The y-axis, was pointed towards the 5th metatarsal. The z-axis was the cross-product of both x- and y-axes, pointed upward. 
This coordinate system also served as the static coordinate system for the MTP joint. 

The ankle joint center was defined as the midpoint between the medial and lateral malleous. 
The ankle's local z-axis is aligned vertically with the shank center, defined as the center between the lateral shank and medial shank landmarks. 
The ankle's local y-axis is aligned from the shank center to the lateral malleolus. 
The ankle's x-axis is the cross-product of the y- and z-axis, pointed in the forward direction towards the toes.

Static reference angles were taken from these coordinate systems at mid-stance. 
For the ankle joint, the z-axis served as the internal/external rotation axis, the y-axis as the dorsi/plantarflexion axis, and the x-axis as the inversion/eversion axis.
Since the model's origin was at the toes, the calculation for MTP dorsi/plantarflexion was modified. 
The new local MTP joint coordinate system had the x-axis defined as pointing from the ankle joint center to the MTP joint center, as such the y-axis represented MTP dorsi/plantarflexion. 
Since there is little flexibility in the transverse and frontal planes of the MTP joint, the x-axis therefore represented whole foot inversion/eversion,  and the z-axis represented whole foot internal/external rotation around the origin. 
MTP and ankle joint angles were calculated for every other scan as the Euler angle difference from the static joint coordinate system around each axis. 
Each subject's joint angles are low-pass filtered with a 2nd order low-pass Butterworth filter with a cutoff frequency of 15 Hz. 
The global and local coordinate systems are summarized in [@fig:angles].

![Coordinate system defined from registered scans. Anatomical landmarks are shown as black dots. The ankle joint's local coordinate system is shown in blue, the MTP joint's local coordinate system is shown in yellow, and the model's origin coordinate system is shown in red. Directions for each coordinate system are shown in bold text](fig/coordsystem.png){#fig:angles width=90%}
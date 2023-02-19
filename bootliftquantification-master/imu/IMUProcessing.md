# IMU Data Processing Steps

## Pre-processing raw data

The Opal IMU data files are saved as .h5 binary files, with one file saved for each subject/configuration combination.
Each binary file includes all the data collected for each set of trials. 
The .h5 files are saved in a folder for each subject, and are accompanied by .mat files which outline the starting and stopping times of each trial. 

The function ``processTrials(subject,config)`` translates each .h5 file into an ``IMUTrial`` object, of length equal to the number of trials collected per subject/configuration.

The ``IMUTrial`` object contains the following properties for each IMU:
* subject
* config
* trialNum
* numSamples
* time
* sampleRate
* IMUs (hidden)
* IMUNames (hidden)
* strIdx (hidden)
* endIdx (hidden)


When ``IMUTrial`` is called, a nested function ``loadTrialData`` is run to add data to the each IMU saved in the ``IMUTrial`` object.

``getIMUData.m`` was written to process and save the properties of each ``IMUTrial``object into a single ``.mat`` file for each trial.

``getIMUData.m`` saves the following data into the properties with ``.mat`` file, where *n* is the number of samples collected in each trial:

|Property|Value|Shape|
|:-------|:----|:----|
|name|IMU Label|string|
|time|Time vector|(nx1)|
|accel| gravity removed acceleration vector|(nx3)|
|quart| APDM calculated quaternions|(nx4)|
|euler| APDM calculated euler angles|(nx3)|
|eulerFromQuart| Self-calculated euler angles|(nx3)|
|invquart| Inverse APDM calculated quaternions|(nx4)|
|eulerFromQuartInv| Self-calculated inverse euler angles|(nx4)|
|sampleRate|sample rate|int|

APDM quaternions are given as the global-local transformation of the IMU.
Inverse quaternions (``invquart`` ) are calculated using ``quatinv.m``. 

The gravity removed acceleration vector is given by APDM. 
The self-calculated euler angles are calculated with the function ``quart2euler.m``, using the following formula:
$$
\begin{bmatrix}
\phi\\
\theta\\
\psi\\
\end{bmatrix}=
\begin{bmatrix}
arctan\frac{2(q_{0}q_{1}+q_{2}q_{3})}{1-2(q_{1}^{2}+q_{2}^{2})}\\
arcsin(2(q_{0}q_{2}-q_{3}q_{1}))\\
arctan\frac{2(q_{0}q_{3}+q_{1}q_{2})}{1-2(q_{2}^{2}+q_{3}^{2})}\\
\end{bmatrix}
$$








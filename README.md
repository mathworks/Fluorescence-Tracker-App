# Fluorescence Tracker App
This app uses computer vision point tracking to quantify near infrared signals emitted by (ICG) Indocyanine Green during fluorescence angiography.  A quick overview of how this app works can be seen in the following 4-minute video: [How to Detect and Track Features in a Video](https://www.mathworks.com/videos/how-to-detect-and-track-features-in-a-video-1648706043636.html).

The following research in colorectal cancer was carried out using this software: ["Digital Dynamic Discrimination of Primary Colorectal Cancer using Systemic Indocyanine Green with Near-infrared Endoscopy"](https://rdcu.be/clDRi) by Jeffrey Dalli et al., UCD Centre for Precision Surgery, School of Medicine, University College Dublin, Ireland (2021).

This research is also highlighted in the article ["Automating Endoscopic Tissue Characterization in Cancer Patients with Computer Vision"](https://www.mathworks.com/company/newsletters/articles/automating-endoscopic-tissue-characterization-in-cancer-patients-with-computer-vision.html).

## Requirements
* MATLAB R2020b (or newer)
* Image Processing Toolbox, Computer Vision Toolbox, and Statistics and Machine Learning Toolbox
* Please see the [Fluorescence Tracker App User Guide](https://github.com/mathworks/Fluorescence-Tracker-App/blob/main/FluorescenceTrackerUserGuide.pdf) for video format requirements
* <code>FeatureTrackingUsingKLTExample.mlx</code> is a reference example independent of the Fluorescence Tracker App

## Installation and Setup
* Download/navigate to the installer file (Fluorescence Tracker.mlappinstall)
* Double-click on the installer file
* Click "Install" when prompted in MATLAB
* The app will then appear in the APPS tab in MATLAB
* The app source code can then be found in the installation folder specified by your MATLAB Add-Ons Preferences (or by querying the [app installation location](https://www.mathworks.com/help/matlab/ref/matlab.apputil.getinstalledappinfo.html))
* Please see the [Fluorescence Tracker App User Guide](https://github.com/mathworks/Fluorescence-Tracker-App/blob/main/FluorescenceTrackerUserGuide.pdf) for more information

## References
* [Overview of MATLAB Apps](https://www.mathworks.com/help/matlab/creating_guis/apps-overview.html)
* [App Building with MATLAB](https://www.mathworks.com/help/matlab/gui-development.html)
* [Feature Detection and Extraction with MATLAB](https://www.mathworks.com/help/vision/feature-detection-and-extraction.html)
* [Tracking and Motion Estimation with MATLAB](https://www.mathworks.com/help/vision/tracking-and-motion-estimation.html)

[![View Fluorescence Tracker App on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/89679-fluorescence-tracker-app)

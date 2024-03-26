# Fluorescence Tracker App  [![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=mathworks/Fluorescence-Tracker-App)

This app uses computer vision point tracking to quantify near infrared signals emitted by (ICG) Indocyanine Green during fluorescence angiography.  Short overview videos of how to use this app can be found in the ["How To" Video Series for Biomedical and Pharmaceutical Applications](https://www.mathworks.com/videos/series/how-to-video-series-for-biomedical-and-pharmaceutical-applications.html).

The following research in colorectal cancer was carried out using this software: ["Digital Dynamic Discrimination of Primary Colorectal Cancer using Systemic Indocyanine Green with Near-infrared Endoscopy"](https://rdcu.be/clDRi) by Jeffrey Dalli et al., UCD Centre for Precision Surgery, School of Medicine, University College Dublin, Ireland (2021).

This research is also highlighted in the article ["Automating Endoscopic Tissue Characterization in Cancer Patients with Computer Vision"](https://www.mathworks.com/company/newsletters/articles/automating-endoscopic-tissue-characterization-in-cancer-patients-with-computer-vision.html).


## Requirements
* MATLAB R2020b (or newer)
* Image Processing Toolbox, Computer Vision Toolbox, and Statistics and Machine Learning Toolbox
* Please see the [Fluorescence Tracker App User Guide](https://github.com/mathworks/Fluorescence-Tracker-App/blob/main/FluorescenceTrackerUserGuide.pdf) for video format requirements


## Installation and Setup
* Download/navigate to the installer file (<code>Fluorescence Tracker.mlappinstall</code>)
* Double-click on the installer file
* Click "Install" when prompted in MATLAB
* The app will then appear in the APPS tab in MATLAB
* The app source code can then be found in the installation folder specified by your MATLAB Add-Ons Preferences (or by querying the [app installation location](https://www.mathworks.com/help/matlab/ref/matlab.apputil.getinstalledappinfo.html))
* Please see the [Fluorescence Tracker App User Guide](https://github.com/mathworks/Fluorescence-Tracker-App/blob/main/FluorescenceTrackerUserGuide.pdf) for more information
* 3 reference examples are available in the <code>howto</code> folder and can be used independent of the app:
  * <code>FeatureTrackingUsingKLTExample.mlx</code> from [How to Detect and Track Features in a Video with MATLAB](https://www.mathworks.com/videos/series/how-to-video-series-for-biomedical-and-pharmaceutical-applications.html)
  * <code>ImageRegistrationExample.mlx</code> from [How to Register and Align Features in a Video with MATLAB](https://www.mathworks.com/videos/how-to-register-and-align-features-in-a-video-with-matlab-1687170979668.html)
  * <code>FluorescenceClassification.mlx</code> from [How to Develop a Machine Learning Classifier with MATLAB](https://www.mathworks.com/videos/how-to-develop-a-machine-learning-classifier-with-matlab-1687171767480.html)


## References
* [Overview of MATLAB Apps](https://www.mathworks.com/help/matlab/creating_guis/apps-overview.html)
* [App Building with MATLAB](https://www.mathworks.com/help/matlab/gui-development.html)
* [Feature Detection and Extraction with MATLAB](https://www.mathworks.com/help/vision/feature-detection-and-extraction.html)
* [Tracking and Motion Estimation with MATLAB](https://www.mathworks.com/help/vision/tracking-and-motion-estimation.html)
* [Image Registration with MATLAB](https://www.mathworks.com/help/images/image-registration.html)
* [MATLAB for Machine Learning](https://www.mathworks.com/solutions/machine-learning.html)

[![View Fluorescence Tracker App on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/89679-fluorescence-tracker-app)

_Copyright 2021-2023 The MathWorks, Inc._

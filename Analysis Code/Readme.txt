This repository contains code to run a psychophysics eye-tracking double-step ramp task for the project titled ‘Predicted Position Error Triggers Catch-up Saccades During Sustained Smooth Pursuit’. For those wishing to replicate the findings from this study, the analysis code and steps are provided as well.
Data collected during the summer of 2018 pertaining to the paper can be found in this dryad repository: https://doi.org/10.5061/dryad.245j1p8
The pre-registered report related to this study can be found on OSF: https://osf.io/wvjbf/
To begin, clone the repository and ensure all system requirements are met. 
System requirements:
- MatLab 2017 or higher
- Psychophysics toolbox
- Eyelink 1000
Under Task Code, users can find a file titled ‘SaccadeTriggerTask’. After adjusting for particular experiment parameters such as screen width, distance etc, run the code. This will generate a dialogue box to input subject and session information and task conditions. For review of the double-step ramp task, refer to the pre-registration linked above. 
Once the last trial is finished, users should make sure the .mat and .edf file are saved in the appropriate location or moved to a subject and session specific directory. 
For the analysis pipeline to work, users should follow the naming scheme found in the documentation, and ensure the same directory hierarchy. The following diagram outlines the analysis pipeline in order to generate the same figures from the paper. 


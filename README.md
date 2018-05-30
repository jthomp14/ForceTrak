# ForceTrak
ForceTrak MATLAB app
ForceTrak Readme
This provides a broad overview of what each script does
Last Updated: May 24th, 2018


————————————————————————————————————————————————————————————————————————————————————————————————————————————————
Table of contents:
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
Explanation of scripts / .m files:
1) ForceTrak.m
2) BoxMainTrackOneVid.m / BoxMainTrack2Vid.m
3) boxtracking_dualsorted.m
4) improc.m
5) marker.m
6) MarkerTrackingMainCode.m
7) OccultationCalc.m
8) Power_CalcNOPLOT.m
9) replaceNAN.m
10) Segments.m
11) uccslogo.jpg
12) vidsync.m
13) Windowspline.m
14) Winter_Table4.1.xlsx

Other Pertinent information:
15) Planned Updates
————————————————————————————————————————————————————————————————————————————————————————————————————————————————







————————————————————————————————————————————————————————————————————————————————————————————————————————————————
1) ForceTrak.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- This script is the primary graphical user interface (GUI) script

- It sets up the GUI, tabs, buttons, text, boxes, etc.
- These are organized near the top of the script

- ForceTrak is a class, and object oriented programming approach is used

- The properties are all things that are stored under the ForceTrak class and are assigned as the user 
interacts with the app
- Objects (of class ForceTrak) obtain the properties
- Properties are analogous to the structure class built into MATLAB

- Methods are analogous to functions
- The methods in ForceTrak work such that they execute when the user interacts with the GUI in 
various ways
- For example, if the user clicks a button, there is a method to determine what happens after 
that button is clicked

- In the ForceTrak script, the initial markers are set up
- Currently the old method of doing this stores initial positions of markers in a 3-dimensional 
matrix “markerpos1” and “markpos2”
- This is still functioning
- Additionally, a class called “marker” (see explanation marker.m below) stores the initial position 
data in a “markerarray” variable that is an array of variables of class “marker”
- Various properties of each marker are stored in the marker class objects
- At some point, the markerpos1 and 2 can be removed from the program, but for now 
“boxtracking_dualsorted.m” still partially functions on the 3-D Matrix way of storing 
coordinates

- Finally, ForceTrak assigns all necessary properties to a new instance (or object) of the class 
“ForceTrak” called “output1” and “output2”
- These “output” variables are what feeds into the scripts:
- BoxMainTrackOneVid.m
- BoxMainTrack2Vid.m
- The properties under the output objects are used to do the actual tracking for the program
- There may be a better, more organized way of doing this, but at the time (may 24th 2018) of 
writing this, the functionality of this organization structure is working, and thus is not a 
priority for re-structuring
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
2) BoxMainTrackOneVid.m / BoxMainTrack2Vid.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- These scripts take the “output1” properties in the case of 1 video (BoxMainTrackOneVid.m) or, for the 
case of 2 videos takes the “output1” and “output2” (BoxMainTrack2Vid.m) and assigns them to a struct 
called Svid1 and or Svid2.

- The main function is to get all the data organized for the execution of “boxtracking_dualsorted.m”

- The scriptstake all tracking coordinate information and save that information to excel documents, and 
also then output the final tracking coordinates to the ForceTrak method where BoxMainTrackOneVid is 
called

- Commented out (at the time (may 24th 2018) of writing this readme) is code to generate a video of the 
results
- This is available for use when testing the system to see frame-by-frame the tracking results,
where the .avi video was used as it allows for easy frame by frame viewing.  If using this,
simply uncomment the code, and ensure after the video is done plotting, it is opened outside of
MATLAB (right click video file, open outside of MATLAB)
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
3) boxtracking_dualsorted.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- This is the main workhorse script that conducts all the tracking analysis, including testing for 
occultation and executing the occultation solution

- This script iterates through each frame for each selected marker and finds the centroid of the marker
- During occultation, the system assigns an arbitrary value to the occulted marker, and then using
the information obtained for that frame from all markers, calculates the position of the occulted
marker as necessary.
- Special Note: an error will be generated if any two markers occult on any given frame
- The occultation functionality only works for occultation of the hip, knee, and thigh markers
- Lighting and shadows (at the time of writing this readme (may 24th 2018)) greatly increase 
noise of both the normal tracking results and the occultation calculation results
- At the time of writing this readme (may 24th 2018), additional testing is needed to 
ensure the markers, once there is no more occultation happening, get easily picked 
back up by the normal tracking methods

- The script also plots the positions of each marker, for each frame in the reference distance tab on the
GUI.
- At the time of writing this readme (may 24th 2018), work is being done to make this plotting 
optional
- Preliminary tests show, that when the plotting is engaged, it takes roughly 0.9 - 1.6 seconds
to calculate the positions of markers per frame.
- Without the plotting this is reduced to roughly 0.04 - 0.07 seconds, which is a huge
decrease, especially if there exists 1 full second of data, then the user can expect to
wait to get their results a full 2 minutes at 120fps if plotting is engaged

- The script currently runs partially on markerpos (3D matrix storage of marker positions) and on the
marker array - which is of class “marker.”  Future work needs to be done to phase out the markerpos
Portions of the algorithm and utilize the marker class 100%.  Though this is not currently a high 
priority, as it does not seem to be affecting the efficiency of the algorithm too much.
- The main purpose of this transition is to get away from MATLAB’s inherent matrix functionality
to make the transition to another language easier (one that runs on object oriented programming)
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
4) improc.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- This is the image processing class with associated functions for image processing.  Each function is
Clearly marked, and this script includes the following functions/methods:
- A clicking / get values method (for the initial rbg/hsv values for the first frame)
- A host of binary image functions used for the marker tracking
- Centroid functions for finding marker centroids.
- Other misc functions/methods
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
5) marker.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- This is the marker class file.  This contains all the properties of class marker and the associated
Functions/methods.  The purpose of this script is to define all the necessary information for the marker
class setup so the app can store pertinent information for each individual marker and have necessary
functions to deal with calculations/adding markers/etc.

- There are some unused methods and unnecessary properties that, At the time of writing this readme 
(may 24th 2018), could be deleted and cleaned up.

- For the most part, each method is explained as to it’s functionality/purpose, and each property is fairly
self explanatory.
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
6) MarkerTrackingMainCode.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- At the time of writing this readme (may 24th 2018), Not sure what this does.  Needs to be further
investigated to determine necessity, functionality, and purpose.
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
7) OccultationCalc.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- This creates a class called OccultationCalc that stores all the necessary properties (i.e. initial
marker geometry, angles, etc.) and contains the functions/methods for dealing with occultation.

- Occultation is only handled for the hip, knee, and thigh markers.  This currently, at the time of 
writing this readme (may 24th 2018) does not have the functionality to deal with occultation of two
markers on the same frame.

- At the time of writing this readme (may 24th 2018), verification of the initial marker geometry needs to
be conducted to ensure the occultation calculation handles angles that exist in all 4 quadrants.

- The calculations for occultation are done with modeling the markers in an inertially fixed reference
frame (origin at the bottom left hand corner of any given frame), and vector math is used to calculate
the position of a marker when occulted based on the average geometry of markers relative to
one another and the origin of previous frames.
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
8) Power_CalcNOPLOT.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- 




————————————————————————————————————————————————————————————————————————————————————————————————————————————————
9) replaceNAN.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- At the time of writing this readme (may 24th 2018), it is unknown why this function exists.
- Further investigation must be done to determine the functionality/purpose of this algorithm.  It
may have something to do with filtering data in the Power_CalcNOPLOT.m original code (prior to
implementing the marker class)
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
10) Segments.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- This is a segments class, similar to defining properties and methods/functions for the marker class,
that houses the segment data (i.e. lower leg, thigh, etc…)

- At the time of writing this readme (may 24th 2018), this class is currently being constructed.  The plan
is for this segment class to calculate all necessary segment information and store that information
within the segment properties.  Then, based on user input with the GUI, necessary data plots or writes
to excel can be extracted and performed.  

- The goal is for this class to handle all the power, energy, moments, etc. that occur / get calculated
for each individual segment.
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
11) uccslogo.jpg
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- The image used on the main tab of the GUI
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
12) vidsync.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- Function that syncs two videos based on noise.
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
13) Windowspline.m
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- Primary method, at the time of writing this readme (may 24th, 2018) that smooths the data and calculates
velocities and accelerations from the marker positions. 
———————————————————————————————————————————————————————————————————————————————————————————————————————————————— 





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
14)Winter_Table4.1.xlsx
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- Excel document that contains all the anthropomorphic data from the Bioemecanics book (Author = Winter)
- Currently, at the time of writing this readme (may 24th 2018), the excel document is being used
for convenience.

- The plan is to hard code the variables for these values into the Power_calcNOPLOT.m file instead of
have that script read in an excel document.  This is low priority for now, and can be easily updated
at a later date.
————————————————————————————————————————————————————————————————————————————————————————————————————————————————





————————————————————————————————————————————————————————————————————————————————————————————————————————————————
15) Planned updates:
————————————————————————————————————————————————————————————————————————————————————————————————————————————————
- At the time of writing this readme (may 24th 2018), in no particular order of importance:

- Verify Occultation calculations (ensure works for all initial marker geometries)

- Deal with data smoothing (currently facing issues with large variability in velocities and 
accelerations
- Consider implementation of a filter method instead?

- Write code to do power, energy, etc. calculations
- This includes full system and segments

- Determine how to implement results on GUI for user to select the output data they want

- Get rid of excel read of anthropomorphic data

- Integrate a way for user to turn plotting on and off during the running of the analysis
- Have some way of, when plotting is off, to let user know that the system is “thinking”

- Get Github working - for source control and collaboration with Faith

- Devise method for verification of results (i.e. force plate, etc…)
————————————————————————————————————————————————————————————————————————————————————————————————————————————————






























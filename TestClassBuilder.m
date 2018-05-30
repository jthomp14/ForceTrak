%test build markers
%for testing functions in classes

clc
clear;

wristmarker = marker(12,16);
wristmarker.markername = 'wrist';
wristmarker.jointnum = 3;
wrist = 1;
wristmarker = addmarker(wristmarker,marker(13,17));
wristmarker = addmarker(wristmarker,marker(17,18));


hipmarker = marker(9,10);
hipmarker.markername = 'hip';
hipmarker.jointnum = 4;
hip = 2;
hipmarker = addmarker(hipmarker,marker(10,12));
hipmarker = addmarker(hipmarker,marker(11,13));


thighmarker = marker(6,7);
thighmarker.markername = 'thigh';
thighmarker.jointnum = 5;
thigh = 3;
thighmarker = addmarker(thighmarker,marker(8,10));
thighmarker = addmarker(thighmarker,marker(9,12));


kneemarker = marker(3,4);
kneemarker.markername = 'knee';
kneemarker.jointnum = 6;
knee = 4;
kneemarker = addmarker(kneemarker,marker(5,6));
kneemarker = addmarker(kneemarker,marker(7,7));



markerarray = [wristmarker,hipmarker,thighmarker,kneemarker];

OccultationData = OccultationCalc(length(markerarray));
OccultationData = addData(OccultationData,markerarray(knee).lastmarker,markerarray(hip).lastmarker,markerarray(thigh).lastmarker);





















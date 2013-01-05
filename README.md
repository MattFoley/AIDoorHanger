#AIDoorHanger

AIDoorHanger consists of a single class called AIDoorHangerWrapper which you can use to turn any of your UIViews into a door hanger which is rotated and animated as a damping pendulum with CoreMotion accelerometer data

#Requirements

Classes in this project supports both ARC and non-ARC projects

#Installation

Add the AIDoorHangerWrapper folder to your project

#How to use it?

    #import "AIDoorHangerWrapper.h"
    
    //just create a AIDoorHangerWrapper with your custom UIView
    AIDoorHangerWrapper *wrapper = [[AIDoorHangerWrapper alloc] initWithDoorHangerView:myCustomUIView];
    

![Screenshot](http://f.cl.ly/items/453n0w130h0V2V1m2f0F/Pastebot%202013-01-05%2020.58.21%20PM.png)

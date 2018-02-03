# 3D-CT-Lung-Scan-Registration

Image registration is the process of aligning and transforming a 2D or 3D image or multiple images
into a reference image. The sources of difference could be from numerous viewpoints, different
sensors, times or depths. In the field of medical imaging, where images are acquired fromvariety
of modalities, for example, X-ray scanners,Magnetic Resonance Imaging (MRI) scanners, Computed
Tomography (CT) scanners, and Ultrasound scanners, image registration, is an essential tool; because
it helps to combine patient data to yield additional anatomy information by finding the related spatial
information.

Deformable Image Registration (DIR) hasmany exciting potential applications in diagnostic medical
imaging and radiation oncology. Automated propagation of physician-drawn contours to multiple
image volumes, functional imaging, and 4D dose accumulation in thoracic radiotherapy are just a few
examples. However, before such applications can be successfully and safely implemented, we require
that the DIR spatial accuracy performance is rigorously and objectively assessed.
In this project, we are provided four cases including intensity volumes (inhale and exhale) plus
landmark points (see figure 1) to ’train’ that is to search for the optimal parameters in registration from
the moving chest to the fixed one. The goals of this project are to build a robust registration method
to predict 300 fixed landmarks based on provided inputs: inhale, exhale volumes and 300 moving
landmarks coordinates and evaluate by 3D Euclidean distance between transformed landmarks
(TRE).

## Softwares required
* MATLAB
* Elastix \href{http://elastix.isi.uu.nl/index.php}{http://elastix.isi.uu.nl/index.php}

## inhae and exhale images images example

![](images/inhale.PNG "inhae and exhale images")

## sample input and output

![](images/Selection_026.png "Sample input and output image")
![](images/Selection_027.png "Sample input and output image")

## sample output: True positive and False positive pixels
Red collor indicates False positive and Yellow collor is for False positive.

![](images/Selection_028.png "Sample input and output image")


* More detail of the project can be found in report.pdf file.


#ANPR
Source code for a License plate recognition ([ANPR]) demo for iOS using [OpenCV] and [Tesseract OCR] engine.

#Example

###Input
![Alt text](https://raw.github.com/chroman/ANPR/master/input.png "Input")

###Output
![Alt text](https://raw.github.com/chroman/ANPR/master/output.png "Output")

#Introduction
  - Experimental project
  - Require `<opencv2.framework>`
  - Tesseract OCR lang file (`testdata/eng.traineddata`) was trained using this [Gist] script file and a License Plate font.

#Version
1.0

##Improvements
* Improve image processing.
* Improve square (plate) detection.
* Perspective transform (or 3D).
* Improve contour detection algorithm.
* Improve ROI license plate area.
* Better image crop.

##Supports
* iOS 6.0 or later.
* Xcode 4.6 (ARC enabled).
* Required frameworks: oepncv2, UIKit, CoreGraphics and ImageIO.

#Contact
<a href="https://twitter.com/chroman">Follow @chroman</a>

#License

Copyright (c) 2013 Christian Roman, Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[ANPR]: http://en.wikipedia.org/wiki/Automatic_number_plate_recognition
[Tesseract OCR]: https://code.google.com/p/tesseract-ocr/
[OpenCV]: http://opencv.org/
[Gist]: https://gist.github.com/chroman/5745206
# Beer Recognition App

## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [Usage](#Usage)
* [Results](#Results)
* [Liscense](#License)


## General info

This app is part of my final project for university. It works by detecting beers from photo using the yolov2 model, then detecting image features for every detected beer using SIFT algorithm (from opencv framework). 
Then those arrays of features are compressed using the PCA algorithm(opencv framework), and then find closest neighbors. Those neighbors should be beers from that picture.


## Technologies

* Opencv
* Swift
* Objective-C
* machine learning
* [Annoy](https://github.com/jbadger3/SwiftAnnoy)

## Usage 

To run this project, compile it using Xcode and download dependencies from pod.
Unfortunately for now the backend is turned off, so nothing will work in the app.
You can still use mlpackage for beer bottle/can detection.


## Results 

interface examples:
![interface1](https://raw.github.com/MaciejSurowiec/beerapp-ios/main/examples/interface1.JPG)
![interface2](https://raw.github.com/MaciejSurowiec/beerapp-ios/main/examples/interface2.JPG)

recognition example:
![recognition1](https://raw.github.com/MaciejSurowiec/beerapp-ios/main/examples/recognition1.JPG)
![recognition2](https://raw.github.com/MaciejSurowiec/beerapp-ios/main/examples/recognition2.JPG)


## License
The code is licensed under the MIT license.

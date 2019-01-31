# HealthApp ![alt text](https://user-images.githubusercontent.com/42153044/51432658-cb6ce580-1c00-11e9-9593-efea6e7cc575.png)

HealthApp provides a series of tools to provide a better interaction between patients and doctors.
This application is integrated with HealthKit and Firebase, it means that every record of alimentation, sports and more are synchronized between doctor and patient in real time.
In addition incorporates an image analyzer, working in conjunction with automated learning algorithms to predict the presence of melanomas with just one photo.

## Getting started

### Prerequisites

* macOS
* Xcode
* Swift 4
* iOS 12

### Packages

* CocoaPods
* Firebase/Core
* Firebase
* Firebase/Storage
* Firebase/Database
* Firebase/Auth
* SCLAlertView (Optional)
* IQKeyboardManagerSwift (Optional)

### How to Install

1. Clone the project
2. Create a new Pod file from .xcodeproj
3. Install packages listed before
4. Drag and drop [Machine Learning Model](google.com) in HealthApp/Visual Recognizer (Check the Target Membership)
5. Drag and drop your own GoogleService-Info.plist into HealthApp/
7. Activate MapKit to your Apple ID (Targets -> Capabilities)

![alt text](https://user-images.githubusercontent.com/42153044/52024340-2f778f80-24c6-11e9-8652-c28989d6b9dc.png)

## About Trained Model

The model was trained with more than 3,000 images in high resolution

#### Type

Image Classifier

#### Size

20 kb

#### Description

A model trained to determine the pathology of a naevus

#### Model Evaluation Parameters

##### Inputs:

* Image (Color 299x299)

#### Outputs

* classLabelProbs (String -> Double): Probability of each category
* classLabel (String): Most likely image category

## languages
The app was manually translated to
* 🇺🇸 English (US)
* 🇲🇽 Spanish (MX)
* 🇪🇸 Catalan (ES)
* 🇫🇷 French (FR) (Beta)

## Some Screenshots
![alt text](https://user-images.githubusercontent.com/42153044/52024373-4f0eb800-24c6-11e9-9b23-7c70cda40c11.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024374-4f0eb800-24c6-11e9-82b3-8701295e8713.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024376-4f0eb800-24c6-11e9-963e-25b237c1a1dd.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024377-4fa74e80-24c6-11e9-9f5f-8f9fe1470fe2.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024378-4fa74e80-24c6-11e9-9d4a-86df3c70642c.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024379-503fe500-24c6-11e9-9710-c5d9e6609dd6.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024380-503fe500-24c6-11e9-90f9-0a1118e77e10.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024382-503fe500-24c6-11e9-9292-3d4d928ba042.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024383-503fe500-24c6-11e9-8f06-09cfdb9d87b9.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024384-50d87b80-24c6-11e9-9f16-6dc7cdd1a9d7.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024385-50d87b80-24c6-11e9-9259-c6d0b2dcea4d.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024386-50d87b80-24c6-11e9-8985-8104d16c76a1.png)
![alt text](https://user-images.githubusercontent.com/42153044/52024387-51711200-24c6-11e9-9c4b-0e77ecc88518.png)

## License
MIT

## Acknowledgements

* [ISIC](https://www.isic-archive.com/#!/topWithHeader/wideContentTop/main) For main image data set
* [MED-NODE](http://www.cs.rug.nl/~imaging/databases/melanoma_naevi/)

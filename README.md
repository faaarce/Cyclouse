# Food App

<div align="center">
       <h1> <img src="https://github.com/faaarce/Assignment3_Faris/blob/swift-data/Gif/Group%204%403x.png" width="80px"><br/>Cyclouse</h1>
     </div>

FoodApp is a mobile application that allows users to explore, select, and order their favorite dishes right from their smartphones. Built with Swift and UIKit, this application offers a sleek user experience with robust functionality.

## Screenshots

| ![Splash Screen](https://github.com/faaarce/Cyclouse/blob/development/Documentation/GIFs/RocketSim_Recording_iPhone_16_Pro_6.3_2024-11-24_16.21.59.gif?raw=true) | ![Login](https://github.com/faaarce/Cyclouse/blob/development/Documentation/GIFs/RocketSim_Recording_iPhone_16_Pro_6.3_2024-11-24_16.22.45.gif?raw=true) | ![Home](https://github.com/faaarce/Cyclouse/blob/development/Documentation/GIFs/RocketSim_Recording_iPhone_16_Pro_6.3_2024-11-24_16.23.28.gif?raw=true) | ![Checkout](https://github.com/faaarce/Cyclouse/blob/development/Documentation/GIFs/RocketSim_Recording_iPhone_16_Pro_6.3_2024-11-24_16.23.58.gif?raw=true) | ![Profile](https://github.com/faaarce/Assignment3_Faris/blob/swift-data/Gif/onboarding.gif?raw=true) |
|:---:|:---:|:---:|:---:|:---:|
| Splash Screen | Login | Home | Checkout | Onboarding |

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Tech Stack](#tech-stack)
- [License](#license)

## Features

- **Home Page**: Utilizes nested collection views to display various food categories and items in an organized manner. 
- **Detailed Food View**: Users can view detailed descriptions of food items and add them to their order with ease. 
- **Persistent Storage**: Integration of SwiftData, the newest persistent storage solution in Swift, to store and manage user orders and preferences. 
- **Authentication**: Secure user authentication managed via Firebase, ensuring safe access to user accounts and data. 
- **Tab Bar Integration**: Each page is embedded within a tab bar interface, allowing for easy navigation between the Home, Order, and Profile sections. 
- **Enhanced Onboarding**: A collection view connected with an indicator page provides a seamless onboarding experience for first-time users.


## Installation

1. **Clone the repository**
   ```sh
   git clone https://github.com/faaarce/Assignment3_Faris.git
   ```

2. **Open the project**
   Open the cloned repository in Xcode.

3. **Install dependencies**
   This project uses CocoaPods for dependency management. Run the following command to install the necessary dependencies:
   ```sh
   pod install
   ```

4. **Set up Firebase**
   - Go to the Firebase Console and sign in with your Google account.
   - Register your app with the iOS bundle ID found in your Xcode project settings.
   - Download the GoogleService-Info.plist file when prompted and add it to your Xcode project (drag and drop into the project navigator).

## Usage

Here is an example of how to use the Food App:

1. **Launch the app and complete the onboarding process.**

2. **Sign in using your Firebase-authenticated account.**

3. **Browse the food categories on the Home page.**
 
4. **Add items to your order from the detailed food view.**

5. **Access your order via the tab bar and modify it as needed before final checkout.**



## Tech Stack

- **Language**: Swift
- **Framework**: UIKit
- **Networking**: Alamofire
- **Persistence**: SwiftData
- **Authentication**: Firebase
- **Dependency Management**: Swift Package Manager


 ![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
 ![Swift](https://img.shields.io/badge/UIKit-F54A2A?style=for-the-badge&logo=swift&logoColor=white)


## License

This project is licensed under the WTFPL License - see the [WTFPL](https://en.wikipedia.org/wiki/WTFPL) file for details.

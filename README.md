# Bike App

<div align="center">
    <h1>
        <img src="https://github.com/faaarce/Cyclouse/blob/development/Documentation/Images/1730818650581.jpg" width="80px"><br/>
        Cyclouse
    </h1>
</div>

Cyclouse is a modern iOS e-commerce application for bicycles and accessories, built with Swift and leveraging the latest frameworks and technologies 🚲

## Demo Video

| ![Splash Screen](https://github.com/faaarce/Cyclouse/blob/development/Documentation/GIFs/RocketSim_Recording_iPhone_16_Pro_6.3_2024-11-24_16.21.59.gif?raw=true) | ![Home](https://github.com/faaarce/Cyclouse/blob/development/Documentation/GIFs/RocketSim_Recording_iPhone_16_Pro_6.3_2024-11-24_16.22.45.gif?raw=true) | ![Map](https://github.com/faaarce/Cyclouse/blob/development/Documentation/GIFs/RocketSim_Recording_iPhone_16_Pro_6.3_2024-11-24_16.23.28.gif?raw=true) | ![Payment](https://github.com/faaarce/Cyclouse/blob/development/Documentation/GIFs/RocketSim_Recording_iPhone_16_Pro_6.3_2024-11-24_16.23.58.gif?raw=true) | 
|:---:|:---:|:---:|:---:|
| Splash Screen | Home | Map | Payment |


## Table of Contents

- [Features](#features)
- [System Requirements](#system-requirements)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [License](#license)

## How to Clone and Run the Project

1. **Clone the repository:**
   Open a terminal window and type the following command to clone the repository to your local machine:

   ```bash
   git clone https://github.com/faaarce/Cyclouse.git
   ```

2. **Install dependencies using Swift Package Manager:** 
   Navigate to the project directory:

   ```bash
   cd Cyclouse
   ```

   Once in the project directory, run the following command to resolve and fetch the project dependencies:

   ```bash
   swift package resolve
   ```

## Features

### Interactive UI Components

- **Custom Animated Tab Bar**: Engaging navigation with smooth animations
- **Nested Collection Views**: Efficient browsing of categories and products
- **Hero Transitions**: Seamless transitions between screens
- **ReactiveCollectionsKit Integration**: Dynamic collection view updates
- **Plus Jakarta Sans Typography**: Modern and clean font for better readability

### Robust Data Management

- SwiftData for local persistence

### Location Services

- Real-time GPS tracking with CoreLocation
- MapKit integration with 3D views
- Custom map annotations

### Smart Notifications

- SwiftMessages for custom alerts
- EasyNotificationBadge for cart updates
- JDStatusBarNotification integration
- Interactive toast messages
- Status bar notifications

### Enhanced User Experience

- SkeletonView for loading states
- Hero animations for transitions
- IQKeyboardManager integration
- Lottie animations
- NVActivityIndicatorView for loading button

### Technical Architecture

- MVVM-C pattern with Coordinator
- Dependency injection using Swinject
- Reactive programming with Combine
- Protocol-oriented design

## System Requirements

- iOS 15.0 or later
- Xcode 14.0 or later
- Swift 5.5 or later
- CocoaPods 1.11.0 or later

## Architecture

Cyclouse uses MVVM-C pattern with:

- **Model**: Data structures and business logic
- **View**: UI components and layouts
- **ViewModel**: Business logic
- **Coordinator**: Navigation and flow management

## Tech Stack

### Programming Languages & Frameworks

- Swift
- UIKit

### Core Technologies

- SwiftData
- MapKit & CoreLocation
- Combine & CombineCocoa
- SnapKit for layouts
- PhoneNumberKit

### UI/UX

- Hero Transitions
- SwiftMessages
- Lottie Animations
- IQKeyboardManager
- Plus Jakarta Sans typography
- ReactiveCollectionsKit

### Data & Security

- Valet for securely stores sensitive data in the keychain
- Firebase services
- SwiftData persistence

### Networking

- Alamofire with Combine

![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
![UIKit](https://img.shields.io/badge/UIKit-F54A2A?style=for-the-badge&logo=swift&logoColor=white)

## License

This project is currently unlicensed. All rights reserved.
# eLingkod – Barangay Services Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-Mobile%20Development-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-Programming-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend%20Services-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com/)
[![Python](https://img.shields.io/badge/Python-Backend-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![ML Kit](https://img.shields.io/badge/Google%20ML%20Kit-Text%20Recognition-4285F4)](https://developers.google.com/ml-kit)

> **eLingkod** is a barangay services mobile application designed to support digital access to local government services. It combines user registration, profile management, document handling, and ID verification to support a more accessible and organized experience for community members.

---

## Overview

**eLingkod** is a mobile application developed using Flutter and Dart, with supporting backend services for data management and identity verification.

The project explores how digital systems can help simplify barangay-related processes by providing residents with a mobile platform for managing personal information and interacting with government service workflows.

A key technical component is its identity-verification process, which incorporates camera-based document capture, Optical Character Recognition (OCR), and input validation.

The application also considers accessibility and usability, particularly for residents who may require simpler and more readable interfaces.

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile application development |
| Dart | Application logic and interface implementation |
| Python | Backend processing and verification logic |
| FastAPI | API endpoints for identity verification |
| Supabase | Backend services and data storage |
| Google ML Kit | Text recognition and OCR |
| Camera Plugin | Real-time camera access and document capture |
| Image Processing | Document image-quality assessment |
| HTTP | Communication between the mobile application and backend |
| PDF & Printing Packages | PDF document handling and printing support |

---

## Features

### 1. User Registration and Profile Management

Provides a registration workflow for collecting and managing resident information.

The registration process includes:

- Personal information and contact details.
- Date of birth and age calculation.
- Residential address information.
- Civil status and voter status.
- Additional details for senior citizens and Persons with Disabilities (PWDs).

The interface incorporates form fields, selection controls, and validation mechanisms to improve data-entry consistency.

### 2. Camera-Based ID Capture

Integrates device-camera functionality to capture identification documents directly within the application.

The camera workflow includes:

- Real-time document scanning.
- Automatic image-quality assessment.
- Detection of blurred or overexposed images.
- Consecutive-frame quality validation.
- Automatic image capture when configured conditions are satisfied.

These mechanisms help improve the quality of document images submitted for verification.

### 3. Optical Character Recognition

Uses Google ML Kit to recognize text from identification documents.

The OCR process supports extracting relevant identification information and preparing recognized text for validation.

Supported verification workflows include senior citizen and PWD identification, alongside selected valid ID types.

### 4. Identification Number Validation

Implements validation mechanisms that compare user-provided identification numbers with information extracted from scanned documents.

For supported ID types, the process includes:

- Extracting identification numbers from recognized text.
- Normalizing characters and number formats.
- Comparing extracted values with user-submitted information.
- Preventing successful verification when the required identification numbers do not match.

### 5. Backend Verification

Uses backend processing to support document and identity verification.

The verification workflow can process:

- Captured identification images.
- Resident profile information.
- Extracted identification details.
- Image-quality results.
- Validation outcomes.

The backend provides a separation between mobile interface functionality and server-side verification logic.

### 6. Data and Document Handling

Integrates Supabase services to support data-related operations and document storage.

The application includes workflows for handling uploaded identification images and associated registration information.

### 7. Accessibility-Oriented Interface

The interface is designed with consideration for users who may have varying levels of digital literacy.

Design considerations include:

- Readable text and form labels.
- Organized registration steps.
- Clear navigation elements.
- Larger input fields where appropriate.
- User feedback during document scanning and validation.

---

## System Workflow

The resident registration and verification process follows this general sequence:

1. **Profile Registration** – The resident enters the required personal and contact information.
2. **Additional Information** – The resident provides applicable senior citizen or PWD details.
3. **Document Capture** – The application captures the required identification document.
4. **Image Quality Validation** – The captured image is checked for quality requirements.
5. **OCR Processing** – Text recognition extracts relevant identification information.
6. **Identity Validation** – Extracted details are compared against submitted information.
7. **Backend Verification** – The application submits the required data for verification.
8. **Profile Processing** – Registration proceeds according to the verification result.

---

## Project Structure

```text
eLingkod/
├── .vscode/                 # Editor configuration
├── android/                 # Android platform configuration
├── assets/
│   └── images/             # Application images and assets
├── backend/                 # Backend application and services
├── ios/                     # iOS platform configuration
├── lib/                     # Flutter application source code
├── linux/                   # Linux platform configuration
├── macos/                   # macOS platform configuration
├── test/                    # Flutter testing directory
├── web/                     # Web platform configuration
├── windows/                 # Windows platform configuration
├── pubspec.yaml             # Flutter dependencies
└── README.md                # Project documentation
```

---

## Getting Started

### Prerequisites

Before running the application, ensure that the following tools are installed:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android Emulator or a supported physical device
- Python and the backend dependencies
- Git
- Required environment configuration for integrated services

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/cinemaseven/eLingkod.git
cd eLingkod
```

**2. Install Flutter dependencies**

```bash
flutter pub get
```

**3. Verify your development environment**

```bash
flutter doctor
```

**4. Configure environment variables**

Create the required local environment configuration using the values provided by the project maintainers.

The application references a `.env` configuration file.

Keep credentials and API keys out of version control.

**5. Configure the backend**

The repository contains a separate `backend` directory.

Install its required Python dependencies and configure any necessary services according to the backend implementation.

**6. Run the Flutter application**

```bash
flutter run
```

Some registration and verification functionality requires the backend and integrated services to be properly configured.

---

## Technical Highlights

### OCR-Based Document Processing

The application combines real-time camera input, image-quality checks, and OCR to support identification-document verification.

### Input Validation

The verification process compares user-submitted information against document-extracted values to reduce inconsistencies during registration.

### Mobile and Backend Integration

The project demonstrates communication between a Flutter mobile application and backend verification services.

### User-Centered Interface Design

The registration workflow emphasizes readable forms, clear navigation, and accessible interaction patterns for residents.

---

## Project Status

Academic software development project.

The repository contains the application source code and supporting backend components. Specific functions may require environment configuration and external services to operate.

---

## Repository

**Source Code:** [eLingkod on GitHub](https://github.com/cinemaseven/eLingkod)

---

## Development Team

eLingkod was developed as a collaborative academic project.

Individual development responsibilities may include interface design, mobile application development, backend integration, document-processing workflows, and testing.

---

## Security and Privacy Considerations

Because eLingkod processes personal information and identification documents, implementations should follow appropriate data-protection practices.

Important considerations include:

- Protecting personal and identification information.
- Securing backend API communication.
- Restricting access to stored documents.
- Keeping credentials out of the repository.
- Validating user-submitted information.
- Avoiding exposure of sensitive data in logs.

---

*Developed using Flutter and Dart, with integrated backend services and OCR-based identity verification.*


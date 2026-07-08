# Secure Banking Authentication App

A Flutter application for secure banking authentication with sign in and account creation features.

## Features

### Welcome Screen
- Clean, professional interface
- Two main options: Sign In or Create Account
- Modern gradient design

### Sign In Screen
- Request user name and password
- Real-time validation
- Password visibility toggle
- Forgot password link (placeholder)
- Loading indicator for authentication

### Sign Up Screen
- Comprehensive user registration form
- Fields: First Name, Last Name, Username, Password, Confirm Password
- Real-time password strength indicator
- Advanced password validation

### Password Security Requirements
The app enforces strong password requirements:
- **Minimum 8 characters** long
- **At least one uppercase letter** (A-Z)
- **At least one number** (0-9)
- **At least one special character** (!@#$%^&*, etc.)
- **Password confirmation** to ensure user types correctly

### Form Validation
- All fields are validated in real-time
- Clear error messages for user guidance
- Visual feedback for each password requirement
- Prevents form submission until all requirements are met

## Project Structure

```
lib/
├── main.dart                 # App entry point and theme configuration
├── screens/
│   ├── welcome_screen.dart   # Welcome/Home screen with navigation buttons
│   ├── signin_screen.dart    # Sign in form
│   └── signup_screen.dart    # Sign up form with validation
└── utils/
    └── validators.dart       # Password and form validation logic
```

## Getting Started

### Prerequisites
- Flutter SDK (v3.0.0 or higher)
- Dart SDK
- A code editor (VS Code, Android Studio, etc.)

### Installation

1. **Navigate to the project directory:**
   ```bash
   cd "Secure Authencation app"
   ```

2. **Get Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Running on Specific Device

- **iOS Simulator:**
  ```bash
  flutter run -d iPhone
  ```

- **Android Emulator:**
  ```bash
  flutter run -d android
  ```

- **Web:**
  ```bash
  flutter run -d chrome
  ```

## File Descriptions

### `main.dart`
- Initializes the Flutter app
- Sets up Material Design theme
- Configures primary color scheme (Blue)
- Defines app title and home screen

### `screens/welcome_screen.dart`
- Beautiful welcome interface with gradient background
- Two navigation buttons:
  - Sign In button (leads to SignInScreen)
  - Create Account button (leads to SignUpScreen)
- Security icon and branding

### `screens/signin_screen.dart`
- Form with two fields: Name and Password
- Password visibility toggle
- Real-time field validation
- Loading state during sign in
- Forgot password placeholder link
- Responsive design with Material Design components

### `screens/signup_screen.dart`
- Comprehensive registration form
- Five input fields with validation
- Real-time password strength indicator
- Visual checklist showing password requirements:
  - ✓ Length check (8+ characters)
  - ✓ Uppercase letter check
  - ✓ Number check
  - ✓ Special character check
- Password confirmation with match validation
- Link back to sign in screen
- Loading state during account creation

### `utils/validators.dart`
- `PasswordValidator` class with static methods
- `validatePassword()` - Returns ValidationResult with errors
- `passwordsMatch()` - Checks if two passwords match
- `isValidEmail()` - Email format validation
- `ValidationResult` - Data class containing validation status and error messages

## UI/UX Features

### Design Elements
- **Gradient backgrounds** for visual appeal
- **Rounded corners** on input fields and buttons
- **Clear typography** hierarchy
- **Color-coded feedback** (Green for valid, Red for errors)
- **Smooth animations** and transitions

### Accessibility
- Semantic labels for all input fields
- Clear error messages
- High contrast between text and background
- Large touch targets for buttons

## Future Enhancement Ideas

1. Add biometric authentication (fingerprint/face recognition)
2. Implement actual backend API integration
3. Add Terms & Conditions screen
4. Add email verification
5. Add multi-factor authentication (MFA)
6. Add forgot password recovery flow
7. Add user profile management
8. Add transaction history dashboard

## Security Notes

⚠️ **Important:** This is a front-end demonstration app. In production:
- Store passwords securely using encryption
- Use HTTPS for all API communications
- Implement proper backend authentication
- Add rate limiting to prevent brute force attacks
- Use secure token storage
- Implement proper session management
- Add API security headers
- Perform input sanitization on the backend

## Testing

To test the app:

1. **Sign In Flow:**
   - Click "Sign In" on welcome screen
   - Enter a name (minimum 2 characters)
   - Enter a password (minimum 8 characters)
   - Observe the success message

2. **Sign Up Flow:**
   - Click "Create Account" on welcome screen
   - Fill in all required fields
   - Observe the password strength indicator
   - Ensure passwords match before submission

3. **Password Validation:**
   - Try passwords without uppercase letters
   - Try passwords with less than 8 characters
   - Try passwords without numbers
   - Try passwords without special characters
   - See real-time feedback

## Troubleshooting

### App won't run
- Ensure Flutter is installed: `flutter doctor`
- Run `flutter pub get` to fetch dependencies
- Check your Flutter SDK version

### Build issues
- Clear build cache: `flutter clean`
- Get dependencies again: `flutter pub get`
- Rebuild: `flutter run`

## License

This project is provided as-is for educational purposes.

## Contact & Support

For questions or issues, please refer to the Flutter documentation:
- [Flutter Docs](https://flutter.dev/docs)
- [Material Design Guidelines](https://material.io/design)

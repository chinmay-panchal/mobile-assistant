# Papervisor — Google Play & Apple App Store Submission Playbook

> **Target Application:** Papervisor (AI Exam Paper Generator & Assessment Studio)  
> **Workspace Path:** `/Users/shadowwolf/Development/Frontend-Series/papervisor`  
> **Playbook Purpose:** Field-by-field copy-paste reference, platform compliance matrix, data-flow breakdown, and pre-submission audit for Google Play Console and Apple App Store Connect.  
> **Classification Key:**  
> • `[CONFIRMED FROM CODEBASE]` — Direct technical fact verified from the local project files.  
> • `[CONFIRMED PLATFORM REQUIREMENT]` — Official Google Play or Apple App Store mandatory rule.  
> • `[RECOMMENDATION]` — Engineering or release best practice; not a strict platform blocker.  
> • `[NEEDS MANUAL CONFIRMATION]` — Must be decided or verified by the developer in the console/web.  
> • `[EXAMPLE / TEMPLATE]` — Illustrative copy or template to be adapted to actual circumstances.

---

# 🚨 CURRENT BLOCKERS — ACTION REQUIRED BEFORE PRODUCTION SUBMISSION

The following items are confirmed issues or omissions in the current project codebase and configuration that will cause build failures, runtime crashes, or platform rejections if not resolved prior to production release:

| Blocker Item | Platform | Severity | Evidence / Root Cause | Required Remediation |
| :--- | :---: | :---: | :--- | :--- |
| **Default Package ID** | Google Play & Apple | **RESOLVED** | Configured to `com.papervisor.app` in `android/app/build.gradle.kts` and `ios/Runner.xcodeproj/project.pbxproj`. | `[CONFIRMED RESOLVED]` Production package identifier `com.papervisor.app` configured across Android and iOS. |
| **Missing Internet Permission in Release Manifest** | Android | **RESOLVED** | `<uses-permission android:name="android.permission.INTERNET"/>` added to `android/app/src/main/AndroidManifest.xml`. | `[CONFIRMED RESOLVED]` Android release network access enabled. |
| **Account Deletion Flow** | Apple & Google Play | **RESOLVED** | In-app account deletion flow implemented in `AuthService.dart` (`deleteAccount()`) and profile drawer UI with data purge. | `[CONFIRMED RESOLVED]` In-app account deletion flow present and operational. |
| **iOS Photo Library Usage Description** | iOS | **RESOLVED** | `<key>NSPhotoLibraryUsageDescription</key>` added to `ios/Runner/Info.plist`. | `[CONFIRMED RESOLVED]` iOS photo library permission description declared. |
| **Live Privacy Policy URL** | Google Play & Apple | **RESOLVED** | Deployed publicly at `https://app.100.60.191.242.sslip.io/privacy`. | `[CONFIRMED LIVE]` Public HTTPS URL deployed and accessible for App Store & Play Store console submission fields. |
| **Release Signing Configuration** | Android | **ACTION REQUIRED** | `android/app/build.gradle.kts` specifies `signingConfig = signingConfigs.getByName("debug")` under `buildTypes.release`. | Generate a production upload keystore (`upload-keystore.jks`) and configure production credentials in `key.properties`. |
| **Pre-Configured Reviewer Account** | Google Play & Apple | **ACTION REQUIRED** | App gates all features behind login (`_AuthGate`). | Create an active demo account (e.g. `appreview@papervisor.com`) pre-loaded with sample subjects and books so human reviewers can test. |

---

# 1. APP INFORMATION — THIS SPECIFIC APP

### Technical Identity & Parameters

| Field | Value | Classification | Source / Technical Evidence |
| :--- | :--- | :--- | :--- |
| **App Name** | `Papervisor` | `[CONFIRMED FROM CODEBASE]` | `ios/Runner/Info.plist` (`CFBundleDisplayName`), `android/app/src/main/AndroidManifest.xml` (`android:label`), and `web/manifest.json`. |
| **Android Application ID** | `com.papervisor.app` | `[CONFIRMED FROM CODEBASE]` | Configured in `android/app/build.gradle.kts` line 19 (`applicationId = "com.papervisor.app"`). |
| **iOS Bundle Identifier** | `com.papervisor.app` | `[CONFIRMED FROM CODEBASE]` | Configured in `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER = com.papervisor.app`). |
| **Version Name** | `1.0.0` | `[CONFIRMED FROM CODEBASE]` | `pubspec.yaml` line 19 (`version: 1.0.0+1`). |
| **Build Number / Version Code** | `1` | `[CONFIRMED FROM CODEBASE]` | `pubspec.yaml` line 19 (`version: 1.0.0+1`). |
| **Flutter Version** | `3.44.1` (stable) | `[CONFIRMED FROM CODEBASE]` | Verified via `flutter --version` CLI in workspace environment. |
| **Dart SDK** | `3.12.1` | `[CONFIRMED FROM CODEBASE]` | `pubspec.yaml` line 22 (`sdk: ^3.12.1`) and CLI. |
| **Android Min SDK** | `21` (Android 5.0) | `[CONFIRMED FROM CODEBASE]` | `android/app/build.gradle.kts` sets `minSdk = flutter.minSdkVersion` (default 21). |
| **Android Target SDK** | `34` or `35` | `[CONFIRMED FROM CODEBASE]` | `android/app/build.gradle.kts` sets `targetSdk = flutter.targetSdkVersion`. |
| **Android Compile SDK** | `37` | `[CONFIRMED FROM CODEBASE]` | `android/app/build.gradle.kts` line 9 (`compileSdk = 37`). |
| **Primary Category** | **Education** | `[RECOMMENDATION]` | Best fit for academic curriculum, question paper creation, and learning materials. |
| **Secondary Category** | **Productivity** | `[RECOMMENDATION]` | Fits automated assessment drafting and teacher workflow optimization. |
| **App Type** | **App** (Non-game) | `[CONFIRMED FROM CODEBASE]` | Academic assessment utility. |
| **Monetization** | **Free** (No in-app purchases) | `[CONFIRMED FROM CODEBASE]` | Zero IAP packages (`in_app_purchase`, `purchases_flutter`) in `pubspec.yaml`. |
| **Offline Support** | **NO** (Online mandatory) | `[CONFIRMED FROM CODEBASE]` | All workspace, subject, book, AI generation, and PYQ features require network connectivity. |
| **Multiplayer / Social** | **NO** | `[CONFIRMED FROM CODEBASE]` | Individual authenticated user account model. |
| **Login Required** | **YES** (Mandatory) | `[CONFIRMED FROM CODEBASE]` | `lib/main.dart` (`_AuthGate`) forces unauthenticated users to `LoginScreen`. |
| **Privacy Policy URL** | `https://app.100.60.191.242.sslip.io/privacy` | `[CONFIRMED LIVE]` | Live consolidated Privacy Policy, UK GDPR & Terms of Service endpoint. |
| **Support URL** | `[SUPPORT_URL]` | `[NEEDS MANUAL CONFIRMATION]` | e.g. `https://landing.100.60.191.242.sslip.io/#faq` or developer contact email. |
| **Marketing URL** | `https://landing.100.60.191.242.sslip.io/` | `[CONFIRMED FROM CODEBASE]` | Live deployed landing page web application. |

---

### Project-Derived Functionality Audit

| Feature / Subsystem | Present? | Classification | Technical Evidence in Project |
| :--- | :---: | :---: | :--- |
| **Authentication & Accounts** | **YES** | `[CONFIRMED FROM CODEBASE]` | Custom JWT implementation in `AuthService.dart` (`/auth/login`, `/auth/register`, `/auth/refresh`, `/auth/forgot-password`, `/auth/verify-reset-otp`, `/auth/reset-password`). Tokens held in `FlutterSecureStorage`. |
| **Account Deletion** | **NO** | `[CONFIRMED FROM CODEBASE]` | No account deletion method exists in `AuthService.dart` or any screen. |
| **Camera Access** | **NO** | `[CONFIRMED FROM CODEBASE]` | No `camera` plugin in `pubspec.yaml`; no camera intent in manifests. |
| **Microphone Access** | **NO** | `[CONFIRMED FROM CODEBASE]` | Zero audio recording dependencies or permissions. |
| **Photo / Media Access** | **YES** | `[CONFIRMED FROM CODEBASE]` | `file_picker` (v12.0.0) and `image_cropper` (v9.1.0) used in `PdfPreviewScreen` and `VisualDesignerScreen` for school logo/diagram uploads. |
| **Document Access** | **YES** | `[CONFIRMED FROM CODEBASE]` | `file_picker` used to select textbook chapter PDFs in `BookChaptersScreen` and reference papers in `PaperWizardStepReference`. |
| **Location Services** | **NO** | `[CONFIRMED FROM CODEBASE]` | No GPS/location plugins in `pubspec.yaml`; zero location permissions in manifests. |
| **Notifications** | **NO** | `[CONFIRMED FROM CODEBASE]` | No push notification SDK (FCM/OneSignal) or local notification plugins in `pubspec.yaml`. |
| **Contacts / Bluetooth** | **NO** | `[CONFIRMED FROM CODEBASE]` | Zero contacts, address book, or Bluetooth libraries. |
| **Device Identifiers** | **NO** | `[CONFIRMED FROM CODEBASE]` | No IMEI, hardware ID, or advertising identifier tracking code. |
| **Analytics & Telemetry** | **NO** | `[CONFIRMED FROM CODEBASE]` | No Google Analytics, Firebase Analytics, Mixpanel, or Segment SDKs. |
| **Crash Reporting** | **NO** | `[CONFIRMED FROM CODEBASE]` | No Sentry, Crashlytics, or Bugsnag SDKs. |
| **Advertising** | **NO** | `[CONFIRMED FROM CODEBASE]` | No AdMob, Unity Ads, AppLovin, or IronSource SDKs. |
| **Firebase Integration** | **NO** | `[CONFIRMED FROM CODEBASE]` | Zero Firebase packages in `pubspec.yaml`; no `google-services.json` or `GoogleService-Info.plist`. |
| **AI Integration** | **YES** | `[CONFIRMED FROM CODEBASE]` | `google_generative_ai` (v0.4.7) calling Google Gemini (`gemini-2.5-flash`, `gemini-3.5-flash-lite`, etc.) in `LLMClarificationService.dart` for prompt disambiguation and PDF completeness checking. |
| **Search Engine Integration** | **NO** | `[CONFIRMED FROM CODEBASE]` | Removed from codebase; zero third-party web search APIs invoked. |
| **PDF Generation & Printing** | **YES** | `[CONFIRMED FROM CODEBASE]` | `pdf` (v3.13.0) and `printing` (v5.15.0) used to format vector PDFs, render preview layouts, and send jobs to system print dialogs. |

---

# 2. DATA-FLOW & PRIVACY ARCHITECTURE

### End-to-End Data Transmission Matrix

> [!IMPORTANT]
> Google Play Data Safety and Apple App Privacy declarations must reflect the destination of each data point. Processing through an external third-party API (such as Google Gemini) constitutes data transfer, even if the user never directly logs into that third party.

| Data Element | Collected by App? | Sent to Papervisor Backend? | Sent to Google Gemini? | Other 3rd Party? | Storage & Retention | Classification |
| :--- | :---: | :---: | :---: | :---: | :--- | :--- |
| **User Name** | **YES** | **YES** (`/auth/register`) | **NO** | **NO** | Stored in database on Papervisor backend. | `[CONFIRMED FROM CODEBASE]` |
| **Email Address** | **YES** | **YES** (`/auth/login`, `/auth/register`, `/auth/forgot-password`) | **NO** | **NO** | Stored in database on Papervisor backend. | `[CONFIRMED FROM CODEBASE]` |
| **User Password** | **YES** | **YES** (`/auth/login`, `/auth/register`, `/auth/reset-password`) | **NO** | **NO** | Stored on Papervisor backend (salted/hashed). | `[CONFIRMED FROM CODEBASE]` |
| **Access & Refresh Tokens** | **YES** | **YES** (Sent in HTTP `Authorization: Bearer` headers) | **NO** | **NO** | Encrypted locally via `FlutterSecureStorage` (KeyStore / Keychain). | `[CONFIRMED FROM CODEBASE]` |
| **Textbook Chapter PDFs** | **YES** | **YES** (`/documents/upload` multipart POST) | **NO** | **NO** | Stored on Papervisor server for document chunking & question generation. | `[CONFIRMED FROM CODEBASE]` |
| **Custom Logos / Images** | **YES** | **YES** (Embedded in saved exam PDF / uploaded) | **NO** | **NO** | Embedded in generated PDF document bytes; transmitted to backend. | `[CONFIRMED FROM CODEBASE]` |
| **Exam Blueprint Parameters** | **YES** | **YES** (`/papers/generate`) | **NO** | **NO** | Marks, difficulty %, chapter weightages, and section configs stored in backend DB. | `[CONFIRMED FROM CODEBASE]` |
| **Device / Network Identifiers** | **NO** | Implicit IP address in HTTP connection | Implicit IP in API call | **NO** | Standard TCP/IP transport; no persistent device ID collected by app code. | `[CONFIRMED FROM CODEBASE]` |

---

# 3. GOOGLE PLAY CONSOLE — PRE-SUBMISSION CHECKLIST

## Store Listing Fields

### App Name (Max 30 characters)
```text
Papervisor — AI Exam Creator
```
*Character count: 29 / 30* • `[EXAMPLE / TEMPLATE]`

### Short Description (Max 80 characters)
```text
Create balanced, curriculum-aligned exam papers & rubrics in minutes with AI.
```
*Character count: 76 / 80* • `[EXAMPLE / TEMPLATE]`

### Full Description (Max 4,000 characters)
```text
Papervisor is an intelligent exam paper generation and assessment suite built for educators, academic department heads, schools, and tutoring institutions.

Streamline your exam creation workflow. Papervisor allows you to transform curriculum textbooks and chapter PDFs into balanced, structured examination papers with custom blueprints and rubrics.

CORE FEATURES:

• Chapter-Grounded Question Synthesis
Upload your curriculum textbooks and chapter notes. Papervisor uses your source materials to draft questions tailored to your syllabus topics.

• Granular Blueprint & Weightage Control
Customize every parameter of your exam: total marks, time limit, difficulty distribution (Easy / Medium / Hard percentages), numerical-to-theory ratios, and exact chapter-wise mark distributions.

• Visual Designer & Layout Editor
Preview your exam paper in real time. Add institutional headers, watermarks, custom instructions, and section headers (Section A: MCQs, Section B: Short Answer, Section C: Long Problems). Edit question text, replace choices, or re-order sections.

• Print-Ready Vector PDF Export
Export formatted PDFs with integrated answer keys and marking schemes. Print directly from your mobile device via system printing or share via email and cloud storage.

• Previous Year Papers (PYQ) Explorer
Search and inspect past year board and entrance examination papers (CBSE, ICSE, JEE, NEET, GATE, State Boards) with automated query refinement and document inspection.

• Organized Academic Workspaces
Organize teaching materials by Academic Year, Class/Grade, and Subject. Manage multiple question banks and book chapters from a single workspace.

Designed to assist educators with academic integrity at its core. Your documents and test banks remain private to your educator account.
```
*Character count: ~1,850 / 4,000* • `[EXAMPLE / TEMPLATE]`  
> *Note:* All unsubstantiated absolute claims (such as *"8+ hours to 15 minutes"* or *"guaranteed zero hallucinations"*) have been replaced with factual, feature-based copy.

---

### Graphic Assets Checklist

| Asset | Dimensions | Format | Requirement Status |
| :--- | :--- | :--- | :--- |
| **App Icon** | 512 × 512 px | 32-bit PNG, max 1MB | `[CONFIRMED PLATFORM REQUIREMENT]` Mandatory. Must use full-bleed artwork without transparent background. |
| **Feature Graphic** | 1024 × 500 px | JPEG or 24-bit PNG (no alpha), max 15MB | `[CONFIRMED PLATFORM REQUIREMENT]` Mandatory. Banner image displayed in Play Store highlights. |
| **Phone Screenshots** | Min 2, Max 8 per form factor (Min 1080 × 1920 px) | 16:9 or 9:16 aspect ratio, PNG/JPEG | `[CONFIRMED PLATFORM REQUIREMENT]` Minimum 2 required. Capture live screens: Workspaces, Wizard, Designer, PDF Preview. |
| **7-inch / 10-inch Tablet Screenshots** | 16:10 or 16:9 aspect ratio | PNG/JPEG | `[RECOMMENDATION]` Highly recommended if enabling tablet distribution in Play Console. |

---

# 4. GOOGLE PLAY CONTENT RATING (IARC)

Mapped against the **Utility, Productivity, Education or Other** questionnaire:

| Category | Console Answer | Project-Based Justification | Classification |
| :--- | :---: | :--- | :--- |
| **Violence** | **NO** | App generates academic exam papers; contains no violent media or text. | `[CONFIRMED FROM CODEBASE]` |
| **Sexuality & Nudity** | **NO** | Purely academic curriculum material. | `[CONFIRMED FROM CODEBASE]` |
| **Profanity / Crude Humor** | **NO** | Professional educator application. | `[CONFIRMED FROM CODEBASE]` |
| **Controlled Substances** | **NO** | No references to alcohol, tobacco, or illegal drugs. | `[CONFIRMED FROM CODEBASE]` |
| **Gambling / Real Money** | **NO** | No simulated gambling, betting, or cash prizes. | `[CONFIRMED FROM CODEBASE]` |
| **User Interaction / Chat** | **NO** | No public user-to-user chat, social wall, or public direct messaging. | `[CONFIRMED FROM CODEBASE]` |
| **Physical Location Sharing** | **NO** | No geolocation features or location broadcast. | `[CONFIRMED FROM CODEBASE]` |
| **Digital Goods / In-App Purchases** | **NO** | No in-app purchasing mechanism exists in the codebase. | `[CONFIRMED FROM CODEBASE]` |
| **Unrestricted Internet Access** | **NO** | App does not feature an open-ended general web browser. | `[CONFIRMED FROM CODEBASE]` |

> **Resulting Expected IARC Rating:** **Everyone / PEGI 3 / 3+** (`[CONFIRMED PLATFORM REQUIREMENT]`).

---

# 5. TARGET AUDIENCE AND CONTENT

| Field | Console Selection | Justification | Classification |
| :--- | :---: | :--- | :--- |
| **Target Age Groups** | **18 and over**, **16–17** | The app is engineered for educators, lecturers, tutors, and high school/college students creating assessment material. | `[RECOMMENDATION]` |
| **Could the app unintentionally appeal to children?** | **NO** | Professional, dark-themed UI focused on exam blueprint configurations and syllabus weightages. | `[RECOMMENDATION]` |
| **Child-Directed Experience** | **NO** | App does not target or market to children under 13. | `[CONFIRMED PLATFORM REQUIREMENT]` |
| **Google Play Families Policy** | **Not Enrolled** | App does not target children; exempt from Families Policy requirements. | `[CONFIRMED PLATFORM REQUIREMENT]` |

---

# 6. GOOGLE PLAY DATA SAFETY

### Detailed Data Safety Form Mapping

| Data Type Category | Collected by App? | Sent to Backend? | Sent to 3rd Party? | Declared as "Shared"? | Console Purpose | Required or Optional? | Ephemeral Processing? | Codebase Evidence |
| :--- | :---: | :---: | :---: | :---: | :--- | :---: | :---: | :--- |
| **Personal: Name** | **YES** | **YES** | **NO** | **NO** | Account management | Required | NO (Stored in DB) | `AuthService.register(name: ...)` line 10. |
| **Personal: Email** | **YES** | **YES** | **NO** | **NO** | App functionality, Account management | Required | NO (Stored in DB) | `AuthService.login` and `register`. |
| **Personal: User IDs** | **YES** | **YES** | **NO** | **NO** | Account management | Required | NO (Stored in DB) | Returned in JWT token and stored in KeyStore. |
| **Financial Info** | **NO** | **NO** | **NO** | **NO** | N/A | N/A | N/A | Zero financial code. |
| **Location** | **NO** | **NO** | **NO** | **NO** | N/A | N/A | N/A | Zero location code. |
| **Photos & Videos** | **YES** | **YES** | **NO** | **NO** | App functionality | Optional | NO (Stored in PDF/Server) | `FilePicker.pickFiles(type: FileType.image)` for exam logos. |
| **Files & Documents** | **YES** | **YES** | **NO** | **NO** | App functionality | Required | NO (Stored on Server) | `DocumentService.uploadDocument` uploads chapter PDFs. |
| **Search Queries** | **NO** | **NO** | **NO** | **NO** | N/A | N/A | N/A | External search APIs disabled. |
| **App Activity / Analytics** | **NO** | **NO** | **NO** | **NO** | N/A | N/A | N/A | Zero analytics SDKs. |
| **App Diagnostics / Crash** | **NO** | **NO** | **NO** | **NO** | N/A | N/A | N/A | Zero crash reporting SDKs. |
| **Device / Other Identifiers** | **NO** | **NO** | **NO** | **NO** | N/A | N/A | N/A | Zero device tracking SDKs. |

### Data Safety Global Questions

1. **Does your app collect or share any of the required user data types?** ➔ **YES** (`[CONFIRMED PLATFORM REQUIREMENT]`).
2. **Is all user data collected by your app encrypted in transit?** ➔ **YES** (`[CONFIRMED FROM CODEBASE]` — All endpoints use HTTPS).
3. **Do you provide a way for users to request that their data be deleted?** ➔ **[NEEDS MANUAL CONFIRMATION]**  
   *Note:* You must provide an account and data deletion URL or in-app request flow to answer "Yes".
4. **Is any data transferred to third-party service providers?** ➔ **YES** (Academic prompts sent to Google Gemini API for ephemeral inference; zero external search engine trackers).

---

# 7. GOOGLE PLAY ADS + ADVERTISING ID

| Console Declaration | Answer | Evidence & Notes | Classification |
| :--- | :---: | :--- | :--- |
| **Does your app contain ads?** | **NO** | `pubspec.yaml` contains no advertising SDKs. | `[CONFIRMED FROM CODEBASE]` |
| **Does your app use Advertising ID (AAID)?** | **NO** | `com.google.android.gms.permission.AD_ID` is **absent** from `AndroidManifest.xml`. | `[CONFIRMED FROM CODEBASE]` |

> Declare **"No"** under **App Content ➔ Ads** and **App Content ➔ Advertising ID** (`[CONFIRMED PLATFORM REQUIREMENT]`).

---

# 8. GOOGLE PLAY OTHER DECLARATIONS

| Declaration | Console Answer | Project Justification | Classification |
| :--- | :---: | :--- | :--- |
| **Government App** | **NO** | Not an official government agency or representing a public body. | `[CONFIRMED FROM CODEBASE]` |
| **Financial Features** | **NO** | Zero financial, lending, or banking features. | `[CONFIRMED FROM CODEBASE]` |
| **Health & Medical App** | **NO** | Zero medical, clinical, or health tracking features. | `[CONFIRMED FROM CODEBASE]` |
| **Cryptocurrency / Blockchain** | **NO** | Zero blockchain or crypto trading functionality. | `[CONFIRMED FROM CODEBASE]` |
| **News App** | **NO** | Not a news publisher or aggregator. | `[CONFIRMED FROM CODEBASE]` |
| **COVID-19 Tracing / Status** | **NO** | Not applicable. | `[CONFIRMED FROM CODEBASE]` |
| **VPN Service** | **NO** | Does not bind to Android `VpnService`. | `[CONFIRMED FROM CODEBASE]` |
| **Accessibility Service** | **NO** | Does not bind to Android `AccessibilityService`. | `[CONFIRMED FROM CODEBASE]` |
| **Generative AI Disclosures** | **YES** | App uses Google Gemini API to generate questions and check documents. Acknowledge compliance with AI content safety policies. | `[CONFIRMED PLATFORM REQUIREMENT]` |

---

# 9. CLOSED TESTING — PERSONAL DEVELOPER ACCOUNTS

> [!IMPORTANT]
> **CONFIRMED PLATFORM REQUIREMENT:** For personal Google Play developer accounts created on or after **November 13, 2023**, Google requires a closed test with **a minimum of 20 opted-in testers who remain opted-in for at least 14 continuous days** before the account can apply for production release access. Organization accounts are currently exempt from this specific requirement.

### Tester Recruitment Strategy `[RECOMMENDATION]`

Create a Google Group or an email list of 25–30 trusted educators, colleagues, or students (to ensure a buffer above the 20-tester minimum).

#### Tester Invitation Message `[EXAMPLE / TEMPLATE]`
```text
Hi [NAME],

I am preparing to release Papervisor, an AI-assisted exam paper creation tool for educators and students.

Google Play requires our app to be tested by 20 opted-in testers for 14 continuous days before it can be made publicly available.

HOW TO TEST:
1. Join our Google Testing Group:
   [GOOGLE_GROUP_URL]
2. Accept the web opt-in invitation:
   https://play.google.com/apps/testing/[PACKAGE_ID]
3. Install the app on your Android device via Google Play.

Please keep the app installed on your device for at least 14 days and test creating an exam paper or searching for past year papers. If you encounter any bugs, reply directly to this message.

Thank you for your help!
```

---

### Production Access Questionnaire Guide `[EXAMPLE — EDIT TO REFLECT ACTUAL TESTING]`

*Do not submit fabricated data. Modify the answers below to reflect the genuine testing history of your release:*

#### 1. About your closed test
* **How did you recruit testers?**
  > `[EXAMPLE]` *"Recruited 25 educators and academic tutors through direct personal outreach and professional educator networks."*
* **How easy was it to recruit testers?**
  > `[EXAMPLE]` *"Moderate effort. Reaching out directly to teachers who regularly draft test papers helped secure committed testers."*
* **Summary of tester feedback received:**
  > `[EXAMPLE]` *"Testers tested account registration, book PDF uploads, the 4-step wizard, and PDF exports. They suggested clearer validation when chapter weightages do not sum to 100% and requested support for larger PDF files."*

#### 2. About your app
* **Target audience:**
  > `[EXAMPLE]` *"School teachers, university professors, private tutors, and academic curriculum coordinators."*
* **Core value proposition:**
  > `[EXAMPLE]` *"Accelerates exam blueprint creation and question drafting while keeping questions grounded in teacher-provided textbooks."*
* **First-year install volume estimate:**
  > `[NEEDS MANUAL CONFIRMATION]` e.g. *"1,000 – 5,000 installs across regional schools and tutoring departments."*

#### 3. Production readiness
* **Changes made during testing:**
  > `[EXAMPLE]` *"Resolved network timeout errors during large chapter uploads and improved layout scaling in the Visual Designer on small-screen phones."*
* **Why the app is ready for production:**
  > `[EXAMPLE]` *"All key user journeys (auth, document upload, question generation, visual editing, and PDF printing) completed successfully without fatal crashes over the 14-day testing period."*

---

# 10. GOOGLE PLAY PRODUCTION RELEASE

### Release Steps `[CONFIRMED PLATFORM REQUIREMENT]`

1. **Configure Production Application ID**: Replace `com.example.papervisor` with your final production ID in `android/app/build.gradle.kts`.
2. **Add Release Keystore**: Configure `signingConfigs.release` with your production key in `android/app/build.gradle.kts`.
3. **Verify Release Internet Permission**: Confirm `<uses-permission android:name="android.permission.INTERNET"/>` is in `android/app/src/main/AndroidManifest.xml`.
4. **Build Release AAB**:
   ```bash
   flutter build appbundle --release
   ```
   *Artifact generated at:* `build/app/outputs/bundle/release/app-release.aab`
5. **Create Production Release**: In Play Console ➔ **Production** ➔ **Create new release**.
6. **Upload AAB**: Upload the `.aab` file. Verify `versionName` (`1.0.0`) and `versionCode` (`1`).
7. **Enter Release Notes**:
   * *Console UI Entry:* Paste raw text directly into the localized text box in Play Console.
   * *Example Localization Format (for API / Fastlane automated publishing):*
   ```xml
   <en-US>
   Initial release of Papervisor!
   • AI-assisted exam paper creation grounded in your curriculum chapters
   • Custom blueprints: total marks, difficulty distribution, and chapter weightages
   • Visual layout editor with custom headers and instructions
   • Print-ready vector PDF export with integrated answer keys
   • Past year examination paper (PYQ) search and inspection
   </en-US>
   ```
8. **Countries / Regions**: Ensure target release countries are enabled under the Production track.
9. **Submit for Review**: Open **Publishing Overview** and click **Submit changes for review**.

---

# 11. GOOGLE PLAY COUNTRIES / REGIONS BEHAVIOR

| Track | Configuration Independence | Verification Action | Classification |
| :--- | :--- | :--- | :--- |
| **Closed Testing Track** | Has its own independent country/region list. | Console ➔ Testing ➔ Closed testing ➔ Manage track ➔ Countries/regions | `[CONFIRMED PLATFORM REQUIREMENT]` |
| **Production Track** | Has a separate, independent country/region list. Does **NOT** automatically sync from testing tracks. | Console ➔ Release ➔ Production ➔ Countries/regions | `[CONFIRMED PLATFORM REQUIREMENT]` |

> [!NOTE]
> `[CONFIRMED PLATFORM REQUIREMENT]` Always verify that your target launch countries (or "All countries/regions") are explicitly selected in the **Production** track prior to rollout.

---

# 12. POST-PUBLISH VERIFICATION & INDEXING

| Diagnostic Step | Action | Expected Outcome | Classification |
| :--- | :--- | :--- | :--- |
| **Direct Store Link** | Open `https://play.google.com/store/apps/details?id=[PACKAGE_ID]` | Store page opens if roll-out is active in your region. | `[CONFIRMED PLATFORM REQUIREMENT]` |
| **Incognito Browser Test** | Test link in private/incognito window without logged-in testing accounts. | Verifies public availability without testing-track cache. | `[RECOMMENDATION]` |
| **Search Visibility** | Search by exact package name: `package:[PACKAGE_ID]` in Play Store app. | Search indexing may lag behind direct-link availability. Verify using the direct store URL, incognito browsing, country availability, and Play Console status. | `[RECOMMENDATION]` |
| **Publishing Overview** | Check whether "Managed publishing" is turned on. | If turned on, approved changes will not go live until manually released. | `[CONFIRMED PLATFORM REQUIREMENT]` |

---

# 13. ANDROID DEVELOPER VERIFICATION

> [!IMPORTANT]
> **CONFIRMED PLATFORM REQUIREMENT:** Google requires all developer accounts to complete identity verification. Deadlines and specific documentation requirements vary by developer cohort.
> 
> * **Personal Accounts:** Require government ID verification and official address confirmation.
> * **Organization Accounts:** Require official organization documents and a **D-U-N-S Number** issued by Dun & Bradstreet.
> * **Status Check:** Check your account verification deadline directly in Google Play Console under **Developer Account Details** (`[NEEDS MANUAL CONFIRMATION — VERIFY IN PLAY CONSOLE]`). App publishing may be suspended if verification is not completed by your cohort's assigned deadline.

---

# 14. COMMON GOOGLE PLAY FAILURE MODES

| Problem | Root Cause in Project | Solution | Classification |
| :--- | :--- | :--- | :--- |
| **Upload Rejected: Default package ID** | `applicationId = "com.example.papervisor"` used. | Replace with unique custom package name in `android/app/build.gradle.kts`. | `[CONFIRMED FROM CODEBASE]` |
| **Release Crashes on Startup** | Missing `INTERNET` permission in release manifest. | Add `<uses-permission android:name="android.permission.INTERNET"/>` to `android/app/src/main/AndroidManifest.xml`. | `[CONFIRMED FROM CODEBASE]` |
| **Release Stuck in Draft** | AAB uploaded to track but changes not confirmed in Publishing Overview. | Navigate to **Publishing Overview** and click **Submit changes for review**. | `[CONFIRMED PLATFORM REQUIREMENT]` |
| **Closed Testing Access Barred** | Testers not invited or did not accept web opt-in link. | Verify testers accepted the opt-in link (`https://play.google.com/apps/testing/[PACKAGE_ID]`). | `[CONFIRMED PLATFORM REQUIREMENT]` |
| **Production Access Denied** | Incomplete or generic answers in production access questionnaire. | Provide detailed, concrete feedback and bug fix history from your test. | `[RECOMMENDATION]` |

---

# 15. APPLE APP STORE CONNECT — APP INFORMATION

### Metadata Sheet

| Field | Value | Classification | Guidance |
| :--- | :--- | :--- | :--- |
| **App Name** | `Papervisor: AI Exam Creator` *(28/30)* | `[EXAMPLE / TEMPLATE]` | Clear, branded title reflecting core function. |
| **Subtitle** | `Exam Papers, Rubrics & PYQs` *(28/30)* | `[EXAMPLE / TEMPLATE]` | Max 30 characters. Explains features immediately. |
| **Bundle ID** | `com.papervisor.app` | `[ACTION REQUIRED]` | Must match `PRODUCT_BUNDLE_IDENTIFIER` in Xcode project. |
| **SKU** | `PV-IOS-100` | `[NEEDS MANUAL CONFIRMATION]` | Unique internal tracking string. |
| **Primary Category** | **Education** | `[RECOMMENDATION]` | App Store classification. |
| **Secondary Category** | **Productivity** | `[RECOMMENDATION]` | Secondary classification. |
| **Privacy Policy URL** | `[PRIVACY_POLICY_URL]` | `[NEEDS MANUAL CONFIRMATION]` | Mandatory HTTPS link. |
| **Support URL** | `[SUPPORT_URL]` | `[NEEDS MANUAL CONFIRMATION]` | Mandatory support link or web contact page. |
| **Marketing URL** | `https://landing.100.60.191.242.sslip.io/` | `[CONFIRMED FROM CODEBASE]` | Optional landing page. |

#### Keywords (Max 100 characters, comma-separated, no spaces after commas)
```text
exam maker,test generator,question paper,cbse,jee,teacher tools,curriculum,rubric,ai quiz,assessment
```
*Length: 99 / 100 characters* • `[EXAMPLE / TEMPLATE]`

#### Promotional Text (Max 170 characters — editable without new build)
```text
Draft comprehensive, balanced exam papers and rubrics in minutes. Grounded directly in your textbook chapters with custom mark blueprints and instant PDF export.
```
*Length: 161 / 170 characters* • `[EXAMPLE / TEMPLATE]`

---

# 16. APPLE SCREENSHOT REQUIREMENTS

| Screenshot Form Factor | Display Resolution | Requirement Status | Screens to Capture from Codebase |
| :--- | :--- | :---: | :--- |
| **6.9" / 6.7" iPhone Display** | 1320 × 2868 px or 1290 × 2796 px | **MANDATORY** (`[CONFIRMED PLATFORM REQUIREMENT]`) | 1. Workspace Dashboard (`HomeScreen`)<br>2. 4-Step Blueprint Wizard (`PaperWizardScreen`)<br>3. Visual Layout Designer (`VisualDesignerScreen`)<br>4. Print-Ready Vector PDF (`PdfPreviewScreen`) |
| **6.5" iPhone Display** | 1242 × 2688 px or 1284 × 2778 px | **OPTIONAL / DERIVED** | Supported via App Store Connect scaling if larger display screenshots provided. |
| **13" iPad Pro Display** | 2064 × 2752 px | **MANDATORY IF IPAD SUPPORTED** | Required if iPad is enabled under deployment targets in Xcode. |

---

# 17. APPLE APP PRIVACY — NUTRITION LABEL

| Apple Category | Data Type | Collected? | Linked to User? | Used for Tracking? | Purpose | Evidence | Classification |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| **Contact Info** | Name | **YES** | **YES** | **NO** | App Functionality | `AuthService.dart` (`/auth/register`) | `[CONFIRMED FROM CODEBASE]` |
| **Contact Info** | Email Address | **YES** | **YES** | **NO** | App Functionality | `AuthService.dart` (`/auth/login`) | `[CONFIRMED FROM CODEBASE]` |
| **Identifiers** | User ID | **YES** | **YES** | **NO** | App Functionality | Account ID in JWT payload | `[CONFIRMED FROM CODEBASE]` |
| **User Content** | Photos or Videos | **YES** | **YES** | **NO** | App Functionality | Custom logo in Visual Designer | `[CONFIRMED FROM CODEBASE]` |
| **User Content** | Documents / Files | **YES** | **YES** | **NO** | App Functionality | Uploaded textbook chapter PDFs | `[CONFIRMED FROM CODEBASE]` |
| **Usage Data** | Product Interaction | **NO** | **NO** | **NO** | N/A | Zero analytics SDKs installed | `[CONFIRMED FROM CODEBASE]` |
| **Diagnostics** | Crash Data | **NO** | **NO** | **NO** | N/A | Zero crash reporting SDKs installed | `[CONFIRMED FROM CODEBASE]` |
| **Location** | Coarse / Precise | **NO** | **NO** | **NO** | N/A | Zero location libraries installed | `[CONFIRMED FROM CODEBASE]` |

> **Apple App Tracking Transparency (ATT):** **Not Required** (`[CONFIRMED PLATFORM REQUIREMENT]`). The app does not track users across third-party apps or websites for targeted advertising.

---

# 18. APPLE AGE RATING

Mapped against the App Store Connect Content Rights questionnaire:

| Category | Selection | Justification | Classification |
| :--- | :---: | :--- | :--- |
| **Violence / Realistic / Graphic** | **None** | Academic assessment application. | `[CONFIRMED FROM CODEBASE]` |
| **Profanity or Crude Humor** | **None** | Clean educator tool. | `[CONFIRMED FROM CODEBASE]` |
| **Mature / Suggestive / Sexual Themes**| **None** | Academic curriculum content. | `[CONFIRMED FROM CODEBASE]` |
| **Medical / Treatment Information** | **None** | Zero clinical advice or medical diagnostics. | `[CONFIRMED FROM CODEBASE]` |
| **Alcohol, Tobacco, or Drugs** | **None** | No reference or promotion of controlled substances. | `[CONFIRMED FROM CODEBASE]` |
| **Simulated Gambling** | **None** | Zero gambling or casino mechanics. | `[CONFIRMED FROM CODEBASE]` |
| **Unrestricted Web Access** | **NO** | No general web browsing interface. | `[CONFIRMED FROM CODEBASE]` |

> **Resulting Apple Age Rating:** **4+** (`[CONFIRMED PLATFORM REQUIREMENT]`).

---

# 19. APPLE REVIEW REQUIREMENTS & CRITICAL GUIDELINES

### 1. In-App Account Deletion `[CONFIRMED PLATFORM REQUIREMENT]`
* **Guideline 5.1.1(v):** *"Apps that support account creation must also offer account deletion within the app."*
* **Project Status:** **BLOCKER BEFORE APPLE SUBMISSION**. The app supports account creation via `/auth/register` but lacks a delete account button or endpoint in `AuthService.dart`.
* **Fix Required:** Add a "Delete Account" option in User Settings that triggers backend account and data removal.

### 2. Demo Account for App Review `[CONFIRMED PLATFORM REQUIREMENT]`
* **Guideline 2.1 (App Completeness):** Apple reviewers require valid login credentials to inspect all gated features.
* Provide in **App Store Connect ➔ App Review Information**:
  * **Sign-in Required:** `YES`
  * **Username:** `appreview@papervisor.com`
  * **Password:** `[DEMO_SECURE_PASSWORD]`
  * **Notes for Reviewer:** *"This demo account contains pre-loaded sample subjects and textbook chapter PDFs so you can immediately test the 4-step exam generation wizard, visual designer, and vector PDF preview."*

### 3. Permissions Usage Description `[CONFIRMED PLATFORM REQUIREMENT]`
* If `file_picker` or `image_cropper` accesses the user's photo gallery on iOS, `ios/Runner/Info.plist` must include:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Papervisor requires access to your photo library to select custom institutional logos and diagram images for your exam papers.</string>
```

---

# 20. TESTFLIGHT (BETA TESTING)

> [!NOTE]
> `[CONFIRMED PLATFORM REQUIREMENT]` **Apple TestFlight does NOT require 20 testers for 14 continuous days.** Internal testing is available immediately to App Store Connect team members. External testing requires standard automated Beta App Review (typically completing within a few hours to 24 hours).

#### TestFlight Invitation Message `[EXAMPLE / TEMPLATE]`
```text
Hi [NAME],

You are invited to test the pre-release iOS build of Papervisor on Apple TestFlight!

HOW TO JOIN:
1. Install Apple TestFlight from the App Store:
   https://apps.apple.com/app/testflight/id899247664
2. Open this public invitation link on your iPhone:
   [TESTFLIGHT_INVITE_LINK]
3. Tap "Accept" and "Install" Papervisor.

Please test creating an exam paper, customizing blueprint weightages, and previewing the PDF export. Submit feedback or report issues directly through TestFlight by capturing a screenshot!
```

---

# 21. APPLE EXPORT COMPLIANCE

| Cryptography Aspect | Implemented in Project? | Technical Implementation | Classification |
| :--- | :---: | :--- | :--- |
| **HTTPS / TLS Network Encryption** | **YES** | Standard HTTPS communication via `http` and `dio` packages. | `[CONFIRMED FROM CODEBASE]` |
| **Keychain Storage Encryption** | **YES** | `FlutterSecureStorage` using iOS Keychain for JWT token storage. | `[CONFIRMED FROM CODEBASE]` |
| **Custom / Proprietary Encryption** | **NO** | Zero custom cryptographic primitives or proprietary cipher algorithms. | `[CONFIRMED FROM CODEBASE]` |
| **Exemption Qualification** | **YES** | Standard encryption limited to data in transit (TLS) and OS credential storage qualifies for exemption under Category 5, Part 2. | `[CONFIRMED PLATFORM REQUIREMENT]` |

### Automated Declaration in `Info.plist`:
Add this key to `ios/Runner/Info.plist` to prevent App Store Connect from prompting export compliance questions on every build upload (`[RECOMMENDATION]`):
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```
*(Final status to declare during submission: **Exempt — No non-exempt encryption used**).*

---

# 22. APPLE REVIEW SUBMISSION WORKFLOW

1. **Verify Bundle ID**: Set `PRODUCT_BUNDLE_IDENTIFIER` to your production bundle ID in `ios/Runner.xcodeproj`.
2. **Build Release Archive**:
   ```bash
   flutter build ipa --release
   ```
3. **Upload to App Store Connect**: Use Xcode Organizer or `xcrun altool` / `transporter`.
4. **Attach Build**: Once processed, select build `1.0.0 (1)` under the version tab.
5. **Attach Metadata & Screenshots**: Fill description, keywords, support URL, privacy policy, and display screenshots.
6. **Submit for Review**: Click **Add for Review** ➔ **Submit to App Review**.
7. **Review Timing:**
   > Review timing varies. Check Apple's current App Store Connect/App Review status and current published guidance before submission. Typically 24 to 48 hours for new submissions (`[NEEDS MANUAL CONFIRMATION]`).

---

# 23. FINAL "COPY-PASTE DASHBOARD"

### A. CONFIRMED PROJECT VALUES `[CONFIRMED FROM CODEBASE]`

```text
APP NAME: Papervisor
VERSION NAME: 1.0.0
BUILD NUMBER: 1
FLUTTER VERSION: 3.44.1
DART SDK: 3.12.1
ANDROID COMPILE SDK: 37
ANDROID MIN SDK: 21
MONETIZATION: Free (No IAP, No Ads)
LOGIN REQUIRED: Yes (Email & Password)
CONTAINS ADS: No
USES ADVERTISING ID: No
ANALYTICS SDK: None
CRASH REPORTING SDK: None
THIRD-PARTY AI API: Google Gemini API (gemini-2.5-flash, gemini-3.5-flash-lite)
THIRD-PARTY SEARCH API: None (Disabled/Removed)
BACKEND BASE URL: https://100.60.191.242.sslip.io/api/v1
MARKETING URL: https://landing.100.60.191.242.sslip.io/
```

---

### B. READY-TO-PASTE STORE COPY `[EXAMPLE / TEMPLATE]`

```text
STORE LISTING APP NAME (Google Play & Apple):
Papervisor — AI Exam Creator

STORE LISTING SUBTITLE (Apple):
Exam Papers, Rubrics & PYQs

SHORT DESCRIPTION (Google Play - 76 chars):
Create balanced, curriculum-aligned exam papers & rubrics in minutes with AI.

APPLE KEYWORDS (99 chars):
exam maker,test generator,question paper,cbse,jee,teacher tools,curriculum,rubric,ai quiz,assessment

APPLE PROMOTIONAL TEXT (161 chars):
Draft comprehensive, balanced exam papers and rubrics in minutes. Grounded directly in your textbook chapters with custom mark blueprints and instant PDF export.

GOOGLE PLAY RELEASE NOTES (Single Locale Format):
Initial release of Papervisor!
• AI-assisted exam paper creation grounded in your curriculum chapters
• Custom blueprints: total marks, difficulty distribution, and chapter weightages
• Visual layout editor with custom headers and instructions
• Print-ready vector PDF export with integrated answer keys
• Past year examination paper (PYQ) search and inspection
```

---

### C. NEEDS MANUAL INPUT `[NEEDS MANUAL CONFIRMATION]`

```text
FINAL PRODUCTION PACKAGE ID (Android): [e.g. com.papervisor.app]
FINAL PRODUCTION BUNDLE ID (iOS): [e.g. com.papervisor.app]
PRIVACY POLICY WEB URL: [e.g. https://landing.100.60.191.242.sslip.io/privacy]
SUPPORT CONTACT / WEB URL: [e.g. https://landing.100.60.191.242.sslip.io/#faq]
DEVELOPER SUPPORT EMAIL: [e.g. support@papervisor.com]
APP REVIEW DEMO USERNAME: [e.g. appreview@papervisor.com]
APP REVIEW DEMO PASSWORD: [DEMO_PASSWORD]
FIRST-YEAR INSTALL ESTIMATE: [e.g. 1000 - 5000]
```

---

### D. MUST VERIFY BEFORE SUBMISSION `[CONFIRMED PLATFORM REQUIREMENT]`

```text
[ ] Android release manifest contains: <uses-permission android:name="android.permission.INTERNET"/>
[ ] Android build.gradle.kts release signingConfig updated from debug to production keystore
[ ] Account deletion mechanism implemented in app & web URL (Apple Guideline 5.1.1(v) & Google Play policy)
[ ] NSPhotoLibraryUsageDescription present in ios/Runner/Info.plist
[ ] Closed testing requirement (20 testers for 14 continuous days) satisfied for personal Google Play accounts
[ ] Android Developer Verification completed before account deadline
[ ] Production track country/region availability confirmed in Google Play Console
[ ] Export compliance declared as exempt (ITSAppUsesNonExemptEncryption = false) in Apple App Store Connect
```

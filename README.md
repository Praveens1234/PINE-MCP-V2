# TradingView Pine Validator (Android)

## 🛠️ How to Build Your APK (Step-by-Step Guide)

Since you don't have a PC, we will use **GitHub** to build the app for you automatically.

### Step 1: Download & Extract
1.  Download the **`project_source.zip`** provided in this chat.
2.  Extract (Unzip) it on your phone or computer. You should see folders like `lib`, `android`, `.github`, etc.

### Step 2: Create a GitHub Repository
1.  Go to [GitHub.com](https://github.com) and sign in.
2.  Click the **+** icon and select **New repository**.
3.  Name it `pine-validator`.
4.  Make sure it is **Public** (or Private, but Public is easier).
5.  Click **Create repository**.

### Step 3: Upload Files
1.  In your new repository, look for the link **"uploading an existing file"**.
2.  Select **ALL** the files and folders you extracted in Step 1.
    *   **Crucial:** Make sure the hidden folder `.github` and its contents (`workflows/build_apk.yml`) are uploaded. If you can't upload folders via the web interface, you might need to use "Desktop Mode" in your browser or a file uploader app.
    *   **Alternative:** If uploading folders is hard on mobile, you can edit files directly, but uploading the zip content is best.

### Step 4: Wait for Build
1.  Once files are uploaded and committed (green button), click the **"Actions"** tab at the top of your repository page.
2.  You should see a workflow named **"Build and Release APK"** running (yellow spinning icon).
3.  Wait 3-5 minutes.

### Step 5: Download APK
1.  When the circle turns **Green** (Success), click on the **"Releases"** section on the main code page (usually on the right sidebar).
2.  You will see "Release v1.0.x".
3.  Click on **`app-release.apk`** to download it.
4.  Install and Enjoy!

---

## Files to Upload (Checklist)
Ensure these exist in your repo:
- `.github/workflows/build_apk.yml` (The Builder)
- `android/` (Android settings)
- `lib/` (The App Code)
- `pubspec.yaml` (Configuration)
- `analysis_options.yaml`
- `README.md`

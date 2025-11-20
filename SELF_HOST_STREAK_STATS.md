# How to Self-Host GitHub Streak Stats

This guide will help you deploy your own instance of the GitHub Streak Stats service to avoid API rate limiting issues.

## 🚀 Option 1: Deploy to Vercel (Recommended - Free & Easy)

Vercel is the recommended option since it's **free** and takes less than 2 minutes to set up.

### Quick Deploy Method (Easiest)

1. **Fork the Repository**

   - Go to https://github.com/DenverCoder1/github-readme-streak-stats
   - Click the "Fork" button to create a copy under your GitHub account

2. **Fetch the `vercel` Branch** (IMPORTANT!)

   After forking, you need to get the `vercel` branch from the original repository. When you fork, you only get the default branch (`main`), not all branches.

   **Option A: Using GitHub Web Interface (Easiest)**

   - Go to your forked repository on GitHub: `https://github.com/Andreas-Garcia/github-readme-streak-stats`
   - Click the branch dropdown (it will show "main" or "master")
   - Type "vercel" in the search box
   - If it doesn't appear, click "View all branches" or "Find branch"
   - You should see branches from the original repo (DenverCoder1)
   - Find `DenverCoder1/vercel` branch
   - Click on it, then click "Create branch: vercel from 'DenverCoder1:vercel'"
   - This will create the `vercel` branch in your fork

   **Option B: Using Git Commands (Recommended if web interface doesn't work)**

   If you only see `main` branch in the GitHub web interface, use these commands:

   ```bash
   # Clone your fork (if you haven't already)
   git clone https://github.com/Andreas-Garcia/github-readme-streak-stats.git
   cd github-readme-streak-stats

   # Add the original repository as upstream
   git remote add upstream https://github.com/DenverCoder1/github-readme-streak-stats.git

   # Fetch all branches from upstream
   git fetch upstream

   # Checkout the vercel branch from upstream
   git checkout -b vercel upstream/vercel

   # Push the vercel branch to your fork
   git push origin vercel
   ```

   **Option C: Direct Clone Method (If you don't have the fork cloned locally)**

   ```bash
   # Clone the vercel branch directly from the original repository
   git clone -b vercel https://github.com/DenverCoder1/github-readme-streak-stats.git github-readme-streak-stats-vercel
   cd github-readme-streak-stats-vercel

   # Change the remote to point to your fork
   git remote set-url origin https://github.com/Andreas-Garcia/github-readme-streak-stats.git

   # Push the vercel branch to your fork
   git push origin vercel
   ```

3. **Create a GitHub Personal Access Token (Required)**

   The service needs a GitHub token to access the GitHub API. Create one:

   - Go to https://github.com/settings/tokens/new?description=GitHub%20Readme%20Streak%20Stats
   - Or manually: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token (classic)
   - Give it a name: `Vercel Streak Stats` (or any name you prefer)
   - Set expiration: Choose your preference (90 days, or "No expiration" for convenience)
   - **IMPORTANT: Do NOT select any scopes** - Leave all checkboxes unchecked
     - The service works with public data and doesn't need any special permissions
   - Scroll to the bottom and click "Generate token"
   - **IMPORTANT**: Copy the token immediately (it starts with `ghp_`) - you won't be able to see it again!

4. **Deploy to Vercel**

   - Visit https://vercel.com/new
   - Sign in with your GitHub account
   - Click "Import Project"
   - Select your forked `github-readme-streak-stats` repository
   - **IMPORTANT**: Configure these settings BEFORE deploying:
     - **Production Branch**: Set to `vercel` (NOT `main` - this is crucial!)
     - **Root Directory**: Leave empty (or set to `.` - the vercel branch has the correct structure)
     - **Framework Preset**: Leave as "Other" or select "PHP"
   - **Environment Variables**:
     - Name: `TOKEN`
     - Value: Paste your GitHub Personal Access Token (the `ghp_...` token you just created)
     - Environment: Select "Production", "Preview", and "Development" (or at least "Production")
   - Click "Deploy"

   **If you get a 404 error or "public directory doesn't exist" error:**

   - The issue is that you're using the `main` branch instead of `vercel` branch
   - Go to your project settings in Vercel
   - Navigate to **Settings** > **Environments** (NOT Git settings!)
   - Click on the **Production** environment
   - Under "Branch Tracking", change the branch from `main` to `vercel`
   - Click **Save**
   - Redeploy (or push a new commit to trigger deployment)

5. **Get Your URL and Test**

   After deployment completes:

   - Vercel will show you a deployment URL like: `https://github-readme-streak-stats-hkpt.vercel.app`
   - Click on the deployment to see details, or go to your project dashboard
   - **Test the URL**: Open `https://your-app-name.vercel.app/?user=Andreas-Garcia&theme=radical` in your browser
   - You should see an SVG image with your streak stats (not an error message!)
   - If you see an error, check the troubleshooting section below

6. **Update Your README**

   Once verified it's working, update your GitHub profile README:

   - Open your `README.md` file
   - Find the commented-out streak badge section
   - Replace the old URL with your new self-hosted URL:

   ```markdown
   <div align="center">

   ![GitHub Streak](https://your-app-name.vercel.app/?user=Andreas-Garcia&theme=radical&hide_border=true)

   </div>
   ```

   - Replace `your-app-name` with your actual Vercel app name
   - Commit and push the changes
   - The badge should now work reliably without API rate limit errors!

### Video Tutorial

📺 [Watch the video tutorial](https://www.youtube.com/watch?v=maoXtlb8t44)

### Troubleshooting Common Errors

**Error: "The specified Root Directory 'public' does not exist"**

This happens when you're using the `main` branch instead of `vercel` branch:

1. **Fix: Switch to vercel branch:**
   - Go to Vercel Dashboard → Your Project → Settings → **Environments**
   - Click on the **Production** environment
   - Under "Branch Tracking", change from `main` to `vercel`
   - Click **Save**
   - Redeploy (or push a new commit to trigger deployment)

**Error: "404: NOT_FOUND"**

1. **Check Production Branch:**

   - Ensure you're using the `vercel` branch (not `main`)
   - Go to Settings → **Environments** → Click **Production** → Under "Branch Tracking" → Set to `vercel`

2. **Verify Deployment:**
   - Check the deployment logs in Vercel dashboard
   - Ensure the build completed successfully
   - Try accessing: `https://your-app-name.vercel.app/?user=YourUsername`

**Note:** The `vercel` branch has the correct structure with `public` directory and `vercel.json` configuration file. Always use the `vercel` branch for Vercel deployments!

**Note:** PNG mode is not supported on Vercel (Inkscape won't be installed), but SVG mode works perfectly.

---

## 🐳 Option 2: Deploy to Heroku

1. **Fork the Repository**

   - Go to https://github.com/DenverCoder1/github-readme-streak-stats
   - Click "Fork"

2. **Deploy to Heroku**

   - Visit https://github.com/DenverCoder1/github-readme-streak-stats
   - Click the "Deploy to Heroku" button
   - Follow the prompts to deploy

3. **Update Your README**
   - Use your Heroku app URL in your README

**Note:** Heroku automatically installs Inkscape, so PNG mode will work.

---

## 🖥️ Option 3: Deploy on Your Own Server

If you have your own server with PHP 7.4+ installed:

1. **Clone the Repository**

   ```bash
   git clone https://github.com/DenverCoder1/github-readme-streak-stats.git
   cd github-readme-streak-stats
   ```

2. **Install Dependencies**

   ```bash
   composer install
   ```

3. **Configure Your Web Server**

   - Point your web server to the `public` directory
   - Ensure PHP 7.4+ is installed
   - For PNG rendering, install Inkscape and Segoe UI font

4. **Update Your README**
   - Use your server URL: `https://your-domain.com/?user=Andreas-Garcia&theme=radical`

---

## ✅ Benefits of Self-Hosting

- **Better Reliability**: Avoid shared rate limits from public services
- **More Control**: Customize the code to your needs
- **Better Uptime**: Your own instance won't be affected by others' usage
- **No API Issues**: Direct access to GitHub's API without shared limits

---

## 📝 Example Usage

Once deployed, use your self-hosted URL in your README:

```markdown
![GitHub Streak](https://your-app-name.vercel.app/?user=Andreas-Garcia&theme=radical&hide_border=true)
```

All the same parameters work:

- `user` - Your GitHub username (required)
- `theme` - Theme name (e.g., `radical`, `dark`)
- `hide_border` - `true` or `false`
- And all other customization options from the original service

---

## 🔗 Resources

- **Repository**: https://github.com/DenverCoder1/github-readme-streak-stats
- **Vercel Deployment**: https://vercel.com/new
- **Video Tutorial**: https://www.youtube.com/watch?v=maoXtlb8t44
- **Demo Site**: https://streak-stats.demolab.com

# CoPA Pre-Deployment Guide

## ⚠️ IMPORTANT: Complete These Steps Before Deployment

**You MUST create an Azure AD App Registration before deploying CoPA.** This ensures secure authentication is properly configured.

## Step 1: Create Azure AD App Registration

### 1.1 Navigate to Azure Active Directory
1. Go to the **Azure Portal** (https://portal.azure.com)
2. Navigate to **Azure Active Directory**
3. Click **App registrations** in the left menu
4. Click **+ New registration**

### 1.2 Configure App Registration
- **Name:** `CoPA-<YourForceCode>-Prod` (e.g., "CoPA-BTP-Prod")
- **Supported account types:** 
  - Select **"Accounts in this organizational directory only (<Your Organization> only - Single tenant)"**
- **Redirect URI:** 
  - Type: **Web** 
  - URI: `https://<your-planned-app-service-name>.azurewebsites.net/`
  - *Note: You can update this after deployment if needed*

### 1.3 Click "Register"

## Step 2: Configure Authentication Settings

### 2.1 Enable ID Tokens (Required for Easy Auth)
1. In your app registration, go to **Authentication**
2. Scroll down to **Implicit grant and hybrid flows**
3. **Check the box for "ID tokens"** (used for implicit and hybrid flows)
4. Click **Save**

### 2.2 Add Easy Auth Redirect URI
1. Still in the **Authentication** page
2. In the **Redirect URIs** section, click **Add URI**
3. Add: `https://<your-planned-app-service-name>.azurewebsites.net/.auth/login/aad/callback`
   - *Example: `https://app-btp-prod-01-abc123.azurewebsites.net/.auth/login/aad/callback`*
   - *Note: Replace `<your-planned-app-service-name>` with your actual App Service name*
4. Click **Save**

**⚠️ Important:** These two steps are **required** for Easy Auth to work properly. Without them, you'll get authentication errors when trying to access your deployed application.

## Step 3: Create Client Secret

### 2.1 Generate Secret
1. In your new app registration, go to **Certificates & secrets**
2. Click **+ New client secret**
3. **Description:** "CoPA App Secret"
4. **Expires:** Choose **24 months** (or per your organization's policy)
5. Click **Add**

### 2.2 ⚠️ CRITICAL: Copy the Secret Value
- **IMMEDIATELY copy the "Value"** (not the "Secret ID")
- **Store it securely** - you cannot view it again once you leave this page
- This is your `AZURE_CLIENT_SECRET` for deployment

## Step 4: Collect Required Information

From your app registration, collect these three values:

| Parameter | Where to Find | Example |
|-----------|---------------|---------|
| **Application (client) ID** | App registration **Overview** page | `12345678-1234-1234-1234-123456789012` |
| **Directory (tenant) ID** | App registration **Overview** page | `87654321-4321-4321-4321-210987654321` |
| **Client secret value** | From Step 2.2 above | `abc123def456ghi789...` |

## Step 5: Deploy CoPA

Now you're ready to deploy CoPA using your ARM template. You'll need to provide these parameters:

- **AzureClientId:** `<Application (client) ID from Step 3>`
- **AzureClientSecret:** `<Client secret value from Step 3>`
- **AzureTenantId:** `<Directory (tenant) ID from Step 3>`

## ✅ That's It!

Once deployed, your CoPA application will be fully secured with Azure AD authentication. Users will need to sign in with their organizational accounts to access the application.

## 🔧 Post-Deployment (Optional)

After deployment, you may want to:

1. **Update Redirect URI:** If your final App Service URL differs from what you entered
2. **Configure API Permissions:** The app works with default permissions, but you can add more if needed
3. **Set User Assignment:** Control which users can access the application
4. **Configure Conditional Access:** Apply additional security policies

## 🚨 Security Notes

- **Never share your client secret** - treat it like a password
- **Use secure parameter files** for deployment to avoid exposing secrets
- **Rotate secrets regularly** according to your organization's policy
- **Monitor sign-ins** in Azure AD logs for security oversight

---

**Need Help?** Contact your Azure administrator or refer to the main CoPA documentation.

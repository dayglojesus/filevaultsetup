#FileVault Setup

A simple interface for using fdesetup at login time. Supports a single user setup with an FMVI.

##Requirements

Only runs on Mac OS X 10.8.0 or greater

##Overview

This app was designed to be called by a Mac OS X loginhook. 

When run as a loginhook, there are two "modes":

1. Optional
  
  In optional activation mode, the user is presented with the opportunity to enable FileVault, or opt out.

2. Enforced

  In enforced mode, the user must activate FileVault to proceed with login.
  
The default mode is optional, but if you wish enforce FileVault activation, you may do so using MCX policy or by overriding the defaults from the command line (see below).

##Installation

Use Mac OS X 10.8 and Xcode (4.6 recommended) to build the app and install it anywhere.

Once installed, you can activate the app via loginhook:

    defaults write com.apple.loginwindow LoginHook /Applications/FileVault\ Setup.app/Contents/MacOS/FileVault\ Setup

http://support.apple.com/kb/HT2420

Alternatively, you can create a custom launch/wrapper script that calls the app.

##NSUserDefaults

Preferences are stored in the domain: ca.sfu.its.filevaultsetup

FileVault Setup accepts two defaults:

1. FVSDoNotAskForSetup -- this key suppresses prompting the user to enable FileVault

2. FVSForceSetup -- this key enforces the setup and arrests login until the user accepts

Note: if you want to enforce the setup withour using MCX or defaults, you can pass FileVault Setup an argument like this...

    /Applications/FileVault\ Setup.app/Contents/MacOS/FileVault\ Setup -FVSForceSetup YES

## Basic Operation

When launched via a loginhook, FileVault Setup will be operating with root priviledge -- this escalation is what allows ANY user to enable FileVault.

Conversely, when the app is launched by a console user other than root, the app simply acts as an intereface for toggling the FVSDoNotAskForSetup preference.

###Single User

FileVault Setup is only used for intial setup and only handles adding a single user account to the Mac's FileVault configuration.

###Personal Recovery Key

FileVault Setup leverages fdesetup to activate FileVault and emits a property list containing the generated Personal Recovery Key to:

    /private/var/root/fdesetup_output.plist

###FileVaultMaster.keychain

If FileVault Setup detects the presence of a /LibraryKeychains/FileVaultMaster.keychain, it will use it when activating FileVault.

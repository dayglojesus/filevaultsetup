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

##Build/Download

Use Mac OS X 10.8 and Xcode (4.6 recommended) to build the app.

You can also download the pre-compiled app here...

[DOWNLOAD](http://dl.bintray.com/content/dayglojesus/github/filevaultsetup-1.0.2.dmg?direct)

##Installation

You can install it anywhere, though the Applications or Utilities folder is reccommended.

##LoginHook

Once installed, you can activate the app via loginhook:

    sudo defaults write com.apple.loginwindow LoginHook /Applications/FileVault\ Setup.app/Contents/MacOS/FileVault\ Setup

http://support.apple.com/kb/HT2420

Alternatively, you can create a custom launch/wrapper script that calls the app.

##Preferences

Preferences are stored in the domain: ca.sfu.its.filevaultsetup

FileVault Setup accepts four defaults:

1. FVSDoNotAskForSetup:   suppresses prompting the user to enable FileVault, default is NO/FALSE

2. FVSForceSetup:         enforces the setup and arrests login until the user accepts, default is NO/FALSE

3. FVSUseKeychain:        enforces the use of the FileVaultMaster.keychain, default is YES/TRUE

4. FVSCreateRecoveryKey:  enforces the creation of a Personal Recovery Key, default is YES/TRUE

Note: if you want to change the behaviour of the app without using MCX or defaults, you can pass FileVault Setup an argument like this...

    /Applications/FileVault\ Setup.app/Contents/MacOS/FileVault\ Setup -FVSForceSetup YES

## Basic Operation

FileVault Setup is just a friendly face for /usr/bin/fdesetup.

When launched via a loginhook, FileVault Setup will be operating with root priviledge -- this escalation is what allows ANY user to enable FileVault.

Conversely, when the app is launched by a console user other than root, the app simply acts as an intereface for toggling the FVSDoNotAskForSetup preference.

FileVault Setup should work for any user already authenticated at the loginwindow, but the user MUST enter their password a second time to begin the setup.

###Single User

FileVault Setup is only used for intial setup and only handles adding a single user account to the Mac's FileVault configuration.

###Personal Recovery Key

By default, FileVault Setup emits a property list containing a Personal Recovery Key to:

    /private/var/root/fdesetup_output.plist

You can suppress the creation of a PRK by using:

    /Applications/FileVault\ Setup.app/Contents/MacOS/FileVault\ Setup -FVSCreateRecoveryKey NO

Or setting the preference...

    sudo defaults write /Library/Preferences/ca.sfu.its.filevaultsetup FVSCreateRecoveryKey -bool NO

###FileVaultMaster.keychain

By default, the app will try and use /Library/Keychains/FileVaultMaster.keychain when activating FileVault.

If you do not wish to use an Institutional Recovery key, you must suppress this behaviour.

    /Applications/FileVault\ Setup.app/Contents/MacOS/FileVault\ Setup -FVSUseKeychain NO

Or setting the preference...

    sudo defaults write /Library/Preferences/ca.sfu.its.filevaultsetup FVSUseKeychain -bool NO

###PRK or Keychain

Like the fdesetup utility it relies on, FileVault Setup will generate an error if you do not specify at least one of the accepted remediation mechanisms, either FVSUseKeychain or FVSCreateRecoveryKey.

The default for both these options is YES.

Attempts to simultaneouesly negate them both, like this...

    /Applications/FileVault\ Setup.app/Contents/MacOS/FileVault\ Setup -FVSCreateRecoveryKey NO -FVSUseKeychain NO

Will result in an error. You MUST use at least one.

###Issues/Feature Requests

Please use GitHub to log issues or feature requests.

##Credits

Special thanks to Rich Trouton (http://derflounder.wordpress.com) for his valuable input and testing, as well as the rest of the Mac Dev Team at SFU.

######
#
# Remove-Bloatware.ps1
#
# fdcastel@gmail.com
#
###

[CmdletBinding()]
Param()



#
# Remove capabilities
# Source: https://github.com/LeDragoX/Win-Debloat-Tools/blob/main/src/scripts/Remove-CapabilitiesList.ps1
#
$capabilities = @(
    "App.StepsRecorder*"                # Steps Recorder
    "Browser.InternetExplorer*"         # Internet Explorer (Also has on Optional Features)
    "MathRecognizer*"                   # Math Recognizer
    "Microsoft.Windows.PowerShell.ISE*" # PowerShell ISE
    "Microsoft.Windows.WordPad*"        # WordPad
    "Print.Fax.Scan*"                   # Fax features
    "Print.Management.Console*"         # printmanagement.msc
    "App.Support.QuickAssist*"
)

$capabilities | ForEach-Object {
    Get-WindowsCapability -Online -Name $_ | Where-Object State -eq "Installed" | Remove-WindowsCapability -Online
}



#
# Remove optional features
# Source: https://github.com/LeDragoX/Win-Debloat-Tools/blob/main/src/scripts/Optimize-WindowsFeaturesList.ps1
#
$optionalFeatures = @(
    "FaxServicesClientPackage"             # Windows Fax and Scan
    "IIS-*"                                # Internet Information Services
    "Internet-Explorer-Optional-*"         # Internet Explorer
    "LegacyComponents"                     # Legacy Components
    "MediaPlayback"                        # Media Features (Windows Media Player)
    "MicrosoftWindowsPowerShellV2"         # PowerShell 2.0
    "MicrosoftWindowsPowershellV2Root"     # PowerShell 2.0
    "Printing-PrintToPDFServices-Features" # Microsoft Print to PDF
    "Printing-XPSServices-Features"        # Microsoft XPS Document Writer
    "WorkFolders-Client"                   # Work Folders Client
)

$optionalFeatures | ForEach-Object {
    Get-WindowsOptionalFeature -Online -FeatureName $_ | Where-Object State -eq "Enabled" | Disable-WindowsOptionalFeature -Online -NoRestart -Remove
}



# 
# Remove apps
# Source: https://github.com/LeDragoX/Win-Debloat-Tools/blob/main/src/scripts/Remove-BloatwareAppsList.ps1
#
$apps = @(
    # Default Windows 10+ apps
    "Microsoft.3DBuilder"                    # 3D Builder
    "Microsoft.549981C3F5F10"                # Cortana
    "Microsoft.Appconnector"
    "Microsoft.BingFinance"                  # Finance
    "Microsoft.BingFoodAndDrink"             # Food And Drink
    "Microsoft.BingHealthAndFitness"         # Health And Fitness
    "Microsoft.BingNews"                     # News
    "Microsoft.BingSports"                   # Sports
    "Microsoft.BingTranslator"               # Translator
    "Microsoft.BingTravel"                   # Travel
    "Microsoft.BingWeather"                  # Weather
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftPowerBIForWindows"
    "Microsoft.MicrosoftSolitaireCollection" # MS Solitaire
    "Microsoft.MixedReality.Portal"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.Office.OneNote"               # MS Office One Note
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.People"                       # People
    "Microsoft.MSPaint"                      # Paint 3D
    "Microsoft.Print3D"                      # Print 3D
    "Microsoft.SkypeApp"                     # Skype (Who still uses Skype? Use Discord)
    "Microsoft.Todos"                        # Microsoft To Do
    "Microsoft.Wallet"
    "Microsoft.Whiteboard"                   # Microsoft Whiteboard
    "Microsoft.WindowsAlarms"                # Alarms
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"           # Feedback Hub
    "Microsoft.WindowsMaps"                  # Maps
    "Microsoft.WindowsPhone"
    "Microsoft.WindowsReadingList"
    "Microsoft.WindowsSoundRecorder"         # Windows Sound Recorder
    "Microsoft.XboxApp"                      # Xbox Console Companion (Replaced by new App)
    "Microsoft.YourPhone"                    # Your Phone
    "Microsoft.ZuneMusic"                    # Groove Music / (New) Windows Media Player
    "Microsoft.ZuneVideo"                    # Movies & TV

    # Default Windows 11 apps
    "Clipchamp.Clipchamp"				     # Clipchamp – Video Editor
    "MicrosoftWindows.Client.WebExperience"  # Taskbar Widgets
    "MicrosoftTeams"                         # Microsoft Teams / Preview

    # 3rd party Apps
    "ACGMediaPlayer"
    "ActiproSoftwareLLC"
    "AdobePhotoshopExpress"                  # Adobe Photoshop Express
    "Amazon.com.Amazon"                      # Amazon Shop
    "Asphalt8Airborne"                       # Asphalt 8 Airbone
    "AutodeskSketchBook"
    "BubbleWitch3Saga"                       # Bubble Witch 3 Saga
    "CaesarsSlotsFreeCasino"
    "CandyCrush"                             # Candy Crush
    "COOKINGFEVER"
    "CyberLinkMediaSuiteEssentials"
    "DisneyMagicKingdoms"
    "Dolby"                                  # Dolby Products (Like Atmos)
    "DrawboardPDF"
    "Duolingo-LearnLanguagesforFree"         # Duolingo
    "EclipseManager"
    "Facebook"                               # Facebook
    "FarmVille2CountryEscape"
    "FitbitCoach"
    "Flipboard"                              # Flipboard
    "HiddenCity"
    "Hulu"
    "iHeartRadio"
    "Keeper"
    "LinkedInforWindows"
    "MarchofEmpires"
    "Netflix"                                # Netflix
    "NYTCrossword"
    "OneCalendar"
    "PandoraMediaInc"
    "PhototasticCollage"
    "PicsArt-PhotoStudio"
    "Plex"                                   # Plex
    "PolarrPhotoEditorAcademicEdition"
    "RoyalRevolt"                            # Royal Revolt
    "Shazam"
    "Sidia.LiveWallpaper"                    # Live Wallpaper
    "SlingTV"
    "Speed Test"
    "Sway"
    "TuneInRadio"
    "Twitter"                                # Twitter
    "Viber"
    "WinZipUniversal"
    "Wunderlist"
    "XING"

    # Apps which other apps depend on
    "Microsoft.Advertising.Xaml"

    # Xbox apps -- https://github.com/LeDragoX/Win-Debloat-Tools/blob/main/src/scripts/Remove-Xbox.ps1
    "Microsoft.GamingServices"          # Gaming Services
    "Microsoft.XboxApp"                 # Xbox Console Companion (Replaced by new App)
#   "Microsoft.XboxGameCallableUI"      # (returns error)
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.XboxGamingOverlay"       # Xbox Game Bar
    "Microsoft.XboxIdentityProvider"    # Xbox Identity Provider (Xbox Dependency)
    "Microsoft.Xbox.TCUI"               # Xbox Live API communication (Xbox Dependency)

    # Widgets
    "WebExperience"

    # Windows Store
    "WindowsStore"
)

$apps | ForEach-Object {
    Get-AppxPackage -AllUsers -Name "*$_*" | Remove-AppxPackage -AllUsers
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*$_*" | Remove-AppxProvisionedPackage -Online -AllUsers
}

$provisionedApps = @(
    'Microsoft.GamingApp'
    'MicrosoftCorporationII.QuickAssist'
    'Microsoft.XboxGameCallableUI'
)

$provisionedApps | ForEach-Object {
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*$_*" | Remove-AppxProvisionedPackage -Online -AllUsers
}




#
# Disable Xbox services
# Source: https://github.com/LeDragoX/Win-Debloat-Tools/blob/main/src/scripts/Remove-Xbox.ps1
# 
$xboxServices = @(
        "XblAuthManager"                    # Xbox Live Auth Manager
        "XblGameSave"                       # Xbox Live Game Save
        "XboxGipSvc"                        # Xbox Accessory Management Service
        "XboxNetApiSvc"
    )

$xboxServices | ForEach-Object {
    Get-Service -Name $_ | Set-Service -StartupType 'Disabled'
}

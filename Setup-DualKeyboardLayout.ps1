# Set two Keyboard Layouts: pt-BR/ABNT2, en-US/International

# Set Windows UI Language
Set-WinUILanguageOverride 'en-US'

# Set languages and input methods 
$LanguageList = Get-WinUserLanguageList 
$LanguageList.Clear()
$LanguageList.Add('pt-BR') 
$LanguageList[0].InputMethodTips.Clear()
$LanguageList[0].InputMethodTips.Add('0416:00010416')
$LanguageList.Add('en-US') 
$LanguageList[1].InputMethodTips.Clear()
$LanguageList[1].InputMethodTips.Add('0416:00020409')
Set-WinUserLanguageList $LanguageList -Force

# Disable hotkeys for switching input layout/language
$HKCUInputMethodHotKeys104 = 'HKCU:\Control Panel\Input Method\Hot Keys\00000104'
Remove-Item -Path $HKCUInputMethodHotKeys104 -Recurse -ErrorAction 'SilentlyContinue'
$HKCUKeyboardLayoutToggle = 'HKCU:\Keyboard Layout\Toggle\'
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Language Hotkey' -Value 3
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Layout Hotkey' -Value 3
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Hotkey' -Value 3

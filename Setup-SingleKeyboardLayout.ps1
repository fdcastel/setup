# Set the only Keyboard Layout to pt-BR/ABNT2

# Set Windows UI Language
Set-WinUILanguageOverride 'en-US'

# Set language and input methods 
$langList = New-WinUserLanguageList pt-BR
$langList[0].InputMethodTips.Clear()
$langList[0].InputMethodTips.Add('0416:00010416')
Set-WinUserLanguageList $langList -Force

# Disable hotkeys for switching input layout/language
$HKCUInputMethodHotKeys104 = 'HKCU:\Control Panel\Input Method\Hot Keys\00000104'
Remove-Item -Path $HKCUInputMethodHotKeys104 -Recurse -ErrorAction 'SilentlyContinue'
$HKCUKeyboardLayoutToggle = 'HKCU:\Keyboard Layout\Toggle\'
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Language Hotkey' -Value 3
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Layout Hotkey' -Value 3
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Hotkey' -Value 3

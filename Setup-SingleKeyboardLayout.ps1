# Set the only Keyboard Layout to pt-BR/ABNT2

# Determine Windows version
$WindowsVersion = [System.Environment]::OSVersion.Version.Major * 10 + [System.Environment]::OSVersion.Version.Minor

if ($WindowsVersion -ge 62)
{
    # Windows 8 or higher
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
} else {
    # Windows 7 or lower
    $HKCUKeyboardPreload = 'HKCU:\Keyboard Layout\Preload'
    $HKCUKeyboardSubstitutes = 'HKCU:\Keyboard Layout\Substitutes'
    Remove-ItemProperty $HKCUKeyboardPreload -Name (Get-Item $HKCUKeyboardPreload).Property    # Remove all (dumb?) 
    Remove-ItemProperty $HKCUKeyboardSubstitutes -Name (Get-Item $HKCUKeyboardSubstitutes).Property
    Set-ItemProperty -path $HKCUKeyboardPreload -name '1' -value '00000416'
    Set-ItemProperty -path $HKCUKeyboardSubstitutes -name '00000416' -value '00010416'
}

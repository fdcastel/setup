# Set two Keyboard Layouts: pt-BR/ABNT2, en-US/International

# Determine Windows version
$WindowsVersion = [System.Environment]::OSVersion.Version.Major * 10 + [System.Environment]::OSVersion.Version.Minor

if ($WindowsVersion -ge 62)
{
    # Windows 8 or higher
    $langList = New-WinUserLanguageList pt-BR
    $langList[0].InputMethodTips.Clear()
    $langList[0].InputMethodTips.Add('0416:00010416')
    $langList[0].InputMethodTips.Add('0416:00020409')
    Set-WinUserLanguageList $langList -Force
} else {
    # Windows 7 or lower
    $HKCUKeyboardPreload = 'HKCU:\Keyboard Layout\Preload'
    $HKCUKeyboardSubstitutes = 'HKCU:\Keyboard Layout\Substitutes'
    Remove-ItemProperty $HKCUKeyboardPreload -Name (Get-Item $HKCUKeyboardPreload).Property    # Remove all (dumb?) 
    Remove-ItemProperty $HKCUKeyboardSubstitutes -Name (Get-Item $HKCUKeyboardSubstitutes).Property
    Set-ItemProperty -path $HKCUKeyboardPreload -name '1' -value '00000416'
    Set-ItemProperty -path $HKCUKeyboardPreload -name '2' -value '00000409'
    Set-ItemProperty -path $HKCUKeyboardSubstitutes -name '00000409' -value '00020409'
    Set-ItemProperty -path $HKCUKeyboardSubstitutes -name '00000416' -value '00010416'
}

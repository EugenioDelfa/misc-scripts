Add-Type -AssemblyName System.Speech

Function Invoke-SimonDice {
    param(
        [Parameter(Mandatory = $True)][string]$Text,
        [Parameter(Mandatory = $False)][switch]$isFile
    )
    $Content = $Text
    If ($isFile) { $Content = Get-Content -Path $Text -Raw }
    $synthesizer = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
    $synthesizer.SelectVoice("Microsoft Helena Desktop");
    $synthesizer.Speak($Content)
}

Function Invoke-SimonEscucha {
    param(
        [Parameter(Mandatory = $False)][switch]$toFile
    )
    $speechRecog = New-Object -TypeName System.Speech.Recognition.SpeechRecognitionEngine -ArgumentList (, (Get-Culture))
    $speechRecog.LoadGrammar( (New-Object -TypeName System.Speech.Recognition.DictationGrammar) )
    $speechRecog.SetInputToDefaultAudioDevice()
    While (1) {
        $words = $speechRecog.Recognize()
        If ($toFile) {
            $words | Out-File -Append texto.txt 
        } Else {
            Write-Host -NoNewLine "$($words.Text) "
        }
        If ($words.Text -eq "final") { break } 
    }
}
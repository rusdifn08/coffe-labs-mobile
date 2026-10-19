Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
# Try to select a female voice, usually Microsoft Zira
try {
    $synth.SelectVoiceByHints([System.Speech.Synthesis.VoiceGender]::Female)
} catch {
    # fallback
}
$synth.Rate = -1 # slightly slower, more relaxing
$synth.SetOutputToWaveFile("E:\APPS From Agent\Mobile-Flutter\Coffee Hub\coffee_hub_mobile\assets\audio\enjoy.wav")
$synth.Speak("Enjoy your coffee.")
$synth.Dispose()

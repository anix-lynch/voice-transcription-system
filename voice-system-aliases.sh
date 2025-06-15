# Voice Transcription System - Bchan's Setup
# Created: June 15, 2025
# Usage: 
#   vr = quick voice recording → clipboard
#   vt = voice test menu with options
#   vb = background mode (always listening)
#   voice-help = show this help

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

alias vr="bash $SCRIPT_DIR/claude-voice-transcribe.sh"
alias vt="bash $SCRIPT_DIR/test-smart.sh"
alias vb="bash $SCRIPT_DIR/background-voice.sh"
alias voice-help="echo '🎤 Voice Commands:'; echo '  vr = quick record (auto-stop)'; echo '  vt = test menu'; echo '  vb = background mode (always listening)'; echo '  voice-help = this help'; echo ''; echo 'Files: $SCRIPT_DIR/*voice*.sh'"

# Auto-show help on first load
if [[ ! -f ~/.voice-system-shown ]]; then
    echo "🎤 Voice transcription system loaded!"
    voice-help
    touch ~/.voice-system-shown
fi
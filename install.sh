#!/bin/bash

echo "🎤 Installing Voice Transcription System..."
echo "==========================================="

# Check for macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This system is designed for macOS only"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install Homebrew first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Install FFmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "🔧 Installing FFmpeg..."
    brew install ffmpeg
else
    echo "✅ FFmpeg already installed"
fi

# Install Python and pip if needed
if ! command -v python3 &> /dev/null; then
    echo "🐍 Installing Python..."
    brew install python
fi

# Install Whisper
if ! command -v whisper &> /dev/null; then
    echo "🤖 Installing OpenAI Whisper..."
    pip3 install openai-whisper
else
    echo "✅ Whisper already installed"
fi

# Make scripts executable
echo "🔧 Setting up scripts..."
chmod +x claude-voice-transcribe.sh
chmod +x test-smart.sh
chmod +x background-voice.sh
chmod +x voice-system-aliases.sh

# Add aliases to shell profile
echo "⚙️ Setting up aliases..."
SCRIPT_DIR="$(pwd)"

# Add to .zshrc if not already there
if ! grep -q "voice-system-aliases.sh" ~/.zshrc 2>/dev/null; then
    echo "# Voice Transcription System" >> ~/.zshrc
    echo "source $SCRIPT_DIR/voice-system-aliases.sh" >> ~/.zshrc
    echo "✅ Added to ~/.zshrc"
else
    echo "✅ Already configured in ~/.zshrc"
fi

# Test audio device (device :1 for EMEET)
echo "🎤 Testing audio device..."
echo "Checking if device :1 is available..."
if ffmpeg -f avfoundation -list_devices true -i "" 2>&1 | grep -q "\[1\]"; then
    echo "✅ Audio device :1 found"
else
    echo "⚠️  Device :1 not found. You may need to adjust the device number in the scripts."
    echo "   Run 'ffmpeg -f avfoundation -list_devices true -i ""' to see available devices"
fi

echo ""
echo "🎉 Installation complete!"
echo ""  
echo "📋 Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Test with: vr (quick record) or vt (test menu)"
echo "3. Use voice-help to see all commands"
echo ""
echo "🎯 Usage:"
echo "  vr = Quick voice recording → clipboard"
echo "  vt = Test menu with options"
echo "  vb = Background listening mode"
echo "  voice-help = Show help"
echo ""
echo "✨ Ready to transcribe! Perfect for Claude conversations!"
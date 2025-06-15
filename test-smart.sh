#!/bin/bash
set -e

echo "Simple Smart Recording Test"
echo "=========================="
echo ""
echo "Choose test:"
echo "1) 5-second recording (quick test)"
echo "2) 15-second recording (longer speech test)"
echo "3) Press-spacebar-to-stop test (unlimited)"
echo ""
echo "Pick 1, 2, or 3:"
read choice

timestamp=$(date +%s)
outdir="/tmp/test_smart_$timestamp"
mkdir -p "$outdir"
audio="$outdir/test.wav"
txt="$outdir/test.txt"

case $choice in
    1)
        echo ""
        echo "🎤 5-second test - speak NOW:"
        echo "Say: 'This is a quick test of the smart recording system'"
        ffmpeg -f avfoundation -i ":1" -t 5 -ac 1 -ar 16000 -filter:a "volume=5.0" "$audio" -y -loglevel error
        ;;
    2)
        echo ""
        echo "🎤 15-second test - speak NOW:"
        echo "Say something longer, like describe your day or plans"
        ffmpeg -f avfoundation -i ":1" -t 15 -ac 1 -ar 16000 -filter:a "volume=5.0" "$audio" -y -loglevel error
        ;;
    3)
        echo ""
        echo "🔴 Recording started - speak now"
        echo "Press SPACE to stop (or auto-stop in 60 seconds)"
        
        # Start recording in background
        timeout 60 ffmpeg -f avfoundation -i ":1" -ac 1 -ar 16000 -filter:a "volume=5.0" "$audio" -y -loglevel error &
        ffmpeg_pid=$!
        
        # Wait for spacebar
        read -n1 -s key
        kill $ffmpeg_pid 2>/dev/null || true
        wait $ffmpeg_pid 2>/dev/null || true
        echo "⏹️ Stopped"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

# Quick transcribe
echo "🧠 Transcribing..."
whisper "$audio" --language en --task transcribe --output_format txt --output_dir "$outdir" --model tiny --fp16 False --verbose False > /dev/null 2>&1

# Show result
if [[ -f "$txt" ]]; then
    pbcopy < "$txt"
    echo ""
    echo "📋 Result (copied to clipboard):"
    echo "================================"
    cat "$txt"
    echo "================================"
    echo ""
    echo "✅ Success! Ready to paste in Claude"
else
    echo "❌ Transcription failed"
fi

# Clean up
rm -rf "$outdir"
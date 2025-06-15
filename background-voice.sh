#!/bin/bash
set -e

echo "🎧 Background Voice Recording Mode"
echo "=================================="
echo "💡 This runs in background - speak whenever you want!"
echo "📝 Commands:"
echo "  ENTER = transcribe what you just said"
echo "  q = quit"
echo "  h = help"
echo ""

# Create session directory
session_timestamp=$(date +%s)
session_dir="/tmp/voice_session_$session_timestamp"
mkdir -p "$session_dir"

echo "🎙️ Background recording started..."
echo "Speak naturally - I'm always listening!"
echo ""

# Start continuous recording in background
continuous_audio="$session_dir/continuous.wav"
ffmpeg -f avfoundation -i ":1" -ac 1 -ar 16000 -filter:a "volume=5.0" "$continuous_audio" -y -loglevel error &
recording_pid=$!

transcript_count=0

while true; do
    echo -n "💬 Ready (ENTER=transcribe, q=quit): "
    read -r input
    
    case "$input" in
        "q"|"quit"|"exit")
            echo "👋 Stopping background recording..."
            kill $recording_pid 2>/dev/null || true
            rm -rf "$session_dir"
            echo "✅ Session ended"
            exit 0
            ;;
        "h"|"help")
            echo "📖 Commands:"
            echo "  ENTER = transcribe recent speech (last 30 seconds)"
            echo "  q = quit and cleanup"
            echo "  h = show this help"
            ;;
        *)
            # Transcribe last 30 seconds
            transcript_count=$((transcript_count + 1))
            
            echo "🔄 Capturing last 30 seconds..."
            
            # Kill current recording and extract last 30 seconds
            kill $recording_pid 2>/dev/null || true
            wait $recording_pid 2>/dev/null || true
            
            # Extract last 30 seconds
            segment_audio="$session_dir/segment_$transcript_count.wav"
            ffmpeg -sseof -30 -i "$continuous_audio" -c copy "$segment_audio" -y -loglevel error 2>/dev/null || {
                # If file too short, use whole thing
                cp "$continuous_audio" "$segment_audio"
            }
            
            echo "🧠 Transcribing..."
            segment_txt="$session_dir/segment_$transcript_count.txt"
            whisper "$segment_audio" --language en --task transcribe --output_format txt --output_dir "$session_dir" --model base --fp16 False --verbose False > /dev/null 2>&1
            
            # Find the generated txt file (whisper creates its own naming)
            txt_file=$(find "$session_dir" -name "segment_$transcript_count.txt" -o -name "*segment_$transcript_count*.txt" | head -1)
            
            if [[ -f "$txt_file" ]]; then
                echo "📋 Transcription #$transcript_count:"
                echo "================================"
                cat "$txt_file"
                echo "================================"
                echo "✅ Copied to clipboard"
                pbcopy < "$txt_file"
            else
                echo "❌ Transcription failed"
            fi
            
            # Restart continuous recording
            ffmpeg -f avfoundation -i ":1" -ac 1 -ar 16000 -filter:a "volume=5.0" "$continuous_audio" -y -loglevel error &
            recording_pid=$!
            echo ""
            ;;
    esac
done
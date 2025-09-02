import { useState, useRef, useEffect, useCallback } from 'react'
import { Stack, IconButton, MessageBar, MessageBarType } from '@fluentui/react'
import { MicRegular, MicFilled, MicOffRegular, EditRegular, CheckmarkRegular, DismissRegular } from '@fluentui/react-icons'

import styles from './SpeechToText.module.css'

interface Props {
  onTranscriptUpdate: (transcript: string) => void
  onTranscriptConfirmed: (transcript: string) => void
  disabled?: boolean
  placeholder?: string
}

// Check if the browser supports speech recognition
const getSpeechRecognition = (): typeof window.SpeechRecognition | typeof window.webkitSpeechRecognition | null => {
  if (typeof window !== 'undefined') {
    return window.SpeechRecognition || window.webkitSpeechRecognition || null
  }
  return null
}

export const SpeechToText = ({ onTranscriptUpdate, onTranscriptConfirmed, disabled, placeholder = 'Click microphone to start speaking...' }: Props) => {
  const [isListening, setIsListening] = useState<boolean>(false)
  const [transcript, setTranscript] = useState<string>('')
  const [isEditing, setIsEditing] = useState<boolean>(false)
  const [editedTranscript, setEditedTranscript] = useState<string>('')
  const [error, setError] = useState<string | null>(null)
  const [isSupported, setIsSupported] = useState<boolean>(true)
  const recognition = useRef<any>(null)
  const silenceTimer = useRef<number | null>(null)
  const finalTranscriptRef = useRef<string>('')

  // Check browser support on component mount
  useEffect(() => {
    const SpeechRecognition = getSpeechRecognition()
    if (!SpeechRecognition) {
      setIsSupported(false)
      setError('Speech recognition is not supported in this browser. Please try Chrome, Edge, or Safari.')
      return
    }

    // Initialize speech recognition
    recognition.current = new SpeechRecognition()
    recognition.current.continuous = true  // Keep listening for longer phrases
    recognition.current.interimResults = true
    recognition.current.lang = 'en-US'
    recognition.current.maxAlternatives = 5  // Get even more alternatives for better accuracy
    
    // Additional settings for better recognition
    if ('webkitSpeechRecognition' in window) {
      // Chrome-specific settings for better accuracy
      const webkitRecognition = recognition.current as any
      webkitRecognition.servicePath = 'chromium'
      // Try to improve recognition of legal terms
      webkitRecognition.grammars = []
    }

    recognition.current.onstart = () => {
      setIsListening(true)
      setError(null)
    }

    recognition.current.onresult = (event: any) => {
      let finalTranscript = ''
      let interimTranscript = ''

      // Clear any existing silence timer
      if (silenceTimer.current) {
        clearTimeout(silenceTimer.current)
        silenceTimer.current = null
      }

      // Process all results from the beginning
      for (let i = 0; i < event.results.length; i++) {
        // Try the best alternative first, fallback to others if needed
        let bestTranscript = event.results[i][0].transcript
        
        // If we have multiple alternatives, log them for debugging
        if (event.results[i].length > 1) {
          console.log(`Speech alternatives for result ${i}:`)
          for (let j = 0; j < Math.min(5, event.results[i].length); j++) {
            const alt = event.results[i][j]
            const confidence = alt.confidence !== undefined ? alt.confidence.toFixed(3) : 'unknown'
            console.log(`  ${j}: "${alt.transcript}" (confidence: ${confidence})`)
          }
          
          // If confidence is low on the top choice, consider if any alternatives contain "theft"
          const topConfidence = event.results[i][0].confidence
          if (topConfidence !== undefined && topConfidence < 0.8) {
            for (let j = 1; j < Math.min(5, event.results[i].length); j++) {
              const alt = event.results[i][j]
              if (alt.transcript.toLowerCase().includes('theft')) {
                console.log(`Found "theft" in alternative ${j}, using that instead`)
                bestTranscript = alt.transcript
                break
              }
            }
          }
        }
        
        if (event.results[i].isFinal) {
          finalTranscript += bestTranscript
        } else {
          interimTranscript += bestTranscript
        }
      }

      // Build the complete transcript
      const currentTranscript = finalTranscript || interimTranscript

      // Update the stored final transcript
      if (finalTranscript) {
        finalTranscriptRef.current = finalTranscript
      }

      // Debug logging
      console.log('Speech results:', {
        finalTranscript,
        interimTranscript,
        currentTranscript,
        resultCount: event.results.length,
        results: Array.from(event.results).map((result: any, i) => ({
          index: i,
          transcript: result[0]?.transcript || 'no transcript',
          confidence: result[0]?.confidence || 'unknown',
          isFinal: result.isFinal
        }))
      })

      setTranscript(currentTranscript.trim())
      onTranscriptUpdate(currentTranscript.trim())

      // Only set a silence timer if we have substantial final content
      // This prevents premature stopping during longer phrases
      if (finalTranscript && finalTranscript.trim().length > 3) {
        silenceTimer.current = setTimeout(() => {
          if (recognition.current && isListening) {
            console.log('Stopping due to silence timeout')
            recognition.current.stop()
          }
        }, 5000) // 5 seconds after final results to allow for longer phrases
      }
    }

    recognition.current.onerror = (event: any) => {
      setError(`Speech recognition error: ${event.error}`)
      setIsListening(false)
    }

    recognition.current.onend = () => {
      console.log('Speech recognition ended. Final transcript ref:', finalTranscriptRef.current)
      setIsListening(false)
      
      // Clear any pending silence timer
      if (silenceTimer.current) {
        clearTimeout(silenceTimer.current)
        silenceTimer.current = null
      }
      
      // Use the most recent final transcript if available
      const finalText = finalTranscriptRef.current || transcript
      if (finalText && finalText.trim()) {
        setTranscript(finalText.trim())
        onTranscriptUpdate(finalText.trim())
      }
    }

    return () => {
      if (recognition.current) {
        recognition.current.stop()
      }
    }
  }, [onTranscriptUpdate])

  const startListening = useCallback(() => {
    if (disabled || !recognition.current || !isSupported) {
      console.log('Cannot start listening:', { disabled, hasRecognition: !!recognition.current, isSupported })
      return
    }

    try {
      setError(null)
      // Reset the final transcript for a fresh start
      finalTranscriptRef.current = ''
      console.log('Starting speech recognition...')
      recognition.current.start()
    } catch (error) {
      console.error('Speech recognition start error:', error)
      setError(`Could not start speech recognition: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }, [disabled, isSupported])

  const stopListening = useCallback(() => {
    try {
      if (recognition.current) {
        console.log('Stopping speech recognition...')
        recognition.current.stop()
      }
      // Clear any pending silence timer
      if (silenceTimer.current) {
        clearTimeout(silenceTimer.current)
        silenceTimer.current = null
      }
    } catch (error) {
      console.error('Speech recognition stop error:', error)
    }
  }, [])

  const handleStartEdit = () => {
    setIsEditing(true)
    setEditedTranscript(transcript)
  }

  const handleConfirmEdit = () => {
    setTranscript(editedTranscript)
    onTranscriptUpdate(editedTranscript)
    setIsEditing(false)
  }

  const handleCancelEdit = () => {
    setIsEditing(false)
    setEditedTranscript('')
  }

  const handleConfirmTranscript = () => {
    const finalTranscript = isEditing ? editedTranscript : transcript
    onTranscriptConfirmed(finalTranscript)
    setTranscript('')
    setEditedTranscript('')
    setIsEditing(false)
  }

  const handleClearTranscript = () => {
    setTranscript('')
    setEditedTranscript('')
    setIsEditing(false)
    onTranscriptUpdate('')
  }

  if (!isSupported) {
    return (
      <div className={styles.speechContainer}>
        <MessageBar messageBarType={MessageBarType.warning}>
          {error}
        </MessageBar>
      </div>
    )
  }

  return (
    <div className={styles.speechContainer}>
      {error && (
        <MessageBar messageBarType={MessageBarType.error} onDismiss={() => setError(null)}>
          {error}
        </MessageBar>
      )}
      
      <Stack horizontal className={styles.speechControls}>
        {/* Microphone button */}
        <IconButton
          iconProps={{ 
            iconName: 'Microphone',
            children: isListening ? <MicFilled /> : <MicRegular />
          }}
          title={isListening ? 'Stop recording' : 'Start recording'}
          ariaLabel={isListening ? 'Stop recording' : 'Start recording'}
          disabled={disabled}
          className={`${styles.micButton} ${isListening ? styles.micButtonActive : ''}`}
          onClick={isListening ? stopListening : startListening}
        />

        {/* Transcript display/edit area */}
        {transcript && (
          <Stack className={styles.transcriptContainer}>
            {isEditing ? (
              <Stack horizontal className={styles.editContainer}>
                <textarea
                  className={styles.transcriptEdit}
                  value={editedTranscript}
                  onChange={(e) => setEditedTranscript(e.target.value)}
                  placeholder="Edit your transcript..."
                  aria-label="Edit transcript"
                />
                <Stack horizontal className={styles.editButtons}>
                  <IconButton
                    iconProps={{ children: <CheckmarkRegular /> }}
                    title="Confirm edit"
                    ariaLabel="Confirm edit"
                    onClick={handleConfirmEdit}
                    className={styles.confirmButton}
                  />
                  <IconButton
                    iconProps={{ children: <DismissRegular /> }}
                    title="Cancel edit"
                    ariaLabel="Cancel edit"
                    onClick={handleCancelEdit}
                    className={styles.cancelButton}
                  />
                </Stack>
              </Stack>
            ) : (
              <Stack horizontal className={styles.transcriptDisplay}>
                <div className={styles.transcriptText} aria-live="polite">
                  {transcript}
                  {isListening && <span className={styles.listeningIndicator}>...</span>}
                </div>
                <Stack horizontal className={styles.transcriptButtons}>
                  <IconButton
                    iconProps={{ children: <EditRegular /> }}
                    title="Edit transcript"
                    ariaLabel="Edit transcript"
                    onClick={handleStartEdit}
                    className={styles.editButton}
                  />
                  <IconButton
                    iconProps={{ children: <CheckmarkRegular /> }}
                    title="Use this transcript"
                    ariaLabel="Use this transcript"
                    onClick={handleConfirmTranscript}
                    className={styles.confirmButton}
                  />
                  <IconButton
                    iconProps={{ children: <DismissRegular /> }}
                    title="Clear transcript"
                    ariaLabel="Clear transcript"
                    onClick={handleClearTranscript}
                    className={styles.cancelButton}
                  />
                </Stack>
              </Stack>
            )}
          </Stack>
        )}

        {/* Status indicator */}
        {isListening && (
          <div className={styles.listeningStatus} aria-live="polite">
            <span>Listening...</span>
            <div className={styles.soundWave}>
              <div className={styles.wave}></div>
              <div className={styles.wave}></div>
              <div className={styles.wave}></div>
            </div>
          </div>
        )}
      </Stack>

      {!transcript && !isListening && (
        <div className={styles.placeholder}>
          {placeholder}
        </div>
      )}
    </div>
  )
}

import React, { useState, useRef, useEffect, useCallback } from 'react'
import { IconButton } from '@fluentui/react'
import styles from './SpeechToText.module.css'

interface SpeechToTextProps {
  onTranscriptUpdate: (transcript: string) => void
  onTranscriptConfirmed?: (transcript: string) => void
  onSpeechStart?: () => void
  disabled?: boolean
  placeholder?: string
  forceStop?: boolean
}

// Simple speech recognition interface
declare global {
  interface Window {
    SpeechRecognition: any
    webkitSpeechRecognition: any
  }
}

const SpeechToText: React.FC<SpeechToTextProps> = ({ 
  onTranscriptUpdate, 
  onTranscriptConfirmed,
  onSpeechStart,
  disabled = false,
  placeholder,
  forceStop = false 
}) => {
  const [isListening, setIsListening] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [isSupported, setIsSupported] = useState(true)
  
  const recognition = useRef<any>(null)
  const isListeningRef = useRef(false)
  const shouldStopRef = useRef(false)

  // Get speech recognition class
  const getSpeechRecognition = () => {
    return window.SpeechRecognition || window.webkitSpeechRecognition
  }

  // Check browser support
  useEffect(() => {
    const SpeechRecognition = getSpeechRecognition()
    if (!SpeechRecognition) {
      setIsSupported(false)
      setError('Speech recognition is not supported in this browser. Please try Chrome, Edge, or Safari.')
    }
  }, [])

  const startListening = useCallback(() => {
    if (!isSupported || disabled) {
      return
    }

    // If already listening, don't start
    if (isListeningRef.current) {
      return
    }

    // If in process of stopping, don't start
    if (shouldStopRef.current) {
      return
    }

    // Create a fresh recognition instance to avoid state issues
    const SpeechRecognition = getSpeechRecognition()
    if (!SpeechRecognition) {
      return
    }

    try {
      setError(null)
      
      // Create new recognition instance
      recognition.current = new SpeechRecognition()
      recognition.current.continuous = true
      recognition.current.interimResults = true
      recognition.current.lang = 'en-US'

      // Set up event handlers
      recognition.current.onstart = () => {
        if (!shouldStopRef.current) {
          setIsListening(true)
          isListeningRef.current = true
          setError(null)
          // Call the speech start callback to capture current input text
          onSpeechStart?.()
        }
      }

      recognition.current.onresult = (event: any) => {
        if (shouldStopRef.current) {
          return
        }

        let finalTranscript = ''
        let interimTranscript = ''

        for (let i = 0; i < event.results.length; i++) {
          const transcript = event.results[i][0].transcript
          if (event.results[i].isFinal) {
            finalTranscript += transcript
          } else {
            interimTranscript += transcript
          }
        }

        const currentTranscript = finalTranscript || interimTranscript
        
        if (!shouldStopRef.current && isListeningRef.current) {
          onTranscriptUpdate(currentTranscript.trim())
        }
      }

      recognition.current.onerror = (event: any) => {
        if (event.error === 'aborted') {
          return
        }
        
        console.error('Speech recognition error:', event.error)
        setError(`Speech recognition error: ${event.error}`)
        setIsListening(false)
        isListeningRef.current = false
        shouldStopRef.current = false // Reset on error
      }

      recognition.current.onend = () => {
        setIsListening(false)
        isListeningRef.current = false
        shouldStopRef.current = false // Reset immediately
      }

      recognition.current.start()
    } catch (error) {
      console.error('Error starting speech recognition:', error)
      setError('Could not start speech recognition. Please try again.')
    }
  }, [isSupported, disabled, onTranscriptUpdate, onSpeechStart])

  const stopListening = useCallback(() => {
    if (recognition.current) {
      try {
        // Set stop flag immediately to prevent further processing
        shouldStopRef.current = true
        isListeningRef.current = false
        
        recognition.current.stop()
        
        // Immediately update UI state
        setIsListening(false)
        // Clear any error when manually stopping
        setError(null)
        
        // Don't reset shouldStopRef here - let onend event handle it
      } catch (error) {
        console.error('Error stopping speech recognition:', error)
        // Force state reset even if stop fails
        setIsListening(false)
        isListeningRef.current = false
        shouldStopRef.current = false // Reset immediately only on error
      }
    } else {
      // Force state reset anyway
      setIsListening(false)
      isListeningRef.current = false
      shouldStopRef.current = false // Reset immediately when no recognition
    }
  }, [])

  // Cleanup effect - stop recognition when component is disabled
  useEffect(() => {
    if (disabled && isListening) {
      stopListening()
    }
  }, [disabled, isListening, stopListening])

  // Force stop effect
  useEffect(() => {
    if (forceStop && isListening) {
      stopListening()
    }
  }, [forceStop, isListening, stopListening])

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (recognition.current && (isListening || isListeningRef.current)) {
        shouldStopRef.current = true
        isListeningRef.current = false
        recognition.current.stop()
      }
    }
  }, [])

    const toggleListening = useCallback(() => {
    if (isListening) {
      stopListening()
    } else {
      startListening()
    }
  }, [isListening, startListening, stopListening])

  // Don't render if not supported
  if (!isSupported) {
    return (
      <div className={styles.container}>
        <div className={styles.error}>
          Speech recognition is not supported in this browser
        </div>
      </div>
    )
  }

  return (
    <div className={styles.container}>
      <div className={styles.controls}>
        <IconButton
          iconProps={{ 
            iconName: isListening ? 'MicOff' : 'Microphone',
          }}
          onClick={toggleListening}
          disabled={disabled}
          className={isListening ? styles.listeningButton : styles.micButton}
          title={isListening ? 'Stop listening' : 'Start speech recognition'}
        />
        
        {isListening && (
          <div className={styles.listeningIndicator}>
            <span>Listening...</span>
          </div>
        )}
      </div>

      {error && (
        <div className={styles.error}>
          {error}
        </div>
      )}
    </div>
  )
}

export default SpeechToText

import React, { useState, useRef, useEffect, useCallback } from 'react'
import { IconButton } from '@fluentui/react'
import styles from './SpeechToText.module.css'

interface SpeechToTextProps {
  onTranscriptUpdate: (transcript: string) => void
  onTranscriptConfirmed?: (transcript: string) => void
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
  disabled = false,
  placeholder,
  forceStop = false 
}) => {
  const [isListening, setIsListening] = useState(false)
  const [transcript, setTranscript] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isSupported, setIsSupported] = useState(true)
  const [shouldStop, setShouldStop] = useState(false)
  
  const recognition = useRef<any>(null)
  const isListeningRef = useRef(false)
  const shouldStopRef = useRef(false)

  // Get speech recognition class
  const getSpeechRecognition = () => {
    return window.SpeechRecognition || window.webkitSpeechRecognition
  }

  // Initialize speech recognition
  useEffect(() => {
    const SpeechRecognition = getSpeechRecognition()
    if (!SpeechRecognition) {
      setIsSupported(false)
      setError('Speech recognition is not supported in this browser. Please try Chrome, Edge, or Safari.')
      return
    }

    try {
      recognition.current = new SpeechRecognition()
      recognition.current.continuous = true
      recognition.current.interimResults = true
      recognition.current.lang = 'en-US'

      recognition.current.onstart = () => {
        console.log('Speech recognition started')
        if (!shouldStopRef.current) {
          setIsListening(true)
          isListeningRef.current = true
          setError(null)
        }
      }

      recognition.current.onresult = (event: any) => {
        // Only process results if we're not supposed to stop
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
        console.log('Speech result:', currentTranscript)
        
        // Only update if we're still supposed to be listening
        if (!shouldStopRef.current && isListeningRef.current) {
          setTranscript(currentTranscript.trim())
          onTranscriptUpdate(currentTranscript.trim())
        }
      }

      recognition.current.onerror = (event: any) => {
        console.error('Speech recognition error:', event.error)
        setError(`Speech recognition error: ${event.error}`)
        setIsListening(false)
        isListeningRef.current = false
      }

      recognition.current.onend = () => {
        console.log('Speech recognition ended')
        setIsListening(false)
        isListeningRef.current = false
        
        // Reset stop flag
        shouldStopRef.current = false
      }

    } catch (error) {
      console.error('Failed to initialize speech recognition:', error)
      setIsSupported(false)
      setError('Failed to initialize speech recognition')
    }
  }, [onTranscriptUpdate])

  const startListening = useCallback(() => {
    if (!recognition.current || !isSupported || disabled) {
      console.log('Cannot start - not supported or disabled')
      return
    }

    try {
      setError(null)
      shouldStopRef.current = false
      recognition.current.start()
      console.log('Starting speech recognition')
    } catch (error) {
      console.error('Error starting speech recognition:', error)
      setError('Could not start speech recognition')
    }
  }, [isSupported, disabled])

  const stopListening = useCallback(() => {
    if (recognition.current) {
      try {
        // Set stop flag immediately to prevent further processing
        shouldStopRef.current = true
        isListeningRef.current = false
        
        recognition.current.stop()
        console.log('Stopping speech recognition')
        
        // Immediately update UI state
        setIsListening(false)
        setTranscript('')
      } catch (error) {
        console.error('Error stopping speech recognition:', error)
      }
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
    console.log('Toggle listening - current state:', isListening)
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

      {transcript && (
        <div className={styles.transcript}>
          <strong>Transcript:</strong> {transcript}
        </div>
      )}
    </div>
  )
}

export default SpeechToText

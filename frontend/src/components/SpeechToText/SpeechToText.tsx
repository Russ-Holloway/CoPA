import React, { useState, useRef, useEffect, useCallback } from 'react'
import { IconButton } from '@fluentui/react'
import styles from './SpeechToText.module.css'

interface SpeechToTextProps {
  onTranscriptUpdate: (transcript: string) => void
  onTranscriptConfirmed?: (transcript: string) => void
  disabled?: boolean
  placeholder?: string
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
  placeholder 
}) => {
  const [isListening, setIsListening] = useState(false)
  const [transcript, setTranscript] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isSupported, setIsSupported] = useState(true)
  
  const recognition = useRef<any>(null)

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
        setIsListening(true)
        setError(null)
      }

      recognition.current.onresult = (event: any) => {
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
        
        setTranscript(currentTranscript.trim())
        onTranscriptUpdate(currentTranscript.trim())
      }

      recognition.current.onerror = (event: any) => {
        console.error('Speech recognition error:', event.error)
        setError(`Speech recognition error: ${event.error}`)
        setIsListening(false)
      }

      recognition.current.onend = () => {
        console.log('Speech recognition ended')
        setIsListening(false)
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
        recognition.current.stop()
        console.log('Stopping speech recognition')
      } catch (error) {
        console.error('Error stopping speech recognition:', error)
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

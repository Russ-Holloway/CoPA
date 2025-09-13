import { useState, useRef, useEffect } from 'react'
import { ArrowEnterRegular, ArrowEnterFilled } from '@fluentui/react-icons'

import styles from './QuestionInput.module.css'
import './QuestionInputOverrides.css'
import { ChatMessage } from '../../api'
import { SpeechToText } from '../SpeechToText'

interface Props {
  onSend: (question: ChatMessage['content'], id?: string) => void
  disabled: boolean
  placeholder?: string
  clearOnSend?: boolean
  conversationId?: string
  enableSpeechToText?: boolean
}

export const QuestionInput = ({ onSend, disabled, placeholder, clearOnSend, conversationId, enableSpeechToText = true }: Props) => {
  const [question, setQuestion] = useState<string>('')
  const [hasError, setHasError] = useState<boolean>(false)
  const [errorMessage, setErrorMessage] = useState<string>('')
  const [statusMessage, setStatusMessage] = useState<string>('')
  const [showSpeechToText, setShowSpeechToText] = useState<boolean>(false)
  const [forceStopSpeech, setForceStopSpeech] = useState<boolean>(false)
  const speechStartTextRef = useRef<string>('')
  const textAreaRef = useRef<HTMLTextAreaElement>(null)

  // Clear error when user starts typing
  useEffect(() => {
    if (question.trim() && hasError) {
      setHasError(false)
      setErrorMessage('')
    }
  }, [question, hasError])

  const sendQuestion = () => {
    if (disabled) {
      setStatusMessage('Cannot send message while processing')
      return
    }

    if (!question.trim()) {
      setHasError(true)
      setErrorMessage('Please enter a question before sending')
      setStatusMessage('Error: Question cannot be empty')
      textAreaRef.current?.focus()
      return
    }

    const questionTest: ChatMessage['content'] = question.toString()

    if (conversationId && questionTest !== undefined) {
      onSend(questionTest, conversationId)
    } else {
      onSend(questionTest)
    }

    if (clearOnSend) {
      setQuestion('')
    }

    setStatusMessage('Question sent successfully')
    setHasError(false)
    setErrorMessage('')

    // Clear status message after 3 seconds
    setTimeout(() => {
      setStatusMessage('')
    }, 3000)
  }

  const onEnterPress = (ev: React.KeyboardEvent<Element>) => {
    if (ev.key === 'Enter' && !ev.shiftKey && !(ev.nativeEvent?.isComposing === true)) {
      ev.preventDefault()
      sendQuestion()
    }
  }

  // Speech-to-text handlers
  const handleSpeechStart = () => {
    // Capture the current text when speech recognition starts
    speechStartTextRef.current = question
  }

  const handleTranscriptUpdate = (transcript: string) => {
    // Only update question if speech-to-text is still enabled and showing
    if (showSpeechToText && enableSpeechToText) {
      // Combine existing text with new speech transcript
      const existingText = speechStartTextRef.current
      const needsSpace = existingText.trim() && transcript.trim() && !existingText.endsWith(' ')
      const newQuestion = existingText + (needsSpace ? ' ' : '') + transcript
      setQuestion(newQuestion)
    }
  }

  const handleTranscriptConfirmed = (transcript: string) => {
    // Set the final transcript and hide speech-to-text
    const existingText = speechStartTextRef.current
    const needsSpace = existingText.trim() && transcript.trim() && !existingText.endsWith(' ')
    const finalQuestion = existingText + (needsSpace ? ' ' : '') + transcript
    setQuestion(finalQuestion)
    setShowSpeechToText(false)
    speechStartTextRef.current = ''
    // Focus back on the text area for editing if needed
    setTimeout(() => {
      textAreaRef.current?.focus()
    }, 100)
  }

  // Handle toggle off - need to stop any active speech recognition
  const handleSpeechToggleChange = (_: unknown, checked: boolean | undefined) => {
    const isEnabled = checked || false
    setShowSpeechToText(isEnabled)
    
    if (isEnabled) {
      // When enabling speech-to-text, save the current text as the starting point
      speechStartTextRef.current = question
    } else {
      // If turning off speech-to-text, force stop any active recognition
      setForceStopSpeech(true)
      speechStartTextRef.current = ''
      // Reset the force stop flag after a brief delay
      setTimeout(() => {
        setForceStopSpeech(false)
      }, 100)
    }
  }

  const sendQuestionDisabled = disabled || !question.trim()

  return (
    <div className={styles.questionInputContainer}>
      {/* Screen reader only status announcements */}
      <div aria-live="polite" aria-atomic="true" className={styles.srOnly}>
        {statusMessage}
      </div>

      {/* Speech-to-text component */}
      {enableSpeechToText && (
        <div className={styles.speechToggleContainer}>
          <label className={styles.speechToggle}>
            <input
              type="checkbox"
              checked={showSpeechToText}
              onChange={(e) => handleSpeechToggleChange(e, e.target.checked)}
              disabled={disabled}
            />
            <span>Speech to Text</span>
          </label>
        </div>
      )}

      {/* Show speech-to-text component when enabled */}
      {showSpeechToText && enableSpeechToText && (
        <SpeechToText
          onTranscriptUpdate={handleTranscriptUpdate}
          onTranscriptConfirmed={handleTranscriptConfirmed}
          onSpeechStart={handleSpeechStart}
          disabled={disabled}
          forceStop={forceStopSpeech}
          placeholder="Click the microphone to start speaking, or toggle off to use keyboard input."
        />
      )}

      <div className={styles.questionInputMainContainer}>
        <textarea
          ref={textAreaRef}
          className={styles.questionInputTextArea}
          placeholder={showSpeechToText ? "Speak or type your question here..." : placeholder}
          value={question}
          onChange={(e) => setQuestion(e.target.value)}
          onKeyDown={onEnterPress}
          aria-invalid={hasError}
          aria-describedby={hasError ? 'question-error' : undefined}
          aria-label="Type your question here"
          rows={3}
        />

        {hasError && (
          <div id="question-error" role="alert" aria-live="assertive" className={styles.errorMessage}>
            {errorMessage}
          </div>
        )}

        <div
          className={styles.questionInputSendButtonContainer}
          role="button"
          tabIndex={0}
          aria-label={sendQuestionDisabled ? 'Send button disabled' : 'Send question'}
          aria-disabled={sendQuestionDisabled}
          onClick={sendQuestion}
          onKeyDown={e => (e.key === 'Enter' || e.key === ' ' ? sendQuestion() : null)}>
          {sendQuestionDisabled ? (
            <ArrowEnterRegular className={styles.questionInputSendButtonDisabled} aria-hidden="true" />
          ) : (
            <ArrowEnterFilled className={styles.questionInputSendButton} title="Press Enter to send" aria-hidden="true" />
          )}
        </div>
      </div>
      
      <div className={styles.questionInputBottomBorder} />
    </div>
  )
}

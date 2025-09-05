import React, { useContext } from 'react'
import { AppStateContext } from '../state/AppProvider'

export const DebugPanel: React.FC = () => {
  const appStateContext = useContext(AppStateContext)
  
  return (
    <div style={{ 
      position: 'fixed', 
      top: 0, 
      right: 0, 
      background: 'yellow', 
      padding: '10px',
      fontSize: '12px',
      maxWidth: '400px',
      zIndex: 9999
    }}>
      <h4>Debug Info</h4>
      <div><strong>Frontend Settings Loaded:</strong> {appStateContext?.state.frontendSettings ? 'Yes' : 'No'}</div>
      <div><strong>UI Settings:</strong> {appStateContext?.state.frontendSettings?.ui ? 'Yes' : 'No'}</div>
      <div><strong>Tagline 1:</strong> {appStateContext?.state.frontendSettings?.ui?.police_force_tagline || 'NOT SET'}</div>
      <div><strong>Tagline 2:</strong> {appStateContext?.state.frontendSettings?.ui?.police_force_tagline_2 || 'NOT SET'}</div>
      <div><strong>Is Loading:</strong> {appStateContext?.state.isLoading ? 'Yes' : 'No'}</div>
    </div>
  )
}

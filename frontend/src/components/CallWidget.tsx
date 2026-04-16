import { useState, useCallback } from 'react'
import { useConversation } from '@11labs/react'
import { Phone, PhoneOff, Mic, MicOff, X } from 'lucide-react'

export function CallWidget() {
  const [isOpen, setIsOpen] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const conversation = useConversation({
    onConnect: () => setError(null),
    onDisconnect: () => {},
    onError: (err: unknown) => setError(typeof err === 'string' ? err : 'Connection error'),
  })

  const agentId = import.meta.env.VITE_ELEVENLABS_AGENT_ID

  const startCall = useCallback(async () => {
    try {
      setError(null)
      await navigator.mediaDevices.getUserMedia({ audio: true })
      if (!agentId) {
        setError('Agent ID not configured')
        return
      }
      await conversation.startSession({ agentId })
    } catch (err: any) {
      setError(err.message || 'Failed to start call')
    }
  }, [agentId, conversation])

  const endCall = useCallback(async () => {
    await conversation.endSession()
  }, [conversation])

  const isConnected = conversation.status === 'connected'
  const isConnecting = conversation.status === 'connecting'

  if (!isOpen) {
    return (
      <button
        onClick={() => setIsOpen(true)}
        className="fixed bottom-6 right-6 w-14 h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-full shadow-lg flex items-center justify-center transition-all hover:scale-105 z-50"
        title="Talk to AI Agent"
      >
        <Phone className="w-6 h-6" />
      </button>
    )
  }

  return (
    <div className="fixed bottom-6 right-6 w-80 bg-white rounded-2xl shadow-2xl border border-gray-200 overflow-hidden z-50">
      {/* Header */}
      <div className="bg-blue-600 text-white px-4 py-3 flex items-center justify-between">
        <div>
          <h3 className="text-sm font-semibold">SafeGuard AI Agent</h3>
          <p className="text-xs text-blue-200">
            {isConnected ? 'Connected' : isConnecting ? 'Connecting...' : 'Ready to call'}
          </p>
        </div>
        <button
          onClick={() => { if (isConnected) endCall(); setIsOpen(false) }}
          className="p-1 hover:bg-blue-500 rounded"
        >
          <X className="w-4 h-4" />
        </button>
      </div>

      {/* Body */}
      <div className="p-6 text-center">
        {error && (
          <div className="mb-4 p-2 bg-red-50 border border-red-200 rounded-lg">
            <p className="text-xs text-red-600">{error}</p>
          </div>
        )}

        {!agentId && (
          <div className="mb-4 p-2 bg-yellow-50 border border-yellow-200 rounded-lg">
            <p className="text-xs text-yellow-700">Agent ID not set. Add VITE_ELEVENLABS_AGENT_ID to .env</p>
          </div>
        )}

        {/* Call Status Indicator */}
        <div className={`w-20 h-20 mx-auto rounded-full flex items-center justify-center mb-4 ${
          isConnected ? 'bg-green-100 animate-pulse' : isConnecting ? 'bg-yellow-100 animate-pulse' : 'bg-gray-100'
        }`}>
          {isConnected ? (
            <Mic className="w-8 h-8 text-green-600" />
          ) : isConnecting ? (
            <Phone className="w-8 h-8 text-yellow-600 animate-bounce" />
          ) : (
            <MicOff className="w-8 h-8 text-gray-400" />
          )}
        </div>

        {conversation.isSpeaking && (
          <p className="text-sm text-blue-600 mb-3">Agent is speaking...</p>
        )}

        {/* Call Button */}
        {!isConnected && !isConnecting ? (
          <button
            onClick={startCall}
            disabled={!agentId}
            className="w-full py-3 bg-green-600 hover:bg-green-700 disabled:bg-gray-300 text-white font-medium rounded-xl transition-colors flex items-center justify-center gap-2"
          >
            <Phone className="w-5 h-5" />
            Start Call
          </button>
        ) : (
          <button
            onClick={endCall}
            className="w-full py-3 bg-red-600 hover:bg-red-700 text-white font-medium rounded-xl transition-colors flex items-center justify-center gap-2"
          >
            <PhoneOff className="w-5 h-5" />
            End Call
          </button>
        )}
      </div>
    </div>
  )
}

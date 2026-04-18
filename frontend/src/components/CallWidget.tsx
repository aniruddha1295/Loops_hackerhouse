import { createElement } from 'react'

export function CallWidget() {
  const agentId = import.meta.env.VITE_ELEVENLABS_AGENT_ID

  if (!agentId) {
    return (
      <div className="fixed bottom-6 right-6 p-3 bg-yellow-50 border border-yellow-200 rounded-lg max-w-xs z-50">
        <p className="text-xs text-yellow-700">
          Agent ID not set. Add VITE_ELEVENLABS_AGENT_ID to .env
        </p>
      </div>
    )
  }

  return createElement('elevenlabs-convai', { 'agent-id': agentId })
}

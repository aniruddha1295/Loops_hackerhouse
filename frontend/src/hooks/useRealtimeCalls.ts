import { useEffect, useState, useCallback } from 'react'
import { API_BASE_URL } from '../lib/api'
import type { CallToolExecution } from '../types'

interface CallEvent {
  type: 'tool-executed' | 'call-completed'
  payload: any
}

export function useRealtimeCalls() {
  const [latestEvent, setLatestEvent] = useState<CallEvent | null>(null)
  const [toolExecutions, setToolExecutions] = useState<CallToolExecution[]>([])

  const clearEvents = useCallback(() => {
    setLatestEvent(null)
    setToolExecutions([])
  }, [])

  useEffect(() => {
    // Server-Sent Events from the backend (GET /api/events); EventSource reconnects on its own
    const baseUrl = new URL(API_BASE_URL, window.location.origin)
    const source = new EventSource(new URL('/api/events', baseUrl).toString())

    source.addEventListener('tool-executed', (event) => {
      const payload = JSON.parse((event as MessageEvent).data)
      const execution = payload?.tool_execution as CallToolExecution
      if (execution) {
        setToolExecutions((prev) => [...prev, execution])
      }
      setLatestEvent({ type: 'tool-executed', payload })
    })

    source.addEventListener('call-completed', (event) => {
      const payload = JSON.parse((event as MessageEvent).data)
      setLatestEvent({ type: 'call-completed', payload })
    })

    return () => {
      source.close()
    }
  }, [])

  return { latestEvent, toolExecutions, clearEvents }
}

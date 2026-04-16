import { useEffect, useRef } from 'react'
import { Bot, User } from 'lucide-react'

interface TranscriptEntry {
  role: string
  message: string
  timestamp?: string
}

interface TranscriptViewerProps {
  transcript: TranscriptEntry[]
}

export function TranscriptViewer({ transcript }: TranscriptViewerProps) {
  const bottomRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [transcript])

  if (transcript.length === 0) {
    return (
      <div className="flex items-center justify-center h-full text-gray-400 text-sm">
        No transcript available
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-3 overflow-y-auto h-full p-4">
      {transcript.map((entry, index) => {
        const isAgent = entry.role === 'agent' || entry.role === 'assistant' || entry.role === 'ai'
        return (
          <div
            key={`${entry.role}-${index}-${entry.timestamp || ''}`}
            className={`flex gap-3 ${isAgent ? 'justify-start' : 'justify-end'}`}
          >
            {isAgent && (
              <div className="flex-shrink-0 w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center">
                <Bot className="w-4 h-4 text-blue-600" />
              </div>
            )}
            <div className={`max-w-[75%] ${isAgent ? '' : 'order-first'}`}>
              <div className={`flex items-center gap-2 mb-1 ${isAgent ? '' : 'justify-end'}`}>
                <span className="text-xs font-medium text-gray-500">
                  {isAgent ? 'AI Agent' : 'Caller'}
                </span>
                {entry.timestamp && (
                  <span className="text-xs text-gray-400">{entry.timestamp}</span>
                )}
              </div>
              <div
                className={`px-4 py-2.5 rounded-2xl text-sm leading-relaxed ${
                  isAgent
                    ? 'bg-gray-100 text-gray-800 rounded-tl-sm'
                    : 'bg-blue-600 text-white rounded-tr-sm'
                }`}
              >
                {entry.message}
              </div>
            </div>
            {!isAgent && (
              <div className="flex-shrink-0 w-8 h-8 rounded-full bg-green-100 flex items-center justify-center">
                <User className="w-4 h-4 text-green-600" />
              </div>
            )}
          </div>
        )
      })}
      <div ref={bottomRef} />
    </div>
  )
}

import { Loader2 } from 'lucide-react'

export function LoadingSpinner({ message }: { message?: string }) {
  return (
    <div className="flex flex-col items-center justify-center h-64">
      <Loader2 className="w-8 h-8 text-blue-600 animate-spin" />
      {message && <p className="text-sm text-gray-500 mt-3">{message}</p>}
    </div>
  )
}

import { clsx } from 'clsx'

const statusConfig: Record<string, { label: string; className: string }> = {
  submitted: { label: 'Submitted', className: 'bg-blue-100 text-blue-700' },
  under_review: { label: 'Under Review', className: 'bg-yellow-100 text-yellow-700' },
  approved: { label: 'Approved', className: 'bg-green-100 text-green-700' },
  denied: { label: 'Denied', className: 'bg-red-100 text-red-700' },
  documents_needed: { label: 'Docs Needed', className: 'bg-orange-100 text-orange-700' },
  paid: { label: 'Paid', className: 'bg-emerald-100 text-emerald-700' },
  closed: { label: 'Closed', className: 'bg-gray-100 text-gray-700' },
}

export function ClaimStatusBadge({ status }: { status: string }) {
  const config = statusConfig[status] || { label: status, className: 'bg-gray-100 text-gray-700' }
  return (
    <span className={clsx('px-2.5 py-0.5 rounded-full text-xs font-medium', config.className)}>
      {config.label}
    </span>
  )
}

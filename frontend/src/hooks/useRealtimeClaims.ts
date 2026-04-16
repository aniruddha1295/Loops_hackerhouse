import { useEffect, useState, useCallback } from 'react'
import { supabase } from '../lib/supabase'
import type { Claim } from '../types'

export function useRealtimeClaims() {
  const [claims, setClaims] = useState<Claim[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchClaims = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)
      const { data, error: err } = await supabase
        .from('claims')
        .select(`
          *,
          customers!claims_customer_id_fkey ( full_name )
        `)
        .order('updated_at', { ascending: false })

      if (err) throw err

      const mapped = (data || []).map((c: any) => ({
        ...c,
        customer_name: c.customers?.full_name || 'Unknown',
      }))
      setClaims(mapped)
    } catch (err: any) {
      setError(err.message || 'Failed to fetch claims')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchClaims()

    const channel = supabase
      .channel('claims-changes')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'claims' },
        () => {
          fetchClaims()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [fetchClaims])

  return { claims, loading, error, refetch: fetchClaims }
}

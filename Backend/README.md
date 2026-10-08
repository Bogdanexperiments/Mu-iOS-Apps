# Online backend

The repository contains `supabase_schema.sql` for the online account store, public SCP metadata mirror, profile avatars and O5 invitations.

## Setup

1. Create a free Supabase project.
2. Run `supabase_schema.sql` in the Supabase SQL Editor.
3. Enable Email authentication.
4. Add the project URL and publishable anon key to the app's local `SupabaseConfig.swift` (do not commit service-role keys).
5. Implement O5 issue/consume as a Supabase Edge Function or `SECURITY DEFINER` RPC. The first invited address is `ioiopiphone@icloud.com`.

The catalog source is the public SCP Data API metadata index. It provides article title, source URL, creation author and author URL fields without copying article text into the app.

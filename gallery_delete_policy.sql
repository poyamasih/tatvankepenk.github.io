-- Enable RLS if not already enabled
ALTER TABLE gallery_items ENABLE ROW LEVEL SECURITY;

-- Remove any old conflicting policies (to start fresh)
DROP POLICY IF EXISTS "Allow delete for authenticated" ON gallery_items;
DROP POLICY IF EXISTS "Allow insert for authenticated" ON gallery_items;
DROP POLICY IF EXISTS "Allow select for authenticated" ON gallery_items;
DROP POLICY IF EXISTS "Allow update for authenticated" ON gallery_items;

-- Create a permissive insert policy for authenticated users
CREATE POLICY "Allow insert for authenticated"
  ON gallery_items
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Create a permissive select policy for all users (or restrict to authenticated if needed)
CREATE POLICY "Allow select for all" 
  ON gallery_items
  FOR SELECT
  USING (true);  -- Change to (auth.role() = 'authenticated') to restrict to authenticated users

-- Create a permissive update policy for authenticated users
CREATE POLICY "Allow update for authenticated"
  ON gallery_items
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Create a permissive delete policy for authenticated users
CREATE POLICY "Allow delete for authenticated"
  ON gallery_items
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- If you want to debug RLS issues, you can temporarily disable RLS:
-- ALTER TABLE gallery_items DISABLE ROW LEVEL SECURITY;

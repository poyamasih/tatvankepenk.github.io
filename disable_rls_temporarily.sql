-- Script for temporarily disabling RLS for troubleshooting purposes
-- WARNING: This creates a security risk if used in production!

-- Disable RLS temporarily on gallery_items table
ALTER TABLE gallery_items DISABLE ROW LEVEL SECURITY;

-- You can run this SQL script when you're having issues with RLS
-- to see if the problem is related to permissions

-- After testing, be sure to re-enable RLS with:
-- ALTER TABLE gallery_items ENABLE ROW LEVEL SECURITY;

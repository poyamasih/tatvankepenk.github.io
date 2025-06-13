# Drawer Settings RLS Fix - Full Solution

## Overview of the Problem

The application is encountering Row Level Security (RLS) issues when trying to update drawer settings in Supabase. The specific error is "No rows returned after update" which occurs because:

1. The SQL functions defined in `updated_drawer_settings_rls.sql` have not been deployed to Supabase
2. Without these functions, the app falls back to direct table access
3. The RLS policies on the `drawer_settings` table prevent direct updates from the app

## The Solution

The solution involves deploying SQL functions to Supabase that can bypass RLS using the `SECURITY DEFINER` attribute. These functions act as trusted procedures that allow controlled access to the data, even when RLS would normally block it.

### Components of the Fix

1. **SQL Functions**: Three functions have been created:
   - `update_drawer_settings`: Updates an existing settings record
   - `insert_drawer_settings`: Creates a new settings record 
   - `direct_update_drawer_settings`: Alternative method using JSONB

2. **Fallback Mechanism**: The app has been enhanced with a multi-tier approach:
   - First tries the RPC functions
   - Falls back to direct table access if RPC fails
   - Ultimately saves to local cache if both fail

## Deployment Steps

### Option 1: Manual Deployment via Supabase SQL Editor

1. Log in to your Supabase dashboard
2. Navigate to the SQL Editor
3. Create a new query
4. Copy and paste the content from `simplified_drawer_settings_fix.sql`
5. Execute the query

### Option 2: Automated Deployment via Node.js Script

1. Install required packages:
   ```
   npm install pg dotenv
   ```

2. Create a `.env` file with your Supabase database URL:
   ```
   DATABASE_URL=postgres://postgres:your_password@db.your-project-ref.supabase.co:5432/postgres
   ```

3. Run the deployment script:
   ```
   node deploy_functions.js
   ```

## Verification

You can verify the deployment was successful by:

1. Checking if the functions were created in Supabase:
   ```sql
   SELECT routine_name, routine_type
   FROM information_schema.routines
   WHERE routine_schema = 'public' AND 
         (routine_name LIKE '%drawer_settings%')
   ORDER BY routine_name;
   ```

2. Testing the functions manually:
   ```sql
   -- Get your drawer settings ID first
   SELECT id FROM drawer_settings LIMIT 1;
   
   -- Then run an update using the function
   SELECT * FROM update_drawer_settings(
     'the-id-from-above'::uuid, 
     'Test Header', 
     'Test Tagline',
     '+123456789',
     'test@example.com',
     'Test Address',
     'Mon-Fri: 9-5',
     'https://facebook.com/test',
     'https://instagram.com/test',
     'tel:+123456789',
     'mailto:test@example.com'
   );
   ```

3. Observing the logs in your Flutter app:
   - Look for "Successfully updated drawer settings using RPC function"
   - This indicates the RPC function is working properly

## Why This Approach Works

The `SECURITY DEFINER` attribute allows the function to run with the permissions of the function creator (usually a superuser or the database owner) rather than the permissions of the calling user. This effectively bypasses RLS because the function is trusted to perform the operation correctly.

## Testing After Deployment

1. Run the Flutter app
2. Make changes to drawer settings in the admin panel
3. Verify that settings are updated and persist after app restart
4. Check logs for successful RPC function calls

## Additional Notes

- The local cache fallback will continue to work even if there are database connectivity issues
- All three approaches (RPC, direct DB, and local cache) provide seamless user experience
- The solution maintains security while providing the required functionality

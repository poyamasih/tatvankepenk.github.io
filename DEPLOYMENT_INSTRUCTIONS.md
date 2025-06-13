# Drawer Settings RLS Fix - Deployment Instructions

This guide explains how to deploy the SQL functions to Supabase to fix the Row Level Security (RLS) issues with the drawer settings.

## Prerequisites
- Access to the Supabase account and project
- The `updated_drawer_settings_rls.sql` file

## Deployment Steps

### 1. Access Supabase SQL Editor
1. Log in to your Supabase account
2. Open your project
3. Navigate to the "SQL Editor" tab in the left sidebar

### 2. Execute the SQL Script
1. Create a new query in the SQL Editor
2. Copy the entire contents of the `updated_drawer_settings_rls.sql` file into the query editor
3. Click "Run" to execute the script
4. You should see confirmation that the functions were created successfully

### 3. Verify Function Deployment
After running the script, you can verify that the functions were created correctly:

```sql
-- Run this query to check if the functions exist
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public' AND 
      (routine_name LIKE '%drawer_settings%')
ORDER BY routine_name;
```

You should see three functions listed:
- `direct_update_drawer_settings`
- `insert_drawer_settings`
- `update_drawer_settings`

### 4. Test the Functions
You can test the functions directly in the SQL Editor:

```sql
-- To test the update_drawer_settings function
-- (replace the UUID with an actual drawer settings ID from your database)
SELECT * FROM update_drawer_settings(
  'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'::uuid, 
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

## Troubleshooting

### Function Not Found Error
If the app still reports "function not found" errors after deployment:

1. Verify the function names in the SQL Editor match exactly with what's being called in the app:
   - Check for typos in function names
   - Ensure parameters match exactly (names and types)

2. Verify permissions:
   - Make sure the functions have been granted to both `authenticated` and `anon` roles

### Continued RLS Issues
If direct table access still fails after function deployment:

1. Check the RLS policies using the following query:
```sql
SELECT tablename, policyname, permissive, roles, cmd, qual, with_check 
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'drawer_settings';
```

2. Ensure policies are properly configured to allow authenticated users to update records

## Verify in the App
After deployment, your Flutter app should now be able to update drawer settings using the RPC functions rather than falling back to direct table access. Look for logs like:
```
Attempting to update using RPC function...
Successfully updated drawer settings using RPC function
```

instead of:
```
RPC function not available: [error]
Attempting direct table update as fallback...
```

If you still see errors, check the Supabase logs for more detailed information.

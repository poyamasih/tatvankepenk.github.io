-- Updated SQL script for fixing drawer_settings RLS issues

-- Note: This script uses PostgreSQL syntax specific to Supabase
-- Make sure to run this in the Supabase SQL Editor exactly as written

-- 1. First, check if the function already exists to avoid errors
DO $$ 
BEGIN
    -- Drop existing functions if they exist
    DROP FUNCTION IF EXISTS public.update_drawer_settings(uuid, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar);
    DROP FUNCTION IF EXISTS public.insert_drawer_settings(varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar);
EXCEPTION
    WHEN OTHERS THEN 
        RAISE NOTICE 'Error dropping functions: %', SQLERRM;
END $$;

-- 2. Create the function to update drawer settings with SECURITY DEFINER
CREATE OR REPLACE FUNCTION public.update_drawer_settings(
    in_id UUID,
    in_header_title VARCHAR,
    in_header_tagline VARCHAR,
    in_phone VARCHAR,
    in_email VARCHAR,
    in_address VARCHAR,
    in_working_hours VARCHAR,
    in_facebook_link VARCHAR,
    in_instagram_link VARCHAR,
    in_phone_link VARCHAR,
    in_email_link VARCHAR
)
RETURNS SETOF public.drawer_settings
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Update the record and return the updated row
    RETURN QUERY
    UPDATE public.drawer_settings
    SET 
        header_title = in_header_title,
        header_tagline = in_header_tagline,
        phone = in_phone,
        email = in_email,
        address = in_address,
        working_hours = in_working_hours,
        facebook_link = in_facebook_link,
        instagram_link = in_instagram_link,
        phone_link = in_phone_link,
        email_link = in_email_link,
        updated_at = NOW()
    WHERE id = in_id
    RETURNING *;
END;
$$;

-- 3. Grant execute permissions
GRANT EXECUTE ON FUNCTION public.update_drawer_settings TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_drawer_settings TO anon;

-- 4. Create the function to insert new drawer settings
CREATE OR REPLACE FUNCTION public.insert_drawer_settings(
    in_header_title VARCHAR,
    in_header_tagline VARCHAR,
    in_phone VARCHAR,
    in_email VARCHAR,
    in_address VARCHAR,
    in_working_hours VARCHAR,
    in_facebook_link VARCHAR,
    in_instagram_link VARCHAR,
    in_phone_link VARCHAR,
    in_email_link VARCHAR
)
RETURNS SETOF public.drawer_settings
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    new_id UUID;
BEGIN
    -- Generate a new UUID
    SELECT uuid_generate_v4() INTO new_id;
    
    -- Insert the record and return the new row
    RETURN QUERY
    INSERT INTO public.drawer_settings (
        id,
        header_title,
        header_tagline,
        phone,
        email,
        address,
        working_hours,
        facebook_link,
        instagram_link,
        phone_link,
        email_link,
        created_at,
        updated_at
    ) VALUES (
        new_id,
        in_header_title,
        in_header_tagline,
        in_phone,
        in_email,
        in_address,
        in_working_hours,
        in_facebook_link,
        in_instagram_link,
        in_phone_link,
        in_email_link,
        NOW(),
        NOW()
    )
    RETURNING *;
END;
$$;

-- 5. Grant execute permissions
GRANT EXECUTE ON FUNCTION public.insert_drawer_settings TO authenticated;
GRANT EXECUTE ON FUNCTION public.insert_drawer_settings TO anon;

-- 6. Create a direct update function for last resort
CREATE OR REPLACE FUNCTION public.direct_update_drawer_settings(
    in_id UUID,
    in_data JSONB
)
RETURNS SETOF public.drawer_settings
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Update using JSONB to handle any field structure
    RETURN QUERY
    UPDATE public.drawer_settings
    SET 
        header_title = COALESCE(in_data->>'header_title', header_title),
        header_tagline = COALESCE(in_data->>'header_tagline', header_tagline),
        phone = COALESCE(in_data->>'phone', phone),
        email = COALESCE(in_data->>'email', email),
        address = COALESCE(in_data->>'address', address),
        working_hours = COALESCE(in_data->>'working_hours', working_hours),
        facebook_link = COALESCE(in_data->>'facebook_link', facebook_link),
        instagram_link = COALESCE(in_data->>'instagram_link', instagram_link),
        phone_link = COALESCE(in_data->>'phone_link', phone_link),
        email_link = COALESCE(in_data->>'email_link', email_link),
        updated_at = NOW()
    WHERE id = in_id
    RETURNING *;
END;
$$;

-- 7. Grant execute permissions
GRANT EXECUTE ON FUNCTION public.direct_update_drawer_settings TO authenticated;
GRANT EXECUTE ON FUNCTION public.direct_update_drawer_settings TO anon;

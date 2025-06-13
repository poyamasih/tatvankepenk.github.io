-- Fix Row Level Security for drawer_settings table

-- First, let's create a stored procedure to update drawer settings
-- This procedure will run with the privileges of the definer (superuser)
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
RETURNS SETOF drawer_settings
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

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.update_drawer_settings TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_drawer_settings TO anon;

-- Also create an insert function for new settings if needed
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
RETURNS SETOF drawer_settings
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
        email_link
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
        in_email_link
    )
    RETURNING *;
END;
$$;

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.insert_drawer_settings TO authenticated;
GRANT EXECUTE ON FUNCTION public.insert_drawer_settings TO anon;

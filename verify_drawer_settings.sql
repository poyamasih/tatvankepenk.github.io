-- This script verifies and fixes drawer_settings table issues

-- First, check if the extension exists and create it if not
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Check if the table exists and create it if not
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'drawer_settings') THEN
    CREATE TABLE public.drawer_settings (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      header_title VARCHAR NOT NULL DEFAULT 'Tatvan Kepenk',
      header_tagline VARCHAR NOT NULL DEFAULT 'Otomatik Kepenk ve Kapı Sistemleri',
      phone VARCHAR DEFAULT '+90 XXX XXX XX XX',
      email VARCHAR DEFAULT 'info@tatvankepenk.com.tr',
      address VARCHAR DEFAULT 'Tatvan, Bitlis, Türkiye',
      working_hours VARCHAR DEFAULT 'Pazartesi - Cumartesi: 09:00-18:00',
      facebook_link VARCHAR DEFAULT 'https://facebook.com/tatvankepenk',
      instagram_link VARCHAR DEFAULT 'https://instagram.com/tatvankepenk',
      phone_link VARCHAR DEFAULT 'tel:+905551234567',
      email_link VARCHAR DEFAULT 'mailto:info@tatvankepenk.com.tr',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
    
    -- Add RLS policies
    ALTER TABLE public.drawer_settings ENABLE ROW LEVEL SECURITY;

    -- Allow anonymous access for reading
    CREATE POLICY drawer_settings_anon_read_policy ON public.drawer_settings 
        FOR SELECT 
        USING (true);

    -- Allow authenticated users to read
    CREATE POLICY drawer_settings_authenticated_read_policy ON public.drawer_settings 
        FOR SELECT 
        USING (auth.role() = 'authenticated');

    -- Allow authenticated users to update
    CREATE POLICY drawer_settings_authenticated_insert_policy ON public.drawer_settings 
        FOR INSERT 
        WITH CHECK (auth.role() = 'authenticated');

    CREATE POLICY drawer_settings_authenticated_update_policy ON public.drawer_settings 
        FOR UPDATE 
        USING (auth.role() = 'authenticated');
  END IF;
END
$$;

-- Create the update trigger if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'update_drawer_settings_updated_at'
  ) THEN
    -- Add a trigger for updating the updated_at timestamp
    CREATE OR REPLACE FUNCTION public.update_drawer_settings_updated_at()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER update_drawer_settings_updated_at
    BEFORE UPDATE ON public.drawer_settings
    FOR EACH ROW EXECUTE FUNCTION public.update_drawer_settings_updated_at();
  END IF;
END
$$;

-- Check if there's at least one record, and insert if not
INSERT INTO public.drawer_settings (
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
)
SELECT 
    'Tatvan Kepenk',
    'Otomatik Kepenk ve Kapı Sistemleri',
    '+90 555 123 4567',
    'info@tatvankepenk.com.tr',
    'Tatvan, Bitlis, Türkiye',
    'Pazartesi - Cumartesi: 09:00-18:00',
    'https://facebook.com/tatvankepenk',
    'https://instagram.com/tatvankepenk',
    'tel:+905551234567',
    'mailto:info@tatvankepenk.com.tr'
WHERE NOT EXISTS (SELECT 1 FROM public.drawer_settings);

-- Print the current records for verification
SELECT * FROM public.drawer_settings;

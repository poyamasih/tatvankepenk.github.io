-- Create drawer_settings table
CREATE TABLE IF NOT EXISTS public.drawer_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    header_title VARCHAR NOT NULL DEFAULT 'Tatvan Kepenk',
    header_tagline VARCHAR NOT NULL DEFAULT 'Otomatik Kepenk ve Kapı Sistemleri',
    phone VARCHAR DEFAULT '+90 XXX XXX XX XX',
    email VARCHAR DEFAULT 'info@tatvankepenk.com.tr',
    address VARCHAR DEFAULT 'Tatvan, Bitlis, Türkiye',
    working_hours VARCHAR DEFAULT 'Pazartesi - Cumartesi: 09:00-18:00',
    facebook_link VARCHAR DEFAULT '',
    instagram_link VARCHAR DEFAULT '',
    phone_link VARCHAR DEFAULT '',
    email_link VARCHAR DEFAULT '',
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

-- Insert a default record if none exists
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
    '+90 XXX XXX XX XX',
    'info@tatvankepenk.com.tr',
    'Tatvan, Bitlis, Türkiye',
    'Pazartesi - Cumartesi: 09:00-18:00',
    'https://facebook.com/tatvankepenk',
    'https://instagram.com/tatvankepenk',
    'tel:+905551234567',
    'mailto:info@tatvankepenk.com.tr'
WHERE NOT EXISTS (SELECT 1 FROM public.drawer_settings);

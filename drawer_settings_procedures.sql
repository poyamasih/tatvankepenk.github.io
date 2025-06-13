-- SQL functions for drawer_settings table management

-- Function to check if a table exists
CREATE OR REPLACE FUNCTION public.check_table_exists(table_name text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
   table_exists boolean;
BEGIN
   SELECT EXISTS (
      SELECT FROM information_schema.tables 
      WHERE table_schema = 'public'
      AND table_name = $1
   ) INTO table_exists;
   
   RETURN table_exists;
END;
$$;

-- Grant execution permission to all users
ALTER FUNCTION public.check_table_exists(text) SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.check_table_exists TO PUBLIC;

-- Function to create the check_table_exists function (meta-function)
CREATE OR REPLACE FUNCTION public.create_check_table_exists_function()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
   -- Create the function if it doesn't exist, or replace it if it does
   EXECUTE $FUNC$
   CREATE OR REPLACE FUNCTION public.check_table_exists(table_name text)
   RETURNS boolean
   LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public
   AS $INNER_FUNC$
   DECLARE
      table_exists boolean;
   BEGIN
      SELECT EXISTS (
         SELECT FROM information_schema.tables 
         WHERE table_schema = 'public'
         AND table_name = $1
      ) INTO table_exists;
      
      RETURN table_exists;
   END;
   $INNER_FUNC$;

   -- Grant execution permission to all users
   ALTER FUNCTION public.check_table_exists(text) SECURITY DEFINER;
   GRANT EXECUTE ON FUNCTION public.check_table_exists TO PUBLIC;
   $FUNC$;
END;
$$;

-- Grant execution permission to all users
ALTER FUNCTION public.create_check_table_exists_function() SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.create_check_table_exists_function() TO PUBLIC;

-- Function to create the drawer_settings table
CREATE OR REPLACE FUNCTION public.create_drawer_settings_table()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
   -- Check if the table already exists
   IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'drawer_settings') THEN
      -- Create the drawer_settings table
      CREATE TABLE public.drawer_settings (
         id VARCHAR PRIMARY KEY,
         header_title VARCHAR NOT NULL DEFAULT 'Tatvan Kepenk',
         header_tagline VARCHAR NOT NULL DEFAULT 'Otomatik Kepenk ve Kapı Sistemleri',
         phone VARCHAR DEFAULT '+90 XXX XXX XX XX',
         email VARCHAR DEFAULT 'info@tatvankepenk.com.tr',
         address VARCHAR DEFAULT 'Tatvan, Bitlis, Türkiye',
         working_hours VARCHAR DEFAULT 'Pazartesi - Cumartesi: 09:00-18:00',
         facebook_link VARCHAR DEFAULT '',
         instagram_link VARCHAR DEFAULT '',
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

      -- Add a trigger for updating the updated_at timestamp
      CREATE OR REPLACE FUNCTION public.update_drawer_settings_updated_at()
      RETURNS TRIGGER AS $TRIGGER$
      BEGIN
         NEW.updated_at = NOW();
         RETURN NEW;
      END;
      $TRIGGER$ LANGUAGE plpgsql;

      CREATE TRIGGER update_drawer_settings_updated_at
      BEFORE UPDATE ON public.drawer_settings
      FOR EACH ROW EXECUTE FUNCTION public.update_drawer_settings_updated_at();

      -- Insert a default record
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
         '1',
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
      );
   END IF;
END;
$$;

-- Grant execution permission to all users
ALTER FUNCTION public.create_drawer_settings_table() SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.create_drawer_settings_table() TO PUBLIC;

-- Function to create the create_drawer_settings_table function (meta-function)
CREATE OR REPLACE FUNCTION public.create_drawer_settings_table_function()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
   -- Create the function if it doesn't exist, or replace it if it does
   EXECUTE $FUNC$
   CREATE OR REPLACE FUNCTION public.create_drawer_settings_table()
   RETURNS void
   LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public
   AS $INNER_FUNC$
   BEGIN
      -- Check if the table already exists
      IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'drawer_settings') THEN
         -- Create the drawer_settings table
         CREATE TABLE public.drawer_settings (
            id VARCHAR PRIMARY KEY,
            header_title VARCHAR NOT NULL DEFAULT 'Tatvan Kepenk',
            header_tagline VARCHAR NOT NULL DEFAULT 'Otomatik Kepenk ve Kapı Sistemleri',
            phone VARCHAR DEFAULT '+90 XXX XXX XX XX',
            email VARCHAR DEFAULT 'info@tatvankepenk.com.tr',
            address VARCHAR DEFAULT 'Tatvan, Bitlis, Türkiye',
            working_hours VARCHAR DEFAULT 'Pazartesi - Cumartesi: 09:00-18:00',
            facebook_link VARCHAR DEFAULT '',
            instagram_link VARCHAR DEFAULT '',
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

         -- Add a trigger for updating the updated_at timestamp
         CREATE OR REPLACE FUNCTION public.update_drawer_settings_updated_at()
         RETURNS TRIGGER AS $TRIGGER$
         BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
         END;
         $TRIGGER$ LANGUAGE plpgsql;

         CREATE TRIGGER update_drawer_settings_updated_at
         BEFORE UPDATE ON public.drawer_settings
         FOR EACH ROW EXECUTE FUNCTION public.update_drawer_settings_updated_at();

         -- Insert a default record
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
            '1',
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
         );
      END IF;
   END;
   $INNER_FUNC$;

   -- Grant execution permission to all users
   ALTER FUNCTION public.create_drawer_settings_table() SECURITY DEFINER;
   GRANT EXECUTE ON FUNCTION public.create_drawer_settings_table() TO PUBLIC;
   $FUNC$;
END;
$$;

-- Grant execution permission to all users
ALTER FUNCTION public.create_drawer_settings_table_function() SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.create_drawer_settings_table_function() TO PUBLIC;

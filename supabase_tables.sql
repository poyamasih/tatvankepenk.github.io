-- Create tables for Tatvan Kepenk Website

-- Table for home page content
CREATE TABLE home_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for kepenk systems content
CREATE TABLE kepenk_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for gallery items
CREATE TABLE gallery_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT,
  description TEXT,
  image_url TEXT NOT NULL,
  location TEXT,
  date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for industrial doors content
CREATE TABLE kapilar_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for about us sections
CREATE TABLE about_sections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  section_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for contact information
CREATE TABLE contact_info (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  address TEXT,
  phone TEXT,
  email TEXT,
  work_hours TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for contact form messages
CREATE TABLE contact_forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  message TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert initial empty records
INSERT INTO home_content (title, description) 
VALUES ('Tatvan Kepenk Sistemleri', 'Hoşgeldiniz, kaliteli ürünlerimizle hizmetinizdeyiz.');

INSERT INTO kepenk_content (title, description) 
VALUES ('Kepenk Sistemlerimiz', 'En iyi kalitede kepenk sistemleri.');

INSERT INTO kapilar_content (title, description) 
VALUES ('Endüstriyel Kapılar', 'Profesyonel endüstriyel kapı çözümleri.');

INSERT INTO about_sections (section_number, title, description) 
VALUES 
(1, 'Hakkımızda', 'Tatvan Kepenk olarak...'),
(2, 'Misyonumuz', 'Amacımız...'),
(3, 'Vizyonumuz', 'Hedefimiz...');

INSERT INTO contact_info (address, phone, email, work_hours) 
VALUES ('Tatvan, Bitlis', '+90 123 456 7890', 'info@tatvankepenk.com', 'Pazartesi - Cuma: 09:00 - 18:00');

-- Create Row Level Security (RLS) policies
ALTER TABLE home_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE kepenk_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE kapilar_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE about_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_forms ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read access to all tables
CREATE POLICY "Allow anonymous read access to home_content" ON home_content FOR SELECT USING (true);
CREATE POLICY "Allow anonymous read access to kepenk_content" ON kepenk_content FOR SELECT USING (true);
CREATE POLICY "Allow anonymous read access to gallery_items" ON gallery_items FOR SELECT USING (true);
CREATE POLICY "Allow anonymous read access to kapilar_content" ON kapilar_content FOR SELECT USING (true);
CREATE POLICY "Allow anonymous read access to about_sections" ON about_sections FOR SELECT USING (true);
CREATE POLICY "Allow anonymous read access to contact_info" ON contact_info FOR SELECT USING (true);

-- Allow authenticated users to perform all operations
CREATE POLICY "Allow authenticated users to manage home_content" ON home_content USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage kepenk_content" ON kepenk_content USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage gallery_items" ON gallery_items USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage kapilar_content" ON kapilar_content USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage about_sections" ON about_sections USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage contact_info" ON contact_info USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage contact_forms" ON contact_forms USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

-- Allow anonymous users to submit contact forms
CREATE POLICY "Allow anonymous submissions to contact_forms" ON contact_forms FOR INSERT WITH CHECK (true);

-- Update for contact_forms table to add phone field if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'contact_forms'
        AND column_name = 'phone'
    ) THEN
        ALTER TABLE contact_forms ADD COLUMN phone TEXT;
    END IF;
END
$$;

-- Fix any inconsistencies in field names and ensure data consistency

-- If you have existing rows in contact_forms where is_read exists but read doesn't
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'contact_forms'
        AND column_name = 'is_read'
    ) THEN
        ALTER TABLE contact_forms RENAME COLUMN is_read TO read;
    END IF;
END
$$;

-- For about_sections table, ensure we're using section_number and not section_id
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'about_sections'
        AND column_name = 'section_id'
    ) THEN
        ALTER TABLE about_sections RENAME COLUMN section_id TO section_number;
    END IF;
END
$$;

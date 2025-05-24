-- SQL script to fix inconsistency between image_path and image_url fields in the gallery_items table

-- First, check if image_url column exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'gallery_items' 
        AND column_name = 'image_url'
    ) THEN
        -- Add image_url column if it doesn't exist
        ALTER TABLE gallery_items ADD COLUMN image_url TEXT;
    END IF;
END$$;

-- Update image_url with values from image_path where image_url is null
UPDATE gallery_items 
SET image_url = image_path 
WHERE image_url IS NULL AND image_path IS NOT NULL;

-- If any rows have image_url but not image_path, update image_path
UPDATE gallery_items 
SET image_path = image_url 
WHERE image_path IS NULL AND image_url IS NOT NULL;

-- Add a trigger to keep these fields in sync for future inserts/updates
CREATE OR REPLACE FUNCTION sync_gallery_image_fields()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.image_url IS NULL AND NEW.image_path IS NOT NULL THEN
        NEW.image_url := NEW.image_path;
    ELSIF NEW.image_path IS NULL AND NEW.image_url IS NOT NULL THEN
        NEW.image_path := NEW.image_url;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Check if the trigger already exists, if not create it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'sync_gallery_image_fields_trigger'
    ) THEN
        CREATE TRIGGER sync_gallery_image_fields_trigger
        BEFORE INSERT OR UPDATE ON gallery_items
        FOR EACH ROW
        EXECUTE FUNCTION sync_gallery_image_fields();
    END IF;
END$$;

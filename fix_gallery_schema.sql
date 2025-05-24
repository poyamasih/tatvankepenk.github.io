-- Check and add both image_url and image_path columns if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'gallery_items' 
        AND column_name = 'image_url'
    ) THEN
        -- Add image_url column if it doesn't exist
        ALTER TABLE gallery_items ADD COLUMN image_url TEXT;
        RAISE NOTICE 'Added image_url column to gallery_items table';
    END IF;

    IF NOT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'gallery_items' 
        AND column_name = 'image_path'
    ) THEN
        -- Add image_path column if it doesn't exist
        ALTER TABLE gallery_items ADD COLUMN image_path TEXT;
        RAISE NOTICE 'Added image_path column to gallery_items table';
    END IF;
END$$;

-- Synchronize values between image_path and image_url
UPDATE gallery_items 
SET image_url = image_path 
WHERE image_url IS NULL AND image_path IS NOT NULL;

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
        RAISE NOTICE 'Created sync_gallery_image_fields_trigger';
    END IF;
END$$;

-- Check the final schema
DO $$
DECLARE
    image_url_exists BOOLEAN;
    image_path_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'gallery_items' 
        AND column_name = 'image_url'
    ) INTO image_url_exists;
    
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'gallery_items' 
        AND column_name = 'image_path'
    ) INTO image_path_exists;
    
    RAISE NOTICE 'Schema check - image_url exists: %, image_path exists: %', image_url_exists, image_path_exists;
END$$;

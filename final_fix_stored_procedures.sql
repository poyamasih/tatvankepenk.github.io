-- First drop existing trigger
DROP TRIGGER IF EXISTS sync_gallery_image_fields_trigger ON gallery_items;

-- Now drop existing functions
DROP FUNCTION IF EXISTS check_column_exists(text,text);
DROP FUNCTION IF EXISTS add_column_if_not_exists(text,text,text);
DROP FUNCTION IF EXISTS create_check_column_exists_function();
DROP FUNCTION IF EXISTS create_add_column_function();
DROP FUNCTION IF EXISTS sync_gallery_image_fields();

-- Function to check if a column exists - IMPORTANT: parameter names match Dart code
CREATE OR REPLACE FUNCTION check_column_exists(
  table_name TEXT,
  column_name TEXT
) RETURNS BOOLEAN AS $$
DECLARE
  column_exists BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = check_column_exists.table_name 
    AND column_name = check_column_exists.column_name
  ) INTO column_exists;
  
  RETURN column_exists;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create the check_column_exists function (meta-function)
CREATE OR REPLACE FUNCTION create_check_column_exists_function()
RETURNS VOID AS $$
BEGIN
  -- Function is already created above, this is just a wrapper for the app to call
  RAISE NOTICE 'check_column_exists function created or already exists';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to add a column if it doesn't exist - IMPORTANT: parameter names match Dart code
CREATE OR REPLACE FUNCTION add_column_if_not_exists(
  p_table_name TEXT,
  p_column_name TEXT,
  p_column_type TEXT
) RETURNS VOID AS $$
BEGIN
  -- Check if the column exists
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = p_table_name 
    AND column_name = p_column_name
  ) THEN
    -- Add the column if it doesn't exist
    EXECUTE format('ALTER TABLE %I ADD COLUMN %I %s', 
                 p_table_name, p_column_name, p_column_type);
    RAISE NOTICE 'Added column % of type % to table %', 
               p_column_name, p_column_type, p_table_name;
  ELSE
    RAISE NOTICE 'Column % already exists in table %', 
               p_column_name, p_table_name;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create the add_column_if_not_exists function (meta-function)
CREATE OR REPLACE FUNCTION create_add_column_function()
RETURNS VOID AS $$
BEGIN
  -- Function is already created above, this is just a wrapper for the app to call
  RAISE NOTICE 'add_column_if_not_exists function created or already exists';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

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

-- Create the trigger inside a DO block
DO $$
BEGIN
    -- Drop the trigger if it exists
    DROP TRIGGER IF EXISTS sync_gallery_image_fields_trigger ON gallery_items;
    
    -- Create the trigger
    CREATE TRIGGER sync_gallery_image_fields_trigger
    BEFORE INSERT OR UPDATE ON gallery_items
    FOR EACH ROW
    EXECUTE FUNCTION sync_gallery_image_fields();
    
    RAISE NOTICE 'Created sync_gallery_image_fields_trigger';
END$$;

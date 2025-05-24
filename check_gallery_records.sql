-- Script to check gallery_items records
-- This will show you all records in the gallery_items table

-- Count records in the table
SELECT COUNT(*) FROM gallery_items;

-- Show all records with basic info
SELECT id, title, location, substring(image_url, 1, 50) as image_url_preview 
FROM gallery_items
ORDER BY created_at DESC;

-- Check for records with missing image URLs (possible data inconsistency)
SELECT id, title, location
FROM gallery_items
WHERE image_url IS NULL OR image_path IS NULL OR image_url = '' OR image_path = '';

-- If you need to manually delete a record, you can use:
-- DELETE FROM gallery_items WHERE id = 'record-id-here';

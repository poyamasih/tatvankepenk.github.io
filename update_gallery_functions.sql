-- Function to directly update a gallery item
CREATE OR REPLACE FUNCTION direct_update_gallery_item(
  item_id UUID,
  new_title TEXT,
  new_description TEXT,
  new_location TEXT,
  new_image_url TEXT,
  new_image_path TEXT
) RETURNS VOID AS $$
BEGIN
  -- Use direct SQL to bypass RLS policies
  UPDATE gallery_items
  SET
    title = new_title,
    description = new_description,
    location = new_location,
    image_url = new_image_url,
    image_path = new_image_path,
    updated_at = NOW()
  WHERE id = item_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Simple function that uses ON CONFLICT DO UPDATE
CREATE OR REPLACE FUNCTION simple_update_gallery_item(
  p_id UUID,
  p_title TEXT,
  p_description TEXT,
  p_location TEXT,
  p_image_url TEXT,
  p_image_path TEXT,
  p_date TEXT
) RETURNS VOID AS $$
BEGIN
  INSERT INTO gallery_items (
    id, 
    title, 
    description, 
    location, 
    image_url, 
    image_path, 
    date,
    updated_at
  )
  VALUES (
    p_id,
    p_title,
    p_description,
    p_location,
    p_image_url,
    p_image_path,
    p_date::TIMESTAMP WITH TIME ZONE,
    NOW()
  )
  ON CONFLICT (id) DO UPDATE
  SET
    title = p_title,
    description = p_description,
    location = p_location,
    image_url = p_image_url,
    image_path = p_image_path,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to temporarily disable RLS for gallery updates
CREATE OR REPLACE FUNCTION disable_rls_for_gallery_temporarily() RETURNS VOID AS $$
BEGIN
  -- Store the current setting
  SET LOCAL row_security = off;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

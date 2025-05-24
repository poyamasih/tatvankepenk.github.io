-- Create stored procedures for schema management

-- Function to check if a column exists
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

-- Function to add a column if it doesn't exist
CREATE OR REPLACE FUNCTION add_column_if_not_exists(
  table_name TEXT,
  column_name TEXT,
  column_type TEXT
) RETURNS VOID AS $$
BEGIN
  -- Check if the column exists
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = add_column_if_not_exists.table_name 
    AND column_name = add_column_if_not_exists.column_name
  ) THEN
    -- Add the column if it doesn't exist
    EXECUTE format('ALTER TABLE %I ADD COLUMN %I %s', 
                 table_name, column_name, column_type);
    RAISE NOTICE 'Added column % of type % to table %', 
               column_name, column_type, table_name;
  ELSE
    RAISE NOTICE 'Column % already exists in table %', 
               column_name, table_name;
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

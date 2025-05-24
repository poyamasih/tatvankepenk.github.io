-- ایجاد Stored Procedure برای حذف رکورد از gallery_items
-- این تابع می‌تواند در شرایطی که RLS مانع حذف می‌شود مفید باشد

-- ابتدا اگر این تابع از قبل وجود دارد، آن را حذف می‌کنیم
DROP FUNCTION IF EXISTS delete_gallery_item(uuid);

-- ایجاد تابع جدید
CREATE OR REPLACE FUNCTION delete_gallery_item(item_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER -- این باعث می‌شود تابع با دسترسی مالک آن اجرا شود
AS $$
BEGIN
  DELETE FROM gallery_items WHERE id = item_id;
  RETURN FOUND; -- FOUND برمی‌گردد اگر حداقل یک ردیف حذف شده باشد
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error deleting gallery item: %', SQLERRM;
    RETURN FALSE;
END;
$$;

-- تست تابع با شناسه نمونه (شناسه خود را جایگزین کنید)
-- SELECT delete_gallery_item('00000000-0000-0000-0000-000000000000');

-- دادن دسترسی به کاربران احراز هویت شده برای اجرای این تابع
GRANT EXECUTE ON FUNCTION delete_gallery_item TO authenticated;

-- همچنین می‌توان یک تابع برای حذف تصویر از استوریج ایجاد کرد:
CREATE OR REPLACE FUNCTION delete_storage_file(bucket_name text, file_path text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result boolean;
BEGIN
  -- این بخش فقط نمونه است و در واقعیت با فراخوانی API استوریج سوپابیس کار نمی‌کند
  -- برای پیاده‌سازی واقعی باید از سمت کلاینت (اپلیکیشن فلاتر) اقدام کرد
  RAISE NOTICE 'Would delete file % from bucket %', file_path, bucket_name;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error deleting storage file: %', SQLERRM;
    RETURN FALSE;
END;
$$;

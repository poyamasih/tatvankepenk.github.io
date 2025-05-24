-- اسکریپت برای شناسایی رکوردها و فایل‌های جدول gallery_items

-- 1. بررسی تعداد کل رکوردها
SELECT COUNT(*) AS total_records FROM gallery_items;

-- 2. نمایش همه رکوردهای موجود با جزئیات
SELECT 
  id, 
  title, 
  description,
  location,
  substring(image_url, 1, 50) as image_url_preview,
  substring(image_path, 1, 50) as image_path_preview,
  created_at,
  updated_at
FROM gallery_items
ORDER BY created_at DESC;

-- 3. شناسایی رکوردهای با مشکل (فاقد تصویر)
SELECT 
  id, 
  title
FROM gallery_items
WHERE 
  image_url IS NULL OR 
  image_url = '' OR 
  image_path IS NULL OR 
  image_path = '';

-- 4. حذف دستی یک رکورد با شناسه مشخص
-- در خط زیر ID رکورد مورد نظر را جایگزین کنید
-- DELETE FROM gallery_items WHERE id = 'ID_RECORD';

-- 5. حذف دستی همه رکوردهای مشکل‌دار (بدون تصویر)
-- DELETE FROM gallery_items 
-- WHERE image_url IS NULL OR image_url = '' OR image_path IS NULL OR image_path = '';

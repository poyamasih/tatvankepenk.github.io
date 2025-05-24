-- گام 1: بررسی وضعیت فعلی RLS
SELECT relname, relrowsecurity 
FROM pg_class 
WHERE relname = 'gallery_items';

-- گام 2: غیرفعال کردن موقت RLS برای تست
ALTER TABLE gallery_items DISABLE ROW LEVEL SECURITY;

-- گام 3: حذف سیاست‌های موجود
DROP POLICY IF EXISTS "Allow delete for authenticated" ON gallery_items;
DROP POLICY IF EXISTS "Allow insert for authenticated" ON gallery_items;
DROP POLICY IF EXISTS "Allow select for authenticated" ON gallery_items;
DROP POLICY IF EXISTS "Allow update for authenticated" ON gallery_items;
DROP POLICY IF EXISTS "Allow select for all" ON gallery_items;

-- گام 4: ایجاد سیاست‌های جدید
-- سیاست برای SELECT - به همه کاربران اجازه می‌دهد عکس‌ها را ببینند (عمومی)
CREATE POLICY "Allow select for all" 
ON gallery_items 
FOR SELECT 
USING (true);

-- سیاست برای INSERT - فقط کاربران احراز هویت شده می‌توانند عکس اضافه کنند
CREATE POLICY "Allow insert for authenticated" 
ON gallery_items 
FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);

-- سیاست برای UPDATE - فقط کاربران احراز هویت شده می‌توانند عکس‌ها را ویرایش کنند
CREATE POLICY "Allow update for authenticated" 
ON gallery_items 
FOR UPDATE 
USING (auth.uid() IS NOT NULL);

-- سیاست برای DELETE - فقط کاربران احراز هویت شده می‌توانند عکس‌ها را حذف کنند
CREATE POLICY "Allow delete for authenticated" 
ON gallery_items 
FOR DELETE 
USING (auth.uid() IS NOT NULL);

-- گام 5: فعال‌سازی مجدد RLS
ALTER TABLE gallery_items ENABLE ROW LEVEL SECURITY;

-- گام 6: تست حذف یک رکورد خاص (اگر نیاز دارید)
-- برای اجرای این دستور، آیدی رکوردی که می‌خواهید حذف شود را جایگزین کنید
-- DELETE FROM gallery_items WHERE id = 'ID_RECORD_HERE';

-- گام 7: بررسی وضعیت رکوردهای جدول
SELECT COUNT(*) FROM gallery_items;

-- گام 8: بررسی رکوردهای موجود
SELECT id, title, 
       substring(image_url, 1, 50) as image_url_preview,
       substring(image_path, 1, 50) as image_path_preview
FROM gallery_items
ORDER BY created_at DESC;

-- گام 9: برای حذف تمامی رکوردهای جدول (فقط در موارد ضروری و آزمایشی)
-- TRUNCATE TABLE gallery_items;

-- گام 10: بررسی و پاک‌سازی فایل‌های بی‌استفاده در استوریج
-- این باید در یک فرآیند جداگانه انجام شود یا با استفاده از Storage Management API سوپابیس

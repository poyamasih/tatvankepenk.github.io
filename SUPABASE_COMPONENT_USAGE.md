# Supabase Component Usage Guide

This document explains how to use the Supabase-powered components in the Tatvan Kepenk project.

## Available Components

### 1. SupabaseContentSection

`SupabaseContentSection` is a widget that displays content from Supabase database. It can show either a static image or a gallery of images.

#### Usage

```dart
const SupabaseContentSection(
  title: 'Title to display if Supabase data not available',
  description: 'Description to display if Supabase data not available',
  imagePath: 'assets/images/fallback_image.png',
  buttonText: 'Button Text',
  onButtonPressed: myFunction,
  contentType: 'kepenk', // or 'kapilar', determines which content to load
  isActive: true,
  animationDelay: 200,
  showGallery: true, // Set to true to show gallery instead of image
),
```

#### Properties

- `title`: Fallback title if Supabase content is unavailable
- `description`: Fallback description if Supabase content is unavailable  
- `imagePath`: Path to fallback image if Supabase content is unavailable
- `buttonText`: Text to display on the button
- `onButtonPressed`: Callback function when button is pressed
- `isActive`: Whether the section should be active (animated)
- `animationDelay`: Delay for animations in milliseconds
- `contentType`: Type of content to load from Supabase ('kepenk' or 'kapilar')
- `showGallery`: Whether to show the gallery component instead of a single image

### 2. SupabaseProjectGallery

`SupabaseProjectGallery` is a widget that displays gallery items from Supabase.

#### Usage

```dart
const SupabaseProjectGallery()
```

This component will automatically fetch gallery items from Supabase and display them in a carousel.

## Initializing Services

Before using these components, ensure the Supabase services are properly initialized:

```dart
Future<void> _initializeServices() async {
  try {
    // Check if services are already registered with Get
    if (!Get.isRegistered<SupabaseService>()) {
      final supabaseService = SupabaseService();
      await supabaseService.initialize();
      Get.put(supabaseService);
    }
    
    if (!Get.isRegistered<SupabaseContentService>()) {
      final sharedPrefs = await SharedPreferences.getInstance();
      final supabaseContentService = SupabaseContentService(
        Get.find<SupabaseService>(), 
        sharedPrefs
      );
      Get.put(supabaseContentService);
    }
  } catch (e) {
    debugPrint('Error initializing Supabase services: $e');
  }
}
```

## Content Management

Content for these components is managed through the Supabase admin panel or the app's built-in admin interface.

### Gallery Items

Gallery items are stored in the `gallery_items` table with the following fields:

- `title`: Title of the gallery item
- `description`: Description of the gallery item
- `image_url`: URL to the image in Supabase storage
- `location`: Location information (optional)
- `date`: Date information (optional)

### Section Content

Section content is stored in separate tables:
- `kepenk_content` for kepenk systems content
- `kapilar_content` for industrial doors content

Each table has:
- `title`: Section title
- `description`: Section description

## Error Handling

Both `SupabaseContentSection` and `SupabaseProjectGallery` have built-in error handling and will display fallback content if there are issues loading data from Supabase.

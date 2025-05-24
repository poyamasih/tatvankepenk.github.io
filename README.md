# Tatvan Kepenk Website

Official website for Tatvan Kepenk, a leading provider of automatic shutter systems and industrial door solutions across Eastern Anatolia, Turkey. Built with Flutter Web and Supabase backend integration.

## Features

- Responsive design for all device sizes
- Dynamic content management via Supabase backend
- Gallery showcase with images loaded from Supabase storage
- Admin panel for content management
- Contact form with email notifications

## Supabase Integration

This project uses Supabase as the backend service for:

1. **Content Storage**: All website content is stored in Supabase tables
2. **Image Management**: Gallery images are stored in Supabase Storage
3. **Contact Form**: Form submissions are saved to Supabase database

### Supabase Components

- **SupabaseService**: Core service for direct Supabase API communication
- **SupabaseContentService**: Manages caching and synchronization with Supabase
- **SupabaseProjectGallery**: Widget that displays gallery items from Supabase
- **SupabaseContentSection**: Dynamic content sections powered by Supabase

## Getting Started

1. Clone this repository
2. Set up Supabase project (see `SUPABASE_SETUP_GUIDE.md`)
3. Update `supabase_config.dart` with your Supabase URL and anon key
4. Run the SQL setup script from `supabase_tables.sql`
5. Run the app:
   ```
   flutter run -d chrome
   ```

## Architecture

The project follows a service-oriented architecture:

- **Services**: Handle data operations and external API calls
- **Widgets**: Reusable UI components
- **Pages**: Screen layouts composed of widgets

## Documentation

Detailed documentation is available in the following files:

- `SUPABASE_IMPLEMENTATION_GUIDE.md`: Comprehensive guide to the Supabase implementation

## Deployment

The website is automatically deployed to GitHub Pages when changes are pushed to the main branch.

Website: [tatvankepenk.com.tr](https://tatvankepenk.com.tr)

### Custom Domain Setup

The website uses a custom domain (tatvankepenk.com.tr) with the following name servers:
- cpns1.turhost.com
- cpns2.turhost.com

DNS A records point to GitHub Pages servers.
- `SUPABASE_SETUP_GUIDE.md`: Step-by-step setup instructions
- `SUPABASE_TEST_PLAN.md`: Testing guidelines
- `SUPABASE_TESTING.md`: Testing results and fixed issues

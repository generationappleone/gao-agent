---
name: WordPress
description: Skill for WordPress development, covering theme development, plugin creation, custom post types, REST API, WooCommerce, security hardening, and performance optimization.
---

# WordPress Skill

## Overview
WordPress powers ~43% of the web. This skill covers modern theme and plugin development, custom post types, REST API, Gutenberg blocks, WooCommerce, and security best practices.

## Project Structure

### Theme
```
wp-content/themes/mytheme/
├── style.css              # Theme metadata (required)
├── functions.php           # Theme setup, hooks, enqueues
├── index.php               # Fallback template
├── front-page.php          # Homepage
├── header.php              # Header template
├── footer.php              # Footer template
├── page.php                # Generic page
├── single.php              # Single post
├── archive.php             # Archive/listing
├── search.php              # Search results
├── 404.php                 # Not found
├── template-parts/         # Reusable partials
│   ├── content-post.php
│   └── content-page.php
├── inc/
│   ├── custom-post-types.php
│   ├── customizer.php
│   └── widgets.php
├── assets/
│   ├── css/
│   ├── js/
│   └── images/
└── screenshot.png          # Theme preview (1200x900)
```

### Plugin
```
wp-content/plugins/my-plugin/
├── my-plugin.php           # Main plugin file (metadata)
├── includes/
│   ├── class-plugin-core.php
│   ├── class-admin.php
│   ├── class-frontend.php
│   └── class-api.php
├── admin/
│   ├── views/
│   └── css/
├── public/
│   ├── views/
│   └── css/
├── languages/
│   └── my-plugin.pot
├── templates/
└── uninstall.php
```

## Theme Development

### style.css (Required Header)
```css
/*
Theme Name:     My Theme
Theme URI:      https://example.com/mytheme
Author:         My Company
Author URI:     https://example.com
Description:    A modern, responsive WordPress theme.
Version:        1.0.0
Requires at least: 6.0
Tested up to:   6.7
Requires PHP:   8.1
License:        GPL-2.0-or-later
Text Domain:    mytheme
*/
```

### functions.php
```php
<?php
defined('ABSPATH') || exit;

// Theme setup
add_action('after_setup_theme', function () {
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support('html5', ['search-form', 'comment-form', 'gallery', 'caption']);
    add_theme_support('responsive-embeds');
    add_theme_support('wp-block-styles');
    add_theme_support('custom-logo', [
        'height' => 100,
        'width'  => 400,
        'flex-height' => true,
        'flex-width'  => true,
    ]);

    register_nav_menus([
        'primary'  => __('Primary Menu', 'mytheme'),
        'footer'   => __('Footer Menu', 'mytheme'),
    ]);
});

// Enqueue assets
add_action('wp_enqueue_scripts', function () {
    $version = wp_get_theme()->get('Version');

    wp_enqueue_style('mytheme-style', get_stylesheet_uri(), [], $version);
    wp_enqueue_style('mytheme-main', get_template_directory_uri() . '/assets/css/main.css', [], $version);

    wp_enqueue_script('mytheme-app', get_template_directory_uri() . '/assets/js/app.js', [], $version, true);

    // Localize script (pass PHP data to JS)
    wp_localize_script('mytheme-app', 'myTheme', [
        'ajaxUrl' => admin_url('admin-ajax.php'),
        'nonce'   => wp_create_nonce('mytheme_nonce'),
        'restUrl' => rest_url('mytheme/v1/'),
    ]);
});

// Include custom post types
require_once get_template_directory() . '/inc/custom-post-types.php';
```

## Custom Post Type
```php
<?php
// inc/custom-post-types.php
add_action('init', function () {
    register_post_type('portfolio', [
        'labels' => [
            'name'          => __('Portfolio', 'mytheme'),
            'singular_name' => __('Project', 'mytheme'),
            'add_new_item'  => __('Add New Project', 'mytheme'),
        ],
        'public'       => true,
        'has_archive'  => true,
        'rewrite'      => ['slug' => 'portfolio'],
        'menu_icon'    => 'dashicons-portfolio',
        'supports'     => ['title', 'editor', 'thumbnail', 'excerpt', 'custom-fields'],
        'show_in_rest' => true, // Enable Gutenberg & REST API
        'taxonomies'   => ['portfolio_category'],
    ]);

    register_taxonomy('portfolio_category', 'portfolio', [
        'labels' => ['name' => __('Categories', 'mytheme')],
        'hierarchical' => true,
        'show_in_rest' => true,
        'rewrite'      => ['slug' => 'portfolio-category'],
    ]);
});
```

## Plugin Development
```php
<?php
/**
 * Plugin Name: My Plugin
 * Description: A custom plugin with best practices.
 * Version:     1.0.0
 * Author:      My Company
 * Requires PHP: 8.1
 * Text Domain: my-plugin
 */

defined('ABSPATH') || exit;

define('MY_PLUGIN_PATH', plugin_dir_path(__FILE__));
define('MY_PLUGIN_URL', plugin_dir_url(__FILE__));

class MyPlugin
{
    private static ?self $instance = null;

    public static function getInstance(): self
    {
        return self::$instance ??= new self();
    }

    private function __construct()
    {
        // Admin hooks
        add_action('admin_menu', [$this, 'addAdminMenu']);
        add_action('admin_init', [$this, 'registerSettings']);

        // Frontend hooks
        add_action('wp_enqueue_scripts', [$this, 'enqueueAssets']);

        // AJAX handlers
        add_action('wp_ajax_my_plugin_action', [$this, 'handleAjax']);
        add_action('wp_ajax_nopriv_my_plugin_action', [$this, 'handleAjax']);

        // REST API
        add_action('rest_api_init', [$this, 'registerRoutes']);

        // Shortcode
        add_shortcode('my_shortcode', [$this, 'renderShortcode']);
    }

    public function addAdminMenu(): void
    {
        add_menu_page(
            __('My Plugin', 'my-plugin'),
            __('My Plugin', 'my-plugin'),
            'manage_options',
            'my-plugin',
            [$this, 'renderAdminPage'],
            'dashicons-admin-generic',
            30
        );
    }

    public function handleAjax(): void
    {
        check_ajax_referer('my_plugin_nonce', 'nonce');

        if (!current_user_can('edit_posts')) {
            wp_send_json_error(['message' => 'Unauthorized'], 403);
        }

        $data = sanitize_text_field($_POST['data'] ?? '');
        // Process data...

        wp_send_json_success(['result' => $data]);
    }

    public function registerRoutes(): void
    {
        register_rest_route('my-plugin/v1', '/items', [
            'methods'             => 'GET',
            'callback'            => [$this, 'getItems'],
            'permission_callback' => function () { return current_user_can('edit_posts'); },
        ]);
    }
}

MyPlugin::getInstance();
```

## Security Best Practices
```php
<?php
// ✅ ALWAYS: Sanitize input
$title = sanitize_text_field($_POST['title']);
$email = sanitize_email($_POST['email']);
$html  = wp_kses_post($_POST['content']);   // Allow safe HTML
$url   = esc_url($_POST['url']);

// ✅ ALWAYS: Escape output
echo esc_html($title);                     // In HTML context
echo esc_attr($value);                     // In HTML attributes
echo esc_url($link);                       // In URLs
echo wp_kses_post($content);              // Rich content

// ✅ ALWAYS: Verify nonces (CSRF protection)
wp_verify_nonce($_POST['_wpnonce'], 'my_action');
check_ajax_referer('my_nonce', 'nonce');

// ✅ ALWAYS: Check capabilities
if (!current_user_can('manage_options')) wp_die('Unauthorized');

// ✅ ALWAYS: Use prepared statements
global $wpdb;
$results = $wpdb->get_results(
    $wpdb->prepare("SELECT * FROM {$wpdb->posts} WHERE post_author = %d AND post_status = %s", $userId, 'publish')
);
```

## WP-CLI (Command Line)
```bash
wp core download                    # Download WordPress
wp core install --url=mysite.test --title="My Site" --admin_user=admin
wp plugin install woocommerce --activate
wp theme activate mytheme
wp post list --post_type=page
wp cache flush
wp db export backup.sql
wp search-replace 'old.com' 'new.com' --dry-run
```

## Rules Integration
- **Security**: Nonces, sanitization, escaping, capability checks, prepared queries
- **SEO**: Title tags, meta descriptions, semantic HTML, breadcrumbs, sitemap
- **PHP**: Follow PHP 8.1+ patterns in theme/plugin code
- **Database**: Use `$wpdb->prepare()` exclusively — never raw SQL

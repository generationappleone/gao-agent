---
name: WordPress
description: Skill for WordPress development, covering theme development, plugin creation, custom post types, REST API, WooCommerce, security hardening, and performance optimization.
---

# WordPress Skill

## Overview
WordPress is the world's most popular CMS powering 40%+ of all websites. It supports theme development, plugin creation, custom post types, REST API, WooCommerce (e-commerce), and Gutenberg blocks. WordPress uses PHP with MySQL/MariaDB.

**References**:
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [REST API Handbook](https://developer.wordpress.org/rest-api/)

---

## Custom Post Type

```php
// functions.php or plugin file
function register_product_post_type() {
    register_post_type('product', [
        'labels' => [
            'name' => 'Products', 'singular_name' => 'Product',
            'add_new_item' => 'Add New Product', 'edit_item' => 'Edit Product',
        ],
        'public' => true, 'has_archive' => true, 'show_in_rest' => true,
        'menu_icon' => 'dashicons-cart', 'menu_position' => 5,
        'supports' => ['title', 'editor', 'thumbnail', 'excerpt', 'custom-fields'],
        'rewrite' => ['slug' => 'products'],
    ]);

    register_taxonomy('product_category', 'product', [
        'labels' => ['name' => 'Product Categories'],
        'hierarchical' => true, 'show_in_rest' => true,
        'rewrite' => ['slug' => 'product-category'],
    ]);
}
add_action('init', 'register_product_post_type');
```

---

## Custom REST API Endpoint

```php
add_action('rest_api_init', function () {
    register_rest_route('myapp/v1', '/products', [
        'methods' => 'GET',
        'callback' => function (WP_REST_Request $request) {
            $args = [
                'post_type' => 'product', 'posts_per_page' => 20, 'post_status' => 'publish',
                'paged' => $request->get_param('page') ?: 1,
            ];
            if ($search = $request->get_param('search')) $args['s'] = $search;

            $query = new WP_Query($args);
            $products = array_map(function ($post) {
                return [
                    'id' => $post->ID, 'title' => $post->post_title,
                    'slug' => $post->post_slug, 'excerpt' => $post->post_excerpt,
                    'price' => get_post_meta($post->ID, '_price', true),
                    'image' => get_the_post_thumbnail_url($post->ID, 'medium'),
                ];
            }, $query->posts);

            return new WP_REST_Response(['data' => $products, 'total' => $query->found_posts], 200);
        },
        'permission_callback' => '__return_true',
    ]);
});
```

---

## Security Hardening

```php
// wp-config.php
define('DISALLOW_FILE_EDIT', true);
define('FORCE_SSL_ADMIN', true);
define('WP_AUTO_UPDATE_CORE', 'minor');

// .htaccess rules
// Block xmlrpc.php, wp-config.php access
// Disable directory browsing
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **CPT** | Custom Post Types for structured content |
| **Taxonomies** | Custom taxonomies for categorization |
| **REST API** | Register custom endpoints for headless |
| **Gutenberg** | Custom blocks for content editing |
| **Hooks** | Actions and filters for extensibility |
| **Security** | DISALLOW_FILE_EDIT, nonces, sanitization |
| **Performance** | Object caching, CDN, image optimization |
| **Child themes** | Extend themes without modifying parent |
| **WooCommerce** | E-commerce with hooks and extensions |
| **ACF** | Advanced Custom Fields for meta data |

---

## Rules Integration
- **CPT**: Custom post types with show_in_rest
- **REST API**: Custom endpoints for headless CMS
- **Security**: File editing disabled, SSL enforced
- **Hooks**: Actions/filters for extensibility

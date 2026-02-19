---
name: Drupal
description: Skill for Drupal CMS development, covering custom module creation, hooks, routing, forms, entity API, theming with Twig, and content modeling.
---

# Drupal Skill

## Overview
Drupal is an enterprise CMS framework for complex content architectures. This skill covers Drupal 10/11 custom module development, entity API, Form API, routing, and Twig theming.

## Module Structure
```
modules/custom/my_module/
├── my_module.info.yml         # Module metadata
├── my_module.module           # Hooks implementation
├── my_module.routing.yml      # Route definitions
├── my_module.services.yml     # Service container
├── my_module.permissions.yml  # Custom permissions
├── my_module.links.menu.yml   # Menu links
├── my_module.install          # Install/update hooks
├── config/
│   └── install/               # Default configuration
├── src/
│   ├── Controller/
│   │   └── MyController.php
│   ├── Form/
│   │   └── SettingsForm.php
│   ├── Plugin/
│   │   └── Block/
│   │       └── MyBlock.php
│   └── Service/
│       └── MyService.php
└── templates/
    └── my-template.html.twig
```

## Module Info
```yaml
# my_module.info.yml
name: 'My Module'
type: module
description: 'Custom module for site functionality'
core_version_requirement: ^10 || ^11
package: Custom
dependencies:
  - drupal:node
  - drupal:user
```

## Routing
```yaml
# my_module.routing.yml
my_module.dashboard:
  path: '/my-module/dashboard'
  defaults:
    _controller: '\Drupal\my_module\Controller\MyController::dashboard'
    _title: 'Dashboard'
  requirements:
    _permission: 'access my_module'

my_module.api.items:
  path: '/api/my-module/items'
  defaults:
    _controller: '\Drupal\my_module\Controller\ApiController::getItems'
  requirements:
    _permission: 'access content'
  methods: [GET]
  options:
    _format: json
```

## Controller
```php
<?php
// src/Controller/MyController.php
namespace Drupal\my_module\Controller;

use Drupal\Core\Controller\ControllerBase;
use Drupal\my_module\Service\MyService;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;

class MyController extends ControllerBase
{
    public function __construct(
        private readonly MyService $myService,
    ) {}

    public static function create(ContainerInterface $container): static
    {
        return new static(
            $container->get('my_module.my_service'),
        );
    }

    public function dashboard(): array
    {
        $items = $this->myService->getRecentItems(10);

        return [
            '#theme' => 'my_template',
            '#items' => $items,
            '#cache' => ['max-age' => 3600],
        ];
    }
}
```

## Service
```php
<?php
// src/Service/MyService.php
namespace Drupal\my_module\Service;

use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Core\Session\AccountProxyInterface;

class MyService
{
    public function __construct(
        private readonly EntityTypeManagerInterface $entityTypeManager,
        private readonly AccountProxyInterface $currentUser,
    ) {}

    public function getRecentItems(int $limit = 10): array
    {
        $storage = $this->entityTypeManager->getStorage('node');
        $query = $storage->getQuery()
            ->condition('type', 'article')
            ->condition('status', 1)
            ->sort('created', 'DESC')
            ->range(0, $limit)
            ->accessCheck(TRUE);

        $nids = $query->execute();
        return $storage->loadMultiple($nids);
    }
}
```

```yaml
# my_module.services.yml
services:
  my_module.my_service:
    class: Drupal\my_module\Service\MyService
    arguments:
      - '@entity_type.manager'
      - '@current_user'
```

## Form API
```php
<?php
// src/Form/SettingsForm.php
namespace Drupal\my_module\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;

class SettingsForm extends ConfigFormBase
{
    protected function getEditableConfigNames(): array
    {
        return ['my_module.settings'];
    }

    public function getFormId(): string
    {
        return 'my_module_settings';
    }

    public function buildForm(array $form, FormStateInterface $form_state): array
    {
        $config = $this->config('my_module.settings');

        $form['api_key'] = [
            '#type' => 'textfield',
            '#title' => $this->t('API Key'),
            '#default_value' => $config->get('api_key'),
            '#required' => TRUE,
        ];

        $form['max_items'] = [
            '#type' => 'number',
            '#title' => $this->t('Max Items'),
            '#default_value' => $config->get('max_items') ?? 10,
            '#min' => 1,
            '#max' => 100,
        ];

        return parent::buildForm($form, $form_state);
    }

    public function submitForm(array &$form, FormStateInterface $form_state): void
    {
        $this->config('my_module.settings')
            ->set('api_key', $form_state->getValue('api_key'))
            ->set('max_items', $form_state->getValue('max_items'))
            ->save();

        parent::submitForm($form, $form_state);
    }
}
```

## Custom Block Plugin
```php
<?php
// src/Plugin/Block/MyBlock.php
namespace Drupal\my_module\Plugin\Block;

use Drupal\Core\Block\BlockBase;
use Drupal\Core\Plugin\ContainerFactoryPluginInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;

/**
 * Provides a 'My Block' block.
 *
 * @Block(
 *   id = "my_module_my_block",
 *   admin_label = @Translation("My Custom Block"),
 *   category = @Translation("Custom"),
 * )
 */
class MyBlock extends BlockBase implements ContainerFactoryPluginInterface
{
    public static function create(ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition): static
    {
        return new static($configuration, $plugin_id, $plugin_definition);
    }

    public function build(): array
    {
        return [
            '#markup' => $this->t('Hello from My Block!'),
            '#cache' => ['max-age' => 3600],
        ];
    }
}
```

## Twig Template
```twig
{# templates/my-template.html.twig #}
<div class="my-module-dashboard">
  <h2>{{ 'Recent Items'|t }}</h2>

  {% if items %}
    <div class="items-grid">
      {% for item in items %}
        <article class="item-card">
          <h3>{{ item.label }}</h3>
          <p>{{ item.get('body').value|striptags|slice(0, 150) }}...</p>
          <a href="{{ path('entity.node.canonical', {'node': item.id}) }}" class="btn">
            {{ 'Read More'|t }}
          </a>
        </article>
      {% endfor %}
    </div>
  {% else %}
    <p>{{ 'No items found.'|t }}</p>
  {% endif %}
</div>
```

## Hooks
```php
<?php
// my_module.module

use Drupal\Core\Entity\EntityInterface;

/**
 * Implements hook_theme().
 */
function my_module_theme(): array
{
    return [
        'my_template' => [
            'variables' => ['items' => []],
            'template' => 'my-template',
        ],
    ];
}

/**
 * Implements hook_entity_presave().
 */
function my_module_entity_presave(EntityInterface $entity): void
{
    if ($entity->getEntityTypeId() === 'node' && $entity->bundle() === 'article') {
        // Auto-generate slug from title
        if (empty($entity->get('field_slug')->value)) {
            $entity->set('field_slug', \Drupal::service('pathauto.alias_cleaner')->cleanString($entity->label()));
        }
    }
}
```

## Drush (CLI)
```bash
drush cr                           # Clear cache (rebuild)
drush en my_module                 # Enable module
drush pm:uninstall my_module       # Uninstall module
drush cex                          # Export configuration
drush cim                          # Import configuration
drush updb                         # Run database updates
drush uli                          # Generate admin login link
drush sql:dump > backup.sql        # Database dump
drush watchdog:show                # View logs
```

## Rules Integration
- **SOLID**: DI container, service-based architecture, plugin system (OCP)
- **Security**: Entity access checks, Form API CSRF protection, render API auto-escaping
- **SEO**: Pathauto for clean URLs, Metatag module, structured data

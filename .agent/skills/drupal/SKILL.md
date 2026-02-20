---
name: Drupal
description: Skill for Drupal CMS development, covering custom module creation, hooks, routing, forms, entity API, theming with Twig, and content modeling.
---

# Drupal Skill

## Overview
Drupal is an enterprise-grade PHP CMS with powerful content modeling. Development uses a modular architecture with hooks, routing (YAML), services (DI container), plugins, forms (Form API), entities, and Twig theming. Drupal 10+ requires PHP 8.1+ and follows Symfony conventions.

**References**:
- [Drupal Developer Docs](https://www.drupal.org/docs/develop)
- [Drupal API Reference](https://api.drupal.org/)
- [Drupal Coding Standards](https://www.drupal.org/docs/develop/standards)

---

## Module Structure

```
modules/custom/my_module/
├── my_module.info.yml           # Module definition
├── my_module.module             # Hook implementations
├── my_module.routing.yml        # URL routes
├── my_module.services.yml       # Service definitions (DI)
├── my_module.permissions.yml    # Custom permissions
├── my_module.links.menu.yml     # Menu links
├── my_module.install            # Install/update hooks
├── config/
│   └── install/                 # Default config
│       └── my_module.settings.yml
├── src/
│   ├── Controller/
│   │   └── MyModuleController.php
│   ├── Form/
│   │   └── SettingsForm.php
│   ├── Plugin/
│   │   └── Block/
│   │       └── CustomBlock.php
│   └── Service/
│       └── MyModuleService.php
├── templates/
│   └── my-custom-block.html.twig
└── tests/
    └── src/
        └── Functional/
            └── MyModuleTest.php
```

---

## Module Declaration

```yaml
# my_module.info.yml
name: 'My Custom Module'
type: module
description: 'Custom functionality for MyApp'
package: Custom
core_version_requirement: ^10 || ^11
php: 8.1
dependencies:
  - drupal:node
  - drupal:views
configure: my_module.settings
```

---

## Routing

```yaml
# my_module.routing.yml
my_module.dashboard:
  path: '/my-module/dashboard'
  defaults:
    _controller: '\Drupal\my_module\Controller\MyModuleController::dashboard'
    _title: 'Module Dashboard'
  requirements:
    _permission: 'access my module'

my_module.api_list:
  path: '/api/my-module/items'
  defaults:
    _controller: '\Drupal\my_module\Controller\MyModuleController::apiList'
  requirements:
    _permission: 'access content'
  options:
    _format: json
    no_cache: TRUE

my_module.settings:
  path: '/admin/config/my-module/settings'
  defaults:
    _form: '\Drupal\my_module\Form\SettingsForm'
    _title: 'My Module Settings'
  requirements:
    _permission: 'administer my module'
```

---

## Controller

```php
<?php
// src/Controller/MyModuleController.php
namespace Drupal\my_module\Controller;

use Drupal\Core\Controller\ControllerBase;
use Drupal\my_module\Service\MyModuleService;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;

class MyModuleController extends ControllerBase
{
    public function __construct(
        protected MyModuleService $myModuleService,
    ) {}

    public static function create(ContainerInterface $container): static
    {
        return new static(
            $container->get('my_module.service'),
        );
    }

    public function dashboard(): array
    {
        $items = $this->myModuleService->getRecentItems(10);

        return [
            '#theme' => 'my_custom_block',
            '#items' => $items,
            '#cache' => [
                'max-age' => 3600,
                'tags' => ['node_list'],
            ],
        ];
    }

    public function apiList(): JsonResponse
    {
        $items = $this->myModuleService->getRecentItems(50);

        return new JsonResponse([
            'data' => $items,
            'count' => count($items),
        ]);
    }
}
```

---

## Services (DI)

```yaml
# my_module.services.yml
services:
  my_module.service:
    class: Drupal\my_module\Service\MyModuleService
    arguments:
      - '@entity_type.manager'
      - '@database'
      - '@logger.factory'
```

```php
<?php
// src/Service/MyModuleService.php
namespace Drupal\my_module\Service;

use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Core\Database\Connection;
use Drupal\Core\Logger\LoggerChannelFactoryInterface;

class MyModuleService
{
    public function __construct(
        protected EntityTypeManagerInterface $entityTypeManager,
        protected Connection $database,
        protected LoggerChannelFactoryInterface $loggerFactory,
    ) {}

    public function getRecentItems(int $limit = 10): array
    {
        $storage = $this->entityTypeManager->getStorage('node');
        $query = $storage->getQuery()
            ->accessCheck(TRUE)
            ->condition('type', 'article')
            ->condition('status', 1)
            ->sort('created', 'DESC')
            ->range(0, $limit);

        $nids = $query->execute();
        $nodes = $storage->loadMultiple($nids);

        return array_map(fn($node) => [
            'id'      => $node->id(),
            'title'   => $node->getTitle(),
            'created' => $node->getCreatedTime(),
            'url'     => $node->toUrl()->toString(),
        ], $nodes);
    }
}
```

---

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
        return 'my_module_settings_form';
    }

    public function buildForm(array $form, FormStateInterface $form_state): array
    {
        $config = $this->config('my_module.settings');

        $form['api_key'] = [
            '#type'          => 'textfield',
            '#title'         => $this->t('API Key'),
            '#default_value' => $config->get('api_key'),
            '#required'      => TRUE,
        ];

        $form['items_per_page'] = [
            '#type'          => 'number',
            '#title'         => $this->t('Items per page'),
            '#default_value' => $config->get('items_per_page') ?? 10,
            '#min'           => 1,
            '#max'           => 100,
        ];

        $form['enable_cache'] = [
            '#type'          => 'checkbox',
            '#title'         => $this->t('Enable caching'),
            '#default_value' => $config->get('enable_cache') ?? TRUE,
        ];

        return parent::buildForm($form, $form_state);
    }

    public function validateForm(array &$form, FormStateInterface $form_state): void
    {
        $apiKey = $form_state->getValue('api_key');
        if (strlen($apiKey) < 10) {
            $form_state->setErrorByName('api_key', $this->t('API Key must be at least 10 characters.'));
        }
    }

    public function submitForm(array &$form, FormStateInterface $form_state): void
    {
        $this->config('my_module.settings')
            ->set('api_key', $form_state->getValue('api_key'))
            ->set('items_per_page', $form_state->getValue('items_per_page'))
            ->set('enable_cache', $form_state->getValue('enable_cache'))
            ->save();

        parent::submitForm($form, $form_state);
    }
}
```

---

## Custom Block Plugin

```php
<?php
// src/Plugin/Block/CustomBlock.php
namespace Drupal\my_module\Plugin\Block;

use Drupal\Core\Block\BlockBase;
use Drupal\Core\Block\Attribute\Block;
use Drupal\Core\StringTranslation\TranslatableMarkup;

#[Block(
    id: 'my_module_custom_block',
    admin_label: new TranslatableMarkup('My Custom Block'),
    category: new TranslatableMarkup('Custom'),
)]
class CustomBlock extends BlockBase
{
    public function build(): array
    {
        return [
            '#theme' => 'my_custom_block',
            '#items' => $this->getItems(),
            '#cache' => ['max-age' => 3600],
        ];
    }

    private function getItems(): array
    {
        return \Drupal::service('my_module.service')->getRecentItems(5);
    }
}
```

---

## Twig Template

```twig
{# templates/my-custom-block.html.twig #}
<div class="my-module-block">
  <h2>{{ 'Recent Items'|t }}</h2>

  {% if items %}
    <ul class="item-list">
      {% for item in items %}
        <li class="item-list__item">
          <a href="{{ item.url }}">{{ item.title }}</a>
          <span class="item-date">{{ item.created|date('M d, Y') }}</span>
        </li>
      {% endfor %}
    </ul>
  {% else %}
    <p>{{ 'No items found.'|t }}</p>
  {% endif %}
</div>
```

```php
<?php
// my_module.module — Register template
function my_module_theme(): array
{
    return [
        'my_custom_block' => [
            'variables' => [
                'items' => [],
            ],
            'template' => 'my-custom-block',
        ],
    ];
}
```

---

## Drush Commands

```bash
# Module management
drush en my_module           # Enable module
drush pmu my_module          # Uninstall module

# Cache
drush cr                     # Clear all caches
drush cc render              # Clear render cache

# Config
drush cex                    # Export config
drush cim                    # Import config
drush cget my_module.settings  # View config

# Database
drush sql-dump > backup.sql  # Database backup
drush updb                   # Run database updates

# User
drush uli                    # Generate one-time login link
drush user:create admin --mail=admin@myapp.com --password=admin123
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Custom modules** | All code in `modules/custom/`, never hack core/contrib |
| **Dependency injection** | Services via `*.services.yml`, constructor injection |
| **Entity API** | Use Entity API (getQuery, loadMultiple) not raw SQL |
| **accessCheck** | Always `->accessCheck(TRUE)` in entity queries |
| **Config API** | Store settings in config, not database |
| **Twig** | Auto-escaping enabled; use `|raw` sparingly |
| **Cache tags** | Use cache tags for proper invalidation |
| **Coding standards** | Run `phpcs --standard=Drupal` |
| **Attributes** | Use PHP 8 attributes for plugins (Drupal 10+) |
| **Drush** | Use Drush for CLI operations, deployment, debugging |

---

## Rules Integration
- **Module**: info.yml + routing.yml + services.yml + hooks
- **Controller**: Symfony-style with DI via create() factory
- **Forms**: ConfigFormBase for settings, validation + submission
- **Plugins**: Block plugins with PHP 8 attributes
- **Theming**: Twig templates registered via hook_theme()

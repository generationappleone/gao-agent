---
name: Joomla!
description: Skill for Joomla! CMS development, covering component creation, module development, plugin hooks, template customization, and MVC architecture.
---

# Joomla! Skill

## Overview
Joomla! is a flexible CMS for building websites and web applications. This skill covers extension development (components, modules, plugins), template creation, and MVC patterns for Joomla 4/5.

## Extension Types
| Type | Purpose | Example |
|------|---------|---------|
| **Component** | Full MVC application | Contact form, e-commerce |
| **Module** | Small content blocks | Latest news, login box |
| **Plugin** | Event-driven hooks | SEO, authentication |
| **Template** | Site appearance | Custom themes |
| **Language** | Translations | Localization packs |

## Component Structure (Joomla 4/5 — MVC)
```
com_mycomponent/
├── admin/                       # Backend (administrator)
│   ├── forms/
│   │   └── item.xml             # Form definition
│   ├── services/
│   │   └── provider.php         # DI service provider
│   ├── sql/
│   │   └── install.mysql.utf8.sql
│   ├── src/
│   │   ├── Controller/
│   │   │   └── ItemController.php
│   │   ├── Model/
│   │   │   ├── ItemModel.php
│   │   │   └── ItemsModel.php
│   │   ├── Table/
│   │   │   └── ItemTable.php
│   │   └── View/
│   │       └── Items/
│   │           └── HtmlView.php
│   └── tmpl/
│       └── items/
│           └── default.php
├── site/                        # Frontend
│   ├── src/
│   │   ├── Controller/
│   │   ├── Model/
│   │   └── View/
│   └── tmpl/
├── media/
│   ├── css/
│   └── js/
└── mycomponent.xml              # Manifest file
```

## Component Model
```php
<?php
// admin/src/Model/ItemModel.php
namespace MyCompany\Component\MyComponent\Administrator\Model;

use Joomla\CMS\MVC\Model\AdminModel;
use Joomla\CMS\Factory;

defined('_JEXEC') or die;

class ItemModel extends AdminModel
{
    public function getForm($data = [], $loadData = true)
    {
        $form = $this->loadForm(
            'com_mycomponent.item',
            'item',
            ['control' => 'jform', 'load_data' => $loadData]
        );
        return $form ?: false;
    }

    protected function loadFormData()
    {
        $data = Factory::getApplication()->getUserState('com_mycomponent.edit.item.data', []);
        if (empty($data)) {
            $data = $this->getItem();
        }
        return $data;
    }
}
```

## Component Controller
```php
<?php
// admin/src/Controller/ItemController.php
namespace MyCompany\Component\MyComponent\Administrator\Controller;

use Joomla\CMS\MVC\Controller\FormController;

defined('_JEXEC') or die;

class ItemController extends FormController
{
    protected $text_prefix = 'COM_MYCOMPONENT_ITEM';

    // Additional custom logic can go here
    // Basic CRUD is handled by FormController
}
```

## Module Development
```php
<?php
// mod_mymodule/mod_mymodule.php
defined('_JEXEC') or die;

use Joomla\CMS\Helper\ModuleHelper;

// Get module parameters
$count = $params->get('count', 5);
$layout = $params->get('layout', 'default');

// Get data from helper
require_once __DIR__ . '/helper.php';
$items = ModMyModuleHelper::getItems($count);

// Render template
require ModuleHelper::getLayoutPath('mod_mymodule', $layout);
```

```php
<?php
// mod_mymodule/helper.php
defined('_JEXEC') or die;

use Joomla\CMS\Factory;

class ModMyModuleHelper
{
    public static function getItems(int $count): array
    {
        $db = Factory::getDbo();
        $query = $db->getQuery(true)
            ->select(['id', 'title', 'created'])
            ->from($db->quoteName('#__content'))
            ->where($db->quoteName('state') . ' = 1')
            ->order('created DESC')
            ->setLimit($count);

        $db->setQuery($query);
        return $db->loadObjectList();
    }
}
```

## Plugin Development
```php
<?php
// plg_system_myplugin/myplugin.php
namespace MyCompany\Plugin\System\MyPlugin;

use Joomla\CMS\Plugin\CMSPlugin;
use Joomla\Event\SubscriberInterface;

defined('_JEXEC') or die;

class MyPlugin extends CMSPlugin implements SubscriberInterface
{
    public static function getSubscribedEvents(): array
    {
        return [
            'onAfterRender'    => 'onAfterRender',
            'onContentPrepare' => 'onContentPrepare',
            'onUserLogin'      => 'onUserLogin',
        ];
    }

    public function onAfterRender(): void
    {
        $app = $this->getApplication();
        if ($app->isClient('administrator')) return;

        $body = $app->getBody();
        // Modify HTML output
        $body = str_replace('</body>', '<script>console.log("Plugin loaded")</script></body>', $body);
        $app->setBody($body);
    }

    public function onUserLogin(array $user, array $options): bool
    {
        // Custom login logic
        return true;
    }
}
```

## Template Override
```php
// Joomla encourages template overrides instead of core hacks
// Override location: templates/mytemplate/html/com_content/article/default.php
// This overrides the default article view without modifying core files
```

## Database (Using Joomla DBO)
```php
<?php
use Joomla\CMS\Factory;

$db = Factory::getDbo();

// ✅ SECURE: Use query builder (parameterized)
$query = $db->getQuery(true)
    ->select(['a.id', 'a.title', 'a.alias'])
    ->from($db->quoteName('#__content', 'a'))
    ->where($db->quoteName('a.state') . ' = :state')
    ->where($db->quoteName('a.catid') . ' = :catid')
    ->bind(':state', $published, \Joomla\Database\ParameterType::INTEGER)
    ->bind(':catid', $categoryId, \Joomla\Database\ParameterType::INTEGER)
    ->order('a.created DESC');

$db->setQuery($query);
$results = $db->loadObjectList();
```

## Commands (CLI)
```bash
# Joomla CLI (Joomla 4+)
php cli/joomla.php extension:install --path=/path/to/extension
php cli/joomla.php cache:clean
php cli/joomla.php config:get
php cli/joomla.php update:joomla:check
php cli/joomla.php user:list
```

## Rules Integration
- **SOLID**: Component MVC pattern separates concerns (Model, View, Controller)
- **Security**: Use Joomla DBO with bind parameters — never raw SQL, escape all output
- **Database**: Follow naming convention `#__mycomponent_tablename`

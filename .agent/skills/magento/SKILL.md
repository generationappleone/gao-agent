---
name: Magento
description: Skill for Magento 2 (Adobe Commerce) development, covering module creation, dependency injection, plugins, observers, layout XML, API, and deployment.
---

# Magento 2 Skill

## Overview
Magento 2 (Adobe Commerce) is an enterprise e-commerce platform. This skill covers custom module development, DI system, plugins/observers, layout XML, API development, and deployment.

## Module Structure
```
app/code/MyCompany/MyModule/
├── registration.php                # Module registration
├── etc/
│   ├── module.xml                  # Module metadata & version
│   ├── di.xml                      # Dependency injection config
│   ├── routes.xml                  # Frontend routes
│   ├── adminhtml/
│   │   ├── di.xml                  # Admin DI config
│   │   ├── routes.xml              # Admin routes
│   │   └── system.xml              # System configuration
│   ├── frontend/
│   │   ├── di.xml
│   │   └── routes.xml
│   └── webapi.xml                  # REST/GraphQL API
├── Api/
│   ├── Data/
│   │   └── ItemInterface.php       # Data interface
│   └── ItemRepositoryInterface.php # Repository contract
├── Controller/
│   └── Index/
│       └── Index.php               # Frontend controller
├── Model/
│   ├── Item.php                    # Model
│   ├── ResourceModel/
│   │   ├── Item.php                # Resource model
│   │   └── Item/
│   │       └── Collection.php      # Collection
│   └── ItemRepository.php          # Repository implementation
├── Block/
│   └── ItemList.php                # View block
├── view/
│   ├── frontend/
│   │   ├── layout/
│   │   │   └── mymodule_index_index.xml
│   │   ├── templates/
│   │   │   └── item/list.phtml
│   │   └── web/
│   │       ├── css/
│   │       └── js/
│   └── adminhtml/
│       └── layout/
├── Setup/
│   └── Patch/
│       └── Data/
│           └── InitialDataPatch.php
└── Plugin/
    └── ProductPlugin.php           # Interceptor
```

## Module Registration
```php
<?php
// registration.php
use Magento\Framework\Component\ComponentRegistrar;

ComponentRegistrar::register(
    ComponentRegistrar::MODULE,
    'MyCompany_MyModule',
    __DIR__
);
```

```xml
<!-- etc/module.xml -->
<?xml version="1.0"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="urn:magento:framework:Module/etc/module.xsd">
    <module name="MyCompany_MyModule" setup_version="1.0.0">
        <sequence>
            <module name="Magento_Catalog"/>
        </sequence>
    </module>
</config>
```

## Model Layer
```php
<?php
// Api/Data/ItemInterface.php
namespace MyCompany\MyModule\Api\Data;

interface ItemInterface
{
    public const ID = 'entity_id';
    public const TITLE = 'title';

    public function getId(): ?int;
    public function getTitle(): ?string;
    public function setTitle(string $title): self;
}
```

```php
<?php
// Model/Item.php
namespace MyCompany\MyModule\Model;

use Magento\Framework\Model\AbstractModel;
use MyCompany\MyModule\Api\Data\ItemInterface;
use MyCompany\MyModule\Model\ResourceModel\Item as ResourceItem;

class Item extends AbstractModel implements ItemInterface
{
    protected function _construct(): void
    {
        $this->_init(ResourceItem::class);
    }

    public function getTitle(): ?string
    {
        return $this->getData(self::TITLE);
    }

    public function setTitle(string $title): self
    {
        return $this->setData(self::TITLE, $title);
    }
}
```

```php
<?php
// Model/ResourceModel/Item.php
namespace MyCompany\MyModule\Model\ResourceModel;

use Magento\Framework\Model\ResourceModel\Db\AbstractDb;

class Item extends AbstractDb
{
    protected function _construct(): void
    {
        $this->_init('mycompany_mymodule_item', 'entity_id');
    }
}
```

## Dependency Injection (di.xml)
```xml
<!-- etc/di.xml -->
<?xml version="1.0"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">

    <!-- Interface → Implementation binding -->
    <preference for="MyCompany\MyModule\Api\ItemRepositoryInterface"
                type="MyCompany\MyModule\Model\ItemRepository"/>

    <preference for="MyCompany\MyModule\Api\Data\ItemInterface"
                type="MyCompany\MyModule\Model\Item"/>
</config>
```

## Plugin (Interceptor)
```php
<?php
// Plugin/ProductPlugin.php
namespace MyCompany\MyModule\Plugin;

use Magento\Catalog\Api\Data\ProductInterface;
use Magento\Catalog\Api\ProductRepositoryInterface;

class ProductPlugin
{
    // Before plugin — modify input
    public function beforeSave(
        ProductRepositoryInterface $subject,
        ProductInterface $product
    ): array {
        // Auto-generate SKU if empty
        if (!$product->getSku()) {
            $product->setSku('AUTO-' . time());
        }
        return [$product];
    }

    // After plugin — modify output
    public function afterGetById(
        ProductRepositoryInterface $subject,
        ProductInterface $result
    ): ProductInterface {
        // Add custom attribute to loaded product
        $result->setCustomAttribute('custom_label', 'Modified by plugin');
        return $result;
    }

    // Around plugin — wrap entire method
    public function aroundSave(
        ProductRepositoryInterface $subject,
        callable $proceed,
        ProductInterface $product
    ): ProductInterface {
        // Before
        $product->setName(trim($product->getName()));

        // Call original
        $result = $proceed($product);

        // After
        // Log or trigger event

        return $result;
    }
}
```

```xml
<!-- etc/di.xml — Register plugin -->
<type name="Magento\Catalog\Api\ProductRepositoryInterface">
    <plugin name="my_product_plugin"
            type="MyCompany\MyModule\Plugin\ProductPlugin"
            sortOrder="10"/>
</type>
```

## Layout XML
```xml
<!-- view/frontend/layout/mymodule_index_index.xml -->
<?xml version="1.0"?>
<page xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      layout="1column"
      xsi:noNamespaceSchemaLocation="urn:magento:framework:View/Layout/etc/page_configuration.xsd">
    <head>
        <title>My Module Page</title>
        <css src="MyCompany_MyModule::css/styles.css"/>
    </head>
    <body>
        <referenceContainer name="content">
            <block class="MyCompany\MyModule\Block\ItemList"
                   name="mymodule.item.list"
                   template="MyCompany_MyModule::item/list.phtml"/>
        </referenceContainer>
    </body>
</page>
```

## CLI Commands
```bash
# Module management
bin/magento module:enable MyCompany_MyModule
bin/magento setup:upgrade
bin/magento setup:di:compile
bin/magento cache:flush

# Development
bin/magento deploy:mode:set developer
bin/magento indexer:reindex
bin/magento setup:static-content:deploy -f

# Database
bin/magento setup:db-data:upgrade
```

## Rules Integration
- **SOLID**: Interface-driven DI (DIP), Plugins extend without modifying (OCP), Repository pattern (SRP)
- **Security**: Input validation, ACL for admin routes, CSRF in forms
- **Database**: Schema patches for migrations, resource models for data access

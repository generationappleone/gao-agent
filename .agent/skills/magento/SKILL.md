---
name: Magento
description: Skill for Magento 2 (Adobe Commerce) development, covering module creation, dependency injection, plugins, observers, layout XML, API, and deployment.
---

# Magento 2 Skill

## Overview
Magento 2 (Adobe Commerce) is a PHP-based enterprise e-commerce platform. Development follows strict conventions: dependency injection, service contracts, layout XML, and modular architecture. All customizations should be through custom modules, never editing core.

**References**:
- [Magento 2 Developer Docs](https://developer.adobe.com/commerce/php/)
- [Magento 2 REST API](https://developer.adobe.com/commerce/webapi/rest/)
- [Magento Coding Standards](https://developer.adobe.com/commerce/php/coding-standards/)

---

## Module Structure

```
app/code/Vendor/ModuleName/
├── Api/                            # Service contracts (interfaces)
│   ├── Data/
│   │   └── ProductDataInterface.php
│   └── ProductRepositoryInterface.php
├── Block/                          # View layer blocks
│   └── Product/
│       └── View.php
├── Controller/                     # Frontend controllers
│   └── Product/
│       └── Index.php
├── etc/                            # Configuration
│   ├── module.xml                  # Module declaration
│   ├── di.xml                      # Dependency injection
│   ├── routes.xml                  # URL routes (frontend)
│   ├── webapi.xml                  # REST/SOAP API routes
│   ├── events.xml                  # Event observers
│   ├── adminhtml/
│   │   ├── di.xml
│   │   ├── routes.xml
│   │   └── system.xml              # System configuration
│   └── frontend/
│       └── di.xml
├── Model/                          # Business logic
│   ├── Product.php                 # Model
│   ├── ProductRepository.php       # Repository implementation
│   └── ResourceModel/
│       ├── Product.php             # Resource model
│       └── Product/
│           └── Collection.php      # Collection
├── Observer/                       # Event observers
│   └── ProductSaveAfter.php
├── Plugin/                         # Interceptors (plugins)
│   └── ProductPlugin.php
├── Setup/                          # Install/upgrade scripts
│   ├── InstallSchema.php
│   └── Patch/
│       └── Data/
│           └── InitialData.php
├── view/                           # Frontend assets
│   ├── frontend/
│   │   ├── layout/
│   │   │   └── vendor_module_product_index.xml
│   │   ├── templates/
│   │   │   └── product/view.phtml
│   │   └── web/
│   │       ├── css/
│   │       └── js/
│   └── adminhtml/
│       └── layout/
└── registration.php                # Module registration
```

---

## Module Declaration

```php
<?php
// registration.php
use Magento\Framework\Component\ComponentRegistrar;

ComponentRegistrar::register(
    ComponentRegistrar::MODULE,
    'Vendor_CustomModule',
    __DIR__
);
```

```xml
<!-- etc/module.xml -->
<?xml version="1.0"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="urn:magento:framework:Module/etc/module.xsd">
    <module name="Vendor_CustomModule" setup_version="1.0.0">
        <sequence>
            <module name="Magento_Catalog"/>
            <module name="Magento_Sales"/>
        </sequence>
    </module>
</config>
```

---

## Dependency Injection

```xml
<!-- etc/di.xml -->
<?xml version="1.0"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">

    <!-- Interface preference (bind implementation) -->
    <preference for="Vendor\CustomModule\Api\ProductRepositoryInterface"
                type="Vendor\CustomModule\Model\ProductRepository"/>

    <!-- Virtual type -->
    <virtualType name="CustomProductCollection"
                 type="Magento\Framework\View\Element\UiComponent\DataProvider\SearchResult">
        <arguments>
            <argument name="mainTable" xsi:type="string">vendor_products</argument>
            <argument name="resourceModel" xsi:type="string">Vendor\CustomModule\Model\ResourceModel\Product</argument>
        </arguments>
    </virtualType>
</config>
```

---

## Plugin (Interceptor)

```php
<?php
// Plugin/ProductPlugin.php
namespace Vendor\CustomModule\Plugin;

use Magento\Catalog\Api\ProductRepositoryInterface;
use Magento\Catalog\Api\Data\ProductInterface;
use Psr\Log\LoggerInterface;

class ProductPlugin
{
    public function __construct(
        private LoggerInterface $logger
    ) {}

    // Before plugin — modify input
    public function beforeSave(
        ProductRepositoryInterface $subject,
        ProductInterface $product,
        bool $saveOptions = false
    ): array {
        // Sanitize product name
        $name = strip_tags($product->getName());
        $product->setName($name);

        return [$product, $saveOptions];
    }

    // After plugin — modify output
    public function afterGetById(
        ProductRepositoryInterface $subject,
        ProductInterface $result,
        int $productId
    ): ProductInterface {
        $this->logger->info("Product loaded: {$result->getSku()}");
        return $result;
    }

    // Around plugin — wrap entire method
    public function aroundSave(
        ProductRepositoryInterface $subject,
        callable $proceed,
        ProductInterface $product,
        bool $saveOptions = false
    ): ProductInterface {
        $this->logger->info("Before save: {$product->getSku()}");
        $result = $proceed($product, $saveOptions);
        $this->logger->info("After save: {$result->getId()}");
        return $result;
    }
}
```

```xml
<!-- etc/di.xml -->
<type name="Magento\Catalog\Api\ProductRepositoryInterface">
    <plugin name="vendor_product_plugin"
            type="Vendor\CustomModule\Plugin\ProductPlugin"
            sortOrder="10"/>
</type>
```

---

## Observer

```php
<?php
// Observer/ProductSaveAfter.php
namespace Vendor\CustomModule\Observer;

use Magento\Framework\Event\ObserverInterface;
use Magento\Framework\Event\Observer;

class ProductSaveAfter implements ObserverInterface
{
    public function execute(Observer $observer): void
    {
        $product = $observer->getEvent()->getProduct();

        // Sync product to external system
        // Clear custom cache
        // Send notification
    }
}
```

```xml
<!-- etc/events.xml -->
<?xml version="1.0"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="urn:magento:framework:Event/etc/events.xsd">
    <event name="catalog_product_save_after">
        <observer name="vendor_product_save_after"
                  instance="Vendor\CustomModule\Observer\ProductSaveAfter"/>
    </event>
</config>
```

---

## CLI Commands

```bash
# Module management
bin/magento module:enable Vendor_CustomModule
bin/magento module:disable Vendor_CustomModule

# Setup
bin/magento setup:upgrade              # Run install/upgrade scripts
bin/magento setup:di:compile           # Compile DI (production)
bin/magento setup:static-content:deploy -f  # Deploy static files

# Cache
bin/magento cache:clean
bin/magento cache:flush
bin/magento cache:status

# Index
bin/magento indexer:reindex
bin/magento indexer:status

# Maintenance
bin/magento maintenance:enable
bin/magento maintenance:disable

# Deploy (production)
bin/magento deploy:mode:set production
bin/magento deploy:mode:show
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Never edit core** | Always use modules, plugins, observers |
| **Service contracts** | Use interfaces (Api/) for all public methods |
| **DI** | Constructor injection via di.xml, avoid ObjectManager |
| **Plugins over observers** | Plugins for modifying behavior, observers for side effects |
| **Plugin sort order** | Use sortOrder to control plugin execution order |
| **Cache** | Always clean cache after config/layout changes |
| **Declarative schema** | Use db_schema.xml instead of InstallSchema |
| **Static tests** | Run `vendor/bin/phpcs --standard=Magento2` |
| **Deploy mode** | Development (dev), Default (testing), Production (live) |
| **Performance** | Full-page cache, Varnish, Redis sessions/cache |

---

## Rules Integration
- **Architecture**: Modular (app/code/Vendor/Module) with strict DI
- **Customization**: Plugins (before/after/around), Observers, Preferences
- **Data**: Repository pattern with Service Contracts
- **Frontend**: Layout XML, Block classes, PHTML templates
- **Deploy**: setup:upgrade → di:compile → static-content:deploy

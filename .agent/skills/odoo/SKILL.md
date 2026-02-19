---
name: Odoo
description: Skill for developing with Odoo ERP platform, covering module development, ORM, views (XML), controllers, security, and business logic customization.
---

# Odoo Skill

## Overview
Odoo is an open-source ERP and business application suite. This skill covers custom module development, ORM patterns, view definitions, controllers, security, and integration with existing Odoo modules.

## Module Structure
```
my_module/
├── __init__.py
├── __manifest__.py          # Module metadata
├── models/
│   ├── __init__.py
│   └── my_model.py          # Business logic & ORM
├── views/
│   ├── my_model_views.xml   # Form, list, search views
│   └── menu_views.xml       # Menu items
├── controllers/
│   ├── __init__.py
│   └── main.py              # HTTP controllers
├── security/
│   ├── ir.model.access.csv  # Access control list
│   └── security_rules.xml   # Record rules (RLS)
├── data/
│   └── demo_data.xml        # Demo/seed data
├── static/
│   └── description/
│       └── icon.png         # Module icon
├── wizard/                  # Transient models (wizards)
│   ├── __init__.py
│   └── export_wizard.py
└── reports/
    └── report_template.xml  # QWeb report templates
```

## __manifest__.py
```python
{
    'name': 'My Custom Module',
    'version': '17.0.1.0.0',
    'category': 'Sales',
    'summary': 'Custom sales management module',
    'description': """
        Long description of the module.
    """,
    'author': 'My Company',
    'website': 'https://example.com',
    'license': 'LGPL-3',
    'depends': ['base', 'sale', 'stock'],
    'data': [
        'security/ir.model.access.csv',
        'security/security_rules.xml',
        'views/my_model_views.xml',
        'views/menu_views.xml',
        'data/demo_data.xml',
    ],
    'demo': [],
    'installable': True,
    'application': True,
    'auto_install': False,
}
```

## Model (ORM)
```python
# models/my_model.py
from odoo import models, fields, api
from odoo.exceptions import ValidationError
import uuid

class SalesOrder(models.Model):
    _name = 'my_module.sales_order'
    _description = 'Custom Sales Order'
    _inherit = ['mail.thread', 'mail.activity.mixin']  # Chatter & activities
    _order = 'create_date desc'

    # Fields
    name = fields.Char(
        string='Order Reference',
        required=True,
        copy=False,
        readonly=True,
        default=lambda self: 'New',
    )
    uuid = fields.Char(string='UUID', default=lambda self: str(uuid.uuid4()), copy=False, index=True)
    partner_id = fields.Many2one('res.partner', string='Customer', required=True, tracking=True)
    date_order = fields.Datetime(string='Order Date', default=fields.Datetime.now, required=True)
    state = fields.Selection([
        ('draft', 'Draft'),
        ('confirmed', 'Confirmed'),
        ('done', 'Done'),
        ('cancelled', 'Cancelled'),
    ], string='Status', default='draft', tracking=True)

    order_line_ids = fields.One2many('my_module.order_line', 'order_id', string='Order Lines')
    total_amount = fields.Float(string='Total', compute='_compute_total', store=True)
    notes = fields.Html(string='Notes')

    # Computed field
    @api.depends('order_line_ids.subtotal')
    def _compute_total(self):
        for record in self:
            record.total_amount = sum(record.order_line_ids.mapped('subtotal'))

    # Constraint
    @api.constrains('total_amount')
    def _check_total(self):
        for record in self:
            if record.total_amount < 0:
                raise ValidationError('Total amount cannot be negative.')

    # Auto-generate sequence
    @api.model_create_multi
    def create(self, vals_list):
        for vals in vals_list:
            if vals.get('name', 'New') == 'New':
                vals['name'] = self.env['ir.sequence'].next_by_code('my_module.sales_order') or 'New'
        return super().create(vals_list)

    # Business logic
    def action_confirm(self):
        self.ensure_one()
        if not self.order_line_ids:
            raise ValidationError('Cannot confirm an order without lines.')
        self.write({'state': 'confirmed'})

    def action_cancel(self):
        self.write({'state': 'cancelled'})


class OrderLine(models.Model):
    _name = 'my_module.order_line'
    _description = 'Order Line'

    order_id = fields.Many2one('my_module.sales_order', string='Order', required=True, ondelete='cascade')
    product_id = fields.Many2one('product.product', string='Product', required=True)
    quantity = fields.Float(string='Quantity', default=1.0)
    unit_price = fields.Float(string='Unit Price')
    subtotal = fields.Float(string='Subtotal', compute='_compute_subtotal', store=True)

    @api.depends('quantity', 'unit_price')
    def _compute_subtotal(self):
        for line in self:
            line.subtotal = line.quantity * line.unit_price

    @api.onchange('product_id')
    def _onchange_product(self):
        if self.product_id:
            self.unit_price = self.product_id.list_price
```

## Views (XML)
```xml
<!-- views/my_model_views.xml -->
<odoo>
  <!-- Form View -->
  <record id="view_sales_order_form" model="ir.ui.view">
    <field name="name">my_module.sales_order.form</field>
    <field name="model">my_module.sales_order</field>
    <field name="arch" type="xml">
      <form string="Sales Order">
        <header>
          <button name="action_confirm" string="Confirm" type="object"
                  class="btn-primary" states="draft"/>
          <button name="action_cancel" string="Cancel" type="object" states="draft,confirmed"/>
          <field name="state" widget="statusbar" statusbar_visible="draft,confirmed,done"/>
        </header>
        <sheet>
          <group>
            <group>
              <field name="name"/>
              <field name="partner_id"/>
            </group>
            <group>
              <field name="date_order"/>
              <field name="total_amount"/>
            </group>
          </group>
          <notebook>
            <page string="Order Lines">
              <field name="order_line_ids">
                <tree editable="bottom">
                  <field name="product_id"/>
                  <field name="quantity"/>
                  <field name="unit_price"/>
                  <field name="subtotal"/>
                </tree>
              </field>
            </page>
            <page string="Notes">
              <field name="notes"/>
            </page>
          </notebook>
        </sheet>
        <div class="oe_chatter">
          <field name="message_follower_ids"/>
          <field name="activity_ids"/>
          <field name="message_ids"/>
        </div>
      </form>
    </field>
  </record>

  <!-- Tree View -->
  <record id="view_sales_order_tree" model="ir.ui.view">
    <field name="name">my_module.sales_order.tree</field>
    <field name="model">my_module.sales_order</field>
    <field name="arch" type="xml">
      <tree decoration-info="state=='draft'" decoration-success="state=='done'">
        <field name="name"/>
        <field name="partner_id"/>
        <field name="date_order"/>
        <field name="total_amount" sum="Total"/>
        <field name="state" widget="badge"
               decoration-info="state=='draft'"
               decoration-success="state=='done'"
               decoration-danger="state=='cancelled'"/>
      </tree>
    </field>
  </record>

  <!-- Action -->
  <record id="action_sales_order" model="ir.actions.act_window">
    <field name="name">Sales Orders</field>
    <field name="res_model">my_module.sales_order</field>
    <field name="view_mode">tree,form</field>
  </record>

  <!-- Menu -->
  <menuitem id="menu_root" name="My Module" sequence="50"/>
  <menuitem id="menu_sales" name="Sales" parent="menu_root"/>
  <menuitem id="menu_orders" name="Orders" parent="menu_sales"
            action="action_sales_order" sequence="10"/>
</odoo>
```

## Security
```csv
# security/ir.model.access.csv
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_sales_order_user,sales_order_user,model_my_module_sales_order,base.group_user,1,1,1,0
access_sales_order_manager,sales_order_manager,model_my_module_sales_order,base.group_system,1,1,1,1
access_order_line_user,order_line_user,model_my_module_order_line,base.group_user,1,1,1,0
```

## Commands
```bash
# Update module
./odoo-bin -u my_module -d mydb --stop-after-init

# Install module
./odoo-bin -i my_module -d mydb --stop-after-init

# Development mode
./odoo-bin --dev=all -d mydb

# Scaffold new module
./odoo-bin scaffold my_new_module addons/
```

## Rules Integration
- **SOLID**: Models (SRP), computed fields (OCP), inheritance (LSP)
- **Database**: UUID field for external references, proper normalization with Many2one/One2many
- **Security**: ACL + record rules for row-level security, input validation with @api.constrains

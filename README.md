## Description
This generator will generate CRUD of resource on admin side with following module
- controller
- policy
- view
- spec/controller

## How to setup ?
copy `admin_template` folder and paste into `lib/generators` folder of your app directory

## Usage
please make sure already prepared model and routes configuration
```
rails g admin_template YourController --model=YourModel
```

##### Additional options
| option | type | default|
|---|---|---|
| --inside_scope | string | nil |
| --skip_view | boolean | false |
| --skip_test | boolean | false |

```
rails g admin_template DcProductsController --model=DcProduct --inside_scope=Lazada
```

```
rails g admin_template DcProductsController --model=DcProduct --skip_view=true
```

```
rails g admin_template DcProductsController --model=DcProduct --skip_test=true
```

#### Example
prepare model
```
rails g model DcProduct title:string description:text quantity:integer active:boolean active_date:datetime
```
config routes
```
#config/routes.rb
....
resources :dc_products do
  list_routes
  admin_form_routes
  post :admin_create, on: :collection
  patch :admin_update, on: :member
end
```
generate admin_template
```
rails g admin_template DcProductsController --model=DcProduct
```
generated files
```
create  app/controllers/dc_products_controller.rb
create  app/policies/dc_product_policy.rb
create  app/views/dc_products/list.slim
create  app/views/dc_products/admin_new.slim
create  app/views/dc_products/admin_edit.slim
create  app/views/dc_products/admin_show.slim
create  app/views/dc_products/_admin_form.slim
create  spec/controllers/dc_products_controller_spec.rb
```

If generate with `inside_scope` option
```
rails g admin_template DcProductsController --model=DcProduct --inside_scope=Lazada
```
generated files
```
create  app/controllers/lazada/dc_products_controller.rb
create  app/policies/dc_product_policy.rb
create  app/views/lazada/dc_products/list.slim
create  app/views/lazada/dc_products/admin_new.slim
create  app/views/lazada/dc_products/admin_edit.slim
create  app/views/lazada/dc_products/admin_show.slim
create  app/views/lazada/dc_products/_admin_form.slim
create  spec/controllers/lazada/dc_products_controller_spec.rb
```

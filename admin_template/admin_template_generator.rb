class AdminTemplateGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  class_option :model, type: :string
  class_option :inside_scope, type: :string
  class_option :skip_view, type: :boolean, default: false
  class_option :skip_test, type: :boolean, default: false

  def generate_controller_file
    raise 'Model option cannot be found' and return unless options[:model].present?

    @attributes = get_model_attributes(options).map { |attribute| ":#{attribute}" }.join(', ')

    generator_file_name = file_name
    @camelized_model_str = options[:model].camelize
    @underscored_model_str = options[:model].underscore
    @underscored_controller_str = file_name.remove('_controller')
    @underscored_controller_path_str = file_name.remove('_controller')

    if options[:inside_scope].present?
      generator_file_name = "#{options[:inside_scope].underscore}/#{file_name}"
      @underscored_controller_str = "#{options[:inside_scope].camelize}/#{@underscored_controller_str}"
      @underscored_controller_path_str = "#{options[:inside_scope].underscore}_#{@underscored_controller_path_str}"
    end

    template 'controller_template.template', "app/controllers/#{generator_file_name}.rb"
  end

  def generate_policy_file
    raise 'Model option cannot be found' and return unless options[:model].present?

    @camelized_model_str = options[:model].camelize

    template 'policy_template.template', "app/policies/#{@camelized_model_str.underscore}_policy.rb"
  end

  def generate_view_files
    return if options[:skip_view].present?

    prepare_view_parent_path
    prepare_action_paths

    generate_view_list
    generate_view_admin_new
    generate_view_admin_edit
    generate_view_admin_show
    generate_view_admin_form
  end

  def generate_controller_spec_file
    return if options[:skip_test].present?

    @attributes = get_model_attributes(options).map { |attribute| ":#{attribute}" }.join(', ')

    generator_file_name = file_name
    @camelized_model_str = options[:model].camelize
    @underscored_model_str = options[:model].underscore
    @underscored_controller_str = file_name.remove('_controller')
    @underscored_controller_path_str = file_name.remove('_controller')

    if options[:inside_scope].present?
      generator_file_name = "#{options[:inside_scope].underscore}/#{file_name}"
      @underscored_controller_str = "#{options[:inside_scope].camelize}/#{@underscored_controller_str}"
      @underscored_controller_path_str = "#{options[:inside_scope].underscore}_#{@underscored_controller_path_str}"
    end

    template 'controller_spec_template.template', "spec/controllers/#{generator_file_name}_spec.rb"
  end

  private

  # active record columns helpers
  def get_model_attributes(options)
    active_record_clazz = options[:model].constantize
    active_record_clazz
      .attribute_names
      .reject { |attribute| %w[id created_at updated_at].include?(attribute) }
  end

  def get_model_attribute_with_type(options)
    active_record_clazz = options[:model].constantize
    model_attributes = get_model_attributes(options)
    model_attributes.map do |attribute|
      [attribute, active_record_clazz.type_for_attribute(attribute).type.to_s]
    end.to_h
  end

  # prepare string
  def prepare_view_parent_path
    @view_parent_path = options[:model].underscore.pluralize

    if options[:inside_scope].present?
      @view_parent_path = "#{options[:inside_scope].underscore}/#{@view_parent_path}"
    end
  end

  def prepare_action_paths
    controller_path_str = file_name.remove('_controller').singularize

    if options[:inside_scope].present?
      controller_path_str = "#{options[:inside_scope].underscore}_#{controller_path_str}"
    end

    @list_path = "list_#{controller_path_str.pluralize}_path"
    @admin_new_path = "admin_new_#{controller_path_str.pluralize}_path"
    @admin_create_path = "admin_create_#{controller_path_str.pluralize}_path"
    @admin_edit_path = "admin_edit_#{controller_path_str}_path"
    @admin_update_path = "admin_update_#{controller_path_str}_path"
    @admin_show_path = "admin_show_#{controller_path_str}_path"
    @destroy_path = "#{controller_path_str}_path"
  end

  # Generate views
  def generate_view_list
    model_attributes = get_model_attributes(options)
    @table_header_attributes = model_attributes.map(&:humanize)
    @table_body_attributes = model_attributes
    @underscored_model_str = options[:model].underscore

    template 'views/list_template.template', "app/views/#{@view_parent_path}/list.slim"
  end

  def generate_view_admin_new
    @underscored_model_str = options[:model].underscore
    template 'views/admin_new_template.template', "app/views/#{@view_parent_path}/admin_new.slim"
  end

  def generate_view_admin_show
    template 'views/admin_show_template.template', "app/views/#{@view_parent_path}/admin_show.slim"
  end

  def generate_view_admin_edit
    @underscored_model_str = options[:model].underscore
    template 'views/admin_edit_template.template', "app/views/#{@view_parent_path}/admin_edit.slim"
  end

  def generate_view_admin_form
    @underscored_model_str = options[:model].underscore
    @generate_input = method(:generate_input)
    @attributes_with_type = get_model_attribute_with_type(options)

    template 'views/admin_form_template.template', "app/views/#{@view_parent_path}/_admin_form.slim"
  end

  def generate_input(attribute, type)
    case type
    when 'string', 'integer', 'decimal', 'datetime', 'text'
      "= f.input :#{attribute}, as: :#{type}, label: '#{attribute.humanize}', input_html: { class: 'form-control', disabled: !submitable }, wrapper_html: { class: 'form-group' }, error_class: 'has-danger'"
    when 'boolean'
      "= render 'layouts/admin/forms/radio_buttons', locals: { f: f, name: '#{attribute.humanize}', label: '#{attribute.humanize}', collection: [[true, 'Yes'] ,[false, 'No']], object_value: f.object.#{attribute}?, disabled: !submitable }"
    else
      ''
    end
  end
end

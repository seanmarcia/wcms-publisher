require 'rails/generators/resource_helpers'

class PublisherGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers

  source_root File.expand_path('../templates', __FILE__)

  argument :attributes, type: :array, default: [], banner: "field:type field:type"

  def create_controller_file
    template "controller.rb", File.join("app/controllers", "#{controller_file_name}_controller.rb")
  end

  def create_policy
    template "policy.rb", File.join("app/policies", "#{singular_table_name}_policy.rb")
  end

  def create_views
    template "views/_index_partial.html.slim", File.join("app/views/#{plural_table_name}", "_#{plural_table_name}.html.slim")
    template "views/_menu.html.slim", File.join("app/views/#{plural_table_name}", "_menu.html.slim")
    template "views/edit.html.slim", File.join("app/views/#{plural_table_name}", "edit.html.slim")
    template "views/index.html.slim", File.join("app/views/#{plural_table_name}", "index.html.slim")
    template "views/new.html.slim", File.join("app/views/#{plural_table_name}", "new.html.slim")
    template "views/edit_partials/_form.html.slim", File.join("app/views/#{plural_table_name}/edit_partials", "_form.html.slim")
  end

  def create_route
    route "resources :#{controller_file_name}"
  end

  def create_specs
    puts "Skipping tests for now"
  end

  def add_to_menu
    puts "TODO: Add #{class_name} to the application menu and to the settings file list"
  end

end

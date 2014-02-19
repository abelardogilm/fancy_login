class FancyLogin::ConfigGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  desc "Generate the fancy login config and initializer files in your project."
  def copy_initializer_file
    copy_file "fancy_login.yml", "config/fancy_login.yml"
    copy_file "fancy_login.rb", "config/initializers/fancy_login.rb"
  end
end
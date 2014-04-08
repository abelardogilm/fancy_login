require 'yaml'

module FancyLogin
  class Config
    class << self
    	def load!(file_name)
        @properties = YAML.load(ERB.new(File.read(file_name)).result)
      end

      def properties
        @properties
      end

      def user
        properties["user"]
      end

      def app
        properties["app"]
      end

      def routes
        properties["routes"]
      end

      def app_name
        app["name"]
      end

      def url
        routes["url"]
      end

      def sign_in_url
        url + routes["sign_in_path"]
      end

      def sign_up_url
        url + routes["sign_up_path"]
      end

      def facebook_url
        url + routes["facebook_path"]
      end

      def facebook_url_callback
        url + facebook_url + "/callback"
      end

      def reset_password_url
        url + routes["reset_password_path"]
      end

      def confirmation_url
        url + routes["confirmation_path"]
      end

    end
  end
end
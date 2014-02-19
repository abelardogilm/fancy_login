module FancyLogin
  module ViewHelpers
    def fancy_login
      @current_user = current_user if current_user.present?
      @config = FancyLogin::Config
      render 'fancy_login/fancy_login'
    end
  end
end
require 'fancy_login/version'
require 'fancy_login/engine'
require 'fancy_login/helper'

ActionView::Base.send(:include, FancyLogin::ViewHelpers)

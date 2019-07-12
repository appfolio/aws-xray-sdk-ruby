require 'aws-xray-sdk/facets/rack'
require 'aws-xray-sdk/facets/rails/ex_middleware'

module XRay
  # configure X-Ray instrumentation for rails framework
  class Railtie < ::Rails::Railtie
    RAILS_OPTIONS = %I[active_record enabled].freeze

    initializer("aws-xray-sdk.rack_middleware") do |app|
      if app.config.respond_to?('xray') && app.config.xray[:enabled]
        app.middleware.insert 0, Rack::Middleware
        app.middleware.use XRay::Rails::ExceptionMiddleware
      end
    end

    config.after_initialize do |app|
      if app.config.respond_to?('xray') && app.config.xray[:enabled]
        options = app.config.xray
        require 'aws-xray-sdk/facets/rails/active_record' if options[:active_record]
        general_options = options.reject { |k, v| RAILS_OPTIONS.include?(k) }
        XRay.recorder.configure(general_options)
      end
    end
  end
end

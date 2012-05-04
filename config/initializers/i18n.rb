I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
I18n.fallbacks.map('ru' => 'en')
I18n.fallbacks.map('nl' => 'en')
I18n.fallbacks.map('sw' => 'en')
I18n.fallbacks.map('el' => 'en')
I18n.fallbacks.map('ro' => 'en')
I18n.fallbacks.map('fr' => 'en')
I18n.fallbacks.map('es' => 'en')
I18n.fallbacks.map('es-ES' => 'es')
I18n.fallbacks.map('ca' => 'es-ES')
I18n.fallbacks.map('zh' => 'en')
I18n.fallbacks.map('it' => 'en')



module I18n
  def self.with_locale(locale, &block)
    orig_locale = self.locale
    self.locale = locale
    return_value = yield
    self.locale = orig_locale
    return_value
  end
end

# Monkey patch the translate method to include always some variables for interpolation
I18n.module_eval do

  class << self
    
    # The method is quite strictly the original, only modifcation of "options" is added few lines below.
    def translate(*args)
            
      options = args.last.is_a?(Hash) ? args.pop : {}
      key     = args.shift
      backend = config.backend
      locale  = options.delete(:locale) || config.locale
      raises  = options.delete(:raise)

      # insert here the variables
      service_name = ApplicationHelper.fetch_community_service_name_from_thread
      #puts "in I18n using service name: #{service_name}"
      options.merge!(:service_name => service_name) unless options.key?(:service_name)
      # end added code here

      raise I18n::ArgumentError if key.is_a?(String) && key.empty?

      if key.is_a?(Array)
        key.map { |k| backend.translate(locale, k, options) }
      else
        backend.translate(locale, key, options)
      end
    rescue I18n::ArgumentError => exception
      raise exception if raises
      handle_exception(exception, locale, key, options)
    end
    alias :t :translate
  end
end
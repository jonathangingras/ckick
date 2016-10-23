module CKick

  module PluginDelegate

    def self.find(plugin)
      Object.const_get(plugin[:name]).new(plugin[:args] || {})
    end

  end

end

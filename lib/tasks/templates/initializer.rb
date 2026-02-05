Rtypes.config.path = 'app/javascript/types'
Rtypes.config.types = {
  integer: 'number',
  decimal: 'string',
  boolean: 'boolean',
}
Rtypes.config.enable_kotlin = false
Rtypes.config.kotlin_package_name = 'your.pacakge.name'

if Rails.env.development?
  Rtypes.auto_generate
end

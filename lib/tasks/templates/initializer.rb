Rtypes.config.path = 'app/javascript/types'
Rtypes.config.types = {
  integer: 'number',
  decimal: 'string',
  boolean: 'boolean',
}
Rtypes.config.enable_kotlin = false

if Rails.env.development?
  Rtypes.auto_generate
end

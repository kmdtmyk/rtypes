Rtypes.config.path = 'app/javascript/types'
Rtypes.config.types = {
  integer: 'number',
  bigint: 'number',
  decimal: 'string',
  boolean: 'boolean',
}
Rtypes.config.line_space = 1

Rtypes.config.enable_kotlin = false
Rtypes.config.kotlin_package_name = 'your.pacakge.name'
Rtypes.config.kotlin_root_directory = Rails.root.join('app/serializers')
Rtypes.config.kotlin_types = [
  # { type: :decimal, class: 'java.math.BigDecimal', annotation: '@Serializable(with = BigDecimalSerializer::class)' },
]

if Rails.env.development?
  Rtypes.auto_generate
end

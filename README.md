# Rtypes
Short description and motivation.

## Usage

```bash
rails rtypes:generate
```

```ruby
class UserSerializer < ActiveModel::Serialier
  attributes(
    :id,
    :name,
  )
end
```

↓

```ts
type User = {
  id: number | null
  name: string
}

export default User
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem "rtypes"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install rtypes
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

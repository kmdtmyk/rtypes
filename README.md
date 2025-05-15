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
gem 'rparam', git: 'https://github.com/kmdtmyk/rparam', ref: '<commit_hash>'
```

And then execute:
```bash
$ bundle install
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

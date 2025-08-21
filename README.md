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
  id: number
  name: string
}

export default User
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rtypes', git: 'https://github.com/kmdtmyk/rtypes', ref: '<commit_hash>'
```

And then execute:
```bash
$ bundle install
```

## Test

```
docker compose run --rm app bin/test
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

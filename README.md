# Disqus API for Ruby
[![Gem Version](https://badge.fury.io/rb/disqus_api.png)](http://badge.fury.io/rb/disqus_api)
[![Build Status](https://travis-ci.org/einzige/disqus_api.png?branch=master)](https://travis-ci.org/einzige/disqus_api)

Provides clean Disqus REST API for your Ruby app. Currently supported API version: 3.0.

See also [Disqus API for Rails](https://github.com/einzige/disqus_api_rails).

## Install

```bash
gem install disqus_api
```

## Configure

```ruby
require 'disqus_api'

DisqusApi.config = {api_secret: 'secret key',
                    api_key: 'public key',
                    access_token: 'token from app settings'}
```

## Enjoy

```ruby
DisqusApi.v3.users.details
# => {"code" => 0, "response" => {
#                     "isFollowing"=>false,
#                     "isFollowedBy"=>false, "connections"=>{}, "isPrimary"=>true, "id"=>"84792962"
#                     ...
#                  }
```

Use response to get response body

```ruby
DisqusApi.v3.users.details.response
# => {
#       "isFollowing"=>false,
#       "isFollowedBy"=>false, "connections"=>{}, "isPrimary"=>true, "id"=>"84792962"
#       ...
#    }
```

Alias `#body` for response body

```ruby
DisqusApi.v3.users.details.body
# => {
#       "isFollowing"=>false,
#       "isFollowedBy"=>false, "connections"=>{}, "isPrimary"=>true, "id"=>"84792962"
#       # ...
#    }
```

Setting additional parameters to a query

```ruby
DisqusApi.v3.posts.list(forum: 'my_form')
```

### Fetching full collections

By default Disqus API limits returning collections by 25 records per requests. The maximum limit you can set is 100.
In order to fetch **all records** from a collection use `#all` method:

```ruby
DisqusApi.v3.posts.list(forum: 'my_form').all
```

### Pagination

```ruby
first_page  = DisqusApi.v3.posts.list(forum: 'my_forum', limit: 10)

second_page = first_page.next
third_page  = second_page.next
# ...
```

### Performing custom requests

```ruby
DisqusApi.v3.get('posts/list.json', forum: 'my_forum')
DisqusApi.v3.post('posts/create.json', forum: 'my_forum')
```

### Using in test environment

Disqus API uses Faraday gem, refer to its documentation for details.

```ruby
before :all do
  # You can move this block in RSpec initializer or `spec_helper.rb`

  stubbed_request = Faraday::Adapter::Test::Stubs.new do |stub|
    stub.get('/api/3.0/users/details.json') { [200, {}, {code: 0, body: {response: :whatever}}.to_json] }
  end
  DisqusApi.adapter = [:test, stubbed_requests]
end

it 'performs requests' do
  DisqusApi.v3.users.details['code'].should == 0
end
```

## Contributing to disqus_api

- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
- Fork the project
- Start a feature/bugfix branch
- Commit and push until you are happy with your contribution
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

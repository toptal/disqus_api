# Disqus API for Ruby
[![Gem Version](https://badge.fury.io/rb/disqus_api.png)](http://badge.fury.io/rb/disqus_api)
[![Build Status](https://travis-ci.org/toptal/disqus_api.png?branch=master)](https://travis-ci.org/toptal/disqus_api)
[![Code Climate](https://codeclimate.com/repos/52ab1c4c7e00a455db041687/badges/69e7a7201240be64f8de/gpa.png)](https://codeclimate.com/repos/52ab1c4c7e00a455db041687/feed)

Provides clean Disqus REST API for your Ruby app. Currently supported API version: 3.0.

Rails >3.0 is also supported.

## Install

```bash
gem install disqus_api
```

## Configure

If you are not using Rails:

```ruby
require 'disqus_api'

DisqusApi.config = {api_secret: 'secret key',
                    api_key: 'public key',
                    access_token: 'token from app settings'}
```

For **Rails** users:

Put in your `config/disqus_api.yml`:

```ruby
development:
  api_secret: development_secret_key
  api_key: 'public key',
  access_token: 'token from app settings'}

production:
  api_secret: production_secret_key
  api_key: 'public key',
  access_token: 'token from app settings'}

# ... any other env
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

Step by step:

```ruby
first_page  = DisqusApi.v3.posts.list(forum: 'my_forum', limit: 10)

second_page = first_page.next
third_page  = second_page.next
first_page  = thrid_page.prev.prev
# ...
```

It is useful to go through all records. This way you will pass every page in batches by 10:

```ruby
DisqusApi.v3.posts.list(limit: 10).each_resource do |comment|
  puts comment.inspect
end
```

You can also iterate collection page by page.

```ruby
DisqusApi.v3.posts.each_page do |comments|
  comments.each do |comment|
    puts comment.inspect
  end
end
```

You can also move on next page:

```ruby
response = DisqusApi.v3.posts
response.next!
```

Or on previous one:

```ruby
response.prev!
```

### Performing custom requests

```ruby
DisqusApi.v3.get('posts/list.json', forum: 'my_forum')
DisqusApi.v3.post('posts/create.json', forum: 'my_forum')
```

### Handling exceptions

Just catch `DisqusApi::InvalidApiRequestError`. It has `code` to identify problems with a request.

```ruby
begin
  DisqusApi.v3.posts.list(forum: 'something-wrong')
rescue DisqusApi::InvalidApiRequestError => e
  e.response.inspect
end

#=> {"code"=>2, "response"=>"Invalid argument, 'forum': Unable to find forum 'something-wrong'"}
```

### Using in test environment

```ruby
before :all do
  # You can move this block in RSpec initializer or `spec_helper.rb`

  DisqusApi.stub_requests do |stub|
    stub.get('/api/3.0/users/details.json') { [200, {}, {code: 0, body: {response: :whatever}}.to_json] }
  end
end

it 'performs requests' do
  DisqusApi.v3.users.details['code'].should == 0
end
```

Disqus API uses Faraday gem, refer to its documentation for details.

### Running specs

Use any of the following commands from the project directory:

```bash
rspec
```

```ruby
rake # rake gem must be installed
```

In order to test on a real Discus account
- specify `spec/config/disqus.yml` (see `spec/config/disqus.yml.example` for details)
- run specs passing `USE_DISQUS_ACCOUNT` environment variable:

```bash
USE_DISQUS_ACCOUNT=1 rspec
```

## Contributing to disqus_api

- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
- Fork the project
- Start a feature/bugfix branch
- Commit and push until you are happy with your contribution
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

require 'spec_helper'

describe DisqusApi, perform_requests: true do
  describe "user details" do
    let(:request_path) { '/api/3.0/users/details.json' }

    it 'performs requests' do
      expect(DisqusApi.v3.users.details['code']).to eq(0)
    end
  end

  describe "posts list", local: true do
    before :each do
      stubbed_requests.get("/api/3.0/posts/list.json?forum=my_forum&access_token=&api_key=&api_secret=&limit=1")          { [200, {}, {code: 0, response: ['first_one'],  cursor: {hasNext: true,  next: 1}}.to_json] }
      stubbed_requests.get("/api/3.0/posts/list.json?cursor=1&forum=my_forum&access_token=&api_key=&api_secret=&limit=1") { [200, {}, {code: 0, response: ['second_one'], cursor: {hasNext: true,  next: 2}}.to_json] }
      stubbed_requests.get("/api/3.0/posts/list.json?cursor=2&forum=my_forum&access_token=&api_key=&api_secret=&limit=1") { [200, {}, {code: 0, response: ['third_one'],  cursor: {hasNext: false, next: 3}}.to_json] }
      stubbed_requests.get("/api/3.0/posts/list.json?cursor=3&forum=my_forum&access_token=&api_key=&api_secret=&limit=1") { [200, {}, {code: 0, response: ['fourth_one'], cursor: {hasNext: false         }}.to_json] }
    end

    it 'fetches all comments' do
      expect(DisqusApi.v3.posts.list(forum: 'my_forum', limit: 1).all).to eq(%w{first_one second_one third_one})
    end
  end
end

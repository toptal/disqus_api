require 'spec_helper'

describe DisqusApi, perform_requests: true do
  let(:request_path) { '/api/3.0/users/details.json' }

  it 'performs requests' do
    DisqusApi.v3.users.details['code'].should == 0
  end
end
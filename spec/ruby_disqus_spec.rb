require 'spec_helper'

describe DisqusApi do

  it 'performs requests', integration: true do
    DisqusApi.v3.users.details['code'].should == 0
  end
end
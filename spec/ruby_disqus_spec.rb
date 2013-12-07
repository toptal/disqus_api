require 'spec_helper'

describe RubyDisqus do
  it 'works' do
    RubyDisqus.config = {
      api_secret:   'D9IEQlSUm0znL2MFcldtrcZjqiVVaLlp9w0vjXo1ULZdHvpUbsqJdCgL5HCt5DMs',
      api_key:      'xNDRmrQf2FaBuLsgVai6uHpjUUNBE5xyTMTrVqhvp6sLRDVOP7Qvag7pTIVQhyW9',
      access_token: 'bfb575586f7949b29dfeef678ddfaa01'
    }

    puts RubyDisqus.v3.users.details
  end
end
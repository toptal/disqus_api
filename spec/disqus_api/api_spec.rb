require 'spec_helper'

describe DisqusApi::Api do
  subject(:api) { described_class.new(version, specifications) }

  let(:version) { '3.0' }
  let(:specifications) { {'users' => 'details'} }

  its(:version) { should eq(version) }
  its(:specifications) { should eq(specifications) }
  its(:namespaces) { should have_key(:users) }
  its(:endpoint) { should eq('https://disqus.com/api/3.0/') }
  it { should respond_to(:users) }
  its(:users) { should be_a(DisqusApi::Namespace) }
  its(:connection_options) { should eq ({headers: {"Accept"=>"application/json", "User-Agent"=>"DisqusAgent"},
                                         ssl: {verify: false},
                                         url: "https://disqus.com/api/3.0/"}) }

  describe "unregistered namespace metacalls" do
    it { is_expected.not_to respond_to(:foo) }
    specify { expect { api.foo }.to raise_error(ArgumentError) }
  end

  describe "#connection" do
    subject { api.connection }
    it { is_expected.to be_a(Faraday::Connection) }
    its(:params) { should have_key('api_key') }
    its(:params) { should have_key('api_secret') }
    its(:params) { should have_key('access_token') }
  end

  describe "#get", perform_requests: true do
    let(:request_path) { '/api/3.0/users/details.json' }

    it 'performs GET request' do
      expect(api.get(request_path)['code']).to eq(0)
    end

    context "invalid request" do
      let(:request_path) { '/api/3.0/invalid/request.json' }
      let(:response_code) { 1 }

      specify do
        expect { api.get(request_path) }.to raise_error(DisqusApi::InvalidApiRequestError, /"code"=>1/)
      end
    end
  end

  describe "#post", perform_requests: true do
    let(:request_type) { :post }
    let(:request_path) { '/api/3.0/forums/create.json' }
    let(:request_args) { {name: 'TestRspec', short_name: 'tspec', website: 'http://disqus.com'} } # no way!

    context "local", local: true do
      it 'performs POST request' do
        expect(api.post(request_path, request_args)['code']).to eq(0)
      end
    end

    context "invalid request" do
      let(:request_path) { '/api/3.0/invalid/request.json' }
      let(:response_code) { 1 }

      specify do
        expect { api.post(request_path) }.to raise_error(DisqusApi::InvalidApiRequestError, /"code"=>1/)
      end
    end
  end
end

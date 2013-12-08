require 'spec_helper'

describe DisqusApi::Namespace do
  let(:api) { DisqusApi::Api.new(version, specifications) }
  let(:version) { '3.0' }
  let(:specifications) { {'users' => {'details' => 'get'}} }

  let(:namespace_name) { 'users' }
  subject(:namespace) { described_class.new(api, namespace_name) }

  its(:api) { should == api }
  its(:specification) { should == {'details' => 'get'} }
  its(:name) { should == namespace_name }

  it { should respond_to :details }

  describe "#initialize" do
    let(:namespace_name) { 'foos' }
    it { expect { subject }.to raise_error(ArgumentError, "No such namespace <foos>") }
  end

  describe "#build_action_request" do
    subject(:request) { namespace.build_action_request('details', {args: true}) }
    its(:path) { should == 'users/details.json' }
    its(:api) { should == api }
    its(:arguments) { should == {args: true} }
  end

  context perform_requests: true do
    let(:request_path) { '/api/3.0/users/details.json' }

    it 'performs requests' do
      namespace.details['code'].should == 0
    end

    describe "#request_action" do
      let(:response) { namespace.request_action('details') }

      it 'performs action request' do
        response['code'].should == 0
      end

      context "invalid request" do
        let(:response) { namespace.request_action('foos') }
        specify { expect { response }.to raise_error(ArgumentError) }
        specify { expect { namespace.foos }.to raise_error(NoMethodError) }
      end
    end
  end
end
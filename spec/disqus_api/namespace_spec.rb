require 'spec_helper'

describe DisqusApi::Namespace do
  let(:api) { DisqusApi::Api.new(version, specifications) }
  let(:version) { '3.0' }
  let(:specifications) { {'users' => {'details' => 'get'}} }

  let(:namespace_name) { 'users' }
  subject(:namespace) { DisqusApi::Namespace.new(api, namespace_name) }

  its(:api) { is_expected.to eq(api) }
  its(:specification) { is_expected.to eq({'details' => 'get'}) }
  its(:name) { is_expected.to eq(namespace_name) }

  it { should respond_to :details }

  describe "#initialize" do
    let(:namespace_name) { 'foos' }
    it { expect { subject }.to raise_error(ArgumentError, "No such namespace <foos>") }
  end

  describe "#build_action_request" do
    subject(:request) { namespace.build_action_request('details', {args: true}) }
    its(:path) { is_expected.to eq('users/details.json') }
    its(:api) { is_expected.to eq(api) }
    its(:arguments) { is_expected.to eq({args: true}) }
  end

  context 'requests', perform_requests: true do
    let(:request_path) { '/api/3.0/users/details.json' }

    its(:details) { should be_a(Hash) }
    its(:details) { should be_a(::DisqusApi::Response) }

    it 'performs requests' do
      expect(namespace.details['code']).to eq(0)
    end

    describe "#request_action" do
      let(:response) { namespace.request_action('details') }

      it 'performs action request' do
        expect(response['code']).to eq(0)
      end

      context "invalid request" do
        let(:response) { namespace.request_action('foos') }
        specify { expect { response }.to raise_error(ArgumentError) }
        specify { expect { namespace.foos }.to raise_error(NoMethodError) }
      end
    end
  end
end

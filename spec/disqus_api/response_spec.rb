require 'spec_helper'

describe DisqusApi::Response do
  let(:request) { DisqusApi::Request.new(api, namespace, action, request_arguments) }
  let(:api) { DisqusApi::Api.new(version, specifications) }
  let(:version) { '3.0' }
  let(:specifications) { {'posts' => {'list' => 'get'}} }
  let(:namespace) { 'posts' }
  let(:action) { 'list' }
  let(:request_arguments) { {forum: 'my_forum'} }

  subject(:response) { described_class.new(request, arguments) }
  let(:arguments) { {limit: 1} }
  let(:response_body) { {} }

  before do
    request.should_receive(:perform).with(arguments).and_return(response_body)
  end

  describe "#has_next?" do
    context "has" do
      let(:response_body) { {'cursor' => {'hasNext' => true}} }
      its(:has_next?) { should be_true }
    end

    context 'has not' do
      let(:response_body) { {'cursor' => {'hasNext' => false}} }
      its(:has_next?) { should be_false }
    end
  end

  describe "#next_cursor" do
    let(:response_body) { {'cursor' => {'next' => 'next identifier'}} }
    its(:next_cursor) { should == 'next identifier' }
  end

  describe "#body" do
    let(:response_body) { {'response' => {'received' => true}} }
    its(:body) { should == {'received' => true} }
  end

  describe "#code" do
    let(:response_body) { {'code' => 0} }
    its(:code) { should == 0}
  end

  describe "#next" do
    context "has next page" do
      let(:response_body) { {'cursor' => {'hasNext' => true, 'next' => 'Next:2'}} }
      let(:next_page_response) { double('next_page_response') }

      before do
        request.should_receive(:response).with({limit: 1, cursor: 'Next:2'}).and_return(next_page_response)
      end

      its(:next) { should == next_page_response }
    end

    context 'has no next page' do
      let(:response_body) { {'cursor' => {'hasNext' => false, 'next' => 'Next:2'}} }
      its(:next) { should be_nil }
    end
  end

  describe "#all" do
    let(:response_body) { {'cursor' => {'hasNext' => false, 'next' => 'Next:2'}, 'response' => ['page_1_elem_1']} }
    its(:all) { should == ['page_1_elem_1'] }

    context "many pages" do
      let(:response_body) { {'cursor' => {'hasNext' => true, 'next' => 'Next:2'}, 'response' => ['page_1_elem_1']} }
      let(:next_page_response) { double('next_page_response') }

      before do
        request.should_receive(:response).with({limit: 1, cursor: 'Next:2'}).and_return(next_page_response)
        next_page_response.should_receive(:body).and_return(['page_2_elem_1'])
        next_page_response.should_receive(:next).and_return(nil)
      end

      its(:all) { should == ['page_1_elem_1', 'page_2_elem_1'] }
    end
  end
end
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
      its(:has_next?) { is_expected.to be true }
    end

    context 'has not' do
      let(:response_body) { {'cursor' => {'hasNext' => false}} }
      its(:has_next?) { is_expected.to be false  }
    end
  end

  describe "#has_prev?" do
    context "has" do
      let(:response_body) { {'cursor' => {'hasPrev' => true}} }
      its(:has_prev?) { is_expected.to be true }
    end

    context 'has not' do
      let(:response_body) { {'cursor' => {'hasPrev' => false}} }
      its(:has_prev?) { is_expected.to be false }
    end
  end

  describe "#next_cursor" do
    let(:response_body) { {'cursor' => {'next' => 'next identifier'}} }
    its(:next_cursor) { should == 'next identifier' }
  end

  describe "#prev_cursor" do
    let(:response_body) { {'cursor' => {'prev' => 'prev identifier'}} }
    its(:prev_cursor) { should == 'prev identifier' }
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
      let(:response_body) { {'cursor' => {'hasNext' => true, 'next' => 'another_page'}} }
      let(:next_page_response) { double('next_page_response') }

      before do
        request.should_receive(:response).with({limit: 1, cursor: 'another_page'}).and_return(next_page_response)
      end

      its(:next) { should == next_page_response }
    end

    context 'has no next page' do
      let(:response_body) { {'cursor' => {'hasNext' => false, 'next' => 'another_page'}} }
      its(:next) { should be_nil }
    end
  end

  describe "#prev" do
    context "has previous page" do
      let(:response_body) { {'cursor' => {'hasPrev' => true, 'prev' => 'another_page'}} }
      let(:prev_page_response) { double('prev_page_response') }

      before do
        request.should_receive(:response).with({limit: 1, cursor: 'another_page'}).and_return(prev_page_response)
      end

      its(:prev) { should == prev_page_response }
    end

    context 'has no prev page' do
      let(:response_body) { {'cursor' => {'hasPrev' => false, 'prev' => 'another_page'}} }
      its(:prev) { should be_nil }
    end
  end

  describe "pagination" do
    its(:each_page) { should be_a(Enumerator) }

    context "building a enumerator" do
      before do
        request.should_not_receive(:prev)
        request.should_not_receive(:next)
        request.should_not_receive(:perform)
      end

      describe "#each_page" do
        specify { subject.each_page }
      end

      describe "#each_resource" do
        specify { subject.each_resource }
      end
    end

    context "multiple pages" do
      before do
        request.should_receive(:perform).with(arguments.merge(cursor: 'another_page')).and_return(another_page_response_body)
      end

      let(:page_1_elem_1) { double('page_1_elem_1') }
      let(:page_2_elem_1) { double('page_2_elem_1') }

      let(:response_body) {
        {'cursor' => {'hasNext' => true, 'next' => 'another_page'}, 'page' => 1, 'response' => [page_1_elem_1]}
      }
      let(:another_page_response_body) {
        {'cursor' => {'hasNext' => false}, 'page' => 2, 'response' => [page_2_elem_1]}
      }
      its(:all) { should == [page_1_elem_1, page_2_elem_1] }

      describe "#next!" do
        before { response.next! }
        it { should be_a(described_class) }

        it 'steps on next page' do
          response['page'].should == 2
        end

        context "no next" do
          before { response.next! }

          it 'does nothing' do
            response['page'].should == 2
          end
        end
      end

      describe "#prev!" do
        let(:response_body) {
          {'cursor' => {'hasPrev' => true, 'prev' => 'another_page'}, 'page' => 2}
        }
        let(:another_page_response_body) {
          {'cursor' => {'hasPrev' => false}, 'page' => 1}
        }

        before { response.prev! }
        it { should be_a(described_class) }

        it 'steps on previous page' do
          response['page'].should == 1
        end

        context "no previous" do
          before { response.prev! }

          it 'does nothing' do
            response['page'].should == 1
          end
        end
      end

      describe "#each_page" do
        it 'returns each page' do
          subject.each_page.to_a.should == [[page_1_elem_1], [page_2_elem_1]]
        end

        it 'iterates through each page' do
          page_1_elem_1.should_receive(:get_block_message)
          page_2_elem_1.should_receive(:get_block_message)

          subject.each_page { |page| page.each(&:get_block_message) }
        end
      end

      describe "#each_resource" do
        it 'returns each record iterator' do
          subject.each_resource.to_a.should == [page_1_elem_1, page_2_elem_1]
        end

        it 'iterates through each resource' do
          page_1_elem_1.should_receive(:get_block_message)
          page_2_elem_1.should_receive(:get_block_message)

          subject.each_resource(&:get_block_message)
        end
      end
    end
  end
end
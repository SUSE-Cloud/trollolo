require_relative 'spec_helper'

include GivenFilesystemSpecHelpers

describe BurndownData do
  
  before(:each) do
    @burndown = BurndownData.new( dummy_settings )
    @burndown.board_id = "myboardid"
  end

  describe BurndownData::Result do
    it "calculates total" do
      r = BurndownData::Result.new
      r.open = 7
      r.done = 4
      
      expect( r.total).to eq 11
    end
  end

  describe "setters" do
    it "sets open story points" do
      @burndown.story_points.open = 13
      expect( @burndown.story_points.open ).to eq 13
    end
    
    it "sets open tasks" do
      @burndown.tasks.open = 42
      expect( @burndown.tasks.open ).to eq 42
    end
  end

  describe "#to_hash" do
    it "converts to hash" do
      @burndown.story_points.open = 1
      @burndown.story_points.done = 2
      @burndown.tasks.open = 3
      @burndown.tasks.done = 4
      @burndown.extra_story_points.open = 5
      @burndown.extra_story_points.done = 6
      @burndown.extra_tasks.open = 7
      @burndown.extra_tasks.done = 8
      @burndown.date_time = DateTime.parse("2015-01-15")

      expected_hash = {
        "date" => "2015-01-15",
        "story_points" => {
          "total" => 3,
          "open" => 1
        },
        "tasks" => {
          "total" => 7,
          "open" => 3
        },
        "story_points_extra" => {
          "done" => 6
        },
        "tasks_extra" => {
          "done" => 8
        }
      }

      expect(@burndown.to_hash).to eq(expected_hash)
    end
  end

  describe "#fetch_todo_list_id" do
    it "returns list id" do
      list_url_match = /https:\/\/trello.com\/1\/boards\/myboardid\/lists\?-*/
          
      stub_request(:any,list_url_match).to_return(:status => 200,
        :body => load_test_file("lists.json"), :headers => {})

      expect( @burndown.fetch_todo_list_id ).to eq "53186e8391ef8671265eba9e"
    end
    
    it "raises exception if it does not find done column" do
      expect{ @burndown.fetch_todo_list_id }.to raise_error
    end
  end
  
  describe "#fetch_doing_list_id" do
    it "returns list id" do
      list_url_match = /https:\/\/trello.com\/1\/boards\/myboardid\/lists\?-*/
          
      stub_request(:any,list_url_match).to_return(:status => 200,
        :body => load_test_file("lists.json"), :headers => {})

      expect( @burndown.fetch_doing_list_id ).to eq "53186e8391ef8671265eba9f"
    end
    
    it "raises exception if it does not find done column" do
      expect{ @burndown.fetch_doing_list_id }.to raise_error
    end
  end
  
  describe "#fetch_done_list_id" do
    it "returns list id" do
      list_url_match = /https:\/\/trello.com\/1\/boards\/myboardid\/lists\?-*/
          
      stub_request(:any,list_url_match).to_return(:status => 200,
        :body => load_test_file("lists.json"), :headers => {})

      expect( @burndown.fetch_done_list_id ).to eq "5319bf088cdf9cd82be336b0"
    end
    
    it "raises exception if it does not find done column" do
      expect{ @burndown.fetch_done_list_id }.to raise_error
    end
  end
  
  describe "#fetch" do
    before(:each) do
      card_url_match = /https:\/\/trello.com\/1\/boards\/myboardid\/cards\?-*/
          
      stub_request(:any,card_url_match).to_return(:status => 200,
        :body => load_test_file("cards.json"), :headers => {})

      list_url_match = /https:\/\/trello.com\/1\/boards\/myboardid\/lists\?-*/
          
      stub_request(:any,list_url_match).to_return(:status => 200,
        :body => load_test_file("lists.json"), :headers => {})
    end
    
    it "returns story points" do
      @burndown.fetch
      
      expect( @burndown.story_points.total ).to eq 16
      expect( @burndown.story_points.open ).to eq 13
      expect( @burndown.story_points.done ).to eq 3
    end

    it "returns extra story points" do
      @burndown.fetch
      
      expect( @burndown.extra_story_points.total ).to eq 8
      expect( @burndown.extra_story_points.open ).to eq 8
      expect( @burndown.extra_story_points.done ).to eq 0
    end

    it "returns tasks" do
      @burndown.fetch

      expect( @burndown.tasks.total ).to eq 13
      expect( @burndown.tasks.open ).to eq 9
      expect( @burndown.tasks.done ).to eq 4
    end
    
    it "returns extra tasks" do
      @burndown.fetch

      expect( @burndown.extra_tasks.total ).to eq 1
      expect( @burndown.extra_tasks.open ).to eq 1
      expect( @burndown.extra_tasks.done ).to eq 0
    end

    it "returns meta data" do
      @burndown.fetch

      expect( @burndown.meta ).to eq({
        "sprint" => 10,
        "total_days" => 18,
        "weekend_lines" => [1.5, 6.5, 11.5, 16.5]
      })
    end

    it "saves date and time" do
      expected_date_time = DateTime.parse("2015-01-12T13:57:16+01:00")

      allow(DateTime).to receive(:now).and_return(expected_date_time)

      @burndown.fetch

      expect(@burndown.date_time).to eq(expected_date_time)
    end
  end
end

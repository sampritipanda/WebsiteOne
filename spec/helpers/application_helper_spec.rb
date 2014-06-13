require 'spec_helper'

describe ApplicationHelper do

  it '#date_format returns formatted date 1st Jan 2015' do
    expect(date_format(Date.new(2015,1,1))).to eq('1st Jan 2015')
    expect(date_format(Date.new(2015,5,3))).to eq('3rd May 2015')
  end

  describe '#valid_email?' do
    it 'returns true if email is valid' do
      expect(valid_email?('valid@valid.com')).to be_true
    end

    it 'returns false if email is invalid' do
      expect(valid_email?('invalid')).to be_false
      expect(valid_email?('invalid@')).to be_false
      expect(valid_email?('invalid@invalid')).to be_false
      expect(valid_email?('invalid@invalid.')).to be_false
      expect(valid_email?('invalid@.invalid')).to be_false
      expect(valid_email?('invalid@invalid.i')).to be_false
    end
  end

  describe '#shared_meta_keywords' do
    before do
      @keywords = helper.shared_meta_keywords.split(',').map { |word| word.squish }
    end

    it 'should contain AgileVentures' do
      expect(@keywords).to include 'AgileVentures'
    end

    it 'should contain pair programming' do
      expect(@keywords).to include 'pair programming'
    end

    it 'should contain crowdsourced learning' do
      expect(@keywords).to include 'crowdsourced learning'
    end
  end

  describe '#default_meta_description' do
    it 'should include the words AgileVentures' do
      expect(helper.default_meta_description).to contain 'AgileVentures'
    end
  end

  describe '#custom_css_btn' do
    before(:each) do
      @custom_btn_html = helper.custom_css_btn 'this is a text', 'fa fa-icon', root_path, id: 'my-id', class: 'btn-random'
    end

    it 'should render the text "this is a text"' do
      @custom_btn_html.should have_css '[title="this is a text"]'
    end

    it 'should render the icon classes "fa fa-icon"' do
      @custom_btn_html.should have_css '.fa.fa-icon'
    end

    it 'should have a link to the root path' do
      @custom_btn_html.should have_link '', href: root_path
    end

    it 'should have the id="my-id" and class="btn-random"' do
      @custom_btn_html.should have_css '#my-id.btn-random'
    end
  end

  describe '#social_button' do
    before(:each) do
      @user = stub_model(User)
      @user.stub_chain(:authentications, :where, :first, :id).and_return(100)
      helper.stub(current_user: @user)
    end

    it 'should render the correct provider' do
      btn_html = helper.social_button 'github'
      btn_html.should have_css '.btn-github'
    end

    it 'should render the delete method if the option is specified' do
      btn_html = helper.social_button 'gplus', delete: true
      btn_html.should have_css '[method=delete]'
    end
  end

  describe "#roots" do
    it 'should fetch documents which are roots and belong to @project sorted by created at' do
      project = FactoryGirl.create(:project)
      project2 = FactoryGirl.create(:project)
      FactoryGirl.create(:document, project_id: project.id, parent_id: nil)
      FactoryGirl.create(:document, project_id: project.id, parent_id: nil)
      FactoryGirl.create(:document, project_id: project.id, parent_id: 5)
      FactoryGirl.create(:document, project_id: project2.id, parent_id: 3)
      FactoryGirl.create(:document, project_id: project2.id, parent_id: nil)

      helper.instance_variable_set("@project", project)
      roots = helper.roots
      roots.count.should eq 2
      roots.each do |doc|
        doc.parent_id.should be_nil
        doc.project.should eq project
      end
      roots.first.created_at.should be < roots.last.created_at
    end
  end
end

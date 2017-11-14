require "spec_helper"

def check_page_availability(name)
  get :show, format: :html, page: name
  expect(response.status).to eq 200
end

describe StaticController do
  render_views

  context "render pages" do
    it 'features' do
      check_page_availability('features')
    end

    it 'privacy' do
      check_page_availability('privacy')
    end

    it 'support'  do
      check_page_availability('support')
    end

    it 'team' do
      check_page_availability('team')
    end

    it 'terms' do
      check_page_availability('terms')
    end

    it 'displays correcty 500 message if page not exists' do
      expect {
        get :show, format: :html, page: :this_page_should_never_exists
        expect(response.status).to eq(500)
      }.to raise_error(ActionController::RoutingError)
    end
  end
end

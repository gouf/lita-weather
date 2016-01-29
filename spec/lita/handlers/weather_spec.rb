require 'spec_helper'

describe Lita::Handlers::Weather, lita_handler: true do
  it { is_expected.to route('weather tokyo') }
  it { is_expected.to route('weather tokyo').to(:weather) }
  it 'retrieved message includes "Area: Tokyo"' do
    send_command('weather tokyo')
    expect(replies).to include('Area: Tokyo')
  end

  it 'JSON response includes a key as text' do
    response = http.post '/weather', text: 'yokohama'
    expect(JSON.parse(response.body).keys).to include('text')
  end
end

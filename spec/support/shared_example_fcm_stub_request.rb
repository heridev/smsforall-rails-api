RSpec.shared_examples 'fcm stub request' do
  let(:fcm_response) do
    {
      status_code: 200,
      body: {
        response: 'responseeeee'
      }.to_json
    }
  end

  before do
    allow_any_instance_of(FCM).to receive(:send_v1).and_return(fcm_response)
  end
end

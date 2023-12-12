# spec/http_client_spec.rb

require 'http_client'

RSpec.describe HTTPClient::Client do
  let(:client) { HTTPClient::Client.new('https://jsonplaceholder.typicode.com') }

  describe '#get' do
    it 'performs a successful GET request' do
      response = client.get('/posts/1')
      expect(response).to_not be_empty
      expect(response).to include('userId')
      expect(response).to include('id')
      expect(response).to include('title')
      expect(response).to include('body')
    end

    it 'raises an HTTPError for an invalid GET request' do
      expect { client.get('/invalid_path') }.to raise_error(HTTPClient::HTTPError)
    end
  end

  describe '#post' do
    it 'performs a successful POST request' do
      body = { title: 'Test Title', body: 'Test Body', userId: 1 }.to_json
      response = client.post('/posts', body, { 'Content-Type': 'application/json' })
      expect(response).to_not be_empty
      expect(response).to include('id')
      expect(response['title']).to eq('Test Title')
      expect(response['body']).to eq('Test Body')
      expect(response['userId']).to eq(1)
    end

    it 'raises an HTTPError for an invalid POST request' do
      expect { client.post('/invalid_path', nil, {}) }.to raise_error(HTTPClient::HTTPError)
    end
  end

  # Add tests for other HTTP methods (PUT, DELETE) following a similar pattern
  describe '#put' do
    it 'performs a successful PUT request' do
      body = { title: 'Updated Title' }.to_json
      response = client.put('/posts/1', body, { 'Content-Type': 'application/json' })
      expect(response).to_not be_empty
      expect(response['title']).to eq('Updated Title')
    end

    it 'raises an HTTPError for an invalid PUT request' do
      expect { client.put('/invalid_path', nil, {}) }.to raise_error(HTTPClient::HTTPError)
    end
  end

  describe '#delete' do
    it 'performs a successful DELETE request' do
      response = client.delete('/posts/1')
      expect(response).to eq('{}') # Placeholder for the expected response after deletion
    end

    it 'raises an HTTPError for an invalid DELETE request' do
      expect { client.delete('/invalid_path') }.to raise_error(HTTPClient::HTTPError)
    end
  end
end

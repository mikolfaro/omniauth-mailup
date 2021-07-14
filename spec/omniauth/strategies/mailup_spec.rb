require 'spec_helper'
require 'omniauth-mailup'
require 'base64'
require 'pry'
require 'pry-byebug'

describe OmniAuth::Strategies::MailUp do
  before :each do
    @request = double('Request', params: {}, cookies: {}, env: {})
    allow(@request).to receive(:params) { {} }
    allow(@request).to receive(:cookies) { {} }
  end

  subject do
    OmniAuth::Strategies::MailUp.new(nil, @options || {}).tap do |strategy|
      allow(strategy).to receive(:request) { @request }
    end
  end

	describe '#client' do
    it 'has correct MailUp api site' do
      site = subject.options.client_options.site
      expect(site).to eq('https://services.mailup.com')
    end

    it 'has correct access token path' do
      token_url = subject.options.client_options.token_url
      expect(token_url).to eq('/Authorization/OAuth/Token')
    end

    it 'has correct authorize url' do
      authorize_url = subject.options.client_options.authorize_url
      expect(authorize_url).to eq('/Authorization/OAuth/LogOn')
    end
  end

	describe '#callback_path' do
    it 'should have the correct callback path' do
      expect(subject.callback_path).to eq('/auth/mailup/callback')
    end
  end

  describe '#credentials' do
    before :each do
      @access_token = double('OAuth2::AccessToken')
      allow(@access_token).to receive(:token)
      allow(@access_token).to receive(:expires?)
      allow(@access_token).to receive(:expires_at)
      allow(@access_token).to receive(:refresh_token)
      allow(subject).to receive(:access_token) { @access_token }
    end

    it 'returns a Hash' do
      expect(subject.credentials).to be_a(Hash)
    end

    it 'returns the token' do
      allow(@access_token).to receive(:token) { '123' }
      expect(subject.credentials['token']).to eq('123')
    end

    it 'returns the expiry status' do
      allow(@access_token).to receive(:expires?) { true }
      expect(subject.credentials['expires']).to eq(true)

      allow(@access_token).to receive(:expires?) { false }
      expect(subject.credentials['expires']).to eq(false)
    end
  end
end

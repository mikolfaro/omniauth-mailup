require 'omniauth-oauth2'
require 'multi_json'

module OmniAuth
  module Strategies
    class MailUp < OmniAuth::Strategies::OAuth2

      def initialize(app, *args, &block)
        super(app, *args, &block)

        @env = {}
      end

      option :name, :mailup

      option :client_options, {
        site: "https://services.mailup.com",
        authorize_url: "/Authorization/OAuth/LogOn",
        token_url: "/Authorization/OAuth/Token"
      }

      # TODO: Do we need this?
      option :provider_ignores_state, true

      # AuthHash data for Omniauth
      uid { raw_info["UID"] } # TODO: Need uid from MailUp

      info do
        {
          company: raw_info["Company"],
          nickname: raw_info["Username"],
          version: raw_info["Version"],
          is_trial: raw_info["IsTrial"]
        }
      end

      # Get more information about the user.
      def raw_info
        req = access_token.get('/API/v1.1/Rest/ConsoleService.svc/Console/Authentication/Info')
        @raw_info ||= MultiJson.load(req.body)
      end

      # Workaround to avoid Invalid URI error
      # Remove Redirect URI completely
      def build_access_token
        verifier = request.params["code"]
        client.auth_code.get_token(verifier, token_params.to_hash(:symbolize_keys => true), deep_symbolize(options.auth_token_params))
      end
    end
  end
end

# Make sure that 'mailup' camelizes properly to 'MailUp'.
OmniAuth.config.add_camelization 'mailup', 'MailUp'

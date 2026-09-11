module Opennms
  module Trapd
    class Snmpv3UserIdentity
      SECURITY_LEVELS = {
        'NOAUTH_NOPRIV' => 1,
        'AUTH_NOPRIV' => 2,
        'AUTH_PRIV' => 3,
      }.freeze

      SECURITY_LEVEL_NAMES =
        SECURITY_LEVELS.invert.freeze

      attr_reader :engine_id
      attr_reader :security_name
      attr_reader :security_level
      attr_reader :auth_protocol
      attr_reader :privacy_protocol

      def self.key_for(
        engine_id: nil,
        security_name:,
        security_level:,
        auth_protocol: nil,
        privacy_protocol: nil
      )
        [
          engine_id,
          security_name,
          security_level,
          auth_protocol,
          privacy_protocol,
        ].join('|')
      end

      def self.from_hash(user)
        new(
          engine_id: user['engineId'],
          security_name: user['securityName'],
          security_level: SECURITY_LEVEL_NAMES.fetch(
            user['securityLevel']
          ),
          auth_protocol: user['authProtocol'],
          privacy_protocol: user['privacyProtocol']
        )
      end

      def initialize(
        engine_id: nil,
        security_name:,
        security_level:,
        auth_protocol: nil,
        privacy_protocol: nil
      )
        @engine_id = engine_id&.freeze
        @security_name = security_name.freeze
        @security_level = security_level.freeze
        @auth_protocol = auth_protocol&.freeze
        @privacy_protocol = privacy_protocol&.freeze

        @key = self.class.key_for(
          engine_id: @engine_id,
          security_name: @security_name,
          security_level: @security_level,
          auth_protocol: @auth_protocol,
          privacy_protocol: @privacy_protocol
        ).freeze

        @hash = @key.hash

        freeze
      end

      attr_reader :key

      attr_reader :hash

      def to_h
        {
          'engineId' => engine_id,
          'securityName' => security_name,
          'securityLevel' =>
            SECURITY_LEVELS.fetch(security_level),
          'authProtocol' => auth_protocol,
          'privacyProtocol' => privacy_protocol,
        }.compact
      end

      def ==(other)
        other.is_a?(Snmpv3UserIdentity) &&
          key == other.key
      end
      alias eql? ==

      def inspect
        "#<#{self.class.name} #{key}>"
      end
    end
  end
end

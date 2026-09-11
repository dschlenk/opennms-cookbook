module Opennms
  module Trapd
    class TrapdConfig
      class << self
        def instance_for(node)
          node.run_state['opennms_trapd_config'] ||= begin
            backend =
              if node['opennms']['version'].to_i >= 36
                ApiBackend.new(node)
              else
                XmlBackend.new(node)
              end

            new(node, backend)
          end
        end
      end

      attr_reader :current
      attr_reader :desired

      def initialize(node, backend)
        @node = node
        @backend = backend

        @current = backend.load
        @desired = Marshal.load(Marshal.dump(@current))

        build_user_index!
      end

      def update(resource)
        @backend.queue_write(resource, self)
      end

      #
      # SNMPv3 users
      #

      def find_user(identity)
        @user_index[identity]
      end

      def add_or_update_snmpv3_user(user)
        desired['snmpv3User'] ||= []

        identity = identity_for(user)

        existing = @user_index[identity]

        if existing
          preserve_id_and_update(existing, user)
        else
          desired['snmpv3User'] << user
          @user_index[identity] = user
        end
      end

      def delete_snmpv3_user(identity)
        user = @user_index[identity]

        return unless user

        desired['snmpv3User'].delete(user)

        @user_index.delete(identity)
      end

      %w(
        batchInterval
        batchSize
        includeRawMessage
        newSuspectOnTrap
        queueSize
        snmpTrapAddress
        snmpTrapPort
        threads
        useAddressFromVarbind
      ).each do |field|
        define_method("#{field}=") do |value|
          desired[field] = value
        end
      end

      private

      def identity_for(user)
        Snmpv3UserIdentity.from_hash(user)
      end

      def preserve_id_and_update(existing, update)
        existing_id = existing['id']

        existing.replace(
          existing.merge(update)
        )

        existing['id'] = existing_id if existing_id
      end

      def build_user_index!
        @user_index = {}

        desired.fetch('snmpv3User', []).each do |user|
          @user_index[identity_for(user)] = user
        end
      end
    end
  end
end

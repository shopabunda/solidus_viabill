# frozen_string_literal: true

module SolidusViabill
  class Gateway
    def initialize(*args); end

    def authorize(_amount, payment_source, _gateway_options)
    end

    def capture(*args); end

    def void(*args); end

    def purchase(*args); end

    def generate_signature(*args, join_character)
      base_string = args.join(join_character)
      Digest::SHA256.hexdigest(base_string)
    end
  end
end

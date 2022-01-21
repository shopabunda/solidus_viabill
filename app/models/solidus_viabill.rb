# frozen_string_literal: true

module SolidusViabill
  def self.table_name_prefix
    'solidus_viabill_'
  end

  def self.viabill_url
    Rails.env.test? ? 'https://secure-test.viabill.com/api' : 'https://secure.viabill.com/api'
  end
end

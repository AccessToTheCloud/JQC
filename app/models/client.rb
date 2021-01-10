class Client < ApplicationRecord
  belongs_to :suburb, optional: true
  belongs_to :postal_suburb, :class_name => 'Suburb', optional: true
end

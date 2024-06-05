# == Schema Information
#
# Table name: addresses
#
#  id      :bigint           not null, primary key
#  city    :string
#  state   :string
#  street  :string
#  zip     :string
#  user_id :bigint           not null
#
# Indexes
#
#  index_addresses_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Address < ApplicationRecord
  has_many :users
end

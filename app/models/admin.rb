# == Schema Information
#
# Table name: admins
#
#  id         :bigint           not null, primary key
#  email      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Admin < ApplicationRecord
end

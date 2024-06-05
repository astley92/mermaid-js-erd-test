# == Schema Information
#
# Table name: roles
#
#  id            :bigint           not null, primary key
#  assignee_type :string
#  type          :string
#  assignee_id   :bigint
#
# Indexes
#
#  index_roles_on_assignee  (assignee_type,assignee_id)
#
class Role < ApplicationRecord
  belongs_to :assignee, polymorphic: true
end

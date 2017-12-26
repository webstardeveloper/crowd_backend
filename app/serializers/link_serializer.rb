# == Schema Information
#
# Table name: links
#
#  id         :integer          not null, primary key
#  url        :string
#  project_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LinkSerializer < ActiveModel::Serializer
  attributes :id, :url
end

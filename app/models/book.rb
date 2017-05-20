class Book < ApplicationRecord
  belongs_to :user
  has_many :statuses

  def get_max_status
    max_status = self.statuses.order("status_code desc").limit(1)[0]
    max_status.status_code
  end

  def get_lapsed_days(status_code)
    (Time.now - self.statuses.find_by(status_code: status_code).created_at).to_i/(60*60*24)
  end
end

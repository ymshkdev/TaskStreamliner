class TaskShare < ApplicationRecord
  belongs_to :task
  belongs_to :team
end

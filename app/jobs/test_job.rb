class TestJob < ApplicationJob
  def perform
    puts 'Test job complete'
    Rails.logger.info 'Test job complete'
  end
end

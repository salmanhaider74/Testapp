# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.

require 'support/graphql'
require 'support/factory_bot'

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:expect, :should]
  end

  config.before do
    # stubs for encryption service
    EncryptionService.stub(:encrypt) { |plaintext| plaintext }
    EncryptionService.stub(:decrypt) { |binary_string| binary_string }
  end

  config.before do
    # stubs for dwolla service
    PaymentService::Service.any_instance.stub(:create_account).with(instance_of(DwollaAccount), boolean).and_return(true)
    PaymentService::Service.any_instance.stub(:create_funding_source).with(instance_of(DwollaAccount), instance_of(PaymentMethod)).and_return(true)
    PaymentService::Service.any_instance.stub(:initiate_micro_deposits).with(instance_of(PaymentMethod)).and_return(true)
    PaymentService::Service.any_instance.stub(:collect_payment).with(any_args).and_return({ status: 'processed', external_id: '1234', error: nil })
    PaymentService::Service.any_instance.stub(:payout).with(any_args).and_return({ status: 'processed', external_id: '1234', error: nil })

    allow_any_instance_of(Underwriting::Processors::Dnb::Client).to receive(:generate_token).and_return('123456789')
    Underwriting::Processors::Dnb::Client.any_instance.stub(:get_duns_number).with(any_args).and_return('123456789')
    Underwriting::Processors::Dnb::Client.any_instance.stub(:get_json_report).with(any_args).and_return({ "json": 'json_data' })
    Underwriting::Processors::Dnb::Client.any_instance.stub(:get_pdf_report).with(any_args).and_return('asdasdassdasdadaasda')

    Underwriting::Processors::Middesk::Client.any_instance.stub(:create_business).with(any_args).and_return('e9bfe3cb-149b-4f9b-a6f2-4177a98eac2b')
    Underwriting::Processors::Middesk::Client.any_instance.stub(:get_json_report).with(any_args).and_return({ "json": 'json_data' })
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if Rails.env.development?
  image_file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'logo.png'), 'image/png')
  AdminUser.create(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
  vendor = Vendor.create(name: 'Dummy Vendor App', domain: 'vendorapp.com', logo: image_file, favicon: image_file)
  User.create(email: 'vendor@venderapp.com', password: 'password', first_name: 'Vendor', last_name: 'App', vendor: vendor)
end

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
cmd = "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U $(whoami) -d little_shop_development db/data/little_shop_development.pgdump"
puts "Loading PostgreSQL Data dump into local database with command:"
puts cmd
system(cmd)

system("rails db:migrate")

Coupon.create([
    {name: "SUMMER24", code: "SUM24", percentage: false, active: true, amount_off: 10.00, merchant_id: 2},
    {name: "FALL24", code: "FAL24", percentage: false, active: true, amount_off: 20.00, merchant_id: 2},
    {name: "WINTER24", code: "WIN24", percentage: false, active: true, amount_off: 30.00, merchant_id: 2},
    {name: "SPRINT24", code: "SPR24", percentage: false, active: true, amount_off: 40.00, merchant_id: 2},
    {name: "SUMMER25", code: "SUM25", percentage: true, active: true, amount_off: 10.00, merchant_id: 2},
    {name: "FALL25", code: "FAL25", percentage: true, active: false, amount_off: 20.00, merchant_id: 2},
    {name: "SPRINT25", code: "SPR25", percentage: true, active: false, amount_off: 40.00, merchant_id: 2},
    {name: "WINTER25", code: "WIN25", percentage: true, active: false, amount_off: 30.00, merchant_id: 2},
    {name: "SUMMER25", code: "SUM25-1", percentage: true, active: true, amount_off: 10.00, merchant_id: 1},
    {name: "FALL25", code: "FAL25-1", percentage: true, active: false, amount_off: 20.00, merchant_id: 1},
    {name: "SPRINT25", code: "SPR25-1", percentage: true, active: true, amount_off: 40.00, merchant_id: 1},
    {name: "WINTER25", code: "WIN25-1", percentage: true, active: false, amount_off: 30.00, merchant_id: 1},
])


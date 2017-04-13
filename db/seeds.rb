require 'faker'

User.create(email: 'admin@example.com', password: 'wordpass',
            phone_number: ENV['BANDWIDTH_PHONE_NUMBER'])

20.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  phone_number = Faker::Number.numerify('1 555 ### ####')
  Contact.create(first_name: first_name, last_name: last_name,
                 phone_number: phone_number)
end

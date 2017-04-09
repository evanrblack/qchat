require 'faker'

User.create(email: 'admin@example.com', password: 'wordpass',
            phone_number: ENV['PLIVO_PHONE_NUMBER'])

20.times do
  name = Faker::Name.name
  phone_number = Faker::Number.numerify('1 555 ### ####')
  Contact.create(name: name, phone_number: phone_number)
end

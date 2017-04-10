Sequel.migration do
  change do
    create_table :users do
      primary_key :id

      String :email, null: false, unique: true
      String :password_hash, null: false
      String :phone_number, null: false, unique: true 

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    create_table :contacts do
      primary_key :id

      String :first_name
      String :last_name
      String :email
      DateTime :wedding_date
      String :phone_number, null: false, unique: true
      String :lead_source,
      String :notes, text: true

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    create_table :messages do
      primary_key :id

      String :external_id, null: false, unique: true
      String :source, null: false, index: true
      String :destination, null: false, index: true
      String :direction, null: false
      String :content, text: true, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index %i[source destination]
      index %i[destination source]
    end
  end
end

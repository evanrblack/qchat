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
      foreign_key :user_id, :users

      String :first_name
      String :last_name
      String :email
      Date :wedding_date
      String :phone_number, null: false
      String :lead_source
      String :notes, text: true

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index %i[id user_id], unique: true
      index %i[phone_number user_id], unique: true
    end

    create_table :messages do
      primary_key :id

      String :type, null: false
      String :direction, null: false
      String :external_id, unique: true
      String :from, null: false, index: true
      String :to, null: false, index: true
      String :text, text: true, null: false
      String :state, null: false
      DateTime :seen_at

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index %i[from to]
      index %i[to from]
    end
  end
end

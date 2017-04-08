Sequel.migration do
  change do
    create_table :users do
      primary_key :id

      String :email, null: false
      String :password_hash, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    create_table :contacts do
      primary_key :id

      String :first_name, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    create_table :messages do
      primary_key :id

      String :source, null: false
      String :destination, null: false
      String :direction, null: false
      String :content, text: true, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end

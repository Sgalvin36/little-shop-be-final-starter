# Little Shop | Final Project | Backend Starter Repo

## Setup

```ruby
bundle install
rails db:{drop,create}
rails runner ActiveRecord::Tasks::DatabaseTasks.load_seed
rails db:schema:dump
```

This repo uses a pgdump file to seed the database. Your `db:seed` command will produce lots of output, and that's normal. If all your tests fail after running `db:seed`, you probably forgot to run `rails db:schema:dump`. 

Run your server with `rails s` and you should be able to access endpoints via localhost:3000.

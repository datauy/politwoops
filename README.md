# Setting up the app

* Copy config/*.yml.sample and fill with the necessary values
  ```
  cp config/admin.yml.sample config/admin.yml
  ```
  ```
  cp config/database.yml.sample config/database.yml
  ```
  ```
  cp config/config.yml.sample config/config.yml
  ```
* Run ```bundle install``` to install all dependencies.
* Run ```rake db:setup```
* Run ```rake db:rollback```
* Run ```rake db:migrate```
* Run ```rake db:seed``` to load in a default group.

# Loading in data
* The project includes "politicos_uy.csv" which contains all the initial info to get twitter users
* Run ```rake politicians:import CSV="politicos_uy.csv"```
* Run ```rake politicians:reset_avatars```

*NOTE: after every new pull in server environment run ```RAILS_ENV=production rake assets:precompile```*

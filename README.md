# Bezel
A lightweight MVC framework inspired by Ruby on Rails.  
Check it out in action! My SuperMario browser game is built using it. [StochasticSuperMario](http://stochasticsupermario.com) [Github](https://github.com/keithm-thompson/StochasticSuperMario)

## Setup

If you have Ruby and PostgreSQL installed either:


1. clone the [StochasticSuperMario] (https://github.com/keithm-thompson/StochasticSuperMario) repo
2. run bundle install
3. open your favorite developer console
4. require 'Bezel' and any models you'd like to test with
5. play around!

### Or

1. gem install bezel-app
2. bezel-app new *App Name*
3. bezel-app db create
4. bezel-app g migration *migration name*
5. bezel-app db migrate
6. play around!

## Command Line Interface

* `bezel-app new [app name]`
* `bezel-app server`
  * `-p $PORT (defaults to 8080)`
* `bezel-app generate`
  * `model [model name]`
  * `controller [controller name]`
  * `migration [migration name]`
* `bezel-app db`
  * `create`
  * `migrate`
  * `seed`
  * `reset`
  
  
Database
--------

The bezel-app commands prefixed with 'db' interact with the Bezel Postgres database.
* `bezel-app db create` drops any Postgres DB named 'Bezel' and creates a new,
  empty one.
* `bezel-app db migrate` finds and any SQL files under db/migrate that have not
  been migrated and copies them into the DB.
* `bezel-app db seed` calls Seed::populate in db/seeds.rb, allowing you
  to quickly reset your DB to a seed file while in development.
* `bezel-app db reset` executes all three of the above commands, saving you
  time and energy!

Migrations
----------

Entering `bezel-app generate (or bezel-app g) migration [migration name]` in the
command line will create a time-stamped SQL file under db/migrations.
Write SQL in here to stage changes in the DB (add, drop, or change tables),
and `bezel-app db migrate` to implement them.

_*NB:*_ To reverse a migration that has been run, you must generate a new
migration that undoes the changes. Deleting the original migration will
do nothing.

`Bezel::ControllerBase`
---------------------

`Bezel::ControllerBase` connects your models to your routes, allowing
access to the DB through html.erb views.

Router
------

Routes live in config/routes.rb. New routes are written using Regex.
Open a server connection with the `bezel-app server` command.

Bezel Console
-------------

Access your DB with `Bezel::Bezelrecordbase` methods by simply entering
`require 'Bezel'` in Pry (or IRB).

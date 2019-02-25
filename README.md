# Trakt IMDB importer

[Trakt.tv](http://trakt.tv/) is a service where you can subscribe, rate, comments movies or TV shows. It also have integration with some multimedia app such as XBMC, KODI, etc. 

This script will import ratings from IMDB csv output and import it to Trakt.tv using their v2 API via OAuth.

The script is realtively simple < 106 lines of code. You can modify it according to your needs: 

* If you have some time out problem, you might want to reduce the batch (currently 20 shows/movies) per batch.
* You could also filter out TV Shows if you don't want to include them. Just modify the request 

Warning: The author doesn't guarantee anything including the outcome of the running the script. use at your own risk!.

## Known issue
* I Never check/tested ratings for individual episode of TV Shows.
* This script only copies ratings, the action to mark shows as watched has been removed.
* ~~If you rate a TV show on IMDB. it will mark all season as watched.~~

## Installing

clone the repository

**Make sure you have ruby * bundler installed**

Most osx already came with ruby installed. to check 

    $ ruby -v

to install [bundler](http://bundler.io/)

    $ gem install bundler 

    # or with sudo

    $ sudo gem install bundler -v 1.16.1


after bundler is install, download dependency with

    $ bundle install --path vendor/bundle

### Create Trakt.tv application

In order to use OAUTH, you need to create an application on trakt.tv

1. Go to  [Create Application on trakt.tv](https://trakt.tv/oauth/applications/new)
2. Enter Name & Description as you wish
3. Enter Redirect uri: `urn:ietf:wg:oauth:2.0:oob`
4. Tick checking & scrobble
5. Copy "Client ID" & "Client Secret"

### Setting OAUTH client in script

1. Copy `oauth_client.yml.dist` to `oauth_client.yml`
2. Fill in "Client ID" & "Client Secret" from Trakt.tv application

## Using the script

### Getting IMDB csv file.

1. Login to IMDB
2. Form "Your Name" drop down, select "Your Lists"
3. Select "Your Ratings" list
4. At the bottom of the page there is link "Export this list"
5. Save the file on your computer

### Run the application

suppose you have the csv file name 'imdb-ratings.csv' in the same directory as the project

execute 

    $ bundle exec ruby import.rb imdb-ratings.csv

1. On first use it will ask you to authorize:
  a. then ask you to open link in the browser. Login with your account and authorize the app.
  b. Copy the "OAUTH AUTHORIZATION CODE" to the terminal
2. It will then post all the ratings data from IMDB to trakt.

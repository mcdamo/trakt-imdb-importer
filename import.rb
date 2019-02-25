require 'oauth2'
require 'csv'
require 'yaml'

##
# Configuration
##
config = YAML.load(File.read('oauth_client.yml'))

if config['client_id'].empty? || config['client_secret'].empty?
  puts
  puts "  enter API client details in oauth_client.yml"
  puts
  exit 1
end

if ARGV.count < 1
  puts
  puts "  use bundle exec ruby import.rb imdb-filename.csv"
  puts
  exit 1
end

##
# Generate Session token
##
client =  OAuth2::Client.new(
  config['client_id'],
  config['client_secret'],
  :token_url => config['token_url'],
  :site => config['site']
)

begin
  token = OAuth2::AccessToken.from_hash(client, JSON.load(File.read('.oauth_token')))
  puts "Authenticated with saved access token"
rescue
  ## GET access token and ask user to copy
  auth_url = client.auth_code.authorize_url(:redirect_uri => config['redirect_uri'])

  puts
  puts "Open in browser:"
  puts auth_url
  puts
  print "OAuth Authorization Code : "
  auth_token = STDIN.gets.chomp

  token = client.auth_code.get_token(auth_token, :redirect_uri => config['redirect_uri'])

  # Store token for future
  File.open('.oauth_token', 'w') { |file| file.write(JSON.dump(token.to_hash)) }
end

headers = {
  'trakt-api-version' =>  '2',
  'trakt-api-key' =>  config['client_id'],
  'Content-Type' => 'application/json'
}

##
# Read from IMDB csv output and send in batch of 20 entries
##

# IMDB file is encoded in ISO-8859-1, convert internally to utf8
csv = CSV.read(ARGV[0], headers: true, encoding: 'ISO8859-1:utf-8')

nbatch = 20
total_record = csv.count

i = 0
uploaded = 0
csv.each_slice(20) do |batch|

  movies = []
  shows = []

  batch.each do |row|
    entry = {
      "rated_at" => Time.parse(row["Date Rated"]).strftime("%FT%T"),
      "rating"   => row["Your Rating"],
      "title"    => row["Title"],
      "year"     => row["Year"],
      "ids"      => {
        "imdb"   => row["Const"]
      }
    }

    ((row["Title Type"] == "tvSeries" || row["Title Type"] == "tvMiniSeries") ?  shows : movies).push entry
  end
  
  request = {
    body: {movies: movies, shows:shows}.to_json,
    headers: headers
  }

  # synchronize ratings
  response_ratings = token.post('sync/ratings', request)

  # synchronize watched
  #response_history = token.post('sync/history', request)

  if response_ratings && response_ratings.status == 201
    # && response_history && response_history.status == 201
    # success
    batch.each do |entry|
      puts "#{entry['Const']} - #{entry['Year']} #{entry['Title']} -> #{entry['Your Rating']}"
    end
  else
    puts "There is some error while sync data"
    puts "sync ratings resposne: #{response_ratings.status}"
    # sync history response: #{response_history.status}"
  end

  i += 1
  uploaded += batch.count
  puts "Uploaded #{uploaded}, #{(1.0 * i * nbatch / total_record * 100).to_i} %"
end

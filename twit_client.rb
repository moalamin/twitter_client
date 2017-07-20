
# TwitterClient Class
class TwitterClient
  require 'twitter'
  require 'pp'
  # Initialize with twitter API access information.
  # This should be the string of the name of the enviroment variable
  def initialize(consumer_key, consumer_secret, access_token, access_token_secret)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV[consumer_key]
      config.consumer_secret     = ENV[consumer_secret]
      config.access_token        = ENV[access_token]
      config.access_token_secret = ENV[access_token_secret]
    end
  end

  def unfollow_unfollowers
    friends = users_friend_ids
    followers = users_follower_ids

    friends.each_with_index do |friend, index|
      puts "Unfollowing #{index+1} of #{friends.length}"
      @client.unfollow(friend) unless followers.include?(friend)
      sleep 3
    end
  end

  def follow_by_query(query)
    users = search_tweets(query)
    follow_hashtag_users(users)
  end

  private

  def users_follower_ids
    all_followers = []
    followers_cursor = @client.follower_ids
    follower_ids_array = followers_cursor.attrs[:ids]
    all_followers.concat(follower_ids_array)
    all_followers
  end

  def users_friend_ids
    all_friends = []
    friends_cursor = @client.friend_ids
    friend_ids_array = friends_cursor.attrs[:ids]
    all_friends.concat(friend_ids_array)
    all_friends
  end

  def search_tweets(search_query)
    tweets = @client.search(search_query, result_type: 'recent', count: 100, lang: "en")
    tweets.attrs[:statuses].map { |status| status[:user][:id] }
  end

  def follow_hashtag_users(users)
    users.each_with_index do |user, index|
      begin
        puts "AT INDEX: #{index}"
        @client.follow(user)
      rescue
        puts "RATE LIMIT REACHED AT: ---#{Time.now}---"
        sleep(960)
        puts "RATE LIMITED -- retrying: #{index}"
        retry
      end
    end
  end
end

client = TwitterClient.new('TWITTER_CONSUMER_KEY',
                           'TWITTER_CONSUMER_SECRET',
                           'TWITTER_ACCESS_TOKEN',
                           'TWITTER_ACCESS_TOKEN_SECRET')

# follow from an array
['#javascript', '#ruby', '#reactjs', '#html', '#fifa'].each do |topic|
  client.follow_by_query(topic)
end

# unfollow those who don't follow back
# client.unfollow_unfollowers

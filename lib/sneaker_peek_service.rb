require 'bunny'

class SneakerPeekService
  attr_reader :twitter_object

  def initialize(twitter_object)
    @twitter_object = twitter_object
  end

  def publish!
    return if twitter_object.nil?

    exchange = channel.direct("twitter_object_components")
    exchange.publish(payload, routing_key: queue.name, persistent: true)
    connection.close
  end

  private

  def payload
    twitter_object.to_json
  end

  def connection
    @conn ||= begin
      conn = Bunny.new(ENV["CLOUDAMQP_URL"].presence)
      conn.start
    end
  end

  def channel
    @channel ||= connection.create_channel
  end

  def queue
    @queue ||= channel.queue("twitter-object-#{twitter_object.keys.first}", durable: true)
  end
end

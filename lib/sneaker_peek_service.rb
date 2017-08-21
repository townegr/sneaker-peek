require 'bunny'

class SneakerPeekService
  attr_reader :twitter_entity

  def initialize(twitter_entity_id)
    @twitter_entity = TwitterEntity.find_by_id twitter_entity_id
  end

  def publish
    return if twitter_entity.nil?

    exchange = channel.direct("twitter_entity_analytics")
    exchange.publish(payload, routing_key: queue.name, persistent: true)
    connection.close
  end

  private

  def payload
    match.to_json
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
    @queue ||= channel.queue("twitter_entity-#{twitter_entity.id}", durable: true)
  end
end

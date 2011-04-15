require 'bundler'
Bundler.require(:default)
require 'active_support/core_ext'

module ParisPictureSchool
  class Application < Sinatra::Base
    enable :static
    set :path, File.join(File.dirname(__FILE__), 'views')
    set :public, File.join(File.dirname(__FILE__), 'public')

    helpers do
      def local_time(time, timezone)
        ActiveSupport::TimeZone.new(timezone).parse(time)
      end
      def event_link(slug)
        "http://parispictureschool.eventwax.com/" + slug
      end
    end

    get '/' do
      @events = JSON.parse(RestClient.get("https://" + ENV['PARISPICTURESCHOOL'] + "@secure.eventwax.com/api/events.json"))

      @events.each do |e|
        session = e['event_sessions'].first
        tz = e['time_zone']['info']['identifier']
        tix_remaining    = session['capacity'].to_i - session['attendees'].length.to_i
        e['local_start'] = local_time session['starts_on'], tz
        e['local_end']   = local_time session['ends_on'], tz
        e['sold_out']    = (tix_remaining == 0) ? true : false
      end

      haml :index
    end
  end
end

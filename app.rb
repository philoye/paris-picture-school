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
        zone = ActiveSupport::TimeZone.new(timezone)
        DateTime.parse(time).in_time_zone(zone)
      end
    end

    get '/' do
      @events = JSON.parse(RestClient.get("https://" + ENV['PARISPICTURESCHOOL'] + "@secure.eventwax.com/api/events.json"))

      @events.each do |e|
        session = e['event_sessions'].first
        tz = e['time_zone']['info']['identifier']
        tix_remaining    = session['capacity'].to_i - session['attendees'].length.to_i
        e['local_date']  = session['starts_on']
        e['local_start'] = session['starts_on']
        e['local_end']   = session['ends_on']
        e['sold_out']    = (tix_remaining == 0) ? true : false
      end

      haml :index
    end
  end
end

require 'bundler'
Bundler.require(:default)
require 'active_support/core_ext'

module ParisPictureSchool
  class Application < Sinatra::Base
    enable :static
    set :path, File.join(File.dirname(__FILE__), 'views')
    set :public, File.join(File.dirname(__FILE__), 'public')
    enable :logging if development?
    set :haml, :format => :html5
    Sass::Plugin.options['/tmp']

    helpers do
      def local_time(time, timezone)
        ActiveSupport::TimeZone.new(timezone).parse(time)
      end
      def future? (date, timezone)
        t = ActiveSupport::TimeZone.new(timezone)
        return t.parse(date) >= t.today
      end
    end

    get '/' do
      haml :index
    end

    get '/events.json' do
      content_type :json
      events = JSON.parse(RestClient.get("https://" + ENV['PARISPICTURESCHOOL'] + "@secure.eventwax.com/api/events.json"))
      @events = []
      events.each do |e|
        session = e['event_sessions'].first
        tix_remaining    = session['capacity'].to_i - session['attendees'].length.to_i
        tz = e['time_zone']['info']['identifier']
        event = {
          :name     => e['name'],
          :location => e['location'],
          :link     => "http://parispictureschool.eventwax.com/" + e['uri'] + "/register",
          :date     => local_time(session['starts_on'], tz).strftime('%e %b %Y').strip,
          :start    => local_time(session['starts_on'], tz).strftime('%l:%M%P').strip,
          :end      => local_time(session['ends_on'], tz).strftime('%l:%M%P').strip,
          :sold_out => ((tix_remaining == 0) ? true : false)
        }
        @events.push event if future?(session['starts_on'], tz)
      end
      @events.sort_by! {|event| Date.parse(event[:date]) }
      @events.to_json
    end

  end
end

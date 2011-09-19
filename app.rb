require 'bundler'
Bundler.require(:default)
require 'active_support/core_ext'

module ParisPictureSchool
  class Application < Sinatra::Base

    configure do
      enable :static
      set :path, File.join(File.dirname(__FILE__), 'views')
      set :public, File.join(File.dirname(__FILE__), 'public')
      set :haml, :format => :html5
    end
    configure :development do
      enable :logging
      set :sass, :cache => false
    end
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
      response.headers['Cache-Control'] = 'public, max-age=900'
      haml :index
    end

    get '/events.json' do
      response.headers['Cache-Control'] = 'public, max-age=60'
      content_type :json

      request = RestClient::Request.new :url=>'https://parispictureschool:manon181206@secure.eventwax.com/api/events.json',:method=>:get, :timeout=>300000
      events = JSON.parse request.execute
      @events = []
      events.each do |e|
        tix_remaining    = e['capacity'].to_i - e['attendees'].length.to_i
        tz = e['time_zone']['info']['identifier']
        event = {
          :name     => e['name'],
          :location => e['location'],
          :link     => "http://parispictureschool.eventwax.com/" + e['uri'] + "/register",
          :date     => local_time(e['starts_on'], tz).strftime('%e %b %Y').strip,
          :start    => local_time(e['starts_on'], tz).strftime('%l:%M%P').strip,
          :end      => local_time(e['ends_on'], tz).strftime('%l:%M%P').strip,
          :sold_out => ((tix_remaining == 0) ? true : false)
        }
        @events.push event if future?(e['starts_on'], tz)
      end
      @events.sort_by! {|event| Date.parse(event[:date]) }
      @events.to_json
    end

  end
end

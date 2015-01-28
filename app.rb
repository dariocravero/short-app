require 'sinatra/base'

class App < Sinatra::Base
  BASE_HOST         = ENV['BASE_HOST']    || 'http://s.uxtemple.com'
  CODE_LENGTH       = ENV['CODE_LENGTH']  || 3
  # TODO Make it dependent on CODE_LENGTH
  CODE_HEX_PATTERN  = 0xfff
  CODE_REGEX        = /^[0-9a-z]{#{CODE_LENGTH}}$/i

  set :urls, {}
  set :protection, except: :path_traversal

  get '/*' do
    uoc = params[:splat].first

    if uoc =~ CODE_REGEX
      redirect code_to_url uoc
    else
      code = url_to_code uoc
      halt 404 unless code
      "#{BASE_HOST}/#{code}"
    end
  end

  helpers do
    def code_from_url lookup_url
      match = settings.urls.find { |code, url| lookup_url == url }
      match && match.first
    end

    def code_to_url code
      settings.urls[code.downcase]
    end

    def url_to_code url
      code = code_from_url url

      if code.nil?
        code = random_code
        while settings.urls.include? code
          code = random_code
        end
      end

      settings.urls[code] = url
      code
    end

    def random_code
      "%0#{CODE_LENGTH}x" % (rand * CODE_HEX_PATTERN)
    end
  end
end

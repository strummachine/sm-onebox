class Onebox::Engine::StrumMachineListOnebox
  include Onebox::Engine
  include Onebox::LayoutSupport
  
  matches_regexp(/^(https?:\/\/(beta\.|old\.)?strummachine\.com|https?:\/\/flamboyant-wind-09397\.pktriot\.net)\/app\/lists\/.+/)
  always_https

  protected
  
  def data
    # return @data if @data
    meta_data = get_meta_data
    if (meta_data[:"sort-method"] || "a") == "a"
      songs = meta_data[:songs].sort do |a,b|
        a[:title].downcase.gsub(/^(the|an?) /, '') <=> b[:title].downcase.gsub(/^(the|an?) /, '')
      end
    else
      songs = meta_data[:songs]
    end
    @data = {
      link: "https://strummachine.com/app/lists/#{meta_data[:id]}",
      title: meta_data[:title] || "List Not Found",
      songs: songs,
      song_count: songs.size,
      owner: meta_data[:owner],
    }
    @data
  end
  # Onebox::Helpers.truncate(meta_data[:author], 250)

  def transform_song_json(song)
    return {
      :id => song["_id"],
      :title => song["name"].gsub(/ +\[.+\]$/, '').gsub(/(^|[-\u2014\s(\["])'/, "$1\u2018").gsub(/'/, "\u2019"),
      :subtitle => song["name"].match(/ \[(.+)\]$/) { |m| m[1] },
      :user_first => song["userFirst"],
      :user_last => song["userLast"],
    }
  end

  def get_meta_data
    response = Onebox::Helpers.fetch_response(url, 10) rescue nil
    html = Nokogiri::HTML(response)
    meta_data = {}
    html.css('meta').each do |m|
      if m.attribute('property') && m.attribute('property').to_s.match(/^sm-list:/i)
        m_content = m.attribute('content').to_s.strip
        m_property = m.attribute('property').to_s.gsub(/^sm-list:/i, '')
        meta_data[m_property.to_sym] = m_content
      end
    end
    html.xpath('//script[@id="sm-list-songs-data"]').each do |m|
      json = CGI.unescape(m.text)
      song_data = ::MultiJson.load(json)
      meta_data[:songs] = song_data.map { |song| transform_song_json(song) }
    end
    Rails.logger.warn(meta_data.inspect)
    meta_data
  end

end
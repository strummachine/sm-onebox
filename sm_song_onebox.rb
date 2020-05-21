class Onebox::Engine::StrumMachineSongOnebox
  include Onebox::Engine
  include Onebox::LayoutSupport
  
  matches_regexp(/^(https?:\/\/(beta\.|old\.)?strummachine\.com|https?:\/\/flamboyant-wind-09397\.pktriot\.net)\/app\/songs\/.+/)
  always_https

  protected
  
  def data
    # return @data if @data
    meta_data = get_meta_data
    meta_data[:title] = "Song Not Found" unless meta_data[:title]
    title = meta_data[:title].gsub(/ +\[.+\]$/, '').gsub(/(^|[-\u2014\s(\["])'/, "$1\u2018").gsub(/'/, "\u2019")
    subtitle = meta_data[:title].match(/ \[(.+)\]$/) { |m| m[1] }
    @data = { 
      link: "https://strummachine.com/app/songs/#{meta_data[:id]}",
      title: title,
      subtitle: subtitle,
      author: meta_data[:author],
    }
    @data
  end
  # Onebox::Helpers.truncate(meta_data[:author], 250)

  def get_meta_data
    response = Onebox::Helpers.fetch_response(url, 10) rescue nil
    html = Nokogiri::HTML(response)
    meta_data = {}
    html.css('meta').each do |m|
      if m.attribute('property') && m.attribute('property').to_s.match(/^sm-song:/i)
        m_content = m.attribute('content').to_s.strip
        m_property = m.attribute('property').to_s.gsub(/^sm-song:/i, '')
        meta_data[m_property.to_sym] = m_content
      end
    end
    meta_data
  end

end
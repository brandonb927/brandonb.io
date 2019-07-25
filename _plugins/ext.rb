module Jekyll
  class RenderPictureElement < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup
    end

    def render(context)
      site = context.registers[:site]
      page = context.environments.first['page']

      @base_url = site.config['baseurl']
      @site_url = site.config['url']

      if page['layout'].eql? 'post'
        page_year = page['date'].strftime('%Y')
        page_month = page['date'].strftime('%m')
        @media_root = "#{site.config['assets_media']}/#{page['layout']}s/#{page_year}/#{page_month}"
      else
        @media_root = "#{site.config['assets_media']}/#{page['layout']}s"
      end

      @attributes = {}

      @markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = value.gsub(/^'|"/, '').gsub(/'|"$/, '')
      end

      # Get the 1x path
      @image1x = @attributes['src']
      alt_text = @attributes['alt'] ? "alt=\"#{@attributes['alt']}\"" : ''

      if @image1x.include? "http" or @image1x.include? "https"
        """
        <picture>
          <source data-srcset=\"#{@image1x}\">
          <img src=\"#{@image1x}\"
               srcset=\"data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7\"
               data-sizes=\"auto\"
               data-srcset=\"#{@image1x}\"
               class=\"styled-image lazyload\" #{alt_text}>
        </picture>
        """.strip
      else
        # Special case for gifs, just pass them through
        if @image1x.end_with? ".gif"
          @image1x = "#{@media_root}/#{@image1x}"
        else
          # Build the 2x image path from the 1x path
          @image2x_array = @image1x.split('.')
          filename2x = "#{@image2x_array[0]}@2x"
          @image2x = "#{filename2x}.#{@image2x_array[1]}"

          # Replace the images with the proper urls
          @image1x = "#{@media_root}/#{@image1x}"
          @image2x = "#{@media_root}/#{@image2x}"
        end

        """
        <picture>
          <source data-srcset=\"#{@image1x}, #{@image2x} 2x\">
          <img src=\"#{@image1x}\"
               srcset=\"data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7\"
               data-sizes=\"auto\"
               data-srcset=\"#{@image1x}, #{@image2x} 2x\"
               class=\"styled-image lazyload\" #{alt_text}>
        </picture>
        """.strip
      end
    end
  end

  class RenderVideoElement < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup
    end

    def render(context)
      site = context.registers[:site]
      page = context.environments.first['page']

      @base_url = site.config['baseurl']
      @site_url = site.config['url']

      if page['layout'].eql? 'post'
        page_year = page['date'].strftime('%Y')
        page_month = page['date'].strftime('%m')
        @media_root = "#{site.config['assets_media']}/#{page['layout']}s/#{page_year}/#{page_month}"
      else
        @media_root = "#{site.config['assets_media']}/#{page['layout']}s"
      end

      @attributes = {}

      @markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = value.gsub(/^'|"/, '').gsub(/'|"$/, '')
      end

      @attr_src = @attributes['src']
      @attr_height = @attributes['height'] ? @attributes['height'] : 320

      # Replace the images with the proper urls
      @src_path = "#{@media_root}/#{@attr_src}"

      """
      <video width=\"100%\" height=\"#{@attr_height}\" controls>
        <source src=\"#{@src_path}\" type=\"video/mp4\"/>
        <p>Hmm, your browser doesn't seem to support HTML5 video. <a href=\"#{@src_path}\">You can download this video instead</a>.</p>
      </video>
      """.strip
    end
  end
end

Liquid::Template.register_tag('picture', Jekyll::RenderPictureElement)
Liquid::Template.register_tag('video', Jekyll::RenderVideoElement)

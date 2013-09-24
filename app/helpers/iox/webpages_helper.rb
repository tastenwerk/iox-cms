module Iox
  module WebpagesHelper

    def get_page_views_today
      views = 0
      Iox::WebpageStat.where( day: Time.now.to_date ).each do |page|
        views += page.views
      end
      views
    end

    def get_page_visitors_today
      visits = 0
      Iox::WebpageStat.where( day: Time.now.to_date ).each do |page|
        visits += page.visits
      end
      visits
    end

    def get_views
      from, to, views = get_from_to_visits

      puts [from, to, views.inspect]
      Iox::WebpageStat.where( "day > '#{from.to_date}' AND day < '#{to.to_date}'" ).each do |page|
        if @page_stat_range.nil? || @page_stat_range == 'year'
          views[page.day.month-1][1] += page.views
        elsif @page_stat_range == 'month'
          views[page.day.day-1][1] += page.views
        elsif @page_stat_range == 'week'
          views[page.day.wday-1][1] += page.views
        end
      end
      views
    end

    def get_visitors
      from, to, visits = get_from_to_visits
      Iox::WebpageStat.where( "day > '#{from.to_date}' AND day < '#{to.to_date}'" ).each do |page|
        if @page_stat_range.nil? || @page_stat_range == 'year'
          visits[page.day.month-1][1] += page.visits
        elsif @page_stat_range == 'month'
          visits[page.day.day-1][1] += page.visits
        elsif @page_stat_range == 'week'
          visits[page.day.wday-1][1] += page.visits
        end
      end
      visits
    end

    def get_from_to_visits
      from = Time.now.beginning_of_year
      to = Time.now.end_of_year
      views = (1..12).map{ |m| [m,0] }
      if @page_stat_range
        case @page_stat_range
        when 'month'
          from = Time.now.beginning_of_month
          to = Time.now.end_of_month
          views = (1..31).map{ |m| [m,0] }
        when 'week'
          from = Time.now.beginning_of_week
          to = Time.now.end_of_week
          views = (1..7).map{ |m| [m,0] }
        end
      end
      [ from, to, views ]
    end

    #
    # list available webpage_templates
    # in app/views/iox/webpages/templates
    # directory
    def available_webpage_templates( translate=nil )
      tmpl_list = []
      Dir.glob( File.join( Rails.root, 'app', 'views', 'iox', 'webpages', 'templates', '_*.html.erb') ).sort.each do |tmpl_filename|
        next if tmpl_filename.include?('_form.html.erb')
        tmpl_filename = File.basename(tmpl_filename.sub('.html.erb',''))[1..-1]
        trans_tmpl_filename = translate == :translate ? I18n.t("webpage.templates.#{tmpl_filename}") : tmpl_filename
        tmpl_list << [trans_tmpl_filename, tmpl_filename]
      end
      tmpl_list
    end

    #
    # return all template_form view paths
    # if a view path cannot be found, the default_form will
    # be returned instead
    def available_webpage_form_templates
      tmpl_list = []
      Dir.glob( File.join( Rails.root, 'app', 'views', 'iox', 'webpages', 'templates', '_*.html.erb') ).sort.each do |tmpl_filename|
        tmpl_list << File.basename(tmpl_filename).sub('.html.erb','')[1..-1] unless tmpl_filename.include?('_form.html.erb')
      end
      tmpl_list.map! do |tmpl|
        filename = File.join( Rails.root, 'app', 'views', 'iox', 'webpages', 'templates', '_'+tmpl+'_form.html.erb' )
        { file: (File::exists?( filename ) ? "/iox/webpages/templates/#{tmpl}_form" : "/iox/webpages/templates/default_form"),
          name: tmpl }
      end
      tmpl_list
    end

    #
    # list available languages for this website
    #
    # this is configured in the application.rb file
    # of the actual application via the
    # iox.available_langs array
    #
    def available_webpage_langs( translate=nil )
      langs = []
      Rails.configuration.iox.available_langs.sort.each do |lang|
        langs << [(translate == :translate ? I18n.t("langs.#{lang}") : lang), lang]
      end
      langs
    end

    #
    # gets translation of this webbit or webpage
    #
    def get_translation( wb )
      return '' if wb.nil?
      l =  @webpage.lang || I18n.default_locale
      wb.translations.where(locale: l).first
    end

    def get_translation_content( wb )
      return '' if wb.nil?
      if t = get_translation( wb )
        return t.content
      end
      ''
    end

    def get_required_webbits
      arr = []
      @webpage.webbits.each do |wb|
        arr << wb.plugin_type unless arr.include? wb.plugin_type
      end
      arr
    end

  end
end

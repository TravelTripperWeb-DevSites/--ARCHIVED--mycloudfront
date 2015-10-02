# Generate pages from individual records in yml files
# (c) 2014 Adolfo Villafiorita
# Distributed under the conditions of the MIT License

module Jekyll
  class DataPage < Page
    def initialize(site, base, dir, data, name, template)
      @site = site
      @base = base
      @dir = dir
      @name = sanitize_filename(name) + ".html"

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), template + ".html")
      self.data.merge!(data)
      self.data['title'] = data[name]
    end

    private

    # strip characters and whitespace to create valid filenames, also lowercase
    def sanitize_filename(name)
      return name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end
  end

  class DataPagesGenerator < Generator
    safe true

    def generate(site)
      data = site.config['page_gen']
      if data
        data.each do |data_spec|
          # todo: check input data correctness
          template = data_spec['template'] || data_spec['data']
          dir = data_spec['dir'] || data_spec['data']
          
          if site.layouts.key? template
            records =  site.data[data_spec['data']]
            records.each do |record|
              page = DataPage.new(site, site.source, dir, record[1], record[0], template)
              site.pages << page
            end
          else
            puts "error. could not find #{data_file}" if not File.exists?(data_file)
            puts "error. could not find template #{template}" if not site.layouts.key? template
          end
        end
      end
    end 
  end

  module DataPageLinkGenerator
    # use it like this: {{input | datapage_url: dir}}
    # output: dir / input .html
    def datapage_url(input, dir)
      dir + "/" + sanitize_filename(input) + ".html"
    end

    private

    # strip characters and whitespace to create valid filenames, also lowercase
    def sanitize_filename(name)
      return name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end
  end

end

Liquid::Template.register_filter(Jekyll::DataPageLinkGenerator)

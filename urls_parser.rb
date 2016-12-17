require 'mechanize'
require 'pry'

urls_file = File.open(File.expand_path('../urls', __FILE__), 'w+')

@sources = ['http://platesmania.com/by/gallery.php?&region=1031',
            'http://platesmania.com/by/gallery.php?&region=1032',
            'http://platesmania.com/by/gallery.php?&region=1033',
            'http://platesmania.com/by/gallery.php?&region=1034',
            'http://platesmania.com/by/gallery.php?&region=1035',
            'http://platesmania.com/by/gallery.php?&region=1036',
            'http://platesmania.com/by/gallery.php?&region=1037']

REGIONS = 7

(1..REGIONS).each do |region|
  url = "http://platesmania.com/by/regionstat-#{region}"
  mechanize = Mechanize.new

  page = mechanize.get(url)

  links = page.css('table').last.css('tr td:nth-child(3) a')

  links.each do |link|
    href = link.attributes['href'].value
    @sources << "http://platesmania.com/by/#{href}"
  end
end

@sources.each do |source|
  mechanize = Mechanize.new

  (1..100).each do |page_num|
    url = "#{source}&start=#{page_num}"

    puts url

    list_page = mechanize.get(url)
    links = list_page.css('.panel-body .text-center a')

    links.each do |link|
      href = link.attributes['href'].value
      urls_file.puts("http://platesmania.com#{href}") if href =~ /nomer/
    end
  end
end

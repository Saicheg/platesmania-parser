require 'mechanize'
require 'pry'

class PageParser
  OUT_FOLDER = File.expand_path('../out', __FILE__)

  def initialize
    @logger = Logger.new(File.expand_path('../page-log', __FILE__))
  end

  def parse_page(url)
    mechanize = Mechanize.new
    @logger.info("Opening #{url}")

    number = URI.parse(url).path.split('/').last
    folder = File.join(OUT_FOLDER, number)

    if Dir.exists?(folder)
      @logger.info("Skipping #{url}")
      return
    else
      FileUtils.mkdir(folder)
    end

    page = mechanize.get(url)

    license_number = page.css('.breadcrumbs h1').text.strip
    car_image = page.css('.panel-body .row img').first.attributes['src'].value
    plate_image = page.css('.panel-body > img').first.attributes['src'].value

    File.open(File.join(folder, 'value'), 'w+') { |f| f.write(license_number) }

    tries = 5

    File.open(File.join(folder, 'car_image_url'), 'w') { |f| f.write(car_image) }
    extension = car_image.split('.').last

    begin
      tries -= 1

      if tries <= 0
        @logger.info("#{number}: #{car_image} - breaking")
        break
      else
        @logger.info("#{number}: #{car_image} - trying")
      end

      result = mechanize.download(car_image, File.join(folder, "car.#{extension}"))
    end while(result.code != '200')

    tries = 5

    File.open(File.join(folder, 'plate_image_url'), 'w') { |f| f.write(plate_image) }
    extension = plate_image.split('.').last

    begin
      tries -= 1

      if tries <= 0
        @logger.info("#{number}: #{plate_image} - breaking")
        break
      else
        @logger.info("#{number}: #{plate_image} - trying")
      end

      result = mechanize.download(plate_image, File.join(folder, "plate.#{extension}"))
    end while(result.code != '200')

  rescue Exception => e
    @logger.error e.message
  end
end

urls = File.readlines(File.expand_path('../urls', __FILE__))

uniq_urls = urls.uniq.map(&:strip)


threads = []

binding.pry

uniq_urls.each_slice(1000).each do |group|
  threads << Thread.new(group) do |g|
    parser = PageParser.new

    g.each do |url|
    # group.each do |url|
      parser.parse_page(url)
    end
  end
end

threads.each(&:join)


class Scrappeur
  attr_accessor :hash_villes_emails, :ville_email_array, :ville_name_array

  def initialize
    @hash_villes_emails = []
    @ville_email_array = []
    @ville_name_array = []
  end

  def get_ville
    # Régister URL of the needed website
    page_url_region = "https://www.annuaire-des-mairies.com/val-d-oise.html"

    region_page = Nokogiri::HTML(open(page_url_region))

    # From the website, get an array of the city name, convert it to string, put in downcase and replace " " to "-" if any space
    @ville_name_array = region_page.xpath("//a[contains(@class, 'lientxt')]/text()").map {|x| x.to_s.downcase.gsub(" ", "-") }
  end


  # This function return the email of each cities
  def get_email (ville_names)

    # Loop on each cities in the array to get the email
    for n in 0...ville_names.length

      # get each link to the depute
      page_url_ville = "https://www.annuaire-des-mairies.com/95/#{ville_names[n]}.html"

      ville_page = Nokogiri::HTML(open(page_url_ville))

      # If any bug when trying to get any email
      begin

        # Put each email in an array "ville_email_array"
        @ville_email_array << ville_page.xpath("//html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]/text()").to_s
      rescue => e

        @ville_email_array << " "
      end
    end

    # This value as to be returned.
    # If not this not show email in the json file for the function save_as_json
    return @ville_email_array
  end

  # function to save data in a json file
  def save_as_json
    File.open("db/emails.json","w") do |f|
      f.write(JSON.pretty_generate(@hash_villes_emails))
    end
  end

  # function to save data in a google spreadsheet
  def save_as_spreadsheet
    i = 1

    # Creates a session. This will prompt the credential via command line for the
    # first time and save it to config.json file for later usages.
    session = GoogleDrive::Session.from_config("../../config.json")

    # Put the key from the google spreadsheet you whant to use
    ws = session.spreadsheet_by_key("14NaBtVAdrbCF6CSlLhrBM0Ob9nE96zvyrwKNkSF3oIY").worksheets[0]

    # Puts cities and cities emails in 2 colones
    for y in 0...@ville_name_array.length
      ws[i, 1] = @ville_name_array[y]
      ws[i, 2] = @ville_email_array[y]
      i += 1
    end
    ws.save

    # Reloads the worksheet to get changes by other clients.
    ws.reload
  end

  # This methode is used to register data in a CSV file
  # For mor information go to https://www.rubyguides.com/2018/10/parse-csv-ruby/
  def save_as_csv
    CSV.open("db/emails.csv", "wb") do |csv|
      for i in 0...@ville_name_array.length
        csv << [@ville_name_array[i], @ville_email_array[i]]
      end
    end
  end

  def perform
    # Merge ville array with email array
    get_mails =
    @hash_villes_emails = Hash[get_ville.zip(get_email(get_ville))]
    save_as_json
    save_as_spreadsheet
    save_as_csv
  end
end

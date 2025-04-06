module ApplicationHelper
  def format_date(date)
    if !date.blank?
      date.strftime("%B %-d, %Y")
    end
  end
  
  def country_code_to_emoji(country_code)
    # Convert 2-letter country code to flag emoji
    # Country code characters are converted to regional indicator symbols
    country_code.upcase.chars.map { |c| (c.ord + 127397).chr(Encoding::UTF_8) }.join
  end
end

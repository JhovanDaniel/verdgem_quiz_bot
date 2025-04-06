module ApplicationHelper
  def format_date(date)
    if !date.blank?
      date.strftime("%B %-d, %Y")
    end
  end
  
  def country_code_to_emoji(country_code)
    return "" if country_code.blank?
    
    # Convert 2-letter country code to flag emoji
    # Each country code character is converted to a regional indicator symbol
    # (offset by 127397 from the ASCII value)
    country_code.upcase.chars.map { |c| (c.ord + 127397).chr(Encoding::UTF_8) }.join
  end
end

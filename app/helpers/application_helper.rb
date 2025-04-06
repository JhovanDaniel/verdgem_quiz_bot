module ApplicationHelper
  def format_date(date)
    if !date.blank?
      date.strftime("%B %-d, %Y")
    end
  end
  
  def country_code_to_emoji(country_code)
    return "" if country_code.blank?
    
    # Ensure we have exactly 2 characters
    code = country_code.to_s.strip.upcase[0..1]
    return "" unless code.length == 2
    
    # Convert to regional indicator symbols
    base = 127462 - 65  # Regional Indicator Symbol Letter A - 'A'
    code.bytes.map { |b| [base + b].pack('U') }.join
  end
end

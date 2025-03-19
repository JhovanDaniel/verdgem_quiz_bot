module ApplicationHelper
  def format_date(date)
    if !date.blank?
      date.strftime("%B %-d, %Y")
    end
  end
end

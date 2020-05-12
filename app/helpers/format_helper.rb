module FormatHelper

  def dynamic_time_format(date_time)
    if date_time.today?
      date_time.strftime "%l:%M%P"
    elsif date_time.year == DateTime.now.year
       date_time.strftime "%m/%d"
     else
      date_time.strftime "%m/%d/%y"
    end
  end

  # 01/24
  def compact_date(date_time)
    date_time.strftime "%m/%d"
  end

  # 01/24/15
  def short_date(date_time)
    date_time.strftime "%m/%d/%y"
  end

  # 01/24/15 1:23pm
  def short_date_time(date_time)
    date_time.strftime "%m/%d/%y %l:%M%P"
  end

  def short_date_time_spacing(date_time)
    capture do 
      concat date_time.strftime "%m/%d"
      concat raw " &#8226; "
      concat date_time.strftime "%l:%M%P"
    end
  end

  def long_date_time(date_time)
    date_time.strftime "%m/%d/%Y %l:%M%P"
  end

  def long_date(date_time)
    date_time.strftime "%m/%d/%Y"
  end

  def standard_time(date_time)
    date_time.strftime "%l:%M%P"
  end

  #converts a date range array back to string to persist select options
  def date_range_to_string(date_range)
    "%s - %s" % [date_range[0], date_range[1]] rescue nil 
  end


  def short_time_zone(tz)
    Time.now.in_time_zone(tz).strftime('%Z')
  end

  def integer_range_to_string(integer_range)
    "%s - %s" % [integer_range[0].to_i, integer_range[1].to_i] rescue nil 
  end
end

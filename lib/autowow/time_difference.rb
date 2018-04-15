require "time_difference"

module RefinedTimeDifference
  refine(TimeDifference) do
    def humanize_higher_than(limit)
      limit_index = TimeDifference::TIME_COMPONENTS.index(limit)

      diff_parts = []
      in_general.each_with_index do |array, index|
        part, quantity = array
        next if (quantity <= 0) || (limit_index < index)
        part = part.to_s.humanize

        if quantity <= 1
          part = part.singularize
        end

        diff_parts << "#{quantity} #{part}"
      end

      last_part = (diff_parts.pop or "")
      if diff_parts.empty?
        return last_part
      else
        return [diff_parts.join(", "), last_part].join(" and ")
      end
    end
  end
end

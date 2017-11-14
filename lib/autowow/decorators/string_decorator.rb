module StringDecorator
  class ::String
    def reverse_chomp(str)
      reverse.chomp(str.reverse).reverse
    end

    def clean_lines
      each_line.map(&:strip).reject(&:empty?)
    end
  end
end

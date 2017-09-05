module StringDecorator
  class ::String
    def reverse_chomp(str)
      reverse.chomp(str.reverse).reverse
    end
  end
end

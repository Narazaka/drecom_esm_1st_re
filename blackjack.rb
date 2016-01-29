class Card
  attr_reader :number, :mark

  def initialize(number:, mark:)
    @number = number
    @mark = mark
  end
end

class Cards < Array
  def point
    is_1, not_1 = partition {|card| card.number == 1}
    is_1_count = is_1.count
    min_point = is_1_count + not_1.inject(0) {|sum, card| sum + card.number}
    if is_1_count > 0 && min_point + 10 <= 21
      min_point + 10
    else
      min_point
    end
  end
end

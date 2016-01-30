require 'rspec'

class Game
  def initialize(players = [])
    @players = players
  end

  def self.initial_cards
    [:heart, :spade, :clover, :diamond].map do |mark|
      (1 .. 13).map do |number|
        Card.new(number: number, mark: mark)
      end
    end.flatten
  end

  def self.shuffler(cards)
    cards.shuffle
  end

  def setup_cards(shuffler = Game.method(:shuffler))
    @all_cards = shuffler.call(Game.initial_cards)
    return # 中身を知られてはいけない
  end

  def initial_deal
    @players.each do |player|
      player.cards << deal
    end
  end

  def start
    setup_cards
    initial_deal
  end

end

describe Game do
  describe "#setup_cards" do
    let(:game) {Game.new}
    it {expect(game.setup_cards)}
  end
end

class Player
  attr_reader :cards
  def initialize
    @cards = Cards.new
  end
end

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

describe Cards do
  describe "#point" do
    subject {cards.point}
    context do
      let(:cards) { Cards.new([1, 1, 10].map {|n| Card.new(number: n, mark: :spade)}) }
      it { is_expected.to eq 12 }
    end
    context do
      let(:cards) { Cards.new([1, 10].map {|n| Card.new(number: n, mark: :spade)}) }
      it { is_expected.to eq 21 }
    end
  end
end

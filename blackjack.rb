# Coding: utf-8
Encoding.default_external = Encoding::UTF_8
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
    2.times do
      @players.each do |player|
        player.cards << deal
      end
    end
  end

  def start(shuffler = Game.method(:shuffler))
    setup_cards(shuffler)
    initial_deal
    additional_deal
    detect_winner
  end
  
  def additional_deal
    @players.each do |player|
      while player.want_deal?
        player.cards << deal
      end
    end
  end

  def detect_winner
    @players.sort_by {|player| player.cards.point}.last
  end

  def deal
    @all_cards.pop
  end

end

describe Game do
  describe "#start" do
    shuffler = lambda {|cards| cards}
    let(:players) {[Player.new, Player.new]}
    let(:game) {Game.new(players)}
    subject {game.start(shuffler)}
    it {is_expected.to eq players.last}
  end
end

class Player
  attr_reader :cards

  def initialize
    @cards = Cards.new
  end

  def want_deal?
    point = cards.point
    0 <= point && point < 16
  end
end

describe Player do
  let(:player) {Player.new}
  describe "#want_deal?" do
    subject{player.want_deal?}
    context "buta" do
      before do
        player.cards << Card.new(number: 10, mark: :spade)
        player.cards << Card.new(number: 10, mark: :spade)
        player.cards << Card.new(number: 10, mark: :spade)
      end
      it {is_expected.to be_falsey}
    end
    context "not buta and >= 16" do
      before do
        player.cards << Card.new(number: 10, mark: :spade)
        player.cards << Card.new(number: 10, mark: :spade)
      end
      it {is_expected.to be_falsey}
    end
    context "not buta and < 16" do
      before do
        player.cards << Card.new(number: 10, mark: :spade)
        player.cards << Card.new(number: 5, mark: :spade)
      end
      it {is_expected.to be_truthy}
    end
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
    if min_point > 21
      -1
    elsif is_1_count > 0 && min_point + 10 <= 21
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
    context do
      let(:cards) { Cards.new([2, 10, 10].map {|n| Card.new(number: n, mark: :spade)}) }
      it { is_expected.to eq -1 }
    end
  end
end

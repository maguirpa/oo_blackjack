require 'pry'
SUITS = ['Hearts', 'Diamonds', 'Clubs', 'Spades']
FACE_VALUE = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace']

class Card
  attr_accessor :suit, :face_value

  def initialize(s, fv)
    @suit = s
    @face_value = fv
  end

  def pretty_output
    "The #{face_value} of #{suit}"
  end

  def to_s
    pretty_output
  end

end

class Deck
    attr_accessor :cards

  def initialize
    @cards = []
    SUITS.each do |suit|
      FACE_VALUE.each do |face_value|
        @cards << Card.new(suit, face_value)
      end
    end
    scramble!
  end

  def scramble!
    cards.shuffle!
  end

  def deal_one
    cards.pop
  end

  def size
    cards.size
  end

end

module Hand

  def show_hand
    puts "\n-----#{name}'s Hand------"
    cards.each do |card|
      puts "=> #{card}"
    end
    puts "=> #{name}'s total is #{total}"
  end

  def total
    face_values = cards.map {|card| card.face_value }

    total = 0
    face_values.each do |val|
      if val == 'Ace'
        total += 11
      else
        total += (val.to_i == 0 ? 10 : val.to_i)
      end
    end
    face_values.select{|val| val == 'Ace'}.count.times do 
      break if total <= 21
      total -= 10
    end
    total
  end

  def add_card(new_card)
    cards << new_card
  end

  def is_busted?
    total > 21
  end

  def blackjack?
    total == 21
  end

end

class Player
  include Hand
  attr_accessor :name, :cards

  def initialize(name)
    @name = name
    @cards = []
  end

end

class Dealer
  include Hand
  attr_accessor :name, :cards

  def initialize
    @name = "Dealer"
    @cards = []
  end

  def initial_show_hand
    puts "\n-----#{name}'s Hand------"
    puts "=> Facedown card."
    puts "=> #{cards[1]}"
  end
end

class Game
    attr_accessor :deck, :player, :dealer
    @@player_wins = 0
    @@dealer_wins = 0

  def initialize
    system 'clear'
    @deck = Deck.new
    @player = Player.new(' ')
    @dealer = Dealer.new
  end

  def initial_deal
    2.times do
      @player.add_card(@deck.deal_one)
      @dealer.add_card(@deck.deal_one)
    end
    player.show_hand
    dealer.initial_show_hand
  end

  def player_intro
    puts "-----Welcome to Blackjack-----"
    puts "What is your name?"
    player.name = gets.chomp
  end

  def player_prompt
    loop do
      puts "Would you like to stay(s) or hit(h)?"
      @answer = gets.chomp.downcase
      break if @answer == 's' || @answer == 'h'
    end
  end

  def player_turn
    begin
      player_prompt
      if @answer == 'h'
        new_card = @deck.deal_one
        player.add_card(new_card)
        puts "\n#{player.name} dealt the #{new_card}."
        player.show_hand
      end
    end until player.is_busted? || @answer == 's'
  end

  def dealer_turn
    begin
      if dealer.total <= 17
        new_card = @deck.deal_one
        dealer.add_card(new_card)
        puts "\n#{dealer.name} dealt the #{new_card}."
      end
    end until dealer.total >= 17
  end

  def display_results
    puts "\n-----Game Results------"
    puts "#{player.name}'s total is #{player.total}."
    puts "#{dealer.name}'s total is #{dealer.total}."
    bust?
  end

  def bust?
    if player.is_busted?
      puts "#{player.name} is busted."
    elsif dealer.is_busted?
      puts "#{dealer.name} is busted."
    end
  end

  def display_blackjack_win
    if player.blackjack? && dealer.blackjack?
      puts "Two blackjacks!"
      puts "It's a draw"
    elsif player.blackjack?
      puts "#{player.name} has Blackjack!"
      puts "#{player.name} wins!"
      @@player_wins += 1
    elsif dealer.blackjack?
      dealer.show_hand
      puts "#{dealer.name} has Blackjack!"
      puts "#{dealer.name} wins!"
      @@dealer_wins += 1
    end
  end

  def winner?
    display_results
    if player.is_busted?
      puts "#{dealer.name} wins!"
      @@dealer_wins += 1
    elsif dealer.is_busted?
      puts "#{player.name} wins!"
      @@player_wins += 1
    elsif player.total == dealer.total 
      puts "It's a draw."
    elsif player.total < dealer.total
      puts "#{dealer.name} wins!"
      @@dealer_wins += 1
    else
      puts "#{player.name} wins!"
      @@player_wins += 1
    end
  end  

  def play_again?
    puts "Press any key to play again or 'n' to quit."
    play_again = gets.chomp
  end

  def reset
    player.cards = []
    dealer.cards = []
  end

  def player_totals
    puts "Total wins for #{player.name}: #{@@player_wins}."
    puts "Total wins for Dealer: #{@@dealer_wins}."
  end


  def play
    player_intro
    loop do
      system 'clear'
      initial_deal
      if player.blackjack? || dealer.blackjack?
        display_blackjack_win
      else
        player_turn
        if !player.is_busted?
          dealer_turn
        end
        dealer.show_hand
        winner?
      end 
      break if play_again? == 'n'
      reset 
    end
    player_totals
    puts "Thanks for playing!"
    binding.pry
  end

end

Game.new.play










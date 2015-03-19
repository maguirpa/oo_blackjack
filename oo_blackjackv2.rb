class Card
    attr_accessor :face_value, :suit

  def initialize(face_value, suit)
    @face_value = face_value
    @suit = suit
  end

  def to_s
    "=> The #{face_value} of #{suit}"
  end
end

class Deck
  FACE_VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace']
  SUITS = ['Diamonds', 'Hearts', 'Spades', 'Clubs']
  attr_accessor :cards

  def initialize
    @cards = []
    FACE_VALUES.map do |face|
      SUITS.map do |suit|
        @cards << Card.new(face, suit)
      end
    end
    shuffle
  end

  def shuffle
    cards.shuffle!
  end

  def deal_one
    cards.pop
  end

end

module Hand

  def total
    values = cards.map {|card| card.face_value}
    
    total = 0
    values.each do |value|
      if value == 'Ace'
        total += 11
      elsif value.to_i == 0
        total += 10
      else 
        total += value.to_i
      end
    end
      values.select {|card| card == 'Ace'}.count.times do
        total -= 10 if total > 21
      end
    total
  end

  def add_card(new_card)
    cards << new_card
  end

  def bust?
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

  def show_cards
    puts "\n------Player Hand-------"
    puts cards
    puts "=> Card total: #{total}"
  end

end

class Dealer
  include Hand
  attr_accessor :cards, :name

  def initialize
    @name = "Dealer"
    @cards = []
  end

  def show_cards_initial
    puts "\n------Dealer Hand-------"
    puts "=> Facedown card"
    puts cards[1]
  end

  def show_cards_final
    puts "\n------Dealer Hand-------"
    puts cards
    puts "=> Card total: #{total}"
  end

end

class Game
  include Hand
  attr_accessor :deck, :player, :dealer, :prompt_answer
  
  def initialize
    @deck = Deck.new
    @player = Player.new('Patrick')
    @dealer = Dealer.new
    @prompt_answer = ' '
  end

  def initial_deal
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
  end


  def initial_display
    system 'clear'
    initial_deal
    player.show_cards
    dealer.show_cards_initial
  end

  def stay_or_hit_prompt
    begin
      puts "Would you like to hit(h) or stay(s)?"
      @prompt_answer = gets.chomp
    end until ['s','h'].include?(prompt_answer) 
    prompt_answer
  end

  def player_turn
    begin
      stay_or_hit_prompt
      if prompt_answer == 'h'
        player_turn_display
      end
    end until player.bust? || prompt_answer == 's'
    system 'clear'
    player.show_cards
    display_busted
    dealer.show_cards_initial
  end

  def player_turn_display
    system 'clear'
    new_card = deck.deal_one
    player.add_card(new_card)
    player.show_cards
    puts "\n#{player.name} dealt #{new_card}"
    dealer.show_cards_initial
  end

  def dealer_turn
    begin
      if dealer.total <= 17
        new_card = deck.deal_one
        dealer.add_card(new_card)
        puts "\n#{dealer.name} dealt #{new_card}"
        puts "....."
        sleep(1)
      end
    end until dealer.bust? || dealer.total > 17
    dealer_turn_display
  end

  def dealer_turn_display
    system 'clear'
    player.show_cards
    dealer.show_cards_final
  end

  def display_busted
    if player.bust?
      puts "\n#{player.name} busted!"
    elsif dealer.bust?
      puts "\n#{dealer.name} busted!"        
    end
  end

  def display_blackjack
    if player.blackjack? && dealer.blackjack?
      puts "\nTwo blackjacks!! Wow!"
      puts "It's a draw."
    elsif player.blackjack?
      puts "\n#{player.name} hit Blackjack."
    elsif dealer.blackjack?
      puts "\n#{dealer.name} hit Blackjack."
    end
  end

  def display_winner
    if player.bust?
      puts "\n#{dealer.name} wins!"
    elsif dealer.bust?
      puts "\n#{player.name} wins!"
    elsif player.total == dealer.total   
      puts "\nIt's a draw."
    elsif player.total > dealer.total
      puts "\n#{player.name} wins!"
    elsif dealer.total > player.total
      puts "\n#{dealer.name} wins!"
    end
  end

  def final_display
    system 'clear'
    player.show_cards
    display_busted
    display_winner
    dealer.show_cards_final
  end   

  def play_again
    puts "Press any key to play again or 'n' to quit."
    answer = gets.chomp
  end

  def play
    initial_display
    if player.blackjack? || dealer.blackjack?
      final_display
      display_blackjack
    else
      player_turn
      if !player.bust?
        dealer_turn
      end
    final_display
    end
    if play_again != 'n'
      Game.new.play
    end
  end

end


Game.new.play







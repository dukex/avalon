class Game
  attr_reader :players

  ALIGNMENT_PROPORTION = {
    5 =>  { good: 3, evil: 2 },
    6 =>  { good: 4, evil: 2 },
    7 =>  { good: 4, evil: 3 },
    8 =>  { good: 5, evil: 3 },
    9 =>  { good: 6, evil: 3 },
    10 => { good: 6, evil: 4 }
  }

  def initialize(players, shuffle = true)
    @players = shuffle ? players.shuffle : players
    # TODO: Consider creating a custom error class
    raise 'The game needs from 5 to 10 players' if invalid_players_count?

    @quests = Quests.new(players.count)
    assign_roles
  end

  def start
    print_introduction
    current_king = -1

    while !@quests.end? && current_king <= 3
      current_king += 1
      king = players[current_king]
      puts "#{current_king + 1}o turno"
      puts "#{king.name} é o rei"
      current_quest = @quests.next_quest
      puts "O rei precisa escolher #{current_quest.party_size} cavaleiros para uma missão"

      Counsel.new(king, counselors(king), current_quest).start

      puts
    end
  end

  def good_team
    @players.select { |player| player.character.good? }
  end

  def evil_team
    @players.select { |player| player.character.evil? }
  end

  def merlin
    @players.find { |player| player.character.is_a? Characters::Merlin }
  end

  def assassin
    @players.select { |player| player.character.is_a? Characters::Assassin }
  end

  private

  def invalid_players_count?
    players.count > 10 || players.count < 5
  end

  def assign_roles
    players.each do |player|
      player.character = random_character(roles)
    end
  end

  def roles
    @roles ||= begin
      valid_roles = [Characters::Merlin.new, Characters::Assassin.new]
      alignment_proportion = ALIGNMENT_PROPORTION[players.count]

      # Includes good generic characters to fill the good characters capacity
      (alignment_proportion[:good] - 1).times { |_| valid_roles << Characters::LoyalServantOfArthur.new }

      # Includes evil generic characters to fill the evil characters capacity
      (alignment_proportion[:evil] - 1).times { |_| valid_roles << Characters::MinionOfMordred.new }

      valid_roles
    end
  end

  def random_character(roles)
    chosen = rand(0..roles.length - 1)
    roles.delete_at(chosen)
  end

  def counselors(king)
    players.reject { |player| player == king }
  end

  # Simulation methods below. They probably can be removed after the game is properly tested
  def print_introduction
    bullets = '*' * 30
    puts "#{bullets} Avalon #{bullets}"
    puts "Estrelando: "
    puts
    players.each do |player|
      puts "* #{player.name}, como #{player.character.name}"
    end
    puts
    puts "\"A cidade dorme..."
    puts "Os minions de Mordred acordam e se reconhecem"
    puts "(#{evil_team.map(&:name).join(' / ')} abrem os olhos)."
    puts "Os maus voltam a dormir."
    puts "Todos estendem o braço com o punho fechado."
    puts "Os maus erguem o polegar :thumbsup:"
    puts "O Merin acorda e reconhece seus inimigos"
    puts "(#{merlin.name} abre os olhos)."
    puts "Merlin fecha os olhos e a cidade volta a dormir.\""
    puts "#{bullets}********#{bullets}"
    puts
  end
end

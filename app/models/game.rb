class Game
  attr_reader :players

  MAX_ALLOWED_PLAYERS = 10
  MIN_ALLOWED_PLAYESR = 5
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
      puts "#{current_king + 1}o turno".yellow
      puts "#{king.name} é o rei"
      current_quest = @quests.next_quest
      puts "O rei precisa escolher #{current_quest.party_size} cavaleiros para uma missão"

      knights = Counsel.new(king, counselors(king), current_quest).summon_the_knights
      knights.embark_on_a_quest(current_quest)

      puts
    end

    line = '-' * 70
    if @quests.good_won?
      if assassin.character.guessed_who_is_merlin?(players)
        puts line.red
        puts '|              O bem estava para triunfar sobre o mal, mas...        |'.yellow
        print '|                       O Merlin foi '.yellow
        print 'ASSASSINADO!                    |'.red
        puts
        puts '|                     AS TREVAS VENCERAM A LUZ                       |'.red
        puts line.red
      else
        puts line.green
        puts '|                   O BEM TRIUNFOU SOBRE O MAL                       |'.green
        puts line.green
      end
    else
      puts line.red
      puts '|                     AS TREVAS VENCERAM A LUZ                       |'.red
      puts line.red
    end
  end

  def good_team
    @good_team ||= @players.select { |player| player.character.good? }
  end

  def evil_team
    @evil_team ||= @players.select { |player| player.character.evil? }
  end

  def merlin
    @merlin ||= @players.find { |player| player.character.is_a? Characters::Merlin }
  end

  def assassin
    @assassin ||= @players.find { |player| player.character.is_a? Characters::Assassin }
  end

  private

  def invalid_players_count?
    ! players.count.between?(MIN_ALLOWED_PLAYESR, MAX_ALLOWED_PLAYERS)
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
    chosen = Dice.roll(0...roles.length)
    roles.delete_at(chosen)
  end

  def counselors(king)
    players.reject { |player| player == king }
  end

  # Simulation methods below. They probably can be removed after the game is properly tested
  def print_introduction
    puts
    puts '    / \__   ____ _| | ___  _ __  '.green
    puts "   / _ \\ \\ / / _` | |/ _ \\| '_ \\ ".green
    puts '  / ___ \ V / (_| | | (_) | | | |'.green
    puts ' /_/   \_\_/ \__,_|_|\___/|_| |_|'.green
    puts

    bullets = '*' * 30
    puts "Estrelando: "
    puts
    players.each do |player|
      puts "* #{player.name}, como #{player.character.name}"
    end
    puts
    puts "\"A cidade dorme...".yellow
    puts "Os minions de Mordred acordam e se reconhecem".yellow
    puts "(#{evil_team.map(&:name).join(' / ')} abrem os olhos)."
    puts "Os maus voltam a dormir.".yellow
    puts "Todos estendem o braço com o punho fechado.".yellow
    puts "Os maus erguem o polegar :thumbsup:".yellow
    puts "O Merin acorda e reconhece seus inimigos".yellow
    puts "(#{merlin.name} abre os olhos)."
    puts "Merlin fecha os olhos e a cidade volta a dormir.\"".yellow
    puts "#{bullets}********#{bullets}"
    puts
  end
end

require 'io/console'
require 'date'

def valid_date?(input)
  begin
    Date.parse(input)
    true
  rescue ArgumentError, TypeError
    false
  end
end

def clear_console
  system("clear") || system("cls")
end

def write_to_file(nickname, guess_count, answer, date_time)
  if File.exist?("scores.txt")
    File.open("scores.txt", "a") do |f|
      f.write("#{nickname},#{guess_count},#{answer},#{date_time}\n")
    end
  else
    File.open("scores.txt", "w") do |f|
      f.write("nickname,guesses,random_num,date\n")
      f.write("#{nickname},#{guess_count},#{answer},#{date_time}\n")
    end
  end
end

def get_scores_from_file
  if File.exist?("scores.txt")
    file = File.open("scores.txt")
    file_data = file.readlines.map(&:chomp).map{|s| s.split(",")}
    file.close
    file_data
  else
    []
  end

end

def put_scores_by_date(file_data)
  puts "\nType your dates in format: 'from to'(yyyy-mm-dd yyyy-mm-dd) or \nType 'today' to see scores from today or \nType 'all' to see all scores."
  dates = gets.chomp
  from = dates.split(" ")[0]
  to = dates.split(" ")[1]
  date_scores = []

  if dates == "today" || dates == "all"
    case dates
    when "today"
      date_scores = file_data.map { |el| el if
        Date.parse(el[3].split(" ")[0]) == Date.parse(Time.now.to_s.split(" ")[0])}.compact
                             .sort{|a,b| a[1].to_i <=> b[1].to_i}
    when "all"
      date_scores = file_data.sort{|a,b| a[1].to_i <=> b[1].to_i}
    end
  elsif valid_date?(from) && valid_date?(to)
      date_scores = file_data.map { |el| el if
        Date.parse(from) <= Date.parse(el[3].split(" ")[0]) && Date.parse(el[3].split(" ")[0]) <= Date.parse(to)}.compact
                             .sort{|a,b| a[1].to_i <=> b[1].to_i}

  else
    puts "Invalid input."
    return
  end
  put_scores(date_scores)

end

def put_scores(data)
  clear_console
  puts "LEADER BOARD: "
  if data.length >= 1
    i=0
    puts "lp   nickname   guesses  random_num         date"
    data.each do |item|
      message = "%d. %s %s %s %s %s %s" %[i+=1,"".ljust(3-i.to_s.length), item[0].rjust(5).ljust(12), item[1].ljust(9), item[2].ljust(7), item[3].split(" ")[0],item[3].split(" ")[1]]
      puts message
    end
  else
    puts "Nothing to show"
  end

end

class GuessingGame

  def initialize
    @low = 1
    @max = 100
    @answer = rand(@low..@max)
  end

  def min
    @low
  end
  def max
    @max
  end


  def start_game
    clear_console
    while true
      output = game
      if output == -1
        puts("bye")
        break
      end
      if output == "Hit"
        save_game
        puts "Do you want to play again? (y/n)"
        response = gets.chomp
        if response.match(/^(y|ye|yes|Y|YE|YES)/)
          clear_console
          @answer = rand(@low..@max)
          @guess_count = 0
        else
          puts("bye")
          break
        end
      end
    end
  end

  def game
    @guess_count ||= 0
    while true
      guess = ask_for_guess
      if guess.match(/^(q|Q|quit|QUIT)/)
        return -1
      end
      output = check_guess(guess.to_i)
      if output == -1
        return -1
      end
      if output.match(/^(Hit|Higher|Lower)/)
          @guess_count += 1
      end
      puts output
      if output == "Hit"
        break
      end
    end
    output
  end

  def ask_for_guess
    puts "Guess a number between #{@low} and #{@max} (enter 'q' to quit):"
    gets.chomp
  end

  def check_guess(guess)

    unless valid_input?(guess)
      return 'Error: Input not valid.'
    end
    if guess < @answer
      return "Higher"
    elsif guess > @answer
      return "Lower"
    else
      return "Hit"
    end
  end
    end

  def save_game
    puts "Enter your nickname:"
    nickname = gets.chomp
    date_time = Time.now
    write_to_file(nickname,@guess_count,@answer,date_time)

  end

  private
  def valid_input?(guess)
    if guess < @low || guess > @max
      return false
    end

    unless guess.is_a?(Integer)
      return false
    end

    true
  end


class GuessingGameBot

  def initialize
    @game = GuessingGame.new
  end

  def play
    @guess_count = 0
    low = @game.min
    high = @game.max
    while low <= high
      guess = (low  + high) / 2
      puts "Guess a number between #{@game.min} and #{@game.max}:"
      puts guess
      output = @game.check_guess(guess)
      puts output
      @guess_count += 1
      if output == "Hit"
        break
      elsif output == "Higher"
        low = guess + 1
      elsif output == "Lower"
        high = guess - 1
      end
    end
    save_game(guess)
  end

  def save_game(guess)
    nickname = "bot"
    date_time = Time.now
    write_to_file(nickname,@guess_count,guess,date_time)

  end
end

$selected_index = 0
def menu
  menu_items = ['Play Guessing game', 'Make bot play Guessing game', 'Show "n" scores from Leader Board',
                'Show Leader Board only with specific nicknames from specific date', 'Show Leader Board from specific dates']
  while true
    clear_console

    puts 'Menu: (press "q" to quit, control menu either with "w" and "s" or arrows)'
    menu_items.each_with_index do |item, index|
      if index == $selected_index
        puts "  > #{item}"
      else
        puts "    #{item}"
      end
    end
    key = STDIN.getch
    case key

    when "\e[1;5A", "\uE048","\e[A", "w"
      # Up arrow key
      $selected_index -= 1
      $selected_index = menu_items.size - 1 if $selected_index < 0

    when "\e[1;5B", "\uE050", "\e[B" , "s"
      # Down arrow key
      $selected_index += 1
      $selected_index = 0 if $selected_index >= menu_items.size

    when "q"
      $selected_index = -1

      break
    when "\r"
      break

    end

    $selected_index = 0 if $selected_index < 0
    $selected_index = menu_items.size - 1 if $selected_index >= menu_items.size
  end
end

while true
  menu
  clear_console if $selected_index != -1
  case $selected_index
  when -1
    puts "bye"
    break
  when 0
    GuessingGame.new.start_game
    puts "\npress enter to continue"
    gets
  when 1
    n = false

    until n
      puts "how many times bot should play? "
      n = Integer(gets) rescue false

    end
    n.to_i.times do
      GuessingGameBot.new.play
    end
    puts "\npress enter to continue"
    gets

  when 2
    n = false
    until n
      puts "How many scores would you like to see? "
      n = Integer(gets) rescue false
    end

    file_data = get_scores_from_file
    if file_data.length>1
      sorted_data = file_data.slice(1, file_data.length).sort{|a,b| a[1].to_i <=> b[1].to_i}.slice(0,n.to_i)
    else
      sorted_data = []
    end
    put_scores(sorted_data)

    puts "\npress enter to continue"
    gets
  when 3
    puts "Type nicknames here: "
    nicknames = gets.chomp.split(" ")
    file_data = get_scores_from_file
    nicknames_scores = file_data.slice(1,file_data.length).map{|el| el if nicknames.include?(el[0])}.compact
    if nicknames_scores.length>0
      put_scores_by_date(nicknames_scores)
    else
      puts "Nothing to show"
    end
    puts "\npress enter to continue"
    gets
  when 4
    file_data = get_scores_from_file
    put_scores_by_date(file_data.slice(1,file_data.length))
    puts "\npress enter to continue"
    gets
  end
end
# $results = {}
$min = 1
$max = 10


def clear_console
  system("cls") || system("clear")

end
def check_guess(guess)
  if guess > $rand_num
    "Too big"
  else
    if guess < $rand_num
      "Too small"
    else
      "hit"
    end
  end
end

def get_guess
  puts("Type your guess: ")
  gets
end

def game_logic
  clear_console
  $rand_num = rand($min..$max)
  guesses = 0
  puts("Guess random chosen number. 'quit' ends game")
  guess_message = ""

  while guess_message != "hit" do
    guess = get_guess
    if guess.downcase == "quit\n"
      puts("bye")
      return 0
    end
    guess_message = check_guess(guess.to_i)
    guesses += 1
    puts(guess_message)
  end
  guesses
end

def save_score(guesses)
  puts("Type your nickname to save score")
  name = gets.chop
  # if $results[name]
  #   $results[name].append(guesses)
  # else
  #   $results[name] = [guesses]
  # end
  open("scores.txt", 'a') do |f|
    f.puts("#{name},#{guesses},#{$rand_num}")
  end
end

def play_again
  clear_console
  valid_input = false
  until valid_input
    puts("Play again? [Y/N]")
    decision = gets.downcase.chop
    decision_array = %w[y yes n no]

    if decision_array.include? decision
      valid_input = true
      if decision == "y" || decision == "yes"
        return true
      else
        if decision == "n" || decision == "no"
          puts("bye")
          return false
        end
      end
    else
      puts("wrong decision")
    end
  end
end
def start_game
  game_on = true

  while game_on do
    guesses = game_logic
    if guesses == 0
      return
    end
    save_score(guesses)
    game_on = play_again

  end
end
start_game


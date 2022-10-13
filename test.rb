$results = {}
$min = 1
$max = 10

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

def start_game
  $rand_num = rand($min..$max)
  guesses = 0
  puts("Guess random chosen number.\n'quit' ends program")
  guess_message = ""

  while guess_message != "hit" do
    guess = get_guess
    if guess == "quit\n"
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
  if $results[name]
    $results[name].append(guesses)
  else
    $results[name] = [guesses]
  end
  open("scores.txt", 'a') do |f|
    f.puts("#{name},#{guesses},#{$rand_num}")
  end
  # File.write("scores.txt","#{name},#{guesses},#{$rand_num}" , 'a')
end

game_on = true

while game_on do
  guesses = start_game
  if guesses == 0
    break
  end
  save_score(guesses)

  good_input = false

  until good_input
    puts("Play again? [Y/N]")
    decision = gets.downcase.chop
    decision_array = %w[y yes n no]

    if decision_array.include? decision
      good_input = true
      if decision == "y" || decision == "yes"
        guesses = start_game
        if guesses == 0
          break
        end
        save_score(guesses)
      else
        if decision == "n" || decision == "no"
          game_on = false
          puts("bye")
        end
      end
    else
      puts("wrong decision")
    end
  end

end


require 'psych'
require "yaml"
class Hangman
    attr_accessor :word, :unknown_word, :lives, :use_word

    def initialize
        @word = generate_word.downcase
        @unknown_word = '_' * @word.chomp.length
        @lives = 5
        @use_word = String.new
    end
    
    def start
        puts "Game: Hangman. Welcome"
        puts "Menu"
        puts "1. New game"
        puts "2. Load game"
        choose_game
    end
    
    def request_guess
        while @lives > 0
        puts @unknown_word
        print "You use: #{@use_word}\n"
        puts "Enter a letter: "
        guess = gets.downcase.chomp
        save_game if guess == 'save'
        if @use_word.include?(guess) || guess.length > 1 || !('a'..'z').include?(guess)
            puts "Error. Check your letter, or letter is already exist."
            request_guess
        end 
        check(guess)
        break if win? 
        end
        game_over_message
    end
    private
    def check(guess)
        if good_guess = @word.include?(guess)
            puts "Good guess!"
            @use_word << guess + ' '
                @word.length.times do |i|
                    if guess == @word[i]
                        @unknown_word[i] = guess 
                    end
                end   
        else
            @lives -= 1
            @use_word << guess + ' '
            puts "Sorry... you have #{@lives} lives left. try again!"  
        end
    end

    def win?
        true if @unknown_word.split == @word.split
    end

    def game_over_message
        puts "You WIN!!. Correct answear #{@word}" if win?
        puts "You lose :(. Correct answer is #{@word}." if !win?
        exit
    end

    def generate_word
        game_word = Array.new
        contents = File.read('words.txt')
        contents.each_line do |word| #generate and check word
            if word.chomp.length <= 12 && word.chomp.length >= 5
                game_word << word
            end
        end
        game_word.sample #random element from array
    end

    def choose_game
        x = gets.chomp.to_i
        if x == 1
            request_guess
        elsif x == 2
           load_game
           request_guess
        else
            p "Invalid input. Choose again" 
            choose_game
        end
    end

    def save_game
        puts "Enter name of your save file:"
        save_file = gets.chomp
        Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
        YAML.dump({'word' => @word,
        'unknown_word'=> @unknown_word,
        'lives'=> @lives,
        'use_word'=> @use_word}, File.open("./saved_games/#{save_file}.yml", 'w'))
        exit
    end
    
    def load_game
        unless Dir.exist?('saved_games')
            puts "No saved games. Choose new game.\n"
            sleep(2)
            start
        end
        puts "Choose a file. Saved games:"
        puts Dir['./saved_games/*'].map { |file| file.split('/')[-1].split('.')[0]}
        filename = gets.chomp
        yaml_file = YAML::load(File.read("./saved_games/#{filename}.yml"))
        @word = yaml_file['word']
        @unknown_word = yaml_file['unknown_word']
        @lives = yaml_file['lives']
        @use_word = yaml_file['use_word']
        
    end      
end

hangman = Hangman.new
hangman.start

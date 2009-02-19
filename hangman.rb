require 'hpricot'

Shoes.app(:title => "Hangman!", 
          :width => 450, :height => 600, 
          :resizable => false) do
  
  @hanged = [
    proc { oval 300, 125, 50 }, # head 
    proc { line 325, 175, 325, 275 }, # body
    proc { line 325, 200, 275, 200 }, # left arm
    proc { line 325, 200, 375, 200 }, # right arm
    proc { line 325, 275, 300, 350 }, # left leg
    proc { line 325, 275, 350, 350 } # right leg
  ]
  
  def get_random_word
    doc = Hpricot(open("http://watchout4snakes.com/creativitytools/RandomWord/RandomWord.aspx"))
    @word = doc.at("#tmpl_main_lblWord").html.upcase
    @distinct = []
    @word.scan(/./) { |c| @distinct << c }
    @distinct.uniq!
  end
  
  def update_secret
    buf = "" 
    @word.scan(/./) { |c|
      buf << (@good_guesses.include?(c) ? c : "_ ")
    }
    @secret.text = buf
  end

  def guessed?
    @good_guesses.size == @distinct.size
  end
  
  def guess(char)
    if @word.include?(char)
      @good_guesses << char
      update_secret
      if guessed?
        confirm("You are a genius! One more?") ? start : exit
      end
    else
      @hanged[@bad_guesses.size].call # draw hangman body part
      @bad_guesses << char
      if @bad_guesses.size == @hanged.size
        @secret.text = @word
        confirm("You are dead! Try again?") ? start : exit
      end
    end
  end

  def start
    clear
    stroke chocolate
    fill yellow
    strokewidth 4
    @good_guesses = []
    @bad_guesses = []
    background "hangman.jpg"
    get_random_word
    stack {
      caption "Take a guess!"
      @secret = caption("_ " * @word.size)
      flow(:top => 510) {
        ("A".."Z").each { |l|
          button(l) { |b|
            b.state = 'disabled'
            guess(l)
          }
        }
      }
    }
  end
  
  start
end

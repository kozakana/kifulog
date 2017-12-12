require 'google/cloud/bigquery'
require './db'
require 'yaml'

PIECE_MAP = {
  'a' => "\u001b[32m玉\u001b[0m",
  'b' => "\u001b[32m飛\u001b[0m",
  'c' => "\u001b[32m角\u001b[0m",
  'd' => "\u001b[32m金\u001b[0m",
  'e' => "\u001b[32m銀\u001b[0m",
  'f' => "\u001b[32m桂\u001b[0m",
  'g' => "\u001b[32m香\u001b[0m",
  'h' => "\u001b[32m歩\u001b[0m",
  'i' => "\u001b[32m竜\u001b[0m",
  'j' => "\u001b[32m馬\u001b[0m",
  'k' => "\u001b[32m全\u001b[0m",
  'l' => "\u001b[32m圭\u001b[0m",
  'm' => "\u001b[32m杏\u001b[0m",
  'n' => "\u001b[32mと\u001b[0m",
  'A' => "\u001b[31m王\u001b[0m",
  'B' => "\u001b[31m飛\u001b[0m",
  'C' => "\u001b[31m角\u001b[0m",
  'D' => "\u001b[31m金\u001b[0m",
  'E' => "\u001b[31m銀\u001b[0m",
  'F' => "\u001b[31m桂\u001b[0m",
  'G' => "\u001b[31m香\u001b[0m",
  'H' => "\u001b[31m歩\u001b[0m",
  'I' => "\u001b[31m竜\u001b[0m",
  'J' => "\u001b[31m馬\u001b[0m",
  'K' => "\u001b[31m全\u001b[0m",
  'L' => "\u001b[31m圭\u001b[0m",
  'M' => "\u001b[31m杏\u001b[0m",
  'N' => "\u001b[31mと\u001b[0m"
}

command = ARGV[0]
start_date = ARGV[1]
end_date = ARGV[2]

settings = YAML.load_file('settings.yml')
db = Slog::DB.new start_date, end_date, settings[:database_name], settings[:table_name], settings[:bq_option]

def find_no states, no
  states.find do |st|
    st[:no] == no
  end
end

def disp_pos position
  0.upto(8) do |row|
    print "|"
    8.downto(0) do |column|
      piece = PIECE_MAP[position[column * 9 + row]] || '  '
      print "#{piece}|"
    end
    print "\n"
  end
end

if command == 'game'
  game_list = db.game_list
  game_list.each do |game|
    puts "#{game[:start_date].strftime('%Y/%m/%d %R')} > #{game[:game_code]}"
  end
elsif command == 'castle'
  game_list = db.castle ARGV[3]
  game_list.each do |game|
    puts "#{game[:game_code]} : #{game[:no]}手目"
  end
elsif command == 'show'
  states = db.game ARGV[3]
  touch_no = 0
  loop do
    print '> '
    str = STDIN.gets.chomp
    if str =~ /\A\d+\Z/
      no = str.to_i
      state = find_no states, no
      unless state
        puts 'Not found'
        next
      end
      touch_no = no
      p state
      disp_pos state[:position]
    else
      case str
      when /^n($|ext$)/
        touch_no += 1
        state = find_no states, touch_no
        unless state
          puts 'LAST'
          next
        end
        p state
        disp_pos state[:position]
      when /^q($|uit$)/
        puts 'bye'
        break
      end
    end
  end
else
  puts ''
end

require 'csv'
require 'json'
require 'ap'

parserTable = CSV.read("msc/csv/parse_table2.csv")
grammar_J = File.read('msc/grammar.json')

grammar = JSON.parse(grammar_J)

stack = []

state = 1

i = 0

tokens = ["inicio","varinicio","id","literal",";"]

while(i < tokens.size)
  token = tokens[i]
  ind = parserTable[0].index(token)
  if parserTable[state][ind].include?("s")
    stack.push(parserTable[state][ind].delete! "s")
    state = Integer(stack.last()) + 1
  elsif parserTable[state][ind].include?("e")
    puts 'error'
  elsif parserTable[state][ind].include?("r")
    pos = parserTable[state][ind].delete! "r"
    times = grammar[pos][2]
    stack.pop(times)
    stack.push(pos)
    state = stack.last()
    puts "#{grammar[pos][0]} -> #{grammar[pos][1]}"
  end
  i = i + 1
end

ap stack

load 'src/lex.rb'
require 'json'
require 'csv'
require 'pp'

# ===================================================================================== #

dfaJson = File.read('msc/dfa.json')
reservedJson = File.read('msc/reserved.json')
progc = File.open('data/programa.c','r+')

parserTable = CSV.read("msc/csv/parser.csv")
grammar_J = File.read('msc/grammar.json')

grammar = JSON.parse(grammar_J)
$data_hash = JSON.parse(dfaJson)
$symbolTable = JSON.parse(reservedJson)
$reserved = JSON.parse(reservedJson)

oprd = 'er'
pos1 = pos2 = 0

tmpvar = ""
tempfile = ""

t = []
x = 0

tempfile << "#include <stdio.h>\n\n"
tempfile << "typedef char literal[256];\n"
tempfile << "\n\n"
tempfile << "void main(void) {\n"
tempfile << "\n\n"
tempfile << "/* ======== Temp Variaveis ========= */\n"
tempfile << "HERE\n"
tempfile << "/* ================================= */\n"
tempfile << "\n"

# ===================================================================================== #

i = 0
tokenizer = Tokenizer.new
lexer = Lexer.new

tokens = tokenizer.runDfa('data/fonte.alg')

lexer.printTable

puts "\n\n -------------------- Class. Tokens -------------------- \n\n"

while i < tokens.length

	token = lexer.getToken(tokens,i)

	lexer.classToken(token)

	lexer.addToken(token)

	i = i + 1
end

lexer.printTable

# ===================================================================================== #

puts "\n\n -------------------- ------------ -------------------- \n\n"

for i in (0 ... tokens.size)
	if lexer.space?(tokens[i][0])
		tokens.delete(i)
	end
end

tkns = Hash.new

j = 0

tokens.each do |key, value|
	tkns[j] = value
	j += 1
end

stack = [0]
sstack = []

i = 1

actToken = lastToken = token = lexer.getToken(tkns,0).keys[0]

while(1)

	# print "s_st : #{sstack}\n"

	ind = $vars.index(token)
	state = Integer(stack.last())

	# print "token: #{token} state: #{state} ind: #{ind} tb: #{parserTable[state][ind]}\n"

	# print "token #{token}\n"

	if parserTable[state][ind].include?("S")

		sstack.push(actToken)

		stack.push(Integer(parserTable[state][ind][1..-1]))

		# print "stack: #{stack}\n"

		lastToken = token
		actToken = token = lexer.getToken(tkns,i).keys[0]

		if token == nil
			token = "$"
		end

		ind = $vars.index(token)

		if lexer.getToken(tkns,i).values[0] == 9 and !$reserved.key?(token)
			token = "id"
		end

		if lexer.getToken(tkns,i).values[0] == 6
			token = "literal"
		end

		if lexer.getToken(tkns,i).values[0] == 11 or lexer.getToken(tkns,i).values[0] == 12 or lexer.getToken(tkns,i).values[0] == 14
			token = "opr"
		end

		if lexer.getToken(tkns,i).values[0] == 1 or lexer.getToken(tkns,i).values[0] == 15
			token = "opm"
		end

		if lexer.getToken(tkns,i).values[0] == 13
			token = "rcb"
		end

		if lexer.getToken(tkns,i).values[0] == 2 or lexer.getToken(tkns,i).values[0] == 4 or lexer.getToken(tkns,i).values[0] == 21
			token = "num"
		end


		i = i + 1

	elsif parserTable[state][ind].include?("R")

		pos = parserTable[state][ind][1..-1]

		aux = grammar[pos][0]

    times = grammar[pos][2]

    stack.pop(times)

		state = Integer(stack.last())

		ind = $vars.index(aux)

		stack.push(Integer(parserTable[state][ind]))

		puts "#{grammar[pos][0]} -> #{grammar[pos][1]}"

		# print "t -> #{grammar[pos][2]}\n"
		# print "last -> #{sstack.last(Integer(grammar[pos][2]))} + #{pos}\n"

		last = sstack.last(Integer(grammar[pos][2]))

		sstack.pop(grammar[pos][2])
		sstack.push(grammar[pos][0])

		if Integer(pos) == 5
			tempfile << "\n\n\n"
		end

		if Integer(pos) == 9
			type = grammar[String(9)][1]
			puts "|SEM|\tTIPO.tipo <- #{type}"
		end

		if Integer(pos) == 8
			type = "double"
			puts "|SEM|\tTIPO.tipo <- #{type}"
		end

		if Integer(pos) == 7
			type = "int"
			puts "|SEM|\tTIPO.tipo <- #{type}"
		end

		if Integer(pos) == 6
			temp = type + " " + last[0] + ";\n"
			$symbolTable[last[0]][1] = type
			puts "|SEM|\t#{last[0]}.tipo <- #{type}"
			tempfile << temp
		end

		if Integer(pos) == 11
			if $symbolTable[last[1]][1] == 'literal'
				temp = "scanf(\"%s\"," + last[1] +");\n"
				tempfile << temp
			end
			if $symbolTable[last[1]][1] == 'int'
				temp = "scanf(\"%d\"," + "&" + last[1] +");\n"
				tempfile << temp
			end
			if $symbolTable[last[1]][1] == 'double'
				temp = "scanf(\"%lf\"," + "&" + last[1] +");\n"
				tempfile << temp
			end
		end

		if Integer(pos) == 13 or Integer(pos) == 14 or Integer(pos) == 15
			if Integer(pos) == 15 and $symbolTable[last[0]][1] == nil
					puts "\n\n"
					puts "Error: Variavel \"" + last[0] + "\" não encontrada/Declarada."
				exit
			end
			arg = last[0]
			puts "|SEM|\tARG.atributos <- #{last[0]}.atributos"
		end

		if Integer(pos) == 12
			if ($symbolTable.key?(arg) and $symbolTable[arg][1] == 'int')
				temp = "printf(\"%d\"," + arg + ");\n"
				tempfile << temp
			elsif $symbolTable.key?(arg) and $symbolTable[arg][1] == 'double'
				temp = "printf(\"%lf\"," + arg + ");\n"
				tempfile << temp
			elsif $symbolTable.key?(arg) and $symbolTable[arg][1] == 'literal'
				temp = "printf(\"%s\"," + arg + ");\n"
				tempfile << temp
			else
				temp = "printf(" + arg + ");\n"
				tempfile << temp
			end
		end

		if Integer(pos) == 19 or Integer(pos) == 20 or Integer(pos) == 21
			if Integer(pos) == 20 and $symbolTable[last[0]][1] == nil
				puts "\n\n"
				puts "Error: Variavel \"" + last[0] + "\" não encontrada/Declarada."
				exit
			end
			pos2 = Integer(pos1)
			pos1 = Integer(pos)
			loprd = oprd
			oprd = last[0]
			puts "|SEM|\tLD.atributos <- #{oprd}.atributos"
		end

		if Integer(pos) == 17
			if Integer(pos) == 17 and $symbolTable[last[0]][1] == nil
				puts "\n\n"
				puts "Error: Variavel \"" + last[0] + "\" não encontrada/Declarada."
				exit
			end
			temp = last[0] + " = " + loprd + ";\n"
			tempfile << temp
			if $symbolTable.key?(last[0]) and $symbolTable[last[0]][1] != 'double' and (loprd.include?('.') or loprd.include?('E'))
				puts "Error: Tipos incopativeis."
				exit
			end
			if $symbolTable.key?(last[0]) and $symbolTable[last[0]][1] == 'double' and !(loprd.include?('.') or loprd.include?('E'))
				puts "Error: Tipos incopativeis."
				exit
			end
		end

		if Integer(pos) == 18
			t[x] = " = " + loprd + " " + last[1] + " " + oprd + ";\n"
			temp = "T" + String(x) + t[x]
			loprd = "T" + String(x)
			$symbolTable[loprd] = ["TEMP",'int']
			tempfile << temp
			x = x + 1
			if $symbolTable.key?(loprd) and $symbolTable[loprd][1] != 'double' and (oprd.include?('.') or oprd.include?('E'))
				puts "Error: Tipos incopativeis."
				exit
			end
			if $symbolTable.key?(last[0]) and $symbolTable[last[0]][1] == 'double' and !(loprd.include?('.') or loprd.include?('E'))
				puts "Error: Tipos incopativeis."
				exit
			end
			puts "|SEM|\tLD.lexema <- T#{x-1}"
			puts "T#{x - 1} <- #{temp}"
		end

		if Integer(pos) == 23
			tempfile << "}\n"
		end

		if Integer(pos) == 24
			temp = "if (" + loprd + "){\n"
			tempfile << temp
		end

		if Integer(pos) == 25
			t[x] = " = " + loprd + " " + last[1] + " " + oprd + ";\n"
			temp = "T" + String(x) + t[x]
			loprd = "T" + String(x)
			$symbolTable[loprd] = ["TEMP",'int']
			tempfile << temp
			x = x + 1
			if $symbolTable.key?(loprd) and $symbolTable[loprd][1] != 'double' and (oprd.include?('.') or oprd.include?('E'))
				puts "Error: Tipos incopativeis."
				exit
			end
			if $symbolTable.key?(last[0]) and $symbolTable[last[0]][1] != 'double' and !(loprd.include?('.') or loprd.include?('E'))
				puts "Error: Tipos incopativeis."
				exit
			end
			puts "|SEM|\tEXP_R.lexema <- T#{x-1}"
			puts "T#{x - 1} <- #{temp}"
		end


	elsif parserTable[state][ind].include?("E")

		err = Integer(parserTable[state][ind][1..-1])

		lexer.getError(err)

	elsif parserTable[state][ind] == "AC"

			puts "\n\n"

			puts "Codigo Sintaticamente Correto :)"

			puts "\n\n"

			puts "\n\n"

			tempfile << "}"

			break

	end

end

lexer.cleanST
lexer.printTable

File.write(progc,tempfile)

j = 0

while (j < x) do
	tmpvar << "int ""T" + String(j) + ";\n";
	j = j + 1
end

texts = File.read(progc)

new_contents = texts.gsub("HERE",tmpvar)

File.write(progc,new_contents)

# ===================================================================================== #

load 'msc/util.rb'

$i = 0

# ===================================================================================== #

class Tokenizer < Util

	def defineType(char)

		if letter?(char) == 0
			if char == 'E'
				return 'E'
			else
				return 'L'
			end
		elsif numeric?(char) == 0
			return 'D'
		elsif space?(char)
			return 'S'
		elsif char == nil
			return 'EOF'
		else
			return char
		end

	end

	def runDfa(source)

		tokens = Hash.new
		tokens_n = Hash.new

		cur_st = 0
		last_st = 0
		word = ''

		File.open(source,"r").each_char do |char|

			$colum = $colum + 1

			new_c = defineType(char)

			if char == "\n"
				$line = $line + 1
				$colum = 0
			end

			if $data_hash.key?(new_c) and cur_st != 99
				last_st = cur_st
				cur_st = $data_hash[new_c][cur_st]
			end

			if !$data_hash.key?(new_c) and cur_st != (5 or 7)

				if $com != 0
					puts "ERRO 3 - Falantando }"
					puts "Chaves faltando na linha #{$last_com + 1} coluna #{$colum}"
					puts "Exiting..."
					exit
				end

				puts "Cadeia -> #{word}#{char}"
				puts "ERRO 1 - Caracter Não Reconhecido"
				puts "Char -> #{char} Linha -> #{$line + 1} Coluna -> #{$colum}"
				puts "Exiting..."
				exit

			end

			if char == "\""
				$aa = $aa + 1
				$last_a = $line
			end

			if char == "{"
				$com = $com + 1
				$last_com = $line
			end

			if char == "}"
				$com = $com - 1
			end

			if $data_hash.key?(new_c) and cur_st == 99 and $accStates.key?(last_st)

				tokens[word] = last_st

				tokens_n[$i] = [word,last_st]

				$i = $i + 1

				cur_st = $data_hash[new_c][0]

				word = ''

			end

			word << char

		end

		if $aa%2 != 0
			puts "ERRO 2 - Falantando \""
			puts "Abre aspas visto na linha #{$last_a + 1} coluna #{$colum}"
			puts "Exiting..."
			exit
		end

		if $com != 0
			puts "ERRO 3 - Falantando }"
			puts "Abre chaves visto na linha #{$last_com + 1} coluna #{$colum}"
			puts "Exiting..."
			exit
		end

		pp tokens_n

		return tokens_n

	end

end

# ===================================================================================== #

class Lexer < Util

	def getToken(tokens, index)

		token = Hash.new

		if index < tokens.size
			token[tokens[index][0]] = tokens[index][1]
		end

		return token

	end

	def classToken(token)

		fnst = token.values[0]

		if $accStates.key?(fnst) and !space?(token.keys[0])

			 puts "lex -> #{token.keys[0]} \ntoken -> #{$accStates[fnst]}"
			 puts "\n"

		end

	end

	def addToken(token)

		if !$symbolTable.key?(token.keys[0]) and token.values[0] == 9 and !space?(token.keys[0])
			$symbolTable[token.keys[0]] = [$accStates[token.values[0]],nil]
		end

	end

end

# ===================================================================================== #

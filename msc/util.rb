$accStates = {
	2 => "NUM",
	4 => "NUM",
	21 => "NUM",
	6 => "LITERAL",
	9 => "ID",
	8 => "COMENTARIO",
	10 => "EOF",
	11 => "OPR",
	12 => "OPR",
	14 => "OPR",
	13 => "RCB",
	1 => "OPM",
	15 => "OPM",
	16 => "AB_P",
	17 => "FC_P",
	18 => "PT_V"
}

$vars = ["inicio","varinicio","varfim","id","num","inteiro","real","literal","leia","escreva","rcb","opm","opr","se","entao","fimse","fim","(",")",";","$","P'","P","V","LV","D","TIPO","A","ES","CMD","COND","CABEÇALHO","ARG","LD","OPRD","EXP_R","CORPO"]

$colum = 0
$line = 0

$aa = 0
$last_a = 0

$com = 0
$last_com = 0

class Util

	def letter?(char)
	  char =~ /[A-Za-z]/
	end

	def numeric?(char)
	  char =~ /[[:digit:]]/
	end

	def space?(char)
		if char == " " or char == "\t" or char == "\n"
			return true
		else
			return false
		end
	end

	def printTable

		puts "\n\n -------------------- Symbol Table -------------------- \n\n"
		puts "+------------------+----------------+--------------+"
		puts "|     LEXEMA       |     TOKEN      |     TIPO     |"
		puts "+------------------+----------------+--------------+"
		puts "\n"

		i = 0

		while i < $symbolTable.length

			puts "|#{$symbolTable.keys[i]},#{$symbolTable.values[i][0]},#{$symbolTable.values[i][1]}|"

			i = i + 1
		end
	end
	
	def cleanST
	
		$symbolTable.each do |token|
			if token[1][0] == "TEMP"
				$symbolTable.delete(token[0])
			end
		end
	
	end

	def getError(err)

		puts "\n\n"

		print "-------- Erro Sintatico --------\n"

		puts "\n\n"

		if err == 1
			print "Inicio não encontrado.\n"
			exit
		elsif err == 2
			print "Fim não encontrado.\n"
			exit
		elsif err == 3
			print "Varinicio não encontrado.\n"
			exit
		elsif err == 4
			print "ID, leia, escreva, se ou fim não encontrado.\n"
			exit
		elsif err == 5
			print "Varfim ou ID não encontrado.\n"
			exit
		elsif err == 6
			print "ID não encontrado.\n"
			exit
		elsif err == 7
			print "Literal, num ou ID não encontrado.\n"
			exit
		elsif err == 8
			print "RCB  ( <- ) não encontrado.\n"
			exit
		elsif err == 9
			print "Fimse, leia, escreva, ID ou se não encontrado.\n"
			exit
		elsif err == 10
			print "Abre parenteses ( não encontrado.\n"
			exit
		elsif err == 11
			print "Ponto e Virgula ; não encontrado.\n"
			exit
		elsif err == 12
			print "Tipo do ID não encontrado (int, literal ou real).\n"
			exit
		elsif err == 13
			print "ID ou num não encontrado.\n"
			exit
		elsif err == 14
			print "Operador aritimetico não encontrado.\n"
			exit
		elsif err == 15
			print "Operador relacional não encontrado.\n"
			exit
		elsif err == 16
			print "Bloco dem entao não encontrado.\n"
			exit
		end
	end

end

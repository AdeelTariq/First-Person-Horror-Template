class_name RandomKey extends RefCounted


const characters = 'abcdefghijklmnopqrstuvwxyz1234567890'

static func generate(length):
	var word: String
	var n_char = len(characters)
	for i in range(length):
		word += characters[randi()% n_char]
	return word

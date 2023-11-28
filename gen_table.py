dic_table = {
    "A": ["2", "1"],
    "B": ["1", "2"],
    "C": ["3", "1"],
    "D": ["1", "3"],
    "E": ["4", "1"],
    "F": ["3", "2"],
    "G": ["2", "3"],
    "H": ["1", "4"],
    "I": ["5", "1"],
    "J": ["4", "2"],
    "K": ["2", "4"],
    "L": ["1", "5"],
    "M": ["6", "1"],
    "N": ["5", "2"],
    "O": ["4", "3"],
    "P": ["3", "4"],
    "Q": ["2", "5"],
    "R": ["1", "6"],
    "S": ["6", "2"],
    "T": ["5", "3"],
    "U": ["3", "5"],
    "V": ["2", "6"],
    "W": ["6", "3"],
    "X": ["5", "4"],
    "Y": ["4", "5"],
    "Z": ["3", "6"],
    "!": ["6", "4"],
    ".": ["4", "6"],
    " ": ["6", "5"],
    "?": ["5", "6"],
    "(": ["1", "1"],
    ")": ["2", "2"],
    ":": ["3", "3"],
    "^": ["4", "4"],
    ";": ["5", "5"],
    "#": ["6", "6"],
}


def dec_to_bin(x):
    binary = bin(int(x))[2:]
    return binary.zfill(3)


def char_to_bin(x):
    binary = bin(ord(x))[2:]
    return binary.zfill(8)


# for i in dic_table:
#     print(i)

for i in dic_table:
    if dic_table[i][0] == dic_table[i][1]:
        print(
            f"WHEN \"{dec_to_bin(dic_table[i][0]) + dec_to_bin(dic_table[i][1])}\" =>\n\tdout <= \"{char_to_bin(i)}\";")

# for i in dic_table:
#     if dic_table[i][1] == '7':
#         print(f"WHEN \"{dec_to_bin(dic_table[i][0]) + dec_to_bin(dic_table[i][1])}\" =>\ndout <= \"{char_to_bin(i)}\";")

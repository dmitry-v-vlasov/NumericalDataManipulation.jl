using FileIO

# ***** Delimiters *****
@enum Delimiter space=1 comma=2
DELIMITER = Dict{Delimiter, Char}(
    space::Delimiter => ' ',
    comma::Delimiter => ',')

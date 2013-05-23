import Text.ParserCombinators.Parsec

datFile = endBy line eol
line = sepBy cell (many1 (char ' '))
cell = many (oneOf "1234567890.e-")
eol =   try (string "\n\r")
    <|> try (string "\r\n")
    <|> string "\n"
    <|> string "\r"
    <|> fail "Couldn't find EOL"

main = do { result <- parseFromFile datFile "out.dat"
              ; case result of
                    Left err  -> print err
                    Right xs  -> print xs
    }

import Text.ParserCombinators.Parsec

import Numeric.Statistics
import qualified Data.Vector.Storable as V

-- needs cabal install hstatistics
-- gsl-devel lapack-devel
datFile = endBy line eol
line = sepBy cell (many1 (char ' '))
cell = many (oneOf "1234567890.e-")
eol =   try (string "\n\r")
    <|> try (string "\r\n")
    <|> string "\n"
    <|> string "\r"
    <|> fail "Couldn't find EOL"

toDoubleList :: [[String]] -> [[Double]]
toDoubleList = map (map read) . map (tail . init)

v1 :: V.Vector Double
v1 = V.fromList [1.2,1.2, 2.3, 4.5]

v2 :: V.Vector Double
v2 = V.fromList [0, 1.2, 1.2, 2.3, 2.05,-1.2,-7.0 ,2.4, 2.4, 4.6, 9.0, 3.0]

v :: [[Double]] -> V.Vector Double
v = V.fromList . map (head . tail)

test x y = corcoeff (V.take (V.length y) x) y

-- d big small -> [cor]
d :: V.Vector Double -> V.Vector Double -> V.Vector Double
d x y = d' x (V.fromList [])
    where
        d' a l 
            | (V.length a) >= (V.length y) = d' (V.tail a) (V.snoc l (test a y))
            | otherwise = l

main = do { result <- parseFromFile datFile "out.dat"
              ; case result of
                    Left err  -> print err
                    Right xs  -> print xs
    }

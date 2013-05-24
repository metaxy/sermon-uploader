import Text.ParserCombinators.Parsec

import Numeric.Statistics
import qualified Data.Vector.Storable as V
import Data.Either
import Control.Monad

import Data.Colour.Names
import Data.Colour
import Data.Accessor
import Graphics.Rendering.Chart
import Graphics.Rendering.Chart.Gtk

import Numeric.FFT
import Data.Complex
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
-- convert
--toDoubleList :: [[String]] -> [[Double]]
toDoubleList = map (map read) . map (tail . init)

--toVector :: [[Double]] -> V.Vector Double
toVector = V.fromList . map (head . tail)

toA = toVector . toDoubleList 
-- stats
--listCo :: V.Vector Double -> V.Vector Double -> V.Vector Double
listCo x y = d' x (V.length x) (V.fromList [])
    where
        d' a lenA l
            | lenA >= yLength = d' (V.tail a) (lenA-1) (V.snoc l (test a y))          
            | otherwise = l
        yLength = V.length y
        test x y = corcoeff (V.take (V.length y) x) y
-- main
main = do 
    small <- parseFromFile datFile "out.dat"
    big <- parseFromFile datFile "out2.dat"
    let a = liftM ((V.take 100) . toA) small
    let b = liftM ((V.drop 1000) . toA) big
    let c = liftM2 listCo b a
    let d = m c
    return c

m = liftM (V.findIndices (\x -> (abs x) > 0.3))
dat x = do 
    small <- parseFromFile datFile x
    --let a = liftM (studentize . toA) small
    let x = liftM (map (toPairs) . toDoubleList ) small
    return (rema x)

dat' x = do 
    small <- parseFromFile datFile x
    let x = liftM (toDoubleList ) small
    return (rema x)


toPairs (x:(xs:[])) = (x,xs)

rema (Right x) = x
-- test stuff


chart x y = layout 
  where

    audio1 = plot_lines_style .> line_color ^= opaque blue
           $ plot_lines_values ^= [x]
           $ plot_lines_title ^= "audio1"
           $ defaultPlotLines

    audio2 = plot_lines_style .> line_color ^= opaque green
           $ plot_lines_values ^= [y]
           $ plot_lines_title ^= "audio2"
           $ defaultPlotLines

    layout = layout1_title ^="Price History"
           $ layout1_left_axis ^: laxis_override ^= axisGridHide
           $ layout1_right_axis ^: laxis_override ^= axisGridHide
           $ layout1_bottom_axis ^: laxis_override ^= axisGridHide
           $ layout1_plots ^= [Left (toPlot audio1),
                               Right (toPlot audio2)]
           $ layout1_grid_last ^= False
           $ defaultLayout1

plotAll = do
    x <- dat "out.dat"
    let x' =  map (\(a,b) -> (a+2875,b)) x
    y <- dat "out2.dat"
    --renderableToWindow (toRenderable (chart x' y)) 1024 480
    renderableToPNGFile (toRenderable (chart x' y)) 10024 4800 "test.png"

--f = do
  --  x <- dat' "out.dat"
    --let ff = fft $ map(head . tail) x
   -- return fft


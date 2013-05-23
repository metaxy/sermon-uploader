module Main where

import Prelude as P

import           Sound.Iteratee
import qualified Data.Vector.Storable as V
import           Data.Iteratee as I
import           Data.Iteratee.STM
import           Control.Monad.CatchIO
import           System.Environment
import  Data.Iteratee.Iteratee
import Control.Monad.IO.Class

main :: IO ()
main = do
    let e2 = enumAudioIteratee "out.wav"
    e <- e2 maxIter >>= run
    e1 <- e2 maxIter2 >>= run
    print e

--maxIter :: MonadCatchIO m => Iteratee (V.Vector Double) m [Double]
--maxIter = [
--
maxIter :: MonadCatchIO m => Iteratee (V.Vector Double) m Double
maxIter = I.length

--maxIter2 :: MonadCatchIO m => Iteratee (V.Vector Double) m ()
maxIter2 = I.sum

byteCounter :: Monad m => Iteratee (V.Vector Double) m Int
byteCounter = I.length

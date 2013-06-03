module Main where

import Prelude as P

import Sound.Iteratee
import qualified Data.Vector.Storable as V
importData.Iteratee as I
import Control.Monad.CatchIO
import System.Environment
import Data.Iteratee.Iteratee
import Data.Iteratee.ListLike
import Control.Monad.IO.Class as M
import Data.Iteratee hiding (head, break)
import Data.Iteratee.Parallel
import qualified Data.Iteratee.Char as IC
import Data.Functor.Identity
import Data.Monoid

import Control.Applicative
import Control.Monad as CM
import Control.Monad.Writer


main :: IO ([Double])
main = do
    let e2 = enumAudioIteratee "out.wav"
    e <- e2 (maxIter >> maxIter) >>= run
    print e
    return e
alla :: IO([Double])
alla = do
    let e2 = enumAudioIteratee "out.wav"
    e <- e2 maxIter2 >>= run
    return e


--maxIter :: MonadCatchIO m => Iteratee (V.Vector Double) m Int
--maxIter = I.length

maxIter :: MonadCatchIO m => Iteratee (V.Vector Double) m [Double]
maxIter = joinI $ (I.take 50) I.stream2list

maxIter2 :: MonadCatchIO m => Iteratee (V.Vector Double) m [Double]
maxIter2 = joinI $ (I.take 50) I.stream2list

byteCounter :: Monad m => Iteratee (V.Vector Double) m Int
byteCounter = I.length


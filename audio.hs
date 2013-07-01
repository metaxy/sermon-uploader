module Main where

import Prelude as P

import Sound.Iteratee
import System.Environment

import qualified Data.Vector.Storable as V

import Data.Iteratee as I
import Data.Iteratee.Iteratee
import qualified Data.Iteratee.ListLike as LL

import Control.Monad.CatchIO
import Control.Monad.IO.Class as M
import Data.Functor.Identity
import Data.Monoid
import Control.Applicative
import Control.Monad as CM
import Control.Monad.Writer

defaultChunkLength = 10
defaultBufSize = 10
main :: IO (Int)
main = do
    let e2 = enumAudioIteratee "out.wav"
    e <- e2 (byteCounter) >>= run
    print e
    return e
alla :: IO(Int)
alla = do
    let e2 = enumAudioIteratee "out.wav"
    e <- e2 headI >>= run
    return e


--maxIter :: MonadCatchIO m => Iteratee (V.Vector Double) m Int
--maxIter = I.length

maxIter :: MonadCatchIO m => Iteratee (V.Vector Double) m [Double]
maxIter = joinI $ (I.take 50) I.stream2list

maxIter2 :: MonadCatchIO m => Iteratee (V.Vector Double) m [Double]
maxIter2 = joinI $ (I.take 50) I.stream2list

byteCounter :: Monad m => Iteratee (V.Vector Double) m Int
byteCounter = I.length

iter1 :: (MonadCatchIO  m, Functor m) => Iteratee (V.Vector Double) m ([V.Vector Double])
iter1 = do
    e1 <- I.takeFromChunk 100
    e2 <- I.drop 100
    return ([e1])

--iter2:: (MonadCatchIO  m, Functor m) => Iteratee (V.Vector Double) m ([V.Vector Double])
--iter2 = liftI (groupi' 10)
-- what iter2 should do:
-- Iteratee (V Double) m ([V Double])

iter3 :: (MonadCatchIO  m, Functor m) => Iteratee (V.Vector Double) m (Double)
iter3 = LL.foldl' (\a el -> a) a

headI :: (Monad m) => Iteratee (V.Vector Double) m Int
headI = liftI step'
    where
	step' (Chunk c)
	    | V.null c = headI
	    | otherwise = idone (V.length c) (Chunk c)
	step' st = icont step' (Just (setEOF st))

--groupi :: Int -> V.Vector a -> (V.Vector 
--groupi = concat . groupi'
groupi' :: Int -> V.Vector Double -> [V.Vector Double]
groupi' n v 
    | (V.length v > n) = (fst res):(groupi' n (snd res))
    | otherwise = [v]
    where
        res = V.splitAt n v

module Main where

import Echo (echoMessage)
import System.Environment (getArgs)
import Control.Monad (forM_)

main :: IO ()
main = do
    messages <- getArgs
    forM_ messages $ \msg -> do
        echoMessage msg

module Echo (echoMessage) where

echoMessage :: String -> IO ()
echoMessage msg = do
  putStrLn $ msg

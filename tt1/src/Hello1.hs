module Hello1 where

-- |balbla
hello1 :: IO ()
hello1 = putStrLn "hello1"


helloBla :: IO ()
helloBla = do
    hello1
    putStrLn "And BLAA"
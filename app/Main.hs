{-# LANGUAGE GeneralizedNewtypeDeriving, LambdaCase #-}
module Main where
import Control.Distributed.Process.Gossip
import Control.Monad
import Control.Monad.Reader
import Network.Transport
import Network.Transport.TCP (createTransport, defaultTCPParameters)
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Data.ByteString.Char8 as BS (pack,unpack,concat)
import System.Environment


makeNodeId :: String -> NodeId
makeNodeId port = NodeId . EndPointAddress . BS.concat $ [BS.pack ("localhost"), BS.pack (":" ++ port), BS.pack ":0"]

main = do
    port : seeds <- getArgs

    Right t <- createTransport "127.0.0.1" port (\s -> ("localhost", s)) defaultTCPParameters
    node <- newLocalNode t initRemoteTable

    runCluster node (map makeNodeId seeds) $ do
        self <- getSelfPid
        say "Waiting for hello"
        forever $ expect >>= \case
            "hej" -> say "hej"
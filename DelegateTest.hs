--
-- Tests for the Delegate DSL parser and AST defined in
-- DelegateParser.hs and DelegateAst.hs. Descriptions of
-- the tests are found below. To run the tests, install
-- the Glasgow Haskell Compiler, fire up GHCi by typing
-- "ghci DelegateTest.hs" in your terminal. Run the tests
-- by executing either runParserTests ad runReadOutputTests.
--
-- Testfiles are located in the 'tests/'-foler.
--

module DelegateTest
( runParserTests
, runReadOutputTests)
where

import DelegateParser
import System.IO.Unsafe
import DelegateAst

load :: (Read a) => FilePath -> IO a
load f = do s <- readFile f
            return (read s)

files :: [String]
files = ["example"]

prefix :: String
prefix = "tests/"

-- Parse the DSL input found in each .delegate-file
-- in the 'files'-list and parse it. Compare the
-- result with the expected AST output found in its
-- corresponding .delegateAst file. If the second
-- component of the tuple evaluates to true, the test
-- succeeded. This checks that the first code actually
-- compiles to the second.
runParserTests :: [(String,Bool)]
runParserTests = zip files res
    where pFiles    = map (prefix ++) files
          soilFiles = map (++".delegate") pFiles
          astFiles  = map (++".delegateAst") pFiles
          parsed = map (unsafePerformIO . parseFile) soilFiles
          asts = map (Right . unsafePerformIO . load) astFiles
          res = zipWith (==) parsed asts

-- Read and compile the AST outputs found in each
-- .delegateAst file, and display it. This check that
-- second code compiles when read by the Haskell interpreter.
runReadOutputTests :: [(String, Order)]
runReadOutputTests = zip files asts
    where pFiles    = map (prefix++) files
          astFiles  = map (++".delegateAst") pFiles
          asts = map (unsafePerformIO . load) astFiles :: [Order]


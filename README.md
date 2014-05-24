Entry for the Delegate code competition
=======================================

Files:
------
1. DelegateAst.hs - Defines the abstract syntax tree for the Delegate DSL as well as Read and Show instances.
2. DelegateParser.hs - Defines the parser for parsing the delegate DSL into the AST.
3. DelegateTest.hs - Tests of the parser, Show and Read instances.

Compatibility:
--------------
The code conforms to the specifications of the assignment. The code block:

    order { add “Raspberry Pi” 34 Units At 41 If OutOfStock Wait 16 Months
            add “Mad Catz M.O.U.S.9” 55 Units At 43 If OutOfStock Wait 32 Weeks
            add “The Riftshadow Roamer” 89 Units At 47 If OutOfStock Wait 64 Days }

Compiles into an AST whose Show-instance prints it as a list separated with semi-colons, as required by the assignment:

    Order[OrderLine(Product(“Raspberry Pi”,34),Price 41,Period(16,Months));
          OrderLine(Product(“Mad Catz M.O.U.S.9”,55),Price 43,Period(32,Weeks));
          OrderLine(Product(“The Riftshadow Roamer”,89),Price 47,Period(64,Days))]

Furthermore, the implementation allows reading the above input as a semicolon-separated list as well (i.e. both code blocks compile into the AST, and the Read and Show instances form a bijection of the AST).

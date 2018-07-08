
Now we want to improve the gcd.v using the while statement. 
If we use while loop in the always block, the verilog code can be simulated but not synthesised. The main problem is that the always block is a combinational circuit, whose output depends only on x and y. However, in our case, we need x and y to be registers, such that they can store the temporary values when doing the calculaiton.  


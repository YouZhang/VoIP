function tExtractVals

addpath ('../');

B = [1 24 2048];
xi = [23 83 3]
x = CombineVals (xi, B)
[a, b, c] = ExtractVals (x, B)

disp ('==========');
B = [1 24 2048];
xi = [0 0 1]
x = CombineVals (xi, B)
[a, b, c] = ExtractVals (x, B)

disp ('==========');
x = CombineVals (ones (10,1), 2)
bits = ExtractVals (x, 10, 2)

disp ('==========');
x = CombineVals ([1 1 1 zeros(1,7)], 2)
bits = ExtractVals (x, 10, 2)

disp ('==========');
x = CombineVals ([3 1 zeros(1,8)], 4)
vals = ExtractVals (x, 10, 4)

disp ('==========');
B = [1 30 600];
xi = [20 19 10]
x = CombineVals (xi, B)
vals = ExtractVals (x, [30 20 12])

return

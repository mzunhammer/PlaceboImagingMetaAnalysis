function x = nonrandn(rows,cols)
    x=randn(rows,cols);
    x=x-mean(x);
    x=x/std(x);
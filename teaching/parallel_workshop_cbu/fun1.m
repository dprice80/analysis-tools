function [x, y] = fun1(z, subjectid)

    x = z*2;
    y = z*3;
    
save(sprintf('/imaging/dp01/output_subject_%s.mat',subjectid),'x','y')
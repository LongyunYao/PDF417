function [x, y] = findpoint(theta1, rho1, theta2, rho2)
    if(theta1 == 90)
        func1 = sprintf('%s%f', 'y=', abs(rho1));
    elseif(theta1 == 180)
        func1 = sprintf('%s%f', 'x=', abs(rho1));
    else
        k = -cot(theta1/180*pi);
        b = rho1/sin(theta1/180*pi);
        func1 = sprintf('%s%f%s%f%s','y=(',k,')*x+(', b, ')');
    end
    
    if(theta2 == 90)
        func2 = sprintf('%s%f', 'y=', abs(rho2));
    elseif(theta2 == 180)
        func2 = sprintf('%s%f', 'x=', abs(rho2));
    else
        k = -cot(theta2/180*pi);
        b = rho2/sin(theta2/180*pi);
        func2 = sprintf('%s%f%s%f%s','y=(',k,')*x+(', b, ')');
    end
    [x, y] = solve(func1,func2,'x','y');
end
function [xdata,poly] = polyregres(xdata,ydata,winsize,order)

xdata;
ydata;
intervals = length(xdata)/winsize;
order;
M = order + 1; % # of coefficients


h = 1;
r = 1;
inc = 1;
while h <= length(xdata)-winsize
    x = xdata(h:h+winsize-1);
    y = ydata(h:h+winsize-1);
    
    %B matrix
    for row = 1:M %Our choice of polynomial fit (3rd order polynomial)
        
        m = row; % m's start value is determined by the row number
        
        for col = 1:M
            
            sumofx = 0;
            for i = 1:length(x)
                sumofx = sumofx + x(i)^(m-1);
            end
            
            b(row,col) = sumofx;
            m = m + 1;
            
        end
        
    end
    
    
    %Y-matrix
    for row = 1:M
        
        ysum = 0;
        
        for i = 1:length(y)
            ysum = ysum + y(i)*(x(i)^(row-1));
        end
        
        ymatrix(row,1) = ysum;
    end
    
    %Computing coefficients
    a(r,:) = b\ymatrix;
    
    
        for i = 1:winsize
            sum = 0;
            for j = 1:length(a(1,:))
                sum = sum + a(r,j)*x(i)^(j-1);
            end
            poly(inc) = sum;
            inc = inc + 1;
        end
    
    
    r = r + 1;
    
    h = h + winsize;
    
    %Reset all values for next interval
    xintpts = [];
    b = [];
    ymatrix = [];
end




end